import 'dart:math' as math;

import '../../data/models/acao_model.dart';
import 'faxita_predictive_analysis_result.dart';

class FaxitaPredictiveAnalysisService {
  const FaxitaPredictiveAnalysisService();

  static const int quantidadeMinimaParaPrevisao = 3;

  FaxitaPredictiveAnalysisResult analisar({
    required AcaoModel acaoPlanejada,
    required List<AcaoModel> historico,
  }) {
    final selecao = _selecionarBase(
      acaoPlanejada: acaoPlanejada,
      historico: historico,
    );

    if (selecao.acoes.length < quantidadeMinimaParaPrevisao) {
      return FaxitaPredictiveAnalysisResult.semBase(
        criterioComparacao: selecao.criterio,
      );
    }

    final pessoas = selecao.acoes
        .map((acao) => acao.pessoasAlcancadas.toDouble())
        .toList(growable: false);

    final publicoPrevisto = _mediaPonderada(
      selecao.acoes,
      (acao) => acao.pessoasAlcancadas.toDouble(),
      acaoPlanejada,
    );

    final veiculosPrevistos = _mediaPonderada(
      selecao.acoes,
      (acao) => acao.veiculosAbordados.toDouble(),
      acaoPlanejada,
    );

    final desvioPessoas = _desvioPadrao(pessoas);

    final double margem = desvioPessoas > 0
        ? desvioPessoas
        : math.max(publicoPrevisto * 0.20, 1.0).toDouble();

    final double minimoPrevisto =
        math.max(0.0, publicoPrevisto - margem).toDouble();

    final double maximoPrevisto = publicoPrevisto + margem;

    final metaReferencia = acaoPlanejada.publicoMinimo > 0
        ? acaoPlanejada.publicoMinimo
        : acaoPlanejada.publicoEstimado;

    final probabilidadeMeta = _probabilidadeMeta(
      acoes: selecao.acoes,
      metaReferencia: metaReferencia,
    );

    final confianca = _classificarConfianca(
      quantidade: selecao.acoes.length,
      coeficienteVariacao: _coeficienteVariacao(
        media: _media(pessoas),
        desvio: desvioPessoas,
      ),
    );

    final recomendacoes = _gerarRecomendacoes(
      acaoPlanejada: acaoPlanejada,
      publicoPrevisto: publicoPrevisto,
      veiculosPrevistos: veiculosPrevistos,
      probabilidadeMeta: probabilidadeMeta,
      confianca: confianca,
    );

    return FaxitaPredictiveAnalysisResult(
      totalAcoesAnalisadas: selecao.acoes.length,
      publicoPrevisto: publicoPrevisto,
      publicoMinimoPrevisto: minimoPrevisto,
      publicoMaximoPrevisto: maximoPrevisto,
      veiculosPrevistos: veiculosPrevistos,
      probabilidadeMetaAtingida: probabilidadeMeta,
      confianca: confianca,
      criterioComparacao: selecao.criterio,
      parecer: _gerarParecer(
        publicoPrevisto: publicoPrevisto,
        minimoPrevisto: minimoPrevisto,
        maximoPrevisto: maximoPrevisto,
        probabilidadeMeta: probabilidadeMeta,
        confianca: confianca,
      ),
      recomendacoes: recomendacoes,
    );
  }

  _PredictiveSelection _selecionarBase({
    required AcaoModel acaoPlanejada,
    required List<AcaoModel> historico,
  }) {
    final validas = historico.where((acao) {
      if (acao.id == acaoPlanejada.id) return false;
      if (acao.status.trim().toLowerCase() == 'rascunho') return false;
      if (acao.dataAcao.isAfter(acaoPlanejada.dataAcao)) return false;
      return acao.pessoasAlcancadas > 0;
    }).toList(growable: false);

    final mesmoTipo = validas.where((acao) {
      return _iguais(acao.tipoAcao, acaoPlanejada.tipoAcao);
    }).toList(growable: false);

    final tipoTurnoRegional = mesmoTipo.where((acao) {
      return _iguais(acao.turno, acaoPlanejada.turno) &&
          _iguais(acao.regional, acaoPlanejada.regional);
    }).toList(growable: false);

    if (tipoTurnoRegional.length >= quantidadeMinimaParaPrevisao) {
      return _PredictiveSelection(
        acoes: tipoTurnoRegional,
        criterio: 'Mesmo tipo de ação, turno e regional',
      );
    }

    final tipoTurno = mesmoTipo.where((acao) {
      return _iguais(acao.turno, acaoPlanejada.turno);
    }).toList(growable: false);

    if (tipoTurno.length >= quantidadeMinimaParaPrevisao) {
      return _PredictiveSelection(
        acoes: tipoTurno,
        criterio: 'Mesmo tipo de ação e turno',
      );
    }

    if (mesmoTipo.length >= quantidadeMinimaParaPrevisao) {
      return _PredictiveSelection(
        acoes: mesmoTipo,
        criterio: 'Mesmo tipo de ação',
      );
    }

    final mesmoNome = validas.where((acao) {
      return _iguais(acao.nomeAcao, acaoPlanejada.nomeAcao);
    }).toList(growable: false);

    return _PredictiveSelection(
      acoes: mesmoNome,
      criterio: 'Mesmo nome de ação',
    );
  }

  double _mediaPonderada(
    List<AcaoModel> acoes,
    double Function(AcaoModel acao) seletor,
    AcaoModel referencia,
  ) {
    double somaValores = 0;
    double somaPesos = 0;

    for (final acao in acoes) {
      final peso = _pesoSimilaridade(
        historica: acao,
        referencia: referencia,
      );

      somaValores += seletor(acao) * peso;
      somaPesos += peso;
    }

    if (somaPesos == 0) return 0;
    return somaValores / somaPesos;
  }

  double _pesoSimilaridade({
    required AcaoModel historica,
    required AcaoModel referencia,
  }) {
    double peso = 1;

    if (_iguais(historica.turno, referencia.turno)) {
      peso += 0.35;
    }

    if (_iguais(historica.regional, referencia.regional)) {
      peso += 0.35;
    }

    if (_iguais(historica.publicoId, referencia.publicoId)) {
      peso += 0.20;
    }

    if (_iguais(historica.formacaoId, referencia.formacaoId)) {
      peso += 0.10;
    }

    final diferencaDias =
        referencia.dataAcao.difference(historica.dataAcao).inDays.abs();

    if (diferencaDias <= 180) {
      peso += 0.30;
    } else if (diferencaDias <= 365) {
      peso += 0.15;
    }

    return peso;
  }

  double _probabilidadeMeta({
    required List<AcaoModel> acoes,
    required int metaReferencia,
  }) {
    if (acoes.isEmpty || metaReferencia <= 0) return 0;

    final atingiram = acoes.where((acao) {
      return acao.pessoasAlcancadas >= metaReferencia;
    }).length;

    return (atingiram / acoes.length) * 100;
  }

  FaxitaPredictiveConfidence _classificarConfianca({
    required int quantidade,
    required double coeficienteVariacao,
  }) {
    if (quantidade < quantidadeMinimaParaPrevisao) {
      return FaxitaPredictiveConfidence.insuficiente;
    }

    if (quantidade >= 10 && coeficienteVariacao <= 0.35) {
      return FaxitaPredictiveConfidence.alta;
    }

    if (quantidade >= 5 && coeficienteVariacao <= 0.60) {
      return FaxitaPredictiveConfidence.media;
    }

    return FaxitaPredictiveConfidence.baixa;
  }

  String _gerarParecer({
    required double publicoPrevisto,
    required double minimoPrevisto,
    required double maximoPrevisto,
    required double probabilidadeMeta,
    required FaxitaPredictiveConfidence confianca,
  }) {
    final previsto = publicoPrevisto.round();
    final minimo = minimoPrevisto.round();
    final maximo = maximoPrevisto.round();
    final probabilidade = probabilidadeMeta.round();

    return 'Com base no histórico disponível, a Faxita estima '
        'aproximadamente $previsto pessoas alcançadas, com faixa provável '
        'entre $minimo e $maximo. A chance histórica de atingir a meta '
        'informada é de $probabilidade%. Nível da previsão: '
        '${confianca.label.toLowerCase()}.';
  }

  List<String> _gerarRecomendacoes({
    required AcaoModel acaoPlanejada,
    required double publicoPrevisto,
    required double veiculosPrevistos,
    required double probabilidadeMeta,
    required FaxitaPredictiveConfidence confianca,
  }) {
    final recomendacoes = <String>[];

    if (acaoPlanejada.publicoMinimo > publicoPrevisto &&
        acaoPlanejada.publicoMinimo > 0) {
      recomendacoes.add(
        'A meta mínima está acima do desempenho histórico previsto. '
        'Revise o dimensionamento da equipe, do local ou da estratégia de abordagem.',
      );
    }

    if (probabilidadeMeta < 50) {
      recomendacoes.add(
        'A probabilidade histórica de atingir a meta está abaixo de 50%. '
        'Considere reforçar divulgação, materiais e agentes de apoio.',
      );
    }

    if (veiculosPrevistos == 0 && acaoPlanejada.veiculosAbordados > 0) {
      recomendacoes.add(
        'O histórico comparável não apresenta volume consistente de veículos abordados.',
      );
    }

    if (!acaoPlanejada.acaoPlanejada) {
      recomendacoes.add(
        'A ação não está marcada como previamente planejada. '
        'Confirme recursos, equipe e público-alvo antes da execução.',
      );
    }

    if (confianca == FaxitaPredictiveConfidence.baixa) {
      recomendacoes.add(
        'Use esta previsão como referência inicial, pois a base histórica ainda apresenta alta variação.',
      );
    }

    if (recomendacoes.isEmpty) {
      recomendacoes.add(
        'O planejamento está compatível com o padrão histórico observado.',
      );
    }

    return List.unmodifiable(recomendacoes);
  }

  double _media(List<double> valores) {
    if (valores.isEmpty) return 0;
    return valores.reduce((a, b) => a + b) / valores.length;
  }

  double _desvioPadrao(List<double> valores) {
    if (valores.length < 2) return 0;

    final media = _media(valores);
    final somaQuadrados = valores.fold<double>(
      0,
      (soma, valor) => soma + math.pow(valor - media, 2).toDouble(),
    );

    return math.sqrt(somaQuadrados / valores.length);
  }

  double _coeficienteVariacao({
    required double media,
    required double desvio,
  }) {
    if (media <= 0) return 1;
    return desvio / media;
  }

  bool _iguais(String a, String b) {
    final primeiro = _normalizar(a);
    final segundo = _normalizar(b);

    return primeiro.isNotEmpty &&
        segundo.isNotEmpty &&
        primeiro == segundo;
  }

  String _normalizar(String valor) {
    var texto = valor.trim().toLowerCase();

    const substituicoes = <String, String>{
      'á': 'a',
      'à': 'a',
      'â': 'a',
      'ã': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'ó': 'o',
      'ò': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
    };

    substituicoes.forEach((origem, destino) {
      texto = texto.replaceAll(origem, destino);
    });

    return texto.replaceAll(RegExp(r'\s+'), ' ');
  }
}

class _PredictiveSelection {
  const _PredictiveSelection({
    required this.acoes,
    required this.criterio,
  });

  final List<AcaoModel> acoes;
  final String criterio;
}

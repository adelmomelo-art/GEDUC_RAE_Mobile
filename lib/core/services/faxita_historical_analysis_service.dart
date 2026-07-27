import '../../data/models/acao_model.dart';
import 'faxita_historical_analysis_result.dart';

class FaxitaHistoricalAnalysisService {
  const FaxitaHistoricalAnalysisService();

  static const int quantidadeMinimaBaseConfiavel = 3;

  FaxitaHistoricalAnalysisResult analisar({
    required AcaoModel acaoAtual,
    required List<AcaoModel> historico,
  }) {
    final criterio = _definirCriterio(acaoAtual);

    final comparaveis = historico.where((acao) {
      if (acao.id == acaoAtual.id) return false;
      if (acao.status.trim().toLowerCase() == 'rascunho') return false;
      if (acao.dataAcao.isAfter(acaoAtual.dataAcao)) return false;
      if (acao.pessoasAlcancadas <= 0) return false;

      return _acaoSemelhante(atual: acaoAtual, historica: acao);
    }).toList(growable: false)
      ..sort((a, b) => b.dataAcao.compareTo(a.dataAcao));

    if (comparaveis.isEmpty) {
      return FaxitaHistoricalAnalysisResult.semBase(
        criterioComparacao: criterio,
      );
    }

    final mediaPessoas =
        _media(comparaveis.map((acao) => acao.pessoasAlcancadas));
    final mediaVeiculos =
        _media(comparaveis.map((acao) => acao.veiculosAbordados));
    final mediaNota = _media(
      comparaveis
          .where((acao) => acao.notaAvaliacao > 0)
          .map((acao) => acao.notaAvaliacao),
    );

    final metasAtingidas =
        comparaveis.where((acao) => acao.metaAtingida).length;
    final taxaMeta = (metasAtingidas / comparaveis.length) * 100;

    final variacaoPessoas = _calcularVariacaoPercentual(
      atual: acaoAtual.pessoasAlcancadas,
      media: mediaPessoas,
    );
    final variacaoVeiculos = _calcularVariacaoPercentual(
      atual: acaoAtual.veiculosAbordados,
      media: mediaVeiculos,
    );

    final nivel = _classificar(
      variacaoPessoasPercentual: variacaoPessoas,
      quantidadeComparada: comparaveis.length,
    );

    return FaxitaHistoricalAnalysisResult(
      totalAcoesComparadas: comparaveis.length,
      mediaPessoasAlcancadas: mediaPessoas,
      mediaVeiculosAbordados: mediaVeiculos,
      mediaNotaAvaliacao: mediaNota,
      taxaMetaAtingida: taxaMeta,
      variacaoPessoasPercentual: variacaoPessoas,
      variacaoVeiculosPercentual: variacaoVeiculos,
      nivel: nivel,
      parecer: _gerarParecer(
        nivel: nivel,
        quantidadeComparada: comparaveis.length,
        variacaoPessoasPercentual: variacaoPessoas,
        taxaMetaAtingida: taxaMeta,
      ),
      criterioComparacao: criterio,
    );
  }

  bool _acaoSemelhante({
    required AcaoModel atual,
    required AcaoModel historica,
  }) {
    final tipoAtual = _normalizar(atual.tipoAcao);
    final tipoHistorico = _normalizar(historica.tipoAcao);

    if (tipoAtual.isNotEmpty && tipoHistorico.isNotEmpty) {
      return tipoAtual == tipoHistorico;
    }

    final nomeAtual = _normalizar(atual.nomeAcao);
    final nomeHistorico = _normalizar(historica.nomeAcao);

    return nomeAtual.isNotEmpty && nomeAtual == nomeHistorico;
  }

  String _definirCriterio(AcaoModel acao) {
    if (acao.tipoAcao.trim().isNotEmpty) {
      return 'Mesmo tipo de ação: ${acao.tipoAcao.trim()}';
    }
    if (acao.nomeAcao.trim().isNotEmpty) {
      return 'Mesmo nome de ação: ${acao.nomeAcao.trim()}';
    }
    return 'Ações educativas semelhantes';
  }

  double _media(Iterable<int> valores) {
    final lista = valores.toList(growable: false);
    if (lista.isEmpty) return 0;

    final total =
        lista.fold<int>(0, (acumulado, valor) => acumulado + valor);
    return total / lista.length;
  }

  double _calcularVariacaoPercentual({
    required int atual,
    required double media,
  }) {
    if (media <= 0) return 0;
    return ((atual - media) / media) * 100;
  }

  FaxitaHistoricalLevel _classificar({
    required double variacaoPessoasPercentual,
    required int quantidadeComparada,
  }) {
    if (quantidadeComparada < quantidadeMinimaBaseConfiavel) {
      return FaxitaHistoricalLevel.semBase;
    }
    if (variacaoPessoasPercentual > 10) {
      return FaxitaHistoricalLevel.acimaDoPadrao;
    }
    if (variacaoPessoasPercentual < -10) {
      return FaxitaHistoricalLevel.abaixoDoPadrao;
    }
    return FaxitaHistoricalLevel.dentroDoPadrao;
  }

  String _gerarParecer({
    required FaxitaHistoricalLevel nivel,
    required int quantidadeComparada,
    required double variacaoPessoasPercentual,
    required double taxaMetaAtingida,
  }) {
    if (quantidadeComparada < quantidadeMinimaBaseConfiavel) {
      return 'Foram encontradas apenas $quantidadeComparada ações comparáveis. '
          'A Faxita exibirá os indicadores, mas ainda não considera a base '
          'suficiente para uma conclusão histórica definitiva.';
    }

    final variacaoAbsoluta = variacaoPessoasPercentual.abs().round();
    final taxaArredondada = taxaMetaAtingida.round();

    switch (nivel) {
      case FaxitaHistoricalLevel.acimaDoPadrao:
        return 'O alcance desta ação está $variacaoAbsoluta% acima da média '
            'das ações semelhantes. No histórico analisado, '
            '$taxaArredondada% das ações atingiram a meta.';
      case FaxitaHistoricalLevel.abaixoDoPadrao:
        return 'O alcance desta ação está $variacaoAbsoluta% abaixo da média '
            'das ações semelhantes. Recomenda-se revisar as condições '
            'operacionais e as dificuldades registradas.';
      case FaxitaHistoricalLevel.dentroDoPadrao:
        return 'O resultado está dentro do intervalo esperado para ações '
            'semelhantes. No histórico analisado, $taxaArredondada% das ações '
            'atingiram a meta.';
      case FaxitaHistoricalLevel.semBase:
        return 'A base histórica disponível ainda é insuficiente para uma '
            'conclusão comparativa segura.';
    }
  }

  String _normalizar(String valor) {
    var texto = valor.trim().toLowerCase();

    const substituicoes = <String, String>{
      'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
      'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
      'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
      'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
      'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
      'ç': 'c',
    };

    substituicoes.forEach((origem, destino) {
      texto = texto.replaceAll(origem, destino);
    });

    return texto.replaceAll(RegExp(r'\s+'), ' ');
  }
}

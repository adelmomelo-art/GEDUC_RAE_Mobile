import 'dart:math' as math;

import '../../data/models/acao_model.dart';

enum DashboardPeriodo {
  hoje,
  semana,
  mes,
  ano,
  geral,
}

extension DashboardPeriodoExtension on DashboardPeriodo {
  String get label {
    switch (this) {
      case DashboardPeriodo.hoje:
        return 'Hoje';
      case DashboardPeriodo.semana:
        return 'Semana';
      case DashboardPeriodo.mes:
        return 'Mês';
      case DashboardPeriodo.ano:
        return 'Ano';
      case DashboardPeriodo.geral:
        return 'Geral';
    }
  }
}

class DashboardRankingItem {
  final String nome;
  final int quantidade;
  final int pessoasAlcancadas;
  final int veiculosAbordados;
  final int credenciaisEmitidas;
  final double percentual;

  const DashboardRankingItem({
    required this.nome,
    required this.quantidade,
    required this.pessoasAlcancadas,
    required this.veiculosAbordados,
    required this.credenciaisEmitidas,
    required this.percentual,
  });
}

class DashboardSerieTemporalItem {
  final DateTime periodo;
  final String rotulo;
  final int quantidadeAcoes;
  final int pessoasAlcancadas;
  final int veiculosAbordados;
  final int credenciaisEmitidas;

  const DashboardSerieTemporalItem({
    required this.periodo,
    required this.rotulo,
    required this.quantidadeAcoes,
    required this.pessoasAlcancadas,
    required this.veiculosAbordados,
    required this.credenciaisEmitidas,
  });
}

class DashboardIndicadores {
  final DashboardPeriodo periodo;
  final DateTime dataGeracao;
  final int totalAcoes;
  final int pessoasAlcancadas;
  final int veiculosAbordados;
  final int credenciaisEmitidas;
  final int totalAgentes;
  final int totalEquipeTerceirizada;
  final int metasAtingidas;
  final int metasNaoAtingidas;
  final int acoesPlanejadas;
  final int acoesNaoPlanejadas;
  final int acoesComCoberturaMidia;
  final int acoesComParticipacaoOutroOrgao;
  final int acoesSincronizadas;
  final int acoesPendentesSincronizacao;
  final int maiorPublicoEmUmaAcao;
  final int menorPublicoEmUmaAcao;
  final double mediaPessoasPorAcao;
  final double medianaPessoasPorAcao;
  final double desvioPadraoPessoasPorAcao;
  final double mediaVeiculosPorAcao;
  final double mediaCredenciaisPorAcao;
  final double mediaPessoasPorAgente;
  final double mediaVeiculosPorAgente;
  final double percentualMetasAtingidas;
  final double percentualAcoesPlanejadas;
  final double percentualCoberturaMidia;
  final double percentualParticipacaoOutroOrgao;
  final double percentualSincronizacao;
  final List<DashboardRankingItem> rankingRegionais;
  final List<DashboardRankingItem> rankingTiposAcao;
  final List<DashboardRankingItem> rankingProjetos;
  final List<DashboardRankingItem> rankingCoordenadores;
  final List<DashboardRankingItem> rankingInstituicoesParceiras;
  final List<DashboardRankingItem> distribuicaoTurnos;
  final List<DashboardRankingItem> distribuicaoPublicos;
  final List<DashboardRankingItem> distribuicaoFormacoes;
  final List<DashboardRankingItem> distribuicaoPerfisUsuario;
  final List<DashboardRankingItem> distribuicaoFocosTematicos;
  final List<DashboardSerieTemporalItem> serieTemporal;
  final List<String> destaques;
  final List<String> alertas;
  final List<String> recomendacoes;
  final String resumoExecutivo;

  const DashboardIndicadores({
    required this.periodo,
    required this.dataGeracao,
    required this.totalAcoes,
    required this.pessoasAlcancadas,
    required this.veiculosAbordados,
    required this.credenciaisEmitidas,
    required this.totalAgentes,
    required this.totalEquipeTerceirizada,
    required this.metasAtingidas,
    required this.metasNaoAtingidas,
    required this.acoesPlanejadas,
    required this.acoesNaoPlanejadas,
    required this.acoesComCoberturaMidia,
    required this.acoesComParticipacaoOutroOrgao,
    required this.acoesSincronizadas,
    required this.acoesPendentesSincronizacao,
    required this.maiorPublicoEmUmaAcao,
    required this.menorPublicoEmUmaAcao,
    required this.mediaPessoasPorAcao,
    required this.medianaPessoasPorAcao,
    required this.desvioPadraoPessoasPorAcao,
    required this.mediaVeiculosPorAcao,
    required this.mediaCredenciaisPorAcao,
    required this.mediaPessoasPorAgente,
    required this.mediaVeiculosPorAgente,
    required this.percentualMetasAtingidas,
    required this.percentualAcoesPlanejadas,
    required this.percentualCoberturaMidia,
    required this.percentualParticipacaoOutroOrgao,
    required this.percentualSincronizacao,
    required this.rankingRegionais,
    required this.rankingTiposAcao,
    required this.rankingProjetos,
    required this.rankingCoordenadores,
    required this.rankingInstituicoesParceiras,
    required this.distribuicaoTurnos,
    required this.distribuicaoPublicos,
    required this.distribuicaoFormacoes,
    required this.distribuicaoPerfisUsuario,
    required this.distribuicaoFocosTematicos,
    required this.serieTemporal,
    required this.destaques,
    required this.alertas,
    required this.recomendacoes,
    required this.resumoExecutivo,
  });

  factory DashboardIndicadores.vazio({
    DashboardPeriodo periodo = DashboardPeriodo.geral,
  }) {
    return DashboardIndicadores(
      periodo: periodo,
      dataGeracao: DateTime.now(),
      totalAcoes: 0,
      pessoasAlcancadas: 0,
      veiculosAbordados: 0,
      credenciaisEmitidas: 0,
      totalAgentes: 0,
      totalEquipeTerceirizada: 0,
      metasAtingidas: 0,
      metasNaoAtingidas: 0,
      acoesPlanejadas: 0,
      acoesNaoPlanejadas: 0,
      acoesComCoberturaMidia: 0,
      acoesComParticipacaoOutroOrgao: 0,
      acoesSincronizadas: 0,
      acoesPendentesSincronizacao: 0,
      maiorPublicoEmUmaAcao: 0,
      menorPublicoEmUmaAcao: 0,
      mediaPessoasPorAcao: 0,
      medianaPessoasPorAcao: 0,
      desvioPadraoPessoasPorAcao: 0,
      mediaVeiculosPorAcao: 0,
      mediaCredenciaisPorAcao: 0,
      mediaPessoasPorAgente: 0,
      mediaVeiculosPorAgente: 0,
      percentualMetasAtingidas: 0,
      percentualAcoesPlanejadas: 0,
      percentualCoberturaMidia: 0,
      percentualParticipacaoOutroOrgao: 0,
      percentualSincronizacao: 0,
      rankingRegionais: const [],
      rankingTiposAcao: const [],
      rankingProjetos: const [],
      rankingCoordenadores: const [],
      rankingInstituicoesParceiras: const [],
      distribuicaoTurnos: const [],
      distribuicaoPublicos: const [],
      distribuicaoFormacoes: const [],
      distribuicaoPerfisUsuario: const [],
      distribuicaoFocosTematicos: const [],
      serieTemporal: const [],
      destaques: const [],
      alertas: const [],
      recomendacoes: const [],
      resumoExecutivo:
          'Ainda não existem dados suficientes para gerar uma análise.',
    );
  }
}

class DashboardService {
  const DashboardService();

  DashboardIndicadores calcularIndicadores(
    List<AcaoModel> todasAsAcoes, {
    DashboardPeriodo periodo = DashboardPeriodo.geral,
    DateTime? referencia,
  }) {
    final dataReferencia = referencia ?? DateTime.now();

    final acoes = todasAsAcoes
        .where(
          (acao) => _pertenceAoPeriodo(
            acao.dataAcao,
            periodo,
            dataReferencia,
          ),
        )
        .toList()
      ..sort((a, b) => a.dataAcao.compareTo(b.dataAcao));

    if (acoes.isEmpty) {
      return DashboardIndicadores.vazio(periodo: periodo);
    }

    final totalAcoes = acoes.length;
    final pessoasAlcancadas =
        acoes.fold<int>(0, (total, acao) => total + acao.pessoasAlcancadas);
    final veiculosAbordados =
        acoes.fold<int>(0, (total, acao) => total + acao.veiculosAbordados);
    final credenciaisEmitidas =
        acoes.fold<int>(0, (total, acao) => total + acao.credenciaisEmitidas);
    final totalAgentes =
        acoes.fold<int>(0, (total, acao) => total + acao.agentesTransito);
    final totalEquipeTerceirizada =
        acoes.fold<int>(0, (total, acao) => total + acao.equipeTerceirizada);

    final metasAtingidas =
        acoes.where((acao) => acao.metaAtingida).length;
    final metasNaoAtingidas = totalAcoes - metasAtingidas;

    final acoesPlanejadas =
        acoes.where((acao) => acao.acaoPlanejada).length;
    final acoesNaoPlanejadas = totalAcoes - acoesPlanejadas;

    final acoesComCoberturaMidia =
        acoes.where((acao) => acao.coberturaMidia).length;

    final acoesComParticipacaoOutroOrgao =
        acoes.where((acao) => acao.houveParticipacaoOutroOrgao).length;

    final acoesSincronizadas =
        acoes.where((acao) => acao.sincronizado).length;
    final acoesPendentesSincronizacao = totalAcoes - acoesSincronizadas;

    final publicos = acoes
        .map((acao) => acao.pessoasAlcancadas)
        .toList()
      ..sort();

    final maiorPublicoEmUmaAcao = publicos.last;
    final menorPublicoEmUmaAcao = publicos.first;
    final mediaPessoasPorAcao = _media(publicos);
    final medianaPessoasPorAcao = _mediana(publicos);
    final desvioPadraoPessoasPorAcao = _desvioPadrao(publicos);

    final mediaVeiculosPorAcao = _dividir(veiculosAbordados, totalAcoes);
    final mediaCredenciaisPorAcao = _dividir(credenciaisEmitidas, totalAcoes);
    final mediaPessoasPorAgente = _dividir(pessoasAlcancadas, totalAgentes);
    final mediaVeiculosPorAgente = _dividir(veiculosAbordados, totalAgentes);

    final percentualMetasAtingidas =
        _percentual(metasAtingidas, totalAcoes);
    final percentualAcoesPlanejadas =
        _percentual(acoesPlanejadas, totalAcoes);
    final percentualCoberturaMidia =
        _percentual(acoesComCoberturaMidia, totalAcoes);
    final percentualParticipacaoOutroOrgao =
        _percentual(acoesComParticipacaoOutroOrgao, totalAcoes);
    final percentualSincronizacao =
        _percentual(acoesSincronizadas, totalAcoes);

    final rankingRegionais = _criarRanking(
      acoes,
      chave: (acao) => acao.regional,
    );

    final rankingTiposAcao = _criarRanking(
      acoes,
      chave: (acao) => acao.tipoAcao,
    );

    final rankingProjetos = _criarRanking(
      acoes,
      chave: (acao) => acao.nomeAcao,
    );

    final rankingCoordenadores = _criarRanking(
      acoes,
      chave: (acao) => acao.coordenadorNome,
    );

    final rankingInstituicoesParceiras = _criarRanking(
      acoes.where((acao) => acao.instituicaoParceira.trim().isNotEmpty).toList(),
      chave: (acao) => acao.instituicaoParceira,
    );

    final distribuicaoTurnos = _criarRanking(
      acoes,
      chave: (acao) => acao.turno,
    );

    final distribuicaoPublicos = _criarRanking(
      acoes.where((acao) => acao.publicoId.trim().isNotEmpty).toList(),
      chave: (acao) => acao.publicoId,
    );

    final distribuicaoFormacoes = _criarRanking(
      acoes.where((acao) => acao.formacaoId.trim().isNotEmpty).toList(),
      chave: (acao) => acao.formacaoId,
    );

    final distribuicaoPerfisUsuario = _criarRankingMultivalor(
      acoes,
      valores: (acao) => acao.perfilUsuarioIds,
    );

    final distribuicaoFocosTematicos = _criarRankingMultivalor(
      acoes,
      valores: (acao) => acao.focoTematicoIds,
    );

    final serieTemporal = _criarSerieTemporal(
      acoes,
      periodo: periodo,
    );

    final destaques = _gerarDestaques(
      totalAcoes: totalAcoes,
      pessoasAlcancadas: pessoasAlcancadas,
      percentualMetasAtingidas: percentualMetasAtingidas,
      percentualSincronizacao: percentualSincronizacao,
      rankingRegionais: rankingRegionais,
      rankingProjetos: rankingProjetos,
    );

    final alertas = _gerarAlertas(
      totalAcoes: totalAcoes,
      percentualMetasAtingidas: percentualMetasAtingidas,
      percentualAcoesPlanejadas: percentualAcoesPlanejadas,
      percentualCoberturaMidia: percentualCoberturaMidia,
      percentualSincronizacao: percentualSincronizacao,
      acoesPendentesSincronizacao: acoesPendentesSincronizacao,
    );

    final recomendacoes = _gerarRecomendacoes(
      totalAcoes: totalAcoes,
      percentualMetasAtingidas: percentualMetasAtingidas,
      percentualAcoesPlanejadas: percentualAcoesPlanejadas,
      percentualCoberturaMidia: percentualCoberturaMidia,
      percentualParticipacaoOutroOrgao:
          percentualParticipacaoOutroOrgao,
      mediaPessoasPorAgente: mediaPessoasPorAgente,
    );

    final resumoExecutivo = _gerarResumoExecutivo(
      periodo: periodo,
      totalAcoes: totalAcoes,
      pessoasAlcancadas: pessoasAlcancadas,
      veiculosAbordados: veiculosAbordados,
      credenciaisEmitidas: credenciaisEmitidas,
      percentualMetasAtingidas: percentualMetasAtingidas,
      mediaPessoasPorAcao: mediaPessoasPorAcao,
      rankingRegionais: rankingRegionais,
      rankingProjetos: rankingProjetos,
      acoesPendentesSincronizacao: acoesPendentesSincronizacao,
    );

    return DashboardIndicadores(
      periodo: periodo,
      dataGeracao: DateTime.now(),
      totalAcoes: totalAcoes,
      pessoasAlcancadas: pessoasAlcancadas,
      veiculosAbordados: veiculosAbordados,
      credenciaisEmitidas: credenciaisEmitidas,
      totalAgentes: totalAgentes,
      totalEquipeTerceirizada: totalEquipeTerceirizada,
      metasAtingidas: metasAtingidas,
      metasNaoAtingidas: metasNaoAtingidas,
      acoesPlanejadas: acoesPlanejadas,
      acoesNaoPlanejadas: acoesNaoPlanejadas,
      acoesComCoberturaMidia: acoesComCoberturaMidia,
      acoesComParticipacaoOutroOrgao:
          acoesComParticipacaoOutroOrgao,
      acoesSincronizadas: acoesSincronizadas,
      acoesPendentesSincronizacao: acoesPendentesSincronizacao,
      maiorPublicoEmUmaAcao: maiorPublicoEmUmaAcao,
      menorPublicoEmUmaAcao: menorPublicoEmUmaAcao,
      mediaPessoasPorAcao: mediaPessoasPorAcao,
      medianaPessoasPorAcao: medianaPessoasPorAcao,
      desvioPadraoPessoasPorAcao: desvioPadraoPessoasPorAcao,
      mediaVeiculosPorAcao: mediaVeiculosPorAcao,
      mediaCredenciaisPorAcao: mediaCredenciaisPorAcao,
      mediaPessoasPorAgente: mediaPessoasPorAgente,
      mediaVeiculosPorAgente: mediaVeiculosPorAgente,
      percentualMetasAtingidas: percentualMetasAtingidas,
      percentualAcoesPlanejadas: percentualAcoesPlanejadas,
      percentualCoberturaMidia: percentualCoberturaMidia,
      percentualParticipacaoOutroOrgao:
          percentualParticipacaoOutroOrgao,
      percentualSincronizacao: percentualSincronizacao,
      rankingRegionais: rankingRegionais,
      rankingTiposAcao: rankingTiposAcao,
      rankingProjetos: rankingProjetos,
      rankingCoordenadores: rankingCoordenadores,
      rankingInstituicoesParceiras: rankingInstituicoesParceiras,
      distribuicaoTurnos: distribuicaoTurnos,
      distribuicaoPublicos: distribuicaoPublicos,
      distribuicaoFormacoes: distribuicaoFormacoes,
      distribuicaoPerfisUsuario: distribuicaoPerfisUsuario,
      distribuicaoFocosTematicos: distribuicaoFocosTematicos,
      serieTemporal: serieTemporal,
      destaques: destaques,
      alertas: alertas,
      recomendacoes: recomendacoes,
      resumoExecutivo: resumoExecutivo,
    );
  }

  bool _pertenceAoPeriodo(
    DateTime data,
    DashboardPeriodo periodo,
    DateTime referencia,
  ) {
    final dataNormalizada = DateTime(data.year, data.month, data.day);
    final referenciaNormalizada = DateTime(
      referencia.year,
      referencia.month,
      referencia.day,
    );

    switch (periodo) {
      case DashboardPeriodo.hoje:
        return dataNormalizada == referenciaNormalizada;

      case DashboardPeriodo.semana:
        final inicioSemana = referenciaNormalizada.subtract(
          Duration(days: referenciaNormalizada.weekday - 1),
        );
        final fimSemana = inicioSemana.add(const Duration(days: 6));
        return !dataNormalizada.isBefore(inicioSemana) &&
            !dataNormalizada.isAfter(fimSemana);

      case DashboardPeriodo.mes:
        return data.year == referencia.year &&
            data.month == referencia.month;

      case DashboardPeriodo.ano:
        return data.year == referencia.year;

      case DashboardPeriodo.geral:
        return true;
    }
  }

  List<DashboardRankingItem> _criarRanking(
    List<AcaoModel> acoes, {
    required String Function(AcaoModel acao) chave,
  }) {
    if (acoes.isEmpty) {
      return const [];
    }

    final agrupados = <String, List<AcaoModel>>{};

    for (final acao in acoes) {
      final valorOriginal = chave(acao).trim();
      final valor = valorOriginal.isEmpty ? 'Não informado' : valorOriginal;
      agrupados.putIfAbsent(valor, () => []).add(acao);
    }

    final total = acoes.length;

    final ranking = agrupados.entries.map((entry) {
      final grupo = entry.value;

      return DashboardRankingItem(
        nome: entry.key,
        quantidade: grupo.length,
        pessoasAlcancadas: grupo.fold<int>(
          0,
          (soma, acao) => soma + acao.pessoasAlcancadas,
        ),
        veiculosAbordados: grupo.fold<int>(
          0,
          (soma, acao) => soma + acao.veiculosAbordados,
        ),
        credenciaisEmitidas: grupo.fold<int>(
          0,
          (soma, acao) => soma + acao.credenciaisEmitidas,
        ),
        percentual: _percentual(grupo.length, total),
      );
    }).toList()
      ..sort((a, b) {
        final porQuantidade = b.quantidade.compareTo(a.quantidade);
        if (porQuantidade != 0) {
          return porQuantidade;
        }
        return a.nome.compareTo(b.nome);
      });

    return ranking;
  }

  List<DashboardRankingItem> _criarRankingMultivalor(
    List<AcaoModel> acoes, {
    required List<String> Function(AcaoModel acao) valores,
  }) {
    final ocorrencias = <String, int>{};
    final pessoas = <String, int>{};
    final veiculos = <String, int>{};
    final credenciais = <String, int>{};

    int totalOcorrencias = 0;

    for (final acao in acoes) {
      final valoresValidos = valores(acao)
          .map((valor) => valor.trim())
          .where((valor) => valor.isNotEmpty)
          .toSet();

      for (final valor in valoresValidos) {
        ocorrencias[valor] = (ocorrencias[valor] ?? 0) + 1;
        pessoas[valor] =
            (pessoas[valor] ?? 0) + acao.pessoasAlcancadas;
        veiculos[valor] =
            (veiculos[valor] ?? 0) + acao.veiculosAbordados;
        credenciais[valor] =
            (credenciais[valor] ?? 0) + acao.credenciaisEmitidas;
        totalOcorrencias++;
      }
    }

    if (totalOcorrencias == 0) {
      return const [];
    }

    final ranking = ocorrencias.entries.map((entry) {
      return DashboardRankingItem(
        nome: entry.key,
        quantidade: entry.value,
        pessoasAlcancadas: pessoas[entry.key] ?? 0,
        veiculosAbordados: veiculos[entry.key] ?? 0,
        credenciaisEmitidas: credenciais[entry.key] ?? 0,
        percentual: _percentual(entry.value, totalOcorrencias),
      );
    }).toList()
      ..sort((a, b) {
        final porQuantidade = b.quantidade.compareTo(a.quantidade);
        if (porQuantidade != 0) {
          return porQuantidade;
        }
        return a.nome.compareTo(b.nome);
      });

    return ranking;
  }

  List<DashboardSerieTemporalItem> _criarSerieTemporal(
    List<AcaoModel> acoes, {
    required DashboardPeriodo periodo,
  }) {
    final agrupados = <DateTime, List<AcaoModel>>{};

    for (final acao in acoes) {
      final chave = periodo == DashboardPeriodo.ano ||
              periodo == DashboardPeriodo.geral
          ? DateTime(acao.dataAcao.year, acao.dataAcao.month)
          : DateTime(
              acao.dataAcao.year,
              acao.dataAcao.month,
              acao.dataAcao.day,
            );

      agrupados.putIfAbsent(chave, () => []).add(acao);
    }

    final chaves = agrupados.keys.toList()..sort();

    return chaves.map((chave) {
      final grupo = agrupados[chave] ?? const <AcaoModel>[];

      return DashboardSerieTemporalItem(
        periodo: chave,
        rotulo: _rotuloPeriodo(chave, periodo),
        quantidadeAcoes: grupo.length,
        pessoasAlcancadas: grupo.fold<int>(
          0,
          (soma, acao) => soma + acao.pessoasAlcancadas,
        ),
        veiculosAbordados: grupo.fold<int>(
          0,
          (soma, acao) => soma + acao.veiculosAbordados,
        ),
        credenciaisEmitidas: grupo.fold<int>(
          0,
          (soma, acao) => soma + acao.credenciaisEmitidas,
        ),
      );
    }).toList();
  }

  String _rotuloPeriodo(
    DateTime data,
    DashboardPeriodo periodo,
  ) {
    if (periodo == DashboardPeriodo.ano ||
        periodo == DashboardPeriodo.geral) {
      const meses = [
        'Jan',
        'Fev',
        'Mar',
        'Abr',
        'Mai',
        'Jun',
        'Jul',
        'Ago',
        'Set',
        'Out',
        'Nov',
        'Dez',
      ];

      return '${meses[data.month - 1]}/${data.year}';
    }

    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}';
  }

  List<String> _gerarDestaques({
    required int totalAcoes,
    required int pessoasAlcancadas,
    required double percentualMetasAtingidas,
    required double percentualSincronizacao,
    required List<DashboardRankingItem> rankingRegionais,
    required List<DashboardRankingItem> rankingProjetos,
  }) {
    final destaques = <String>[];

    if (totalAcoes > 0) {
      destaques.add(
        '$totalAcoes ações registradas e $pessoasAlcancadas pessoas alcançadas.',
      );
    }

    if (percentualMetasAtingidas >= 80) {
      destaques.add(
        'O índice de metas atingidas está em '
        '${percentualMetasAtingidas.toStringAsFixed(1)}%.',
      );
    }

    if (percentualSincronizacao == 100) {
      destaques.add('Todos os registros estão sincronizados.');
    }

    if (rankingRegionais.isNotEmpty) {
      final lider = rankingRegionais.first;
      destaques.add(
        '${lider.nome} lidera entre as regionais, com '
        '${lider.quantidade} ações.',
      );
    }

    if (rankingProjetos.isNotEmpty) {
      final lider = rankingProjetos.first;
      destaques.add(
        '${lider.nome} é o projeto com maior número de registros.',
      );
    }

    return destaques;
  }

  List<String> _gerarAlertas({
    required int totalAcoes,
    required double percentualMetasAtingidas,
    required double percentualAcoesPlanejadas,
    required double percentualCoberturaMidia,
    required double percentualSincronizacao,
    required int acoesPendentesSincronizacao,
  }) {
    final alertas = <String>[];

    if (totalAcoes < 3) {
      alertas.add(
        'A amostra do período ainda é pequena para conclusões estratégicas.',
      );
    }

    if (percentualMetasAtingidas < 60) {
      alertas.add(
        'O percentual de metas atingidas está abaixo de 60%.',
      );
    }

    if (percentualAcoesPlanejadas < 70) {
      alertas.add(
        'Há predominância relevante de ações não planejadas.',
      );
    }

    if (percentualCoberturaMidia < 20) {
      alertas.add(
        'A cobertura de mídia está presente em menos de 20% das ações.',
      );
    }

    if (percentualSincronizacao < 100) {
      alertas.add(
        '$acoesPendentesSincronizacao registro(s) aguardam sincronização.',
      );
    }

    return alertas;
  }

  List<String> _gerarRecomendacoes({
    required int totalAcoes,
    required double percentualMetasAtingidas,
    required double percentualAcoesPlanejadas,
    required double percentualCoberturaMidia,
    required double percentualParticipacaoOutroOrgao,
    required double mediaPessoasPorAgente,
  }) {
    final recomendacoes = <String>[];

    if (totalAcoes == 0) {
      return recomendacoes;
    }

    if (percentualMetasAtingidas < 75) {
      recomendacoes.add(
        'Revisar metas e causas registradas nas ações que não alcançaram '
        'o resultado mínimo esperado.',
      );
    }

    if (percentualAcoesPlanejadas < 80) {
      recomendacoes.add(
        'Ampliar o planejamento prévio das ações para reduzir demandas '
        'reativas e melhorar a alocação de equipes.',
      );
    }

    if (percentualCoberturaMidia < 30) {
      recomendacoes.add(
        'Avaliar oportunidades de ampliar a cobertura de mídia das ações '
        'com maior alcance.',
      );
    }

    if (percentualParticipacaoOutroOrgao < 20) {
      recomendacoes.add(
        'Estimular ações integradas com outros órgãos e instituições '
        'parceiras.',
      );
    }

    if (mediaPessoasPorAgente < 10) {
      recomendacoes.add(
        'Analisar a composição das equipes em relação ao público alcançado.',
      );
    }

    if (recomendacoes.isEmpty) {
      recomendacoes.add(
        'Manter o acompanhamento periódico dos indicadores e replicar '
        'as práticas das ações com melhor desempenho.',
      );
    }

    return recomendacoes;
  }

  String _gerarResumoExecutivo({
    required DashboardPeriodo periodo,
    required int totalAcoes,
    required int pessoasAlcancadas,
    required int veiculosAbordados,
    required int credenciaisEmitidas,
    required double percentualMetasAtingidas,
    required double mediaPessoasPorAcao,
    required List<DashboardRankingItem> rankingRegionais,
    required List<DashboardRankingItem> rankingProjetos,
    required int acoesPendentesSincronizacao,
  }) {
    final partes = <String>[
      'No período ${periodo.label.toLowerCase()}, foram registradas '
          '$totalAcoes ações, com alcance de $pessoasAlcancadas pessoas, '
          '$veiculosAbordados veículos abordados e '
          '$credenciaisEmitidas credenciais emitidas.',
      'A média foi de ${mediaPessoasPorAcao.toStringAsFixed(1)} pessoas '
          'por ação, e ${percentualMetasAtingidas.toStringAsFixed(1)}% '
          'das metas foram atingidas.',
    ];

    if (rankingRegionais.isNotEmpty) {
      partes.add(
        '${rankingRegionais.first.nome} apresentou o maior volume regional.',
      );
    }

    if (rankingProjetos.isNotEmpty) {
      partes.add(
        '${rankingProjetos.first.nome} liderou entre os projetos registrados.',
      );
    }

    if (acoesPendentesSincronizacao > 0) {
      partes.add(
        'Existem $acoesPendentesSincronizacao registro(s) pendente(s) '
        'de sincronização.',
      );
    } else {
      partes.add('Todos os registros do período estão sincronizados.');
    }

    return partes.join(' ');
  }

  double _media(List<int> valores) {
    if (valores.isEmpty) {
      return 0;
    }

    final soma = valores.fold<int>(0, (total, valor) => total + valor);
    return soma / valores.length;
  }

  double _mediana(List<int> valoresOrdenados) {
    if (valoresOrdenados.isEmpty) {
      return 0;
    }

    final meio = valoresOrdenados.length ~/ 2;

    if (valoresOrdenados.length.isOdd) {
      return valoresOrdenados[meio].toDouble();
    }

    return (valoresOrdenados[meio - 1] + valoresOrdenados[meio]) / 2;
  }

  double _desvioPadrao(List<int> valores) {
    if (valores.length <= 1) {
      return 0;
    }

    final media = _media(valores);
    final variancia = valores.fold<double>(
          0,
          (soma, valor) => soma + math.pow(valor - media, 2),
        ) /
        valores.length;

    return math.sqrt(variancia);
  }

  double _dividir(num numerador, num denominador) {
    if (denominador == 0) {
      return 0;
    }

    return numerador / denominador;
  }

  double _percentual(num parte, num total) {
    if (total == 0) {
      return 0;
    }

    return (parte / total) * 100;
  }
}

import '../models/analytics/alerta_operacional.dart';
import '../models/analytics/analytics_enums.dart';
import '../models/analytics/indicador_estrategico.dart';
import '../models/analytics/insight_operacional.dart';
import '../models/analytics/ranking_item.dart';
import 'performance_score_engine.dart';

/// Serviço analítico do Centro de Inteligência Operacional.
///
/// Consolida dados operacionais e produz:
/// - rankings;
/// - indicadores estratégicos;
/// - insights;
/// - alertas;
/// - recomendações executivas.
class CIOAnalyticsService {
  const CIOAnalyticsService({
    this.scoreEngine = const PerformanceScoreEngine(),
  });

  final PerformanceScoreEngine scoreEngine;

  /// Gera ranking de desempenho a partir de agregados operacionais.
  List<RankingItem> gerarRanking({
    required List<CIOAnalyticsAggregate> agregados,
    required RankingCategoria categoria,
    required PerformanceScoreReference referencia,
    OrigemAnalise origem = OrigemAnalise.cio,
    DateTime? dataGeracao,
  }) {
    final generatedAt = dataGeracao ?? DateTime.now();

    final calculados = agregados.map((agregado) {
      final resultado = scoreEngine.calculate(
        input: agregado.toPerformanceInput(),
        reference: referencia,
      );

      return _RankingCalculado(
        agregado: agregado,
        resultado: resultado,
      );
    }).toList()
      ..sort(
        (a, b) => b.resultado.score.compareTo(a.resultado.score),
      );

    return List<RankingItem>.generate(
      calculados.length,
      (index) {
        final item = calculados[index];

        return RankingItem(
          id: item.agregado.id,
          dataGeracao: generatedAt,
          origem: origem,
          nome: item.agregado.nome,
          categoria: categoria,
          valor: item.resultado.score,
          indice: item.resultado.score,
          posicao: index + 1,
          tendencia: item.agregado.tendencia,
          descricao: item.agregado.descricao,
          quantidadeAcoes: item.agregado.acoes,
          pessoasAlcancadas: item.agregado.pessoasAlcancadas,
          veiculosAbordados: item.agregado.veiculosAbordados,
          credenciaisEmitidas: item.agregado.credenciaisEmitidas,
          percentualMetasAtingidas:
              item.agregado.percentualMetasAtingidas,
        );
      },
      growable: false,
    );
  }

  /// Produz os principais indicadores estratégicos do CIO.
  List<IndicadorEstrategico> gerarIndicadores({
    required CIOAnalyticsSummary resumo,
    OrigemAnalise origem = OrigemAnalise.cio,
    DateTime? dataGeracao,
  }) {
    final generatedAt = dataGeracao ?? DateTime.now();

    return <IndicadorEstrategico>[
      _buildIndicator(
        id: 'total_acoes',
        titulo: 'Ações realizadas',
        valor: resumo.totalAcoes.toDouble(),
        unidade: 'ações',
        meta: resumo.metaAcoes?.toDouble(),
        tendencia: resumo.tendenciaAcoes,
        origem: origem,
        dataGeracao: generatedAt,
      ),
      _buildIndicator(
        id: 'pessoas_alcancadas',
        titulo: 'Pessoas alcançadas',
        valor: resumo.pessoasAlcancadas.toDouble(),
        unidade: 'pessoas',
        meta: resumo.metaPessoas?.toDouble(),
        tendencia: resumo.tendenciaPessoas,
        origem: origem,
        dataGeracao: generatedAt,
      ),
      _buildIndicator(
        id: 'veiculos_abordados',
        titulo: 'Veículos abordados',
        valor: resumo.veiculosAbordados.toDouble(),
        unidade: 'veículos',
        meta: resumo.metaVeiculos?.toDouble(),
        tendencia: resumo.tendenciaVeiculos,
        origem: origem,
        dataGeracao: generatedAt,
      ),
      _buildIndicator(
        id: 'credenciais_emitidas',
        titulo: 'Credenciais emitidas',
        valor: resumo.credenciaisEmitidas.toDouble(),
        unidade: 'credenciais',
        meta: resumo.metaCredenciais?.toDouble(),
        tendencia: resumo.tendenciaCredenciais,
        origem: origem,
        dataGeracao: generatedAt,
      ),
      _buildIndicator(
        id: 'metas_atingidas',
        titulo: 'Metas atingidas',
        valor: resumo.percentualMetasAtingidas,
        unidade: '%',
        meta: 100,
        tendencia: resumo.tendenciaMetas,
        origem: origem,
        dataGeracao: generatedAt,
      ),
    ];
  }

  /// Gera insights automáticos com base no resumo e no ranking.
  List<InsightOperacional> gerarInsights({
    required CIOAnalyticsSummary resumo,
    List<RankingItem> ranking = const <RankingItem>[],
    OrigemAnalise origem = OrigemAnalise.faxita,
    DateTime? dataGeracao,
  }) {
    final generatedAt = dataGeracao ?? DateTime.now();
    final insights = <InsightOperacional>[];

    if (ranking.isNotEmpty) {
      final lider = ranking.first;

      insights.add(
        InsightOperacional(
          id: 'ranking_lider_${lider.id}',
          dataGeracao: generatedAt,
          origem: origem,
          titulo: 'Destaque de desempenho',
          descricao:
              '${lider.nome} ocupa a primeira posição, com índice '
              '${lider.indice.toStringAsFixed(1)}.',
          categoria: InsightCategoria.desempenho,
          criticidade: NivelCriticidade.baixa,
          prioridade: PrioridadeAnalise.normal,
          entidadeRelacionada: lider.nome,
          valorReferencia: lider.indice,
          acaoSugerida:
              'Identificar e compartilhar as práticas que contribuíram '
              'para esse resultado.',
        ),
      );
    }

    if (resumo.percentualMetasAtingidas >= 100) {
      insights.add(
        InsightOperacional(
          id: 'metas_superadas',
          dataGeracao: generatedAt,
          origem: origem,
          titulo: 'Meta operacional alcançada',
          descricao:
              'O desempenho consolidado atingiu '
              '${resumo.percentualMetasAtingidas.toStringAsFixed(1)}% '
              'das metas planejadas.',
          categoria: InsightCategoria.meta,
          criticidade: NivelCriticidade.baixa,
          prioridade: PrioridadeAnalise.normal,
          valorReferencia: resumo.percentualMetasAtingidas,
          acaoSugerida:
              'Manter o acompanhamento e registrar os fatores de sucesso.',
        ),
      );
    } else if (resumo.percentualMetasAtingidas < 70) {
      insights.add(
        InsightOperacional(
          id: 'metas_abaixo',
          dataGeracao: generatedAt,
          origem: origem,
          titulo: 'Metas abaixo do esperado',
          descricao:
              'O desempenho consolidado alcançou apenas '
              '${resumo.percentualMetasAtingidas.toStringAsFixed(1)}% '
              'das metas planejadas.',
          categoria: InsightCategoria.meta,
          criticidade: NivelCriticidade.alta,
          prioridade: PrioridadeAnalise.alta,
          valorReferencia: resumo.percentualMetasAtingidas,
          acaoSugerida:
              'Revisar distribuição de equipes, agenda e capacidade '
              'operacional.',
        ),
      );
    }

    if (resumo.tendenciaAcoes == TendenciaIndicador.crescimento) {
      insights.add(
        InsightOperacional(
          id: 'crescimento_acoes',
          dataGeracao: generatedAt,
          origem: origem,
          titulo: 'Crescimento operacional',
          descricao:
              'A quantidade de ações apresenta tendência de crescimento.',
          categoria: InsightCategoria.tendencia,
          criticidade: NivelCriticidade.baixa,
          prioridade: PrioridadeAnalise.normal,
          acaoSugerida:
              'Avaliar se o crescimento está acompanhado de qualidade '
              'e alcance.',
        ),
      );
    }

    if (resumo.tendenciaAcoes == TendenciaIndicador.queda) {
      insights.add(
        InsightOperacional(
          id: 'queda_acoes',
          dataGeracao: generatedAt,
          origem: origem,
          titulo: 'Redução no volume de ações',
          descricao:
              'A quantidade de ações apresenta tendência de queda.',
          categoria: InsightCategoria.tendencia,
          criticidade: NivelCriticidade.moderada,
          prioridade: PrioridadeAnalise.alta,
          acaoSugerida:
              'Verificar cancelamentos, indisponibilidade de equipes '
              'e restrições operacionais.',
        ),
      );
    }

    return insights;
  }

  /// Gera alertas operacionais a partir dos indicadores e do ranking.
  List<AlertaOperacional> gerarAlertas({
    required CIOAnalyticsSummary resumo,
    List<RankingItem> ranking = const <RankingItem>[],
    OrigemAnalise origem = OrigemAnalise.cio,
    DateTime? dataGeracao,
  }) {
    final generatedAt = dataGeracao ?? DateTime.now();
    final alerts = <AlertaOperacional>[];

    if (resumo.percentualMetasAtingidas < 50) {
      alerts.add(
        AlertaOperacional(
          id: 'alerta_meta_critica',
          dataGeracao: generatedAt,
          origem: origem,
          titulo: 'Meta operacional em nível crítico',
          descricao:
              'O percentual consolidado de metas atingidas está abaixo '
              'de 50%.',
          nivel: NivelAlerta.critico,
          tipo: TipoAlertaOperacional.meta,
          prioridade: PrioridadeAnalise.urgente,
          acaoRecomendada:
              'Realizar análise imediata das causas e definir plano '
              'de recuperação.',
        ),
      );
    } else if (resumo.percentualMetasAtingidas < 70) {
      alerts.add(
        AlertaOperacional(
          id: 'alerta_meta_atencao',
          dataGeracao: generatedAt,
          origem: origem,
          titulo: 'Meta operacional requer atenção',
          descricao:
              'O percentual consolidado de metas atingidas está abaixo '
              'de 70%.',
          nivel: NivelAlerta.alto,
          tipo: TipoAlertaOperacional.meta,
          prioridade: PrioridadeAnalise.alta,
          acaoRecomendada:
              'Reavaliar programação, recursos e capacidade de execução.',
        ),
      );
    }

    if (resumo.totalAcoes == 0) {
      alerts.add(
        AlertaOperacional(
          id: 'alerta_sem_acoes',
          dataGeracao: generatedAt,
          origem: origem,
          titulo: 'Ausência de ações registradas',
          descricao:
              'Não foram identificadas ações no período analisado.',
          nivel: NivelAlerta.alto,
          tipo: TipoAlertaOperacional.quedaAtividade,
          prioridade: PrioridadeAnalise.alta,
          acaoRecomendada:
              'Verificar planejamento, execução e sincronização dos dados.',
        ),
      );
    }

    if (ranking.length >= 2) {
      final maior = ranking.first.indice;
      final menor = ranking.last.indice;
      final diferenca = maior - menor;

      if (diferenca >= 40) {
        alerts.add(
          AlertaOperacional(
            id: 'alerta_desigualdade_ranking',
            dataGeracao: generatedAt,
            origem: origem,
            titulo: 'Desigualdade relevante de desempenho',
            descricao:
                'A diferença entre o primeiro e o último colocado é de '
                '${diferenca.toStringAsFixed(1)} pontos.',
            nivel: NivelAlerta.medio,
            tipo: TipoAlertaOperacional.desempenho,
            prioridade: PrioridadeAnalise.alta,
            acaoRecomendada:
                'Comparar capacidade operacional, demanda e distribuição '
                'de recursos entre as unidades.',
          ),
        );
      }
    }

    return alerts;
  }

  /// Produz recomendações executivas em texto.
  List<String> gerarRecomendacoes({
    required CIOAnalyticsSummary resumo,
    List<RankingItem> ranking = const <RankingItem>[],
  }) {
    final recommendations = <String>[];

    if (resumo.percentualMetasAtingidas < 70) {
      recommendations.add(
        'Priorizar a recuperação das metas com revisão da agenda '
        'e da distribuição de equipes.',
      );
    }

    if (resumo.tendenciaAcoes == TendenciaIndicador.queda) {
      recommendations.add(
        'Investigar as causas da redução no volume de ações.',
      );
    }

    if (ranking.isNotEmpty) {
      recommendations.add(
        'Usar ${ranking.first.nome} como referência para análise '
        'de boas práticas operacionais.',
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add(
        'Manter o acompanhamento periódico dos indicadores e metas.',
      );
    }

    return recommendations;
  }

  IndicadorEstrategico _buildIndicator({
    required String id,
    required String titulo,
    required double valor,
    required String unidade,
    required TendenciaIndicador tendencia,
    required OrigemAnalise origem,
    required DateTime dataGeracao,
    double? meta,
  }) {
    final percentual = _calculatePercentage(valor, meta);
    final status = _statusFromPercentage(percentual);

    return IndicadorEstrategico(
      id: id,
      dataGeracao: dataGeracao,
      origem: origem,
      titulo: titulo,
      valor: valor,
      unidade: unidade,
      meta: meta,
      percentual: percentual,
      tendencia: tendencia,
      status: status,
    );
  }

  double? _calculatePercentage(double value, double? target) {
    if (target == null || target <= 0) {
      return null;
    }

    return ((value / target) * 100).clamp(0.0, 999.0);
  }

  StatusIndicador _statusFromPercentage(double? percentage) {
    if (percentage == null) {
      return StatusIndicador.indisponivel;
    }

    if (percentage >= 100) {
      return StatusIndicador.excelente;
    }

    if (percentage >= 80) {
      return StatusIndicador.adequado;
    }

    if (percentage >= 60) {
      return StatusIndicador.atencao;
    }

    return StatusIndicador.critico;
  }
}

/// Agregado operacional utilizado para rankings e análises comparativas.
class CIOAnalyticsAggregate {
  const CIOAnalyticsAggregate({
    required this.id,
    required this.nome,
    required this.acoes,
    required this.pessoasAlcancadas,
    required this.veiculosAbordados,
    required this.credenciaisEmitidas,
    required this.percentualMetasAtingidas,
    this.tendencia = TendenciaIndicador.indisponivel,
    this.descricao,
  });

  final String id;
  final String nome;
  final int acoes;
  final int pessoasAlcancadas;
  final int veiculosAbordados;
  final int credenciaisEmitidas;
  final double percentualMetasAtingidas;
  final TendenciaIndicador tendencia;
  final String? descricao;

  PerformanceScoreInput toPerformanceInput() {
    return PerformanceScoreInput(
      actions: acoes,
      peopleReached: pessoasAlcancadas,
      vehiclesApproached: veiculosAbordados,
      credentialsIssued: credenciaisEmitidas,
      goalsAchievementPercentage: percentualMetasAtingidas,
    );
  }
}

/// Resumo consolidado utilizado na geração de indicadores, insights e alertas.
class CIOAnalyticsSummary {
  const CIOAnalyticsSummary({
    required this.totalAcoes,
    required this.pessoasAlcancadas,
    required this.veiculosAbordados,
    required this.credenciaisEmitidas,
    required this.percentualMetasAtingidas,
    this.metaAcoes,
    this.metaPessoas,
    this.metaVeiculos,
    this.metaCredenciais,
    this.tendenciaAcoes = TendenciaIndicador.indisponivel,
    this.tendenciaPessoas = TendenciaIndicador.indisponivel,
    this.tendenciaVeiculos = TendenciaIndicador.indisponivel,
    this.tendenciaCredenciais = TendenciaIndicador.indisponivel,
    this.tendenciaMetas = TendenciaIndicador.indisponivel,
  });

  final int totalAcoes;
  final int pessoasAlcancadas;
  final int veiculosAbordados;
  final int credenciaisEmitidas;
  final double percentualMetasAtingidas;

  final int? metaAcoes;
  final int? metaPessoas;
  final int? metaVeiculos;
  final int? metaCredenciais;

  final TendenciaIndicador tendenciaAcoes;
  final TendenciaIndicador tendenciaPessoas;
  final TendenciaIndicador tendenciaVeiculos;
  final TendenciaIndicador tendenciaCredenciais;
  final TendenciaIndicador tendenciaMetas;
}

class _RankingCalculado {
  const _RankingCalculado({
    required this.agregado,
    required this.resultado,
  });

  final CIOAnalyticsAggregate agregado;
  final PerformanceScoreResult resultado;
}

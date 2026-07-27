enum FaxitaPredictiveConfidence {
  insuficiente,
  baixa,
  media,
  alta,
}

extension FaxitaPredictiveConfidenceExtension
    on FaxitaPredictiveConfidence {
  String get label {
    switch (this) {
      case FaxitaPredictiveConfidence.insuficiente:
        return 'Base insuficiente';
      case FaxitaPredictiveConfidence.baixa:
        return 'Confiança baixa';
      case FaxitaPredictiveConfidence.media:
        return 'Confiança moderada';
      case FaxitaPredictiveConfidence.alta:
        return 'Confiança alta';
    }
  }
}

class FaxitaPredictiveAnalysisResult {
  const FaxitaPredictiveAnalysisResult({
    required this.totalAcoesAnalisadas,
    required this.publicoPrevisto,
    required this.publicoMinimoPrevisto,
    required this.publicoMaximoPrevisto,
    required this.veiculosPrevistos,
    required this.probabilidadeMetaAtingida,
    required this.confianca,
    required this.criterioComparacao,
    required this.parecer,
    required this.recomendacoes,
  });

  final int totalAcoesAnalisadas;
  final double publicoPrevisto;
  final double publicoMinimoPrevisto;
  final double publicoMaximoPrevisto;
  final double veiculosPrevistos;
  final double probabilidadeMetaAtingida;
  final FaxitaPredictiveConfidence confianca;
  final String criterioComparacao;
  final String parecer;
  final List<String> recomendacoes;

  bool get possuiBaseHistorica => totalAcoesAnalisadas > 0;

  bool get previsaoDisponivel =>
      confianca != FaxitaPredictiveConfidence.insuficiente;

  int get publicoPrevistoArredondado => publicoPrevisto.round();

  int get publicoMinimoPrevistoArredondado =>
      publicoMinimoPrevisto.round();

  int get publicoMaximoPrevistoArredondado =>
      publicoMaximoPrevisto.round();

  int get veiculosPrevistosArredondado => veiculosPrevistos.round();

  int get probabilidadeMetaPercentual =>
      probabilidadeMetaAtingida.round();

  factory FaxitaPredictiveAnalysisResult.semBase({
    required String criterioComparacao,
  }) {
    return FaxitaPredictiveAnalysisResult(
      totalAcoesAnalisadas: 0,
      publicoPrevisto: 0,
      publicoMinimoPrevisto: 0,
      publicoMaximoPrevisto: 0,
      veiculosPrevistos: 0,
      probabilidadeMetaAtingida: 0,
      confianca: FaxitaPredictiveConfidence.insuficiente,
      criterioComparacao: criterioComparacao,
      parecer:
          'Ainda não existem ações históricas suficientes para gerar uma previsão operacional segura.',
      recomendacoes: const [
        'Continue registrando os resultados das ações para ampliar a base histórica.',
      ],
    );
  }
}

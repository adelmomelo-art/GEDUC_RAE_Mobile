enum FaxitaHistoricalLevel {
  semBase,
  abaixoDoPadrao,
  dentroDoPadrao,
  acimaDoPadrao,
}

extension FaxitaHistoricalLevelExtension on FaxitaHistoricalLevel {
  String get label {
    switch (this) {
      case FaxitaHistoricalLevel.semBase:
        return 'Base histórica insuficiente';
      case FaxitaHistoricalLevel.abaixoDoPadrao:
        return 'Abaixo do padrão histórico';
      case FaxitaHistoricalLevel.dentroDoPadrao:
        return 'Dentro do padrão histórico';
      case FaxitaHistoricalLevel.acimaDoPadrao:
        return 'Acima do padrão histórico';
    }
  }
}

class FaxitaHistoricalAnalysisResult {
  const FaxitaHistoricalAnalysisResult({
    required this.totalAcoesComparadas,
    required this.mediaPessoasAlcancadas,
    required this.mediaVeiculosAbordados,
    required this.mediaNotaAvaliacao,
    required this.taxaMetaAtingida,
    required this.variacaoPessoasPercentual,
    required this.variacaoVeiculosPercentual,
    required this.nivel,
    required this.parecer,
    required this.criterioComparacao,
  });

  final int totalAcoesComparadas;
  final double mediaPessoasAlcancadas;
  final double mediaVeiculosAbordados;
  final double mediaNotaAvaliacao;
  final double taxaMetaAtingida;
  final double variacaoPessoasPercentual;
  final double variacaoVeiculosPercentual;
  final FaxitaHistoricalLevel nivel;
  final String parecer;
  final String criterioComparacao;

  bool get possuiBaseHistorica => totalAcoesComparadas > 0;
  bool get baseHistoricaConfiavel => totalAcoesComparadas >= 3;
  int get mediaPessoasArredondada => mediaPessoasAlcancadas.round();
  int get mediaVeiculosArredondada => mediaVeiculosAbordados.round();
  int get taxaMetaAtingidaPercentual => taxaMetaAtingida.round();
  int get variacaoPessoasArredondada => variacaoPessoasPercentual.round();
  int get variacaoVeiculosArredondada => variacaoVeiculosPercentual.round();

  factory FaxitaHistoricalAnalysisResult.semBase({
    required String criterioComparacao,
    String parecer =
        'Ainda não há ações históricas suficientes para realizar uma comparação segura.',
  }) {
    return FaxitaHistoricalAnalysisResult(
      totalAcoesComparadas: 0,
      mediaPessoasAlcancadas: 0,
      mediaVeiculosAbordados: 0,
      mediaNotaAvaliacao: 0,
      taxaMetaAtingida: 0,
      variacaoPessoasPercentual: 0,
      variacaoVeiculosPercentual: 0,
      nivel: FaxitaHistoricalLevel.semBase,
      parecer: parecer,
      criterioComparacao: criterioComparacao,
    );
  }
}

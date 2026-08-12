import '../../../data/models/acao_model.dart';

enum CioPeriodoRapido {
  hoje('Hoje'),
  ontem('Ontem'),
  ultimos7Dias('7 dias'),
  ultimos30Dias('30 dias'),
  mesAtual('Mês atual'),
  mesAnterior('Mês anterior'),
  anoAtual('Ano atual'),
  personalizado('Personalizado');

  const CioPeriodoRapido(this.rotulo);
  final String rotulo;
}

enum CioComparacao {
  nenhuma('Sem comparação'),
  periodoAnterior('Período anterior'),
  anoAnterior('Mesmo período no ano anterior');

  const CioComparacao(this.rotulo);
  final String rotulo;
}

class CioDashboardFilters {
  const CioDashboardFilters({
    this.periodo = CioPeriodoRapido.ultimos30Dias,
    this.comparacao = CioComparacao.periodoAnterior,
    this.inicioPersonalizado,
    this.fimPersonalizado,
    this.regional = '',
    this.tipoAcao = '',
    this.status = '',
    this.coordenador = '',
  });

  final CioPeriodoRapido periodo;
  final CioComparacao comparacao;
  final DateTime? inicioPersonalizado;
  final DateTime? fimPersonalizado;
  final String regional;
  final String tipoAcao;
  final String status;
  final String coordenador;

  CioDashboardFilters copyWith({
    CioPeriodoRapido? periodo,
    CioComparacao? comparacao,
    DateTime? inicioPersonalizado,
    DateTime? fimPersonalizado,
    String? regional,
    String? tipoAcao,
    String? status,
    String? coordenador,
    bool limparDatas = false,
  }) =>
      CioDashboardFilters(
        periodo: periodo ?? this.periodo,
        comparacao: comparacao ?? this.comparacao,
        inicioPersonalizado: limparDatas
            ? null
            : inicioPersonalizado ?? this.inicioPersonalizado,
        fimPersonalizado:
            limparDatas ? null : fimPersonalizado ?? this.fimPersonalizado,
        regional: regional ?? this.regional,
        tipoAcao: tipoAcao ?? this.tipoAcao,
        status: status ?? this.status,
        coordenador: coordenador ?? this.coordenador,
      );

  DateTimeRangeCio intervalo(DateTime referencia) {
    final hoje = DateTime(referencia.year, referencia.month, referencia.day);
    switch (periodo) {
      case CioPeriodoRapido.hoje:
        return DateTimeRangeCio(hoje, hoje);
      case CioPeriodoRapido.ontem:
        final ontem = hoje.subtract(const Duration(days: 1));
        return DateTimeRangeCio(ontem, ontem);
      case CioPeriodoRapido.ultimos7Dias:
        return DateTimeRangeCio(hoje.subtract(const Duration(days: 6)), hoje);
      case CioPeriodoRapido.ultimos30Dias:
        return DateTimeRangeCio(hoje.subtract(const Duration(days: 29)), hoje);
      case CioPeriodoRapido.mesAtual:
        return DateTimeRangeCio(DateTime(hoje.year, hoje.month), hoje);
      case CioPeriodoRapido.mesAnterior:
        final fim =
            DateTime(hoje.year, hoje.month).subtract(const Duration(days: 1));
        return DateTimeRangeCio(DateTime(fim.year, fim.month), fim);
      case CioPeriodoRapido.anoAtual:
        return DateTimeRangeCio(DateTime(hoje.year), hoje);
      case CioPeriodoRapido.personalizado:
        return DateTimeRangeCio(
            inicioPersonalizado ?? hoje, fimPersonalizado ?? hoje);
    }
  }

  List<AcaoModel> aplicar(List<AcaoModel> acoes, DateTime referencia) {
    final faixa = intervalo(referencia);
    return aplicarFaixa(acoes, faixa);
  }

  List<AcaoModel> aplicarFaixa(
    List<AcaoModel> acoes,
    DateTimeRangeCio faixa,
  ) {
    return acoes.where((acao) {
      final data =
          DateTime(acao.dataAcao.year, acao.dataAcao.month, acao.dataAcao.day);
      return !data.isBefore(faixa.inicio) &&
          !data.isAfter(faixa.fim) &&
          (regional.isEmpty || acao.regional == regional) &&
          (tipoAcao.isEmpty || acao.tipoAcao == tipoAcao) &&
          (status.isEmpty || acao.status == status) &&
          (coordenador.isEmpty || acao.coordenadorNome == coordenador);
    }).toList(growable: false);
  }

  DateTimeRangeCio? intervaloComparacao(DateTime referencia) {
    if (comparacao == CioComparacao.nenhuma) return null;
    final atual = intervalo(referencia);
    if (comparacao == CioComparacao.anoAnterior) {
      return DateTimeRangeCio(
        _dataValidaAnoAnterior(atual.inicio),
        _dataValidaAnoAnterior(atual.fim),
      );
    }
    final duracao = atual.fim.difference(atual.inicio).inDays + 1;
    final fim = atual.inicio.subtract(const Duration(days: 1));
    return DateTimeRangeCio(fim.subtract(Duration(days: duracao - 1)), fim);
  }

  int get quantidadeFiltrosSecundarios => [
        regional,
        tipoAcao,
        status,
        coordenador
      ].where((e) => e.isNotEmpty).length;

  DateTime _dataValidaAnoAnterior(DateTime data) {
    final ano = data.year - 1;
    final ultimoDia = DateTime(ano, data.month + 1, 0).day;
    return DateTime(
      ano,
      data.month,
      data.day > ultimoDia ? ultimoDia : data.day,
    );
  }
}

class DateTimeRangeCio {
  const DateTimeRangeCio(this.inicio, this.fim);
  final DateTime inicio;
  final DateTime fim;
}

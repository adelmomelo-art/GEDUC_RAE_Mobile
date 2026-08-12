import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/data/models/acao_model.dart';
import 'package:geduc_rae_mobile/modules/dashboard/models/cio_dashboard_filters.dart';

void main() {
  final referencia = DateTime(2026, 8, 12);

  test('últimos 7 dias inclui hoje e seis dias anteriores', () {
    const filtros = CioDashboardFilters(periodo: CioPeriodoRapido.ultimos7Dias);
    final faixa = filtros.intervalo(referencia);
    expect(faixa.inicio, DateTime(2026, 8, 6));
    expect(faixa.fim, DateTime(2026, 8, 12));
  });

  test('aplica período e filtros secundários simultaneamente', () {
    const filtros = CioDashboardFilters(
      periodo: CioPeriodoRapido.ultimos30Dias,
      regional: 'Regional 2',
      tipoAcao: 'Oficina',
      status: 'concluido',
      coordenador: 'Maria',
    );
    final resultado = filtros.aplicar([
      _acao(data: DateTime(2026, 8, 10)),
      _acao(data: DateTime(2026, 6, 10)),
      _acao(data: DateTime(2026, 8, 10), regional: 'Regional 3'),
    ], referencia);
    expect(resultado, hasLength(1));
  });

  test('calcula período anterior com a mesma duração', () {
    const filtros = CioDashboardFilters(
      periodo: CioPeriodoRapido.ultimos7Dias,
      comparacao: CioComparacao.periodoAnterior,
    );
    final faixa = filtros.intervaloComparacao(referencia)!;
    expect(faixa.inicio, DateTime(2026, 7, 30));
    expect(faixa.fim, DateTime(2026, 8, 5));
  });

  test('ontem atravessa corretamente a virada do ano', () {
    const filtros = CioDashboardFilters(periodo: CioPeriodoRapido.ontem);
    final faixa = filtros.intervalo(DateTime(2026, 1, 1));
    expect(faixa.inicio, DateTime(2025, 12, 31));
    expect(faixa.fim, DateTime(2025, 12, 31));
  });

  test('mês anterior considera fevereiro de ano bissexto', () {
    const filtros = CioDashboardFilters(periodo: CioPeriodoRapido.mesAnterior);
    final faixa = filtros.intervalo(DateTime(2024, 3, 15));
    expect(faixa.inicio, DateTime(2024, 2, 1));
    expect(faixa.fim, DateTime(2024, 2, 29));
  });

  test('período personalizado inclui os dois limites', () {
    final filtros = CioDashboardFilters(
      periodo: CioPeriodoRapido.personalizado,
      inicioPersonalizado: DateTime(2026, 8, 10),
      fimPersonalizado: DateTime(2026, 8, 12),
    );
    final resultado = filtros.aplicar([
      _acao(data: DateTime(2026, 8, 9)),
      _acao(data: DateTime(2026, 8, 10)),
      _acao(data: DateTime(2026, 8, 12)),
      _acao(data: DateTime(2026, 8, 13)),
    ], referencia);
    expect(resultado.map((e) => e.dataAcao.day), [10, 12]);
  });

  test('comparação anual normaliza 29 de fevereiro', () {
    final filtros = CioDashboardFilters(
      periodo: CioPeriodoRapido.personalizado,
      comparacao: CioComparacao.anoAnterior,
      inicioPersonalizado: DateTime(2024, 2, 29),
      fimPersonalizado: DateTime(2024, 2, 29),
    );
    final faixa = filtros.intervaloComparacao(DateTime(2024, 2, 29))!;
    expect(faixa.inicio, DateTime(2023, 2, 28));
    expect(faixa.fim, DateTime(2023, 2, 28));
  });

  test('sem comparação não produz faixa comparativa', () {
    const filtros = CioDashboardFilters(comparacao: CioComparacao.nenhuma);
    expect(filtros.intervaloComparacao(referencia), isNull);
  });

  test('resultado vazio é válido para combinação sem correspondência', () {
    const filtros = CioDashboardFilters(
      periodo: CioPeriodoRapido.ultimos30Dias,
      coordenador: 'Coordenador inexistente',
    );
    expect(
      filtros.aplicar([_acao(data: DateTime(2026, 8, 10))], referencia),
      isEmpty,
    );
  });
}

AcaoModel _acao({required DateTime data, String regional = 'Regional 2'}) {
  return AcaoModel.fromMap({
    'id': data.toIso8601String(),
    'dataAcao': data.toIso8601String(),
    'regional': regional,
    'tipoAcao': 'Oficina',
    'status': 'concluido',
    'coordenadorNome': 'Maria',
  });
}

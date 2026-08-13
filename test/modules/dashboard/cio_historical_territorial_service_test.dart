import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/data/models/acao_model.dart';
import 'package:geduc_rae_mobile/modules/dashboard/models/cio_dashboard_filters.dart';
import 'package:geduc_rae_mobile/modules/dashboard/services/cio_historical_territorial_service.dart';

void main() {
  const service = CioHistoricalTerritorialService();

  group('série histórica', () {
    test('completa dias sem registros com zero', () {
      final result = service.buildTimeline(
        [
          _action('1', DateTime(2026, 8, 1), people: 10),
          _action('2', DateTime(2026, 8, 3), people: 20),
        ],
        DateTimeRangeCio(DateTime(2026, 8, 1), DateTime(2026, 8, 3)),
      );

      expect(result.granularity, CioTemporalGranularity.daily);
      expect(result.buckets, hasLength(3));
      expect(result.buckets.map((item) => item.actions), [1, 0, 1]);
      expect(result.buckets.map((item) => item.peopleReached), [10, 0, 20]);
      expect(result.hasEnoughSamples, isTrue);
    });

    test('usa meses até 24 meses e inclui meses vazios', () {
      final result = service.buildTimeline(
        [_action('1', DateTime(2026, 1, 15))],
        DateTimeRangeCio(DateTime(2026, 1, 1), DateTime(2026, 3, 15)),
      );

      expect(result.granularity, CioTemporalGranularity.monthly);
      expect(result.buckets.map((item) => item.label), [
        'Jan/2026',
        'Fev/2026',
        'Mar/2026',
      ]);
      expect(result.buckets.map((item) => item.actions), [1, 0, 0]);
    });

    test('usa anos acima de 24 meses', () {
      final result = service.buildTimeline(
        const <AcaoModel>[],
        DateTimeRangeCio(DateTime(2024, 1, 1), DateTime(2026, 8, 1)),
      );

      expect(result.granularity, CioTemporalGranularity.yearly);
      expect(
          result.buckets.map((item) => item.label), ['2024', '2025', '2026']);
    });

    test('compara janelas equivalentes com limite de estabilidade', () {
      final current = service.buildTimeline(
        [
          _action('1', DateTime(2026, 8, 1), people: 52),
          _action('2', DateTime(2026, 8, 2), people: 53),
        ],
        DateTimeRangeCio(DateTime(2026, 8, 1), DateTime(2026, 8, 3)),
      );
      final previous = service.buildTimeline(
        [_action('3', DateTime(2026, 7, 29), people: 100)],
        DateTimeRangeCio(DateTime(2026, 7, 29), DateTime(2026, 7, 31)),
      );

      final comparison = service.compareTimelines(current, previous);

      expect(comparison.peopleReached.percentageChange, closeTo(5, 0.0001));
      expect(comparison.peopleReached.status, CioTrendStatus.stable);
      expect(comparison.actions.status, CioTrendStatus.growth);
    });

    test('não classifica tendência sem três buckets ou base anterior', () {
      final current = service.buildTimeline(
        [_action('1', DateTime(2026, 8, 1), people: 10)],
        DateTimeRangeCio(DateTime(2026, 8, 1), DateTime(2026, 8, 2)),
      );
      final previous = service.buildTimeline(
        const <AcaoModel>[],
        DateTimeRangeCio(DateTime(2026, 7, 30), DateTime(2026, 7, 31)),
      );

      final comparison = service.compareTimelines(current, previous);

      expect(comparison.peopleReached.percentageChange, isNull);
      expect(
        comparison.peopleReached.status,
        CioTrendStatus.insufficientData,
      );
    });
  });

  group('identidade territorial', () {
    test('agrupa pelo regionalId mesmo com nomes diferentes', () {
      final groups = service.groupTerritories([
        _action('1', DateTime(2026, 8, 1), regionalId: 'ser-01', regional: 'I'),
        _action(
          '2',
          DateTime(2026, 8, 2),
          regionalId: 'ser-01',
          regional: 'Regional 1',
        ),
      ]);

      expect(groups, hasLength(1));
      expect(groups.single.id, 'ser-01');
      expect(groups.single.status, CioTerritorialIdentityStatus.identified);
      expect(groups.single.actions, hasLength(2));
    });

    test('não mistura fallback legado com identidade oficial', () {
      final groups = service.groupTerritories([
        _action('1', DateTime(2026, 8, 1), regionalId: 'ser-01', regional: 'I'),
        _action('2', DateTime(2026, 8, 2), regional: 'I'),
      ]);

      expect(groups, hasLength(2));
      expect(
        groups.map((item) => item.status),
        containsAll([
          CioTerritorialIdentityStatus.identified,
          CioTerritorialIdentityStatus.legacy,
        ]),
      );
    });

    test('agrupa nomes legados equivalentes com e sem diacríticos', () {
      final groups = service.groupTerritories([
        _action('1', DateTime(2026, 8, 1), regional: 'São José'),
        _action('2', DateTime(2026, 8, 2), regional: 'Sao Jose'),
        _action('3', DateTime(2026, 8, 3), regional: 'SÃO-JOSÉ'),
      ]);

      expect(groups, hasLength(1));
      expect(groups.single.id, 'legacy_sao_jose');
      expect(groups.single.actions, hasLength(3));
      expect(groups.single.status, CioTerritorialIdentityStatus.legacy);
    });

    test('mantém nomes territoriais semanticamente diferentes separados', () {
      final groups = service.groupTerritories([
        _action('1', DateTime(2026, 8, 1), regional: 'São José'),
        _action('2', DateTime(2026, 8, 2), regional: 'São João'),
      ]);

      expect(groups, hasLength(2));
      expect(
        groups.map((item) => item.id),
        containsAll(['legacy_sao_jose', 'legacy_sao_joao']),
      );
    });
  });

  test('relatório de qualidade distingue cobertura, legado e não resolvido',
      () {
    final report = service.assessQuality([
      _action(
        '1',
        DateTime(2026, 8, 1),
        regionalId: 'ser-01',
        regional: 'I',
        neighborhood: 'Centro',
        latitude: -3.73,
        longitude: -38.52,
        validated: true,
      ),
      _action('2', DateTime(2026, 8, 2), regional: 'II'),
      _action('3', DateTime(2026, 8, 3)),
    ]);

    expect(report.totalRecords, 3);
    expect(report.regionalIdCoverage, closeTo(1 / 3, 0.0001));
    expect(report.neighborhoodCoverage, closeTo(1 / 3, 0.0001));
    expect(report.validCoordinatesCoverage, closeTo(1 / 3, 0.0001));
    expect(report.validatedLocationCoverage, closeTo(1 / 3, 0.0001));
    expect(report.legacyTerritorialRecords, 1);
    expect(report.unresolvedTerritorialRecords, 1);
    expect(report.firstOccurrence, DateTime(2026, 8, 1));
    expect(report.lastOccurrence, DateTime(2026, 8, 3));
  });
}

AcaoModel _action(
  String id,
  DateTime date, {
  int people = 0,
  String regionalId = '',
  String regional = '',
  String neighborhood = '',
  double latitude = 0,
  double longitude = 0,
  bool validated = false,
}) {
  return AcaoModel.fromMap({
    'id': id,
    'dataAcao': date.toIso8601String(),
    'regionalId': regionalId,
    'regional': regional,
    'bairro': neighborhood,
    'latitude': latitude,
    'longitude': longitude,
    'localizacaoValidada': validated,
    'pessoasAlcancadas': people,
    'veiculosAbordados': people ~/ 2,
    'credenciaisEmitidas': people ~/ 4,
    'status': 'concluido',
  });
}

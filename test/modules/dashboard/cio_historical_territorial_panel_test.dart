import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/data/models/acao_model.dart';
import 'package:geduc_rae_mobile/modules/dashboard/models/cio_dashboard_filters.dart';
import 'package:geduc_rae_mobile/modules/dashboard/services/cio_historical_territorial_service.dart';
import 'package:geduc_rae_mobile/modules/dashboard/widgets/cio_historical_territorial_panel.dart';

void main() {
  const emptyQuality = CioDataQualityReport(
    totalRecords: 0,
    recordsWithRegionalId: 0,
    recordsWithNeighborhood: 0,
    recordsWithValidCoordinates: 0,
    recordsWithValidatedLocation: 0,
    legacyTerritorialRecords: 0,
    unresolvedTerritorialRecords: 0,
    firstOccurrence: null,
    lastOccurrence: null,
  );

  testWidgets('apresenta estado vazio sem fabricar dados', (tester) async {
    await tester.pumpWidget(_app(const CioHistoricalTerritorialPanel(
      timeline: null,
      comparison: null,
      quality: emptyQuality,
      territories: [],
    )));

    expect(find.text('Sem dados para construir a série.'), findsOneWidget);
    expect(find.text('Nenhum RAE no período selecionado.'), findsOneWidget);
    expect(find.text('Com ID regional 0%'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mostra lacunas, qualidade e tendência insuficiente',
      (tester) async {
    final timeline = _timeline();
    const comparison = CioTrendComparison(
      actions: CioTrendMetric(
        current: 2,
        previous: 0,
        absoluteChange: 2,
        percentageChange: null,
        status: CioTrendStatus.insufficientData,
      ),
      peopleReached: _stableMetric,
      vehiclesApproached: _stableMetric,
      credentialsIssued: _stableMetric,
    );
    const quality = CioDataQualityReport(
      totalRecords: 4,
      recordsWithRegionalId: 3,
      recordsWithNeighborhood: 2,
      recordsWithValidCoordinates: 1,
      recordsWithValidatedLocation: 1,
      legacyTerritorialRecords: 1,
      unresolvedTerritorialRecords: 0,
      firstOccurrence: null,
      lastOccurrence: null,
    );

    await tester.pumpWidget(_app(CioHistoricalTerritorialPanel(
      timeline: timeline,
      comparison: comparison,
      quality: quality,
      territories: const [],
    )));

    expect(find.text('Com ID regional 75%'), findsOneWidget);
    expect(find.text('Bairro 50%'), findsOneWidget);
    expect(find.text('Coordenadas 25%'), findsOneWidget);
    expect(find.text('1 legados'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(
      find.text('Tendência: dados insuficientes para classificação'),
      findsOneWidget,
    );
  });

  testWidgets('drilldown territorial revela os RAEs de origem', (tester) async {
    final action = _action();
    final territory = CioTerritorialGroup(
      id: 'ser-01',
      name: 'Regional I',
      status: CioTerritorialIdentityStatus.identified,
      actions: [action],
    );

    await tester.pumpWidget(_app(CioHistoricalTerritorialPanel(
      timeline: _timeline(),
      comparison: null,
      quality: emptyQuality,
      territories: [territory],
    )));

    expect(find.text('RAE 2026-001'), findsNothing);
    await tester.tap(find.text('Regional I'));
    await tester.pumpAndSettle();
    expect(find.text('RAE 2026-001'), findsOneWidget);
    expect(find.textContaining('Centro'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 360.0, 412.0, 800.0]) {
    testWidgets('painel sem overflow em ${width.toInt()} px', (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 1800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_app(SingleChildScrollView(
        child: CioHistoricalTerritorialPanel(
          timeline: _timeline(bucketCount: 30),
          comparison: null,
          quality: emptyQuality,
          territories: [
            CioTerritorialGroup(
              id: 'ser-01',
              name: 'Regional Administrativa I',
              status: CioTerritorialIdentityStatus.identified,
              actions: [_action()],
            ),
          ],
        ),
      )));

      expect(find.text('Histórico e território'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('painel suporta escala de texto 1,3 no A05', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
      child: _app(SingleChildScrollView(
        child: CioHistoricalTerritorialPanel(
          timeline: _timeline(),
          comparison: null,
          quality: emptyQuality,
          territories: const [],
        ),
      )),
    ));

    expect(tester.takeException(), isNull);
  });
}

const _stableMetric = CioTrendMetric(
  current: 0,
  previous: 0,
  absoluteChange: 0,
  percentageChange: 0,
  status: CioTrendStatus.stable,
);

CioTemporalAnalysis _timeline({int bucketCount = 3}) => CioTemporalAnalysis(
      range: DateTimeRangeCio(
        DateTime(2026, 8, 1),
        DateTime(2026, 8, bucketCount),
      ),
      granularity: CioTemporalGranularity.daily,
      buckets: List.generate(
        bucketCount,
        (index) => CioTemporalBucket(
          start: DateTime(2026, 8, index + 1),
          label: '${index + 1}/08',
          actions: index == 1 ? 0 : 1,
          peopleReached: index == 1 ? 0 : 10,
          vehiclesApproached: 0,
          credentialsIssued: 0,
        ),
      ),
    );

AcaoModel _action() => AcaoModel.fromMap({
      'id': 'acao-1',
      'numeroRAE': '2026-001',
      'dataAcao': '2026-08-13T10:00:00.000',
      'regionalId': 'ser-01',
      'regional': 'Regional I',
      'bairro': 'Centro',
      'status': 'concluido',
    });

Widget _app(Widget child) => MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(body: child),
    );

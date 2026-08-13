import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/data/models/acao_model.dart';
import 'package:geduc_rae_mobile/modules/dashboard/services/cio_territorial_governance_service.dart';
import 'package:geduc_rae_mobile/modules/dashboard/widgets/cio_territorial_governance_panel.dart';

void main() {
  testWidgets('mantém mapa bloqueado quando catálogo está indisponível',
      (tester) async {
    await tester.pumpWidget(_app(const CioTerritorialGovernancePanel(
      report: null,
      diagnostic: null,
      catalogUnavailable: true,
    )));

    expect(find.text('Portão de qualidade territorial'), findsOneWidget);
    expect(find.textContaining('mapa permanece bloqueado'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('apresenta cobertura e classificações sem alterar RAEs',
      (tester) async {
    final report = CioTerritorialGovernanceReport(
      catalog: const CioTerritorialCatalogReport(
        totalRegionals: 2,
        activeRegionals: 2,
        inactiveRegionals: 0,
        neighborhoodConflicts: [],
      ),
      validations: [
        _validation('1', CioTerritorialClassification.valid),
        _validation('2', CioTerritorialClassification.orphan),
      ],
    );

    await tester.pumpWidget(_app(CioTerritorialGovernancePanel(
      report: report,
      diagnostic: null,
      catalogUnavailable: false,
    )));

    expect(find.text('Cobertura institucional 50%'), findsOneWidget);
    expect(find.text('Coordenadas utilizáveis 100%'), findsOneWidget);
    expect(find.text('Válidos'), findsOneWidget);
    expect(find.text('Órfãos'), findsOneWidget);
    expect(find.textContaining('Mapa bloqueado'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fila consultiva detalha pendência sem dados pessoais',
      (tester) async {
    final validation = _validation(
      'acao-1',
      CioTerritorialClassification.orphan,
      findings: const {CioTerritorialFinding.unknownRegionalId},
    );
    final report = CioTerritorialGovernanceReport(
      catalog: const CioTerritorialCatalogReport(
        totalRegionals: 1,
        activeRegionals: 1,
        inactiveRegionals: 0,
        neighborhoodConflicts: [],
      ),
      validations: [validation],
    );
    final diagnostic = CioTerritorialDiagnostic(
      start: DateTime(2025, 8, 13),
      end: DateTime(2026, 8, 13),
      report: report,
      sanitationQueue: [
        CioTerritorialSanitationItem(
          actionId: 'acao-1',
          raeNumber: '2026-001',
          occurredAt: DateTime(2026, 8, 13),
          regionalName: 'Regional antiga',
          neighborhood: 'Centro',
          classification: CioTerritorialClassification.orphan,
          findings: const {CioTerritorialFinding.unknownRegionalId},
        ),
      ],
    );

    await tester.pumpWidget(_app(SingleChildScrollView(
      child: CioTerritorialGovernancePanel(
        report: report,
        diagnostic: diagnostic,
        catalogUnavailable: false,
      ),
    )));

    expect(find.text('1 RAEs exigem avaliação.'), findsOneWidget);
    await tester.tap(find.text('RAE 2026-001'));
    await tester.pumpAndSettle();
    expect(find.textContaining('ID regional não existe'), findsOneWidget);
    expect(find.textContaining('coordenador'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 360.0, 412.0, 800.0]) {
    testWidgets('painel consultivo sem overflow em ${width.toInt()} px',
        (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_app(const SingleChildScrollView(
        child: CioTerritorialGovernancePanel(
          report: null,
          diagnostic: null,
          catalogUnavailable: true,
        ),
      )));

      expect(tester.takeException(), isNull);
    });
  }
}

CioTerritorialValidation _validation(
        String id, CioTerritorialClassification classification,
        {Set<CioTerritorialFinding> findings = const {}}) =>
    CioTerritorialValidation(
      action: AcaoModel.fromMap({
        'id': id,
        'dataAcao': '2026-08-13T10:00:00.000',
      }),
      classification: classification,
      findings: findings,
    );

Widget _app(Widget child) => MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(body: child),
    );

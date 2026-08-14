import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/dashboard/models/cio_bi_executive_snapshot.dart';
import 'package:geduc_rae_mobile/modules/dashboard/widgets/cio_bi_executive_panel.dart';

void main() {
  for (final width in [320.0, 360.0, 412.0, 800.0]) {
    testWidgets('seção executiva sem overflow em ${width.toInt()} px',
        (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_app(_panel()));

      expect(tester.takeException(), isNull);
      expect(find.text('Visão executiva'), findsOneWidget);
      expect(find.text('Ações por tipo'), findsOneWidget);
      expect(find.text('66.7%'), findsOneWidget);
      expect(find.text('2 Atingidas'), findsOneWidget);
      expect(find.text('1 Não atingidas'), findsOneWidget);
    });
  }

  testWidgets('estado vazio permanece coerente', (tester) async {
    await tester.pumpWidget(_app(CioBiExecutivePanel(
      snapshot: CioBiExecutiveSnapshot(
        totalActions: 0,
        totalPeople: 0,
        totalVehicles: 0,
        totalCredentials: 0,
        actionsByRegional: const [],
        actionsByType: const [],
        goals: const CioBiGoalsSummary(
          achieved: 0,
          notAchieved: 0,
          achievedPercentage: 0,
        ),
      ),
    )));

    expect(find.textContaining('Nenhuma ação'), findsOneWidget);
    expect(find.textContaining('Nenhuma meta'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

CioBiExecutivePanel _panel() => CioBiExecutivePanel(
      snapshot: CioBiExecutiveSnapshot(
        totalActions: 3,
        totalPeople: 180,
        totalVehicles: 58,
        totalCredentials: 27,
        actionsByRegional: const [],
        actionsByType: const [
          CioBiDistributionItem(
            label: 'Oficina educativa de mobilidade segura',
            count: 2,
            percentage: 66.666,
          ),
          CioBiDistributionItem(
            label: 'Palestra',
            count: 1,
            percentage: 33.333,
          ),
        ],
        goals: const CioBiGoalsSummary(
          achieved: 2,
          notAchieved: 1,
          achievedPercentage: 66.666,
        ),
      ),
    );

Widget _app(Widget child) => MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

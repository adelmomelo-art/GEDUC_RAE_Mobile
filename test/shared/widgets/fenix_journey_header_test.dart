import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/theme/app_theme.dart';
import 'package:geduc_rae_mobile/shared/widgets/journey/fenix_journey_header.dart';
import 'package:geduc_rae_mobile/shared/widgets/layout/fenix_app_bar.dart';

void main() {
  for (final scenario in <({double width, double textScale})>[
    (width: 320, textScale: 1.3),
    (width: 360, textScale: 1.3),
    (width: 412, textScale: 1.3),
    (width: 800, textScale: 1.3),
  ]) {
    testWidgets(
      'cabeçalho da jornada responde em ${scenario.width.toInt()} px',
      (tester) async {
        tester.view.physicalSize = Size(scenario.width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: MediaQuery(
              data: MediaQueryData(
                size: Size(scenario.width, 900),
                textScaler: TextScaler.linear(scenario.textScale),
              ),
              child: const Scaffold(
                body: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: FenixJourneyHeader(
                      step: 3,
                      totalSteps: 9,
                      title: 'Caracterização da Ação',
                      subtitle:
                          'Defina o público, a formação e os focos da atividade.',
                      icon: Icons.fact_check_outlined,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.text('Etapa 3 de 9'), findsOneWidget);
        expect(find.text('Caracterização da Ação'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('AppBar desabilita retorno durante processamento',
      (tester) async {
    var backCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          appBar: FenixAppBar(
            title: 'Localização da Ação',
            onBack: () => backCount++,
            backEnabled: false,
          ),
        ),
      ),
    );

    final button = tester.widget<IconButton>(find.byType(IconButton));
    expect(button.onPressed, isNull);
    expect(backCount, 0);
  });
}

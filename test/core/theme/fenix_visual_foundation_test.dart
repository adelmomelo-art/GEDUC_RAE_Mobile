import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/theme/app_theme.dart';
import 'package:geduc_rae_mobile/core/theme/fenix_visual_tokens.dart';
import 'package:geduc_rae_mobile/modules/home/theme/home_visual_tokens.dart';
import 'package:geduc_rae_mobile/shared/widgets/layout/fenix_page_scaffold.dart';

void main() {
  test('tokens compartilhados preservam exatamente a Home PV-007B', () {
    expect(
      FenixVisualTokens.headerOrangeStart,
      HomeVisualTokens.headerOrangeStart,
    );
    expect(FenixVisualTokens.headerOrangeEnd, HomeVisualTokens.headerOrangeEnd);
    expect(FenixVisualTokens.orange, HomeVisualTokens.orange);
    expect(FenixVisualTokens.teal, HomeVisualTokens.teal);
    expect(FenixVisualTokens.blue, HomeVisualTokens.blue);
    expect(FenixVisualTokens.navy, HomeVisualTokens.navy);
    expect(FenixVisualTokens.canvas, HomeVisualTokens.canvas);
    expect(FenixVisualTokens.contentMaxWidth, HomeVisualTokens.contentMaxWidth);
    expect(
      FenixVisualTokens.headerCompactBreakpoint,
      HomeVisualTokens.headerCompactBreakpoint,
    );
  });

  test('tema global usa o contrato visual compartilhado', () {
    final theme = AppTheme.lightTheme;

    expect(theme.scaffoldBackgroundColor, FenixVisualTokens.canvas);
    expect(theme.colorScheme.primary, FenixVisualTokens.teal);
    expect(theme.colorScheme.secondary, FenixVisualTokens.orange);
    expect(theme.colorScheme.tertiary, FenixVisualTokens.blue);
    expect(theme.colorScheme.error, FenixVisualTokens.danger);
    expect(theme.appBarTheme.backgroundColor, FenixVisualTokens.navy);
  });

  for (final width in [320.0, 360.0, 412.0, 800.0]) {
    testWidgets('shell não apresenta overflow em ${width.toInt()} px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(width, 900),
              textScaler: const TextScaler.linear(1.3),
            ),
            child: FenixPageScaffold(
              body: SizedBox(
                key: const Key('content'),
                width: width * 2,
                child: const Text('Conteúdo responsivo da Plataforma Fênix'),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byKey(const Key('content'))).width,
        lessThanOrEqualTo(width),
      );
    });
  }

  testWidgets('shell limita conteúdo em telas amplas', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FenixPageScaffold(body: Container(key: const Key('content'))),
      ),
    );

    expect(
      tester.getSize(find.byKey(const Key('content'))).width,
      lessThanOrEqualTo(FenixVisualTokens.contentMaxWidth),
    );
  });
}

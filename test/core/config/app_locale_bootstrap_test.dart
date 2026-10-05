import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:geduc_rae_mobile/core/config/app_locale_bootstrap.dart';

void main() {
  testWidgets('entrada inicializada renderiza mês da agenda em português',
      (tester) async {
    await AppLocaleBootstrap.initialize();
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Text(
      DateFormat('MMMM yyyy', 'pt_BR').format(DateTime(2026, 10, 4)),
    ))));
    expect(find.text('outubro 2026'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  test('inicialização repetida preserva locale padrão e formatação', () async {
    final initial = Intl.defaultLocale;
    await AppLocaleBootstrap.initialize();
    await AppLocaleBootstrap.initialize();
    expect(Intl.defaultLocale, initial);
    expect(
        Intl.withLocale(
            'pt_BR', () => DateFormat.yMMMMd().format(DateTime(2026, 10, 4))),
        '4 de outubro de 2026');
  });
}

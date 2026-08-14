import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/navigation/safe_route_transition.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('serializa dois retornos disparados no mesmo frame',
      (tester) async {
    var beforeNavigationCalls = 0;
    final guard = SafeRouteTransition();
    final router = GoRouter(
      initialLocation: '/caracterizacao',
      routes: [
        GoRoute(
          path: '/caracterizacao',
          builder: (context, state) => Scaffold(
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () {
                  guard.goAfterFrame(
                    context,
                    '/localizacao',
                    beforeNavigation: () => beforeNavigationCalls++,
                  );
                },
                child: const Text('Voltar'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/localizacao',
          builder: (context, state) => const Scaffold(
            body: Text('Localização'),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    button.onPressed!();
    button.onPressed!();

    expect(guard.isScheduled, isTrue);
    expect(beforeNavigationCalls, 1);

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Localização'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('remove o foco antes de trocar a rota', (tester) async {
    final guard = SafeRouteTransition();
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    final router = GoRouter(
      initialLocation: '/caracterizacao',
      routes: [
        GoRoute(
          path: '/caracterizacao',
          builder: (context, state) => Scaffold(
            body: Column(
              children: [
                TextField(focusNode: focusNode),
                Builder(
                  builder: (context) => FilledButton(
                    onPressed: () =>
                        guard.goAfterFrame(context, '/localizacao'),
                    child: const Text('Voltar'),
                  ),
                ),
              ],
            ),
          ),
        ),
        GoRoute(
          path: '/localizacao',
          builder: (context, state) => const Scaffold(
            body: Text('Localização'),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    focusNode.requestFocus();
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    await tester.tap(find.text('Voltar'));

    expect(focusNode.hasFocus, isFalse);
    await tester.pumpAndSettle();
    expect(find.text('Localização'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

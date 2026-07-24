import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/analytics/dashboard_definition.dart';
import 'package:geduc_rae_mobile/core/analytics/dashboard_registry.dart';

/// Valida o estado estrutural básico de um [DashboardRegistry].
void expectRegistryState(
  DashboardRegistry registry, {
  required int count,
  required bool isEmpty,
  required bool isNotEmpty,
}) {
  expect(registry.count, count);
  expect(registry.isEmpty, isEmpty);
  expect(registry.isNotEmpty, isNotEmpty);
  expect(registry.all().length, count);
}

/// Valida se o Registry está completamente vazio.
void expectRegistryEmpty(DashboardRegistry registry) {
  expectRegistryState(
    registry,
    count: 0,
    isEmpty: true,
    isNotEmpty: false,
  );

  expect(registry.all(), isEmpty);
  expect(registry.enabled(), isEmpty);
}

/// Valida se todas as definições esperadas estão registradas.
void expectRegistryContainsAll(
  DashboardRegistry registry,
  Iterable<DashboardDefinition> definitions,
) {
  final expected = definitions.toList(growable: false);

  expect(registry.count, expected.length);

  for (final definition in expected) {
    expect(
      registry.contains(definition.id),
      isTrue,
      reason:
          'O dashboard "${definition.id}" deveria estar registrado.',
    );

    expect(
      registry.find(definition.id),
      same(definition),
      reason:
          'O Registry deveria devolver a mesma definição registrada.',
    );
  }
}

/// Valida a ordem dos identificadores devolvidos pelo Registry.
void expectRegistryOrder(
  DashboardRegistry registry,
  Iterable<String> expectedIds,
) {
  final actualIds = registry
      .all()
      .map((definition) => definition.id)
      .toList(growable: false);

  expect(actualIds, expectedIds.toList(growable: false));
}

/// Valida que uma lista devolvida pelo Registry é imutável.
void expectUnmodifiableDashboardList(
  List<DashboardDefinition> definitions,
  DashboardDefinition sample,
) {
  expect(
    () => definitions.add(sample),
    throwsUnsupportedError,
  );

  if (definitions.isNotEmpty) {
    expect(
      () => definitions.removeAt(0),
      throwsUnsupportedError,
    );

    expect(
      () => definitions.clear(),
      throwsUnsupportedError,
    );
  }
}
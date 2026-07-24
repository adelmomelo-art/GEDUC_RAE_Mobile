OE-003.7.0 — Revision B
AnalyticsIntegrationFixture

SUBSTITUI integralmente as versões anteriores da OE-003.7.0.

Decisão técnica:
- Manter `dimensions` com o contrato atual do Core Analytics.
- Não alterar `AnalyticsRecord` nesta etapa.
- Validar explicitamente que as dimensões operacionais usadas pela fixture
  são do tipo String e não estão vazias.
- Concentrar a correção no teste, sem introduzir mudança arquitetural fora
  do escopo da OE.

Arquivos:

test/
├── fixtures/
│   └── analytics_integration_fixture.dart
└── core/
    └── analytics/
        └── integration/
            └── analytics_integration_fixture_contract_test.dart

Excluir versões antigas:
- test/core/analytics/integration/analytics_integration_fixture_test.dart

Substituir:
- test/core/analytics/integration/analytics_integration_fixture_contract_test.dart
- test/fixtures/analytics_integration_fixture.dart

Validação:

flutter test test/core/analytics/integration/analytics_integration_fixture_contract_test.dart
flutter test test/core/analytics/
flutter analyze

A OE somente poderá ser homologada após os três comandos concluírem sem erros.

OE-003.7.1 — Full Flow Integration — Revision A
Plataforma Fênix — Core Analytics

SUBSTITUI integralmente a primeira versão da OE-003.7.1.

DECISÕES DA REVISION A

1. Atualização do contrato de versão do AnalyticsEngine:
   - versão esperada: 2.0.0.

2. Remoção da suposição fixa de 100 resultados no teste de volume:
   - os registros elegíveis são calculados diretamente da massa;
   - a ordenação esperada é reproduzida independentemente;
   - o limite é aplicado sobre os registros realmente elegíveis;
   - registros processados, ignorados, métricas e eficiência são derivados
     da massa real.

3. Preservação da separação arquitetural:
   - OE-003.7.1 valida o fluxo integrado;
   - OE-003.7.2 congelará números institucionais e contratos de regressão.

ARQUIVOS

test/core/analytics/integration/
├── analytics_engine_full_flow_test.dart
└── analytics_engine_real_scenarios_test.dart

VALIDAÇÃO

flutter test test/core/analytics/integration/analytics_engine_full_flow_test.dart
flutter test test/core/analytics/integration/analytics_engine_real_scenarios_test.dart
flutter test test/core/analytics/
flutter analyze

A OE somente será homologada após os quatro comandos concluírem sem erros.

OE-003.7.1 — Full Flow Integration
Plataforma Fênix — Core Analytics

OBJETIVO

Validar o fluxo integrado do AnalyticsEngine utilizando a
AnalyticsIntegrationFixture homologada na OE-003.7.0 Revision B.

ARQUIVOS

test/core/analytics/integration/
├── analytics_engine_full_flow_test.dart
└── analytics_engine_real_scenarios_test.dart

ESCOPO

analytics_engine_full_flow_test.dart
- processamento integral da massa oficial;
- filtro vazio;
- combinação domínio + status + período + dimensões;
- inclusão das datas-limite;
- sequência seleção → ordenação → limite;
- contabilização de ignorados;
- resultado vazio;
- Iterable preguiçoso;
- preservação da fonte;
- rastreabilidade do filtro;
- determinismo;
- massa de volume.

analytics_engine_real_scenarios_test.dart
- Educação em julho/2026;
- Regional VI no turno da manhã;
- AMC nas Escolas;
- comandos educativos;
- ações noturnas;
- RPAS;
- fiscalização;
- planejadas;
- canceladas;
- ranking por público;
- ranking por avaliação;
- primeiro semestre;
- Regional VI multidomínio;
- dados parciais.

OBSERVAÇÃO

Esta OE ainda não congela números institucionais como contrato de regressão.
Os resultados esperados são calculados independentemente a partir dos
subconjuntos selecionados da fixture. Os números fixos serão responsabilidade
da OE-003.7.2, no arquivo analytics_engine_regression_test.dart.

VALIDAÇÃO

flutter test test/core/analytics/integration/analytics_engine_full_flow_test.dart
flutter test test/core/analytics/integration/analytics_engine_real_scenarios_test.dart
flutter test test/core/analytics/
flutter analyze

A OE somente será homologada após todos os comandos concluírem sem erros.

# ESC-001H.3 — UI histórica e indicadores de horas

Esta etapa adiciona à Escala GEDUC a tela de histórico operacional de horas.

## Entregas

- rota protegida para o histórico;
- acesso direto pela tela diária da escala;
- período inclusivo com limite de 366 dias;
- visão geral para administrador, gestor e gerente;
- visão própria obrigatória para coordenador e agente;
- cartões de horas planejadas, realizadas, normais, extras e banco de horas;
- saldo consolidado geral e por pessoa;
- pendências explícitas;
- estados de carregamento, vazio, erro e nova tentativa;
- testes de UI e regressão da tela diária.

## Limites

- nenhuma escrita no Firestore;
- nenhuma alteração em regras ou índices;
- nenhum valor financeiro;
- nenhuma pontuação, ranking ou avaliação;
- Faixita e produtividade permanecem para etapa posterior;
- nenhum deploy Firebase.

## Validação esperada

```powershell
flutter test test/modules/escala/pages/escala_historico_page_test.dart
flutter test test/modules/escala/pages/escala_page_test.dart
flutter test
flutter analyze
npm run test:rules
```

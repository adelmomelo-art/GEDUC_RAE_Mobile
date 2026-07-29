# CE-032C.3B.2 — Integração do Rule Engine

## Objetivo

Integrar o Rule Engine homologado na CE-032C.3B.1 ao Centro de Operações,
mantendo separados:

- telemetria operacional;
- inteligência derivada;
- estado da aplicação;
- apresentação visual.

## Arquivos substituídos

1. `lib/core/services/sync_service.dart`
2. `lib/modules/home/controllers/home_controller.dart`
3. `lib/modules/home/models/home_operational_status.dart`
4. `lib/modules/home/models/home_state.dart`
5. `lib/modules/home/widgets/status_widget.dart`

## Decisões arquiteturais

- `HomeOperationalStatus` continua armazenando apenas telemetria.
- `HomeState` passa a armazenar `List<OperationalAlert>`.
- `HomeController` monta o `OperationalRuleContext`.
- `OperationalRuleEngine` é executado centralmente antes da emissão do estado.
- `SyncService` registra falhas consecutivas de sincronização.
- `StatusWidget` exibe os alertas ordenados por prioridade.

## Instalação

Copie os cinco arquivos para os respectivos caminhos, substituindo os atuais.

Não é necessário substituir:

- `home_page.dart`;
- os arquivos da pasta `lib/modules/home/domain/`;
- as regras individuais da CE-032C.3B.1.

## Validação técnica

Execute:

```powershell
dart format lib/core/services/sync_service.dart lib/modules/home/controllers/home_controller.dart lib/modules/home/models/home_operational_status.dart lib/modules/home/models/home_state.dart lib/modules/home/widgets/status_widget.dart

flutter analyze
```

## Validação funcional sugerida

1. Abrir a Home com conexão.
2. Confirmar a seção `Alertas inteligentes`.
3. Confirmar que alertas informativos, de atenção e críticos usam níveis distintos.
4. Desativar a conexão e retornar à Home.
5. Confirmar alerta de operação offline.
6. Criar ou manter registros pendentes e confirmar alerta de sincronização.
7. Restabelecer a conexão.
8. Confirmar sincronização automática.
9. Confirmar que uma sincronização bem-sucedida zera as falhas consecutivas.
10. Confirmar que os seis cards de monitoramento continuam funcionando.

## Resultado esperado

```text
flutter analyze
No issues found!
```

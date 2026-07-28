# CE-032C.2B — Sincronização Inteligente do Dashboard

## Objetivo

Atualizar automaticamente o Centro de Operação quando a conectividade retornar, sem bloquear a interface e sem descartar os dados persistidos pela CE-032C.2A.

## Arquivos do pacote

- `lib/core/services/sync_service.dart`
- `lib/modules/home/controllers/home_controller.dart`
- `lib/modules/home/services/home_loader_service.dart`
- `lib/modules/home/models/home_state.dart`

## Decisões arquiteturais

1. O `SyncService` continua sendo o único responsável pela conectividade e pela sincronização das ações pendentes.
2. Não foi criado um segundo serviço de sincronização para o módulo Home.
3. O `HomeController` observa somente eventos reais de reconexão.
4. A atualização automática ocorre em segundo plano, preservando os indicadores já exibidos.
5. Há proteção contra sincronizações simultâneas e eventos repetidos em intervalo inferior a 20 segundos.
6. Após a sincronização das pendências, o dashboard é recarregado do Firebase e o cache persistente é renovado.
7. O pacote utiliza `connectivity_plus`, dependência que já existe no `pubspec.yaml` do projeto.

## Instalação

Substitua integralmente os quatro arquivos deste pacote nos respectivos caminhos do projeto.

Não é necessário alterar o `pubspec.yaml`.

## Validação técnica

Execute:

```powershell
dart format lib/core/services/sync_service.dart lib/modules/home
flutter analyze
```

## Homologação funcional proposta

1. Abrir o Centro de Operação com internet.
2. Desativar a conexão sem fechar o aplicativo.
3. Confirmar que os dados existentes permanecem visíveis.
4. Criar ou manter uma ação pendente em modo offline, quando aplicável.
5. Reativar a conexão.
6. Aguardar alguns segundos sem pressionar o botão de atualização.
7. Confirmar que as ações pendentes foram sincronizadas.
8. Confirmar que os indicadores e últimos RAEs foram atualizados automaticamente.
9. Fechar o aplicativo, abrir offline e confirmar que o cache atualizado foi preservado.
10. Executar `flutter analyze` e confirmar `No issues found!`.

## Observação

O `connectivity_plus` informa disponibilidade de rede. A confirmação efetiva de acesso ao servidor continua sendo feita pelas consultas ao Firebase. Em caso de falha, o dashboard preserva os dados anteriores e não bloqueia a operação.

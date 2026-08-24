# AUD-L2-R5.5-E — Retry, Backoff, Connectivity e Reconciliacao

## Objetivo

Adicionar a politica controlada de novas tentativas para evidencias sem mover
retry para o transporte e sem criar novas identidades remotas quando o efeito
do upload anterior pode ter ocorrido.

## Responsabilidades

R5.5-E introduz:

- gate de conectividade antes de solicitar grant;
- backoff exponencial deterministico;
- limite maximo de tentativas;
- classificacao entre falhas retryable e nao retryable;
- estado `retryScheduled`;
- estado `blocked`;
- persistencia de `reconciliationObjectKey`;
- exigencia de estabilidade do `objectKey` entre tentativas de reconciliacao.

## Conectividade

`connectivity_plus` e usado apenas como sinal de disponibilidade de rede.

Ele nao prova acesso efetivo a Internet. Por isso:

- sem interface de rede: nenhuma tentativa e contada;
- com interface de rede: a tentativa pode prosseguir;
- a classificacao real de falha continua pertencendo ao transporte.

## Backoff

Politica inicial:

- tentativa 1: 30 s;
- tentativa 2: 60 s;
- tentativa 3: 120 s;
- crescimento exponencial;
- teto: 30 min;
- limite padrao: 6 tentativas.

Nao ha jitter nesta etapa. O cliente mobile opera uma fila local por dispositivo
e a previsibilidade facilita auditoria e teste. Jitter pode ser introduzido
posteriormente se houver evidencia operacional de efeito manada.

## Reconciliacao pos-efeito remoto

Uma falha de timeout/transport pode ocorrer depois que o servidor recebeu o PUT.

Tambem pode haver sucesso remoto seguido de falha na persistencia local.

Para evitar duplicacao:

1. a nova tentativa preserva `reconciliationObjectKey`, sempre originada do
   grant confiavel;
2. um novo grant e solicitado normalmente;
3. antes de qualquer novo upload, o novo grant deve devolver exatamente a mesma
   chave;
4. se a chave mudar, o job e bloqueado antes do transporte;
5. se a chave for a mesma, o PUT pode ser repetido sobre a mesma identidade
   remota e o mesmo snapshot SHA.

`reconciliationObjectKey` nao significa sucesso remoto confirmado. O campo
`objectKey` continua exclusivo do estado `synced`.

## Falhas

- `RemoteEvidenceUploadException.retryCandidate == true`:
  agenda retry e preserva a chave confiavel;
- falha HTTP nao retryable:
  bloqueia;
- falha de persistencia depois de sucesso remoto:
  agenda retry/reconciliacao;
- divergencia de resultado remoto:
  bloqueia preservando a chave confiavel;
- job desaparecido ou alterado concorrentemente:
  falha fechado sem sobrescrever o estado atual.

## Fronteiras preservadas

R5.5-E nao:

- executa retry dentro de `RemoteEvidenceTransport`;
- decide ACL;
- fabrica grant;
- fabrica `objectKey`;
- altera `SyncService`;
- implementa Worker/R2/B2 reais;
- implementa download/DELETE;
- cria lock distribuido;
- remove a evidencia local apos sync.

## Baseline

`57767c55d16e9dd8a02945d60df3c320f83e3e78`

Status: HOMOLOGADO LOCALMENTE — NAO COMMITADO / NAO PUBLICADO.

## Ajustes de validacao

### R1 — const-evaluation

O construtor `EvidenceSyncRetryPolicy` deixou de ser `const` porque as
comparacoes entre `Duration` usadas nos asserts nao sao validas em constant
evaluation no Dart.

A correcao preservou os mesmos invariantes de validacao em runtime.

### R2 — regressao R5.5-D

Os testes legados do `EvidenceSyncUploadCoordinator` foram alinhados ao novo
contrato tipado de confirmacao.

Passaram a validar explicitamente:

- `EvidenceSyncConfirmationFailure.objectKeyMismatch`;
- `EvidenceSyncConfirmationFailure.sizeMismatch`;
- `EvidenceSyncConfirmationFailure.jobChanged`.

A mudanca fortalece a regressao e evita retornar a excecoes genericas.

## Validacao final

- teste legado R5.5-D: aprovado;
- teste focado R5.5-E: aprovado;
- regressao `test/core/sync`: aprovada;
- `flutter analyze`: 0 issues;
- `git diff --check`: aprovado;
- escopo Git: exatamente 11 caminhos.

## Invariantes homologados

1. sem rede nao solicita grant e nao incrementa tentativa;
2. transporte continua com uma unica tentativa por chamada;
3. falha retryable incrementa `attemptCount`;
4. retryable agenda `nextAttemptAt`;
5. backoff inicial: 30 s, 60 s, 120 s, exponencial;
6. teto de backoff: 30 min;
7. limite padrao: 6 tentativas;
8. falha nao retryable vai para `blocked`;
9. `reconciliationObjectKey` vem somente de grant confiavel;
10. novo grant divergente da chave de reconciliacao bloqueia antes do upload;
11. retry com a mesma chave pode reconciliar a mesma identidade remota;
12. `objectKey` final continua exclusivo de `synced`;
13. falha de persistencia depois de efeito remoto e tipada;
14. conflito concorrente nao sobrescreve o snapshot atual;
15. `connectivity_plus` e apenas gate de interface de rede, nao prova Internet;
16. nenhuma credencial permanente foi introduzida;
17. nenhum retry foi movido para o transporte;
18. `SyncService` continua sem receber a logica de evidencias nesta etapa.

## Riscos e limites conhecidos

- nao existe transacao atomica entre efeito remoto e persistencia local;
- nao existe claim/lock distribuido;
- nao existe jitter no backoff;
- `connectivity_plus` nao comprova Internet funcional;
- a idempotencia remota depende da estabilidade do `objectKey` confiavel e do
  mesmo snapshot SHA;
- backend/Worker real ainda devera fazer a validacao autoritativa de ACL e
  definir a chave final;
- R2/B2 reais continuam fora deste gate.

## Parecer

AUD-L2-R5.5-E: **HOMOLOGADO LOCALMENTE**.

A fila de evidencias passa a possuir uma politica explicita de resiliencia:
conectividade como gate antecipado, retry controlado, backoff, limite de
tentativas, bloqueio de falhas definitivas e reconciliacao da janela de efeito
remoto incerto sem criar arbitrariamente uma nova identidade de objeto.

O proximo gate deve tratar o fechamento de integracao/idempotencia e o desenho
final de reconciliacao antes da introducao do backend remoto real.

# AUD-L2-R5.5-A — Durable Evidence Sync Queue

## Objetivo

Criar a fundacao persistente e provider-neutral para sincronizacao de
evidencias antes de integrar upload remoto ao `SyncService`.

## Problema encontrado

O `OfflineService` atual persiste RAEs pendentes, mas o
`EvidenciaStorageService` mantem as evidencias ricas em memoria.

Ligar upload remoto diretamente ao `SyncService` sem uma fila duravel permitiria
perder estado de sincronizacao apos reinicio do processo.

## Decisao

R5.5-A cria uma fila persistente separada para evidencias.

Ela nao substitui a fila de RAEs e nao executa rede.

O job persiste somente o snapshot necessario para futuras tentativas:

- `acaoId`;
- `evidenciaId`;
- caminho local;
- MIME;
- tamanho;
- SHA-256;
- autor canonico;
- estado;
- numero de tentativas;
- timestamps de tentativa/retry;
- `objectKey` e `syncedAt` quando confirmados futuramente.

## Estados

- `pending`;
- `retryScheduled`;
- `synced`;
- `blocked`.

Estados incoerentes falham fechado.

## Persistencia

Implementacao inicial:

`SharedPreferencesEvidenceSyncStore`

A estrutura usa JSON versionado por chave `evidence_sync_queue_v1`.

Operacoes read-modify-write sao serializadas dentro do store para impedir perda
de jobs por intercalacao assincorna.

Fila corrompida nao e descartada automaticamente.

## Fora do escopo

- upload;
- EvidenceAccessBroker real;
- HTTP real;
- retry/backoff;
- conectividade;
- Worker/backend;
- Cloudflare R2/B2;
- alteracao do SyncService;
- alteracao do EvidenciaStorageService;
- credenciais no APK.

## Baseline

`b9bfe53640e9417f236e9c9b4ef913e1d79f1e93`

Status: HOMOLOGADO LOCALMENTE — NÃO COMMITADO / NÃO PUBLICADO.

## Validacao final

- teste focado R5.5-A: aprovado;
- regressao `test/core/sync`: aprovada;
- `flutter analyze`: 0 issues;
- `git diff --check`: aprovado;
- escopo Git: exatamente 7 caminhos;
- contrato `Future<void>` do `salvar()` corrigido no R5.5-A-R1;
- regra fail-closed preservada;
- persistencia separada da fila de RAE;
- nenhuma rede ou upload introduzido;
- nenhuma dependencia de R2/B2;
- nenhuma credencial no APK.

## Gate oficial para R5.5-B

R5.5-B pode introduzir o orquestrador de sincronizacao que consome
`EvidenceSyncStore`, `EvidenceAccessBroker` e `RemoteEvidenceTransport`.

Continuam fora do orquestrador:

- assinatura de URL;
- credenciais permanentes;
- ACL autoritativa;
- fabricacao arbitraria de `objectKey`;
- retry automatico dentro do transport;
- dependencia obrigatoria de Cloudflare R2 ou Backblaze B2.

O estado local da evidencia deve continuar sendo a fonte operacional ate
confirmacao remota explicita.

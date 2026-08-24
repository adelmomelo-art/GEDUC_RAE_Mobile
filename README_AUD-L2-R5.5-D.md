# AUD-L2-R5.5-D — Evidence Upload + Persisted Confirmation

## Objetivo

Consumir `EvidenceSyncGrantPreparation`, executar exatamente uma tentativa no
`RemoteEvidenceTransport` e confirmar o sucesso na fila duravel apenas depois
de resposta remota coerente.

## Fluxo

1. recebe `job + grant`;
2. exige transporte habilitado;
3. valida que o job esta em `pending` ou `retryScheduled`;
4. valida novamente o grant no instante da tentativa;
5. monta `RemoteEvidenceUploadRequest`;
6. executa exatamente uma chamada a `upload`;
7. exige `objectKey` do resultado igual ao `objectKey` autorizado no grant;
8. valida `sizeBytes` quando presente;
9. relê o job persistido;
10. recusa overwrite se o snapshot mudou;
11. persiste `status=synced`, `objectKey`, `syncedAt`, `lastAttemptAt` e incremento
    de `attemptCount`.

## Regra central

Sucesso remoto nao e inferido pelo cliente.

O job somente se torna `synced` depois que o transporte devolve
`RemoteEvidenceUploadResult` coerente e o snapshot local continua sendo a mesma
versao que originou o upload.

## Protecao de autoridade

O cliente nao deriva `objectKey` da URL.

O valor persistido deve ser o mesmo `objectKey` autorizado pelo grant confiavel
e confirmado pelo transporte.

## Concorrencia

A confirmacao faz uma releitura antes do `salvar`.

Se o job mudou durante o upload, o coordenador falha fechado e nao sobrescreve
o estado mais novo.

Esta etapa nao cria mecanismo de claim/lock distribuido. Esse problema continua
fora do escopo da fila atual e deve ser tratado antes de paralelismo real de
uploads.

## Falha apos efeito remoto

Existe uma janela inevitavel entre o sucesso remoto e a persistencia local.

Se `salvar` falhar nessa janela, a fila pode continuar pendente mesmo com o
objeto ja existente remotamente. O R5.5-E/F deve tratar a repeticao como
reconciliacao/idempotencia sobre o mesmo `objectKey` e o mesmo snapshot SHA,
nunca como criacao arbitraria de uma nova chave.

## Fora do escopo

- retry automatico;
- backoff;
- conectividade;
- renovacao automatica de grant;
- claim/lock multi-worker;
- download;
- DELETE;
- Worker/backend real;
- R2/B2 real;
- alteracao do `SyncService`.

## Baseline

`6ea5aaae6cf46734ae559af91448a4b6f2e71936`

Status: HOMOLOGADO LOCALMENTE — NAO COMMITADO / NAO PUBLICADO.

## Validacao final

- teste focado R5.5-D: aprovado;
- regressao `test/core/sync`: aprovada;
- `flutter analyze`: 0 issues;
- `git diff --check`: aprovado;
- escopo Git: exatamente 5 caminhos;
- uma unica chamada de transporte por execucao;
- `synced` persistido somente apos sucesso confirmado;
- `objectKey` do resultado igual ao grant confiavel;
- `sizeBytes` validado quando informado;
- job relido antes da confirmacao;
- overwrite recusado quando o snapshot mudou;
- falha do transporte nao confirma a fila;
- nenhum retry/backoff automatico introduzido;
- nenhuma credencial permanente introduzida.

## Parecer

AUD-L2-R5.5-D: **HOMOLOGADO LOCALMENTE**.

A primeira tentativa controlada de sincronizacao de evidencia agora cobre a
transferencia e a confirmacao duravel de sucesso, preservando a separacao entre
transporte e politica de retry.

R5.5-E fica reservado para retry/backoff/conectividade e deve tratar falhas sem
duplicar arbitrariamente o objeto remoto, preservando a mesma identidade de
evidencia, `objectKey` confiavel e snapshot SHA.

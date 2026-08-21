# AUD-L2-R5.5-B — Evidence Sync Queue Orchestrator

## Objetivo

Criar a camada de orquestracao que decide quais jobs persistidos pelo R5.5-A
estao aptos a serem considerados por uma tentativa de sincronizacao.

## Decisao arquitetural

R5.5-B e deliberadamente uma etapa sem rede.

O orquestrador:

- le `EvidenceSyncStore`;
- valida a fila em modo fail-closed;
- considera `pending` imediatamente elegivel;
- considera `retryScheduled` apenas quando `nextAttemptAt <= agora`;
- exclui `synced` e `blocked`;
- devolve candidatos em ordem deterministica;
- nao altera a fila durante a selecao.

A ordem canonica e:

1. `createdAt`;
2. `acaoId`;
3. `evidenciaId`.

## Por que nao fazer upload aqui

Misturar selecao de fila, emissao de grant e transferencia HTTP nesta etapa
criaria um salto arquitetural desnecessario.

A sequencia controlada permanece:

- R5.5-A: persistencia duravel;
- R5.5-B: selecao/orquestracao da fila;
- R5.5-C: aquisicao de grant via broker;
- R5.5-D: tentativa de upload + confirmacao persistida;
- R5.5-E: retry/backoff/conectividade;
- R5.5-F: fechamento de integracao.

## Fronteiras preservadas

R5.5-B nao:

- decide ACL;
- usa `autorUserId` como autorizacao;
- fabrica `objectKey`;
- solicita URL assinada;
- executa HTTP;
- executa upload;
- calcula backoff;
- altera `SyncService`;
- introduz R2/B2;
- introduz credenciais no APK.

## Baseline

`bd55ba7f8df7d177a4e684c91c322e8ac6c063e0`

Status: HOMOLOGADO LOCALMENTE — NAO COMMITADO / NAO PUBLICADO.

## Validacao final

- teste focado R5.5-B: aprovado;
- regressao `test/core/sync`: aprovada;
- `flutter analyze`: 0 issues;
- `git diff --check`: aprovado;
- escopo Git: exatamente 5 caminhos;
- selecao sem side effects confirmada;
- ordem deterministica confirmada;
- fila invalida falha fechado;
- nenhum grant solicitado;
- nenhum upload executado;
- nenhuma credencial introduzida.

## Parecer

AUD-L2-R5.5-B: **HOMOLOGADO LOCALMENTE**.

O orquestrador de selecao da fila esta pronto para ser consumido pelo R5.5-C,
que podera introduzir a solicitacao de grant de upload via
`EvidenceAccessBroker`, sem transferir autoridade de ACL para o cliente.

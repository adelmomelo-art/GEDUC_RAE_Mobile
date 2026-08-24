# AUD-L2-R5.5-C — Evidence Grant Acquisition

## Objetivo

Consumir o proximo candidato elegivel do R5.5-B e solicitar ao
`EvidenceAccessBroker` um grant temporario de upload.

## Responsabilidade

O coordenador desta etapa:

1. obtem o proximo candidato do `EvidenceSyncOrchestrator`;
2. retorna `null` quando nao ha trabalho;
3. exige broker habilitado quando existe candidato;
4. monta `EvidenceUploadAccessRequest` a partir do snapshot persistido;
5. solicita exatamente um grant de upload;
6. valida operacao, HTTPS, host, expiracao e `objectKey`;
7. retorna `EvidenceSyncGrantPreparation(job + grant)` apenas em memoria.

## Fronteira de confianca

O cliente nao decide ACL.

O `objectKey` aceito vem exclusivamente do grant emitido pelo broker confiavel.

`autorUserId` nao participa da autorizacao.

O grant nao deve ser persistido porque funciona como credencial bearer
temporaria.

## Fora do escopo

- transporte HTTP;
- upload do arquivo;
- persistencia de `objectKey`;
- marcacao de `syncedAt`;
- retry/backoff;
- conectividade;
- renovacao de grant;
- backend/Worker real;
- R2/B2;
- credenciais permanentes no APK;
- alteracao do `SyncService`.

## Sequencia

- R5.5-A: fila duravel;
- R5.5-B: selecao de candidatos;
- R5.5-C: aquisicao e validacao de grant;
- R5.5-D: upload + confirmacao persistida;
- R5.5-E: retry/backoff/conectividade;
- R5.5-F: fechamento.

## Baseline

`d92200e9c8ac7f00330253a0fbd3a95d83448f5e`

Status: HOMOLOGADO LOCALMENTE — NAO COMMITADO / NAO PUBLICADO.

## Validacao final

- teste focado R5.5-C: aprovado;
- regressao `test/core/sync`: aprovada;
- `flutter analyze`: 0 issues;
- `git diff --check`: aprovado;
- escopo Git: exatamente 5 caminhos;
- selecao do candidato preservada;
- request de upload derivado do snapshot canonico;
- broker desabilitado falha fechado;
- grant expirado, de leitura, sem HTTPS ou sem `objectKey` e recusado;
- nenhum upload executado;
- nenhuma persistencia de grant realizada;
- nenhuma credencial permanente introduzida.

## Parecer

AUD-L2-R5.5-C: **HOMOLOGADO LOCALMENTE**.

A fronteira entre orquestracao e autorizacao temporaria esta pronta para o
R5.5-D, que podera consumir `EvidenceSyncGrantPreparation` e executar exatamente
uma chamada ao `RemoteEvidenceTransport`, persistindo sucesso somente depois da
confirmacao do transporte.

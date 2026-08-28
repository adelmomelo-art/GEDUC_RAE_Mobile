# AUD-L2-R5.6-C - Pipeline Integration & Artifact Lifecycle

## Status

HOMOLOGADO LOCALMENTE - PRE-COMMIT / NAO PUBLICADO.

## Baseline

`66e51c788d7ca40b0fe7b306521c1df13fdbab84`

## Branch

`audit/aud-l2-r5-6-c-pipeline-integration-artifact-lifecycle`

## Objetivo

Integrar o contrato de preparacao R5.6-A e a compressao deterministica R5.6-B
ao snapshot duravel de sincronizacao, preservando o original auditavel e
definindo o ciclo de vida seguro do artefato derivado de upload.

## Pipeline consolidado

```text
original auditavel
      |
      v
EvidencePreparer
      |
      v
artefato JPEG derivado e imutavel
      |
      v
metadata / SHA-256 / tamanho / MIME
      |
      v
EvidenceSyncJob
      |
      v
EvidenceSyncStore
      |
      v
R5.5 grant / upload / retry
      |
      v
synced duravel
      |
      v
cleanup seguro do derivado
```

## Decisoes arquiteturais

1. `EvidenciaModel.caminhoArquivo` continua apontando para o original local.
2. Metadados do `EvidenciaModel` continuam representando a evidencia local.
3. O `EvidenceSyncJob` representa o snapshot exato dos bytes preparados para upload.
4. `job.localFilePath` aponta para o artefato preparado, nunca para o original.
5. SHA-256, tamanho e MIME do job sao calculados depois da preparacao.
6. Re-enrollment identico preserva o job duravel e seu estado.
7. Snapshot divergente para a mesma identidade falha fechado.
8. `pending`, `retryScheduled` e `blocked` preservam o artefato preparado.
9. Cleanup so e permitido depois de resultado `synced` com job duravelmente `synced`.
10. Falha de cleanup nao transforma sucesso remoto confirmado em nova tentativa.
11. O lifecycle somente remove `.jpg` dentro da raiz dedicada de artefatos preparados.
12. O original fora dessa raiz e protegido contra remocao pelo lifecycle.
13. O caminho preparado e deterministico por `acaoId + evidenciaId + profile`.
14. Identificadores inseguros para path sao rejeitados.
15. `remoteStorageEnabled` permanece inalterado e desabilitado.
16. Nenhum backend, Worker, R2, B2, Firebase Storage ou credencial foi introduzido.
17. O `SyncService` legado de RAE permanece fora da fila de evidencias.
18. R5.7 permanece fora do escopo.

## Componentes introduzidos

### Storage

- `ApplicationDocumentsEvidencePreparedPathResolver`
- `EvidencePreparedArtifactLifecycle`

### Sync

- `EvidenceUploadEnrollmentCoordinator`
- `EvidenceSyncPipelineCoordinator`

### Testes

- resolver deterministico e path traversal;
- lifecycle seguro e protecao do original;
- enrollment com metadata do preparado;
- preservacao de retry em re-enrollment;
- fail-closed para snapshot divergente;
- cleanup de job ja sincronizado;
- cleanup somente depois de sync duravel;
- falha de cleanup sem reabrir upload.

## Correcao R1A

Durante a validacao, um teste assincrono verificava a existencia do artefato
antes de aguardar o Future que concluia cleanup + falha fechada.

A correcao foi exclusivamente no teste:

`expect(() => Future, throwsA(...))`

passou a aguardar explicitamente:

`await expectLater(Future, throwsA(...))`

O codigo de producao permaneceu inalterado no R1A.

## Escopo Git pre-commit

Exatamente 11 caminhos:

- 8 arquivos de implementacao/testes R5.6-C;
- este README;
- `docs/01_PLATFORM_ARCHITECTURE.md`;
- `docs/06_ENGINEERING_LOG.md`.

## Gates de homologacao pre-commit

- teste exato R1A;
- testes focais R5.6-C;
- regressao `test/core/storage`;
- regressao `test/core/sync`;
- `flutter test` completo;
- `flutter analyze` com 0 issues;
- `git diff --check`;
- validacao de escopo Git;
- validacao semantica dos contratos;
- HEAD preservado no baseline, sem commit.

## Fora do escopo

- commit;
- push;
- Pull Request;
- merge;
- cleanup de branch;
- habilitacao de storage remoto;
- composicao produtiva na UI;
- backend/Worker;
- Cloudflare R2;
- Backblaze B2;
- Firebase Storage;
- R5.7.

## Parecer

AUD-L2-R5.6-C: HOMOLOGADO LOCALMENTE PARA FRONTEIRA PRE-COMMIT.

A proxima fronteira e exclusivamente o commit controlado, sujeito a
autorizacao separada.

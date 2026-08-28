# AUD-L2-R5.7 - Integrated Evidence Tests & Final Homologation

## Status

HOMOLOGADO TECNICAMENTE - DOCUMENTACAO PRE-COMMIT / NAO PUBLICADO.

## Baseline

`c151d3934c47809f0a788192e365f5e5b3467a89`

## Branch

`audit/aud-l2-r5-7-integrated-tests-final-homologation`

## Objetivo

Validar transversalmente os contratos de evidencias consolidados em R5.4,
R5.5 e R5.6, provando a composicao real entre preparacao, enrollment,
persistencia duravel, selecao, grant, upload, retry/reconciliation,
confirmacao de sync e lifecycle do artefato preparado.

R5.7 nao habilita storage remoto e nao altera codigo de producao.

## Blueprint homologado

O R5.7 foi executado como pacote exclusivamente de testes.

Foram mantidos reais no harness:

- `DeterministicImageEvidencePreparer`;
- `ApplicationDocumentsEvidencePreparedPathResolver`;
- `EvidencePreparedArtifactLifecycle`;
- `EvidenceUploadEnrollmentCoordinator`;
- `SharedPreferencesEvidenceSyncStore`;
- `EvidenceSyncOrchestrator`;
- `EvidenceSyncGrantCoordinator`;
- `EvidenceSyncUploadCoordinator`;
- `EvidenceSyncRetryCoordinator`;
- `EvidenceSyncPipelineCoordinator`.

Somente as portas externas foram substituidas por doubles controlados:

- `EvidenceSyncConnectivityProbe`;
- `EvidenceAccessBroker`;
- `RemoteEvidenceTransport`;
- relogio deterministico de teste.

## R5.7-A - Happy Path integrado

O teste transversal comprova:

1. original PNG real materializado em diretorio temporario;
2. preparacao JPEG deterministica real;
3. original preservado byte a byte;
4. enrollment criando snapshot do artefato preparado;
5. SHA-256, tamanho e MIME derivados dos bytes destinados ao upload;
6. persistencia duravel no `SharedPreferencesEvidenceSyncStore`;
7. selecao pelo orchestrator;
8. grant vinculado a `EvidenceUploadIdentity`;
9. upload da copia preparada;
10. confirmacao duravel como `synced`;
11. `objectKey` originado do grant confiavel;
12. cleanup do JPEG derivado somente depois do sync confirmado;
13. original local preservado depois do ciclo completo.

## R5.7-B - Retry, reconciliation e idempotencia

O teste integrado comprova:

1. primeira tentativa com falha retryable;
2. transicao para `retryScheduled`;
3. incremento controlado de `attemptCount`;
4. `nextAttemptAt` conforme politica de backoff;
5. persistencia de `reconciliationObjectKey`;
6. preservacao do artefato preparado durante retry;
7. recuperacao do job por nova instancia do store duravel;
8. segunda tentativa usando a mesma identidade/idempotency key;
9. mesma chave remota confiavel na reconciliacao;
10. conclusao como `synced`;
11. limpeza de `reconciliationObjectKey`;
12. cleanup somente depois da confirmacao final.

## R5.7-C - Fail closed e lifecycle

Foram homologados cenarios de falha:

- sem rede: zero broker, zero upload e zero cleanup;
- grant com binding de identidade divergente: recusado antes do transporte;
- objectKey divergente durante reconciliation: job bloqueado sem segundo upload;
- retorno remoto com objectKey incoerente: nao confirma `synced`;
- alteracao concorrente do job durante efeito remoto: confirmacao local recusada;
- lifecycle tentando remover arquivo fora da raiz preparada: recusado;
- em todos os casos aplicaveis, o original permanece preservado.

## Correcoes durante homologacao

### R1 - import do enum de ciclo

Os tres testes integrados usavam `EvidenceSyncCycleStatus`, mas nao importavam
explicitamente `evidence_sync_retry_coordinator.dart`.

A correcao adicionou somente o import ausente nos tres arquivos de teste.
Nenhum codigo de producao foi alterado.

### R2 - analyze

`flutter analyze` encontrou um unico import nao utilizado no harness:

`evidence_sync_store.dart`

O import foi removido. Nenhuma logica foi alterada.

## Gates tecnicos homologados

- Gate 1 - testes integrados R5.7: APROVADO;
- Gate 2 - regressao `test/core/storage`: APROVADA;
- Gate 3 - regressao `test/core/sync`: APROVADA;
- Gate 4 - `flutter test` completo: APROVADO;
- Gate 5 - `flutter analyze`: APROVADO com 0 issues;
- Gate 6 - `git diff --check`: APROVADO;
- Gate 7 - validacao final de escopo: APROVADA.

## Escopo Git pre-commit

Exatamente 7 caminhos:

### Testes

- `test/support/evidence/evidence_r5_7_test_harness.dart`;
- `test/core/integration/evidence_r5_7_happy_path_test.dart`;
- `test/core/integration/evidence_r5_7_retry_reconciliation_test.dart`;
- `test/core/integration/evidence_r5_7_fail_closed_test.dart`.

### Documentacao

- `README_AUD-L2-R5.7.md`;
- `docs/01_PLATFORM_ARCHITECTURE.md`;
- `docs/06_ENGINEERING_LOG.md`.

## Invariantes preservadas

1. zero arquivos de producao alterados no R5.7;
2. `remoteStorageEnabled` permanece `false`;
3. armazenamento local continua obrigatorio e local-first;
4. original auditavel nunca e substituido pelo preparado;
5. cleanup continua restrito ao artefato preparado;
6. cliente Flutter continua sem segredo permanente de storage;
7. nenhum backend, Worker, R2, B2 ou Firebase Storage foi introduzido;
8. nenhuma composicao operacional/UI foi habilitada;
9. `SyncService` legado continua separado da fila de evidencias.

## Fora do escopo

- alteracao de codigo de producao;
- habilitacao de storage remoto;
- backend/Worker;
- Cloudflare R2;
- Backblaze B2;
- Firebase Storage;
- credenciais ou assinatura no APK;
- integracao operacional em UI;
- commit;
- push;
- Pull Request;
- merge;
- cleanup de branch;
- qualquer fase posterior ao R5.7.

## Parecer

AUD-L2-R5.7: HOMOLOGADO TECNICAMENTE E DOCUMENTADO PARA FRONTEIRA PRE-COMMIT.

O bloco de evidencias R5.4-R5.7 possui agora cobertura transversal dos
contratos locais, de sincronizacao, retry/reconciliation e lifecycle sem
necessidade de ativar infraestrutura remota produtiva.

A proxima fronteira e exclusivamente o commit controlado, sujeito a
autorizacao separada.

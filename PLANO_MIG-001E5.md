# PLANO MIG-001E5 — Rollback / Recovery controlado

## E5-A1 — Blueprint / Plano / Branch

- criar branch `migration/mig-001e5-rollback-recovery`;
- registrar arquitetura;
- zero Firestore.

## E5-B1 — Implementação mock-only

Implementar componente dedicado, separado do writer E3:

- `mig001e5_recovery.mjs`;
- build do probe write set de 4 documentos;
- target allowlist exata;
- `getExistingContentHash`;
- `deleteProbeIfHashMatches`;
- nenhuma função delete genérica pública;
- ordem delete-first-batch / journal-last;
- recovery CREATE_ONLY;
- validação dos 31 targets MIG-001E4 como fora de escopo de delete.

Testes obrigatórios:
- probe exatamente 4 targets;
- IDs exatos;
- hash mismatch bloqueia delete;
- target fora do probe bloqueia delete;
- pilot target bloqueia delete;
- `acoes`/`contadores` bloqueados;
- delete order correta;
- recovery create order correta;
- nenhum PATCH/PUT;
- falha parcial para sem cleanup genérico.

## E5-B2 — Auditoria local

- testes MIG-001E3;
- testes MIG-001E4;
- testes MIG-001E5;
- flutter analyze;
- git diff --check;
- static audit;
- zero gcloud/Firestore real.

## E5-C — Git / PR / CI

- commit;
- push;
- PR;
- Quality Gate Migration Importer deve executar E3 + E4 + E5;
- 6/6 gates;
- merge;
- cleanup;
- baseline novo.

## E5-R1 — Preflight real read-only

Antes do primeiro probe write:
- ADC em memória;
- fingerprint `acoes`;
- fingerprint `contadores`;
- validar 31 MIG-001E4 targets unchanged;
- validar 4 probe targets missing;
- zero writes.

## E5-R2 — Prova real rollback/recovery

Ciclo único controlado:

### Fase A — Create probe
- 4 CREATE_ONLY;
- batch marker por último;
- verificar 4 hashes.

### Fase B — Rollback
- batch marker DELETE primeiro;
- histórico DELETE;
- staging DELETE;
- journal DELETE por último;
- cada DELETE precedido de GET/hash guard;
- verificar 4 missing.

### Fase C — Recovery
- 4 CREATE_ONLY novamente;
- batch marker por último;
- verificar 4 hashes iguais.

### Fase D — Limpeza final
- repetir rollback hash-guarded;
- verificar 4 missing.

## E5-R3 — Reconciliação final

- 31 MIG-001E4 targets ainda unchanged;
- 4 probe targets missing;
- `acoes` fingerprint protegido;
- `contadores` fingerprint protegido;
- zero resíduo probe;
- relatório SAFE.

## Stop conditions

Abortar antes de DELETE se:
- target não é probe;
- hash diverge;
- projeto diverge;
- batch diverge;
- fingerprint protegido diverge;
- 31 documentos válidos do piloto não estiverem unchanged.

Nunca usar force, delete-all, recursive delete ou rollback genérico.
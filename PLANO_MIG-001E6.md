# PLANO MIG-001E6 — Carga Integral Controlada

## Fase A — Arquitetura

### A1
- Blueprint;
- Plano;
- README;
- branch E6;
- zero Firestore.

## Fase B — Engenharia

### B1 — Full-load planner mock-only

Implementar módulo específico E6 para:

- batch `mig001e6_full_1051_v1`;
- 1.051 registros;
- staging/history;
- journal E6 outcome-aware;
- batch marker last;
- resume-forward;
- zero DELETE público;
- zero generic write.

### B2 — Testes

Cobrir:

- total lógico 3.154;
- batch marker last;
- journal rollbackEligible=false;
- recoveryMode=resume_forward;
- 10 pilot IDs reconhecidos como possíveis unchanged;
- changed hash bloqueia;
- rerun idempotente;
- acoes/contadores nunca targets;
- nenhuma superfície delete.

### B3 — CI

Adicionar MIG-001E6 ao Quality Gate Migration Importer.

Executar regressões E3/E4/E5/E6.

## Fase C — Git/GitHub

- freeze;
- commit;
- push;
- PR;
- 6/6 Quality Gates;
- merge;
- cleanup;
- nova baseline oficial.

## Fase R — Operação real

### R1 — Full preflight READ-ONLY

Classificar os 3.154 targets.

Expectativa obrigatória:

- missing: 3.134;
- unchanged: 20;
- blockers: 0.

Também:

- 31 piloto E4 unchanged;
- 4 probes E5 missing;
- fingerprints protegidos.

Nenhuma escrita.

### R2 — Apply controlado

- chunk 100;
- CREATE_ONLY;
- sem batch marker durante chunks;
- journal E6 por registro;
- stop on blocker;
- resume forward em falha.

### R3 — Convergência antes do marker

Exigir:

- staging 1.051 exact;
- history 1.051 exact;
- journals E6 1.051 exact;
- zero blockers;
- fingerprints protegidos.

### R4 — Batch marker LAST

Criar exatamente 1 batch marker E6.

### R5 — Idempotência

Rerun integral:

- zero writes;
- todos unchanged;
- batch marker unchanged;
- fingerprints protegidos;
- probe residual zero.

## Proibições

- bulk rollback;
- delete-all;
- recursive delete;
- force;
- overwrite;
- PATCH/PUT;
- usar `acoes`;
- usar `contadores` como target;
- usar batch marker antes da convergência.
## Refinamento B1 — semântica do journal

O journal E6 não persiste outcome transitório de tentativa.

Persistência:

- política CREATE_ONLY;
- hashes esperados;
- rollbackEligible=false;
- recoveryMode=resume_forward.

Relatório local da execução:

- created;
- unchanged;
- unchanged_after_race;
- contagens por chunk.

Isso mantém o journal imutável entre execução inicial e resumes.

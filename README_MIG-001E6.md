# README MIG-001E6

Status inicial: **A1 — arquitetura**.

## Escopo

Carga integral dos 1.051 registros históricos Google Forms/Sheets.

## Batch final

`mig001e6_full_1051_v1`

## Contagem lógica

- 1 batch;
- 1.051 staging;
- 1.051 history;
- 1.051 journals.

Total: **3.154**.

Preflight esperado:

- **3.134 missing/create**;
- **20 unchanged**;
- **0 blockers**.

## Decisão de segurança

A carga integral usa:

**CREATE_ONLY + resume-forward idempotente**.

Não usa rollback destrutivo em massa.

O batch marker é sempre o último documento do lote.

## Estado de dados antes do E6

- 31 targets MIG-001E4 válidos e preservados;
- 4 probes MIG-001E5 ausentes;
- `acoes` count 44 / fingerprint homologado;
- `contadores` count 1 / fingerprint homologado.

## Neste A1

- Firestore reads: ZERO;
- Firestore writes: ZERO;
- Firestore deletes: ZERO;
- gcloud/ADC: ZERO;
- commit: não;
- push: não.
## B1 — implementação mock-only

Implementado:

- planner específico E6;
- 3.154 targets;
- batch marker last;
- journal determinístico;
- `rollbackEligible=false`;
- `recoveryMode=resume_forward`;
- preflight fechado;
- executor resume-forward;
- chunk de 100 registros;
- marker bloqueado até reconciliação dos 3.153 targets não-batch;
- rerun completo com zero writes;
- sem superfície de DELETE/PATCH/PUT/force/reset.

Refinamento: outcomes transitórios ficam no relatório operacional e não no journal persistido.

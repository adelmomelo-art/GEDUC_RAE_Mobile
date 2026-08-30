# MIG-001E5 — Estado da intervenção

## Objetivo

Provar rollback e recovery da migração histórica antes da carga integral, sem
usar os documentos válidos do MIG-001E4 como material descartável.

## Baseline

- `abbf90eadfcf4099541e67cd468e3717a8f620a6`
- MIG-001E4 piloto homologado:
  - P1 read-only PASS;
  - P2 31 CREATE_ONLY PASS;
  - P3 reconciliado e idempotente PASS.

## Estratégia E5

Probe descartável:

- batch: `mig001e5_rollback_probe_v1`
- doc base: `probe_mig001e5_v1`
- quatro targets nas coleções de migração;
- payload técnico sem dados pessoais;
- rollback somente por hash;
- recovery CREATE_ONLY;
- limpeza final obrigatória.

## B1 — Implementado mock-only

Novo componente:

`tools/migration/mig001e5_recovery.mjs`

Capacidades:

- `buildProbeWriteSet()`
  - quatro CREATE_ONLY;
  - staging;
  - histórico;
  - journal;
  - batch marker por último;

- `buildProbeRollbackPlan()`
  - batch primeiro;
  - histórico;
  - staging;
  - journal por último;

- `FirestoreProbeRecoveryController`
  - projeto fixo `geduc-rae-mobile`;
  - apenas targets probe exatos;
  - `getProbeState()`;
  - `deleteProbeIfHashMatches()`;
  - GET obrigatório antes de DELETE;
  - DELETE somente se `contentHash` existente for exatamente o esperado;

- `executeProbeRollback()`
  - sequencial;
  - para na primeira falha;
  - sem cleanup genérico;

- `executeProbeRecovery()`
  - somente writer `createOnly`;
  - ordem staging → histórico → journal → batch;
  - para na primeira falha.

## Superfície explicitamente ausente

O controller E5 não expõe:

- `delete`;
- `deleteDocument`;
- `deleteAll`;
- `recursiveDelete`;
- `patch`;
- `update`;
- `write`.

## Regra de ouro

**Nenhum DELETE do E5 pode atingir um target do MIG-001E4 piloto.**

Targets de `acoes`, `contadores`, batch E4 e históricos `gf_*` são recusados
antes de qualquer fetch.

## Testes B1

Nova suíte:

`npm run test:migration:mig001e5`

Cobertura inclui:

- target set 4/4;
- IDs determinísticos;
- create order;
- delete order;
- hash mismatch bloqueia DELETE;
- target E4 bloqueado antes da rede;
- `acoes` / `contadores` bloqueados;
- ausência de delete genérico;
- rollback parcial para imediatamente;
- recovery parcial para imediatamente.

## Estado de rede no B1

- gcloud real: não executado;
- ADC token real: não obtido;
- Firestore real: não acessado;
- reads reais: zero;
- creates reais: zero;
- deletes reais: zero.

O primeiro acesso Firestore do E5 permanece reservado para depois de testes,
auditoria, commit, PR, Quality Gates e merge.
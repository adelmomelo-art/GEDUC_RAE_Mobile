# BLUEPRINT MIG-001E6 — Carga Integral Histórica

## 1. Objetivo

Persistir integralmente os 1.051 registros históricos da fonte oficial Google Forms/Sheets nas superfícies históricas da Plataforma Fênix, preservando a separação entre:

- `acoes` — RAE nativo da Plataforma Fênix;
- `acoes_historicas` — histórico Google Forms;
- `migration_google_forms_staging` — staging auditável;
- `migration_batches/{batchId}` — batch marker;
- `migration_batches/{batchId}/changes` — journal do lote.

A carga histórica não gera número RAE e não toca `contadores`.

## 2. Baseline

- Baseline Git: `f7a68d4292c740320ae421d6520bedd947fcd4ee`
- Fonte oficial: 1.051 registros
- SHA256 da fonte:
  `19a80508161dea5a3fe5d610a8a95ee9470e28e9536c56c492840a7bc7a20a00`
- Batch final:
  `mig001e6_full_1051_v1`

## 3. Estado pré-existente homologado

O MIG-001E4 já persistiu 10 registros piloto.

Persistências válidas existentes:

- 10 staging;
- 10 history;
- 10 journals no batch piloto;
- 1 batch marker piloto.

Os 31 targets do piloto foram reconciliados no MIG-001E5-R3 e permanecem intocados.

## 4. Conjunto lógico do lote final

O lote final usa um NOVO batch ID.

Targets lógicos do lote E6:

- 1 batch marker final;
- 1.051 staging;
- 1.051 history;
- 1.051 journals no batch final.

Total lógico: **3.154 targets**.

Expectativa de classificação no preflight:

- staging: 1.041 missing + 10 unchanged;
- history: 1.041 missing + 10 unchanged;
- journals E6: 1.051 missing;
- batch marker E6: 1 missing.

Total esperado:

- **3.134 missing/create**;
- **20 unchanged**;
- **0 changed_pending_review**;
- **0 exists_without_comparable_hash**.

Estes números são EXPECTATIVAS, não autorização de escrita. O preflight real deve comprová-los.

## 5. Regra do batch marker

O construtor genérico `buildExecutableWriteSet()` coloca o batch marker no início.

No E6 isso NÃO será usado diretamente para execução.

A regra operacional é:

1. staging/history;
2. journal E6;
3. validação/reconciliação;
4. batch marker **LAST**.

O batch marker representa conclusão, não intenção.

## 6. Política de persistência

- CREATE_ONLY.
- Sem PATCH.
- Sem PUT.
- Sem overwrite.
- Sem force.
- Sem reset destrutivo.
- Sem escrita em `acoes`.
- Sem escrita em `contadores`.
- Sem raw responder email.
- IDs históricos determinísticos `gf_<sourceIdentityHash>`.

## 7. Política de recuperação

### Decisão

O E6 NÃO executará rollback destrutivo em massa.

O mecanismo de DELETE hash-guarded provado no MIG-001E5 permanece disponível como capacidade técnica, porém não será superfície normal da carga integral.

A recuperação operacional do E6 será:

**resume forward idempotente**.

Em falha parcial:

1. batch marker continua ausente;
2. documentos já criados permanecem válidos;
3. rerun classifica documentos existentes;
4. hash igual = unchanged;
5. missing = create;
6. hash divergente = BLOCK;
7. somente após convergência integral o batch marker é criado.

## 8. Journal E6

O journal genérico atual declara `rollbackEligible: true`.

Isso NÃO pode ser usado sem adaptação no lote integral, porque 10 registros history já existiam antes do E6.

O journal E6 deve ser outcome-aware e orientado a resume-forward.

Requisitos:

- batch ID E6 explícito;
- target history ID;
- target contentHash;
- staging contentHash;
- classificação preflight;
- outcome de staging;
- outcome de history;
- `rollbackEligible: false`;
- `recoveryMode: resume_forward`;
- sem autorização implícita para DELETE.

Rerun deve validar journal existente e nunca reescrevê-lo.

## 9. Proteções

Antes e depois da carga:

- fingerprint `acoes`;
- fingerprint `contadores`.

Baseline protegido:

- `acoes`: count 44
  - SHA256 `e377671d98863e9e949e0ba83beb254b04df279527ee5ef7ee2e5212256fb9e2`
- `contadores`: count 1
  - SHA256 `8fc02c81a0ac2ecbbb47b53e2aaabea8b73112abc177c6fa7253a8263098da2f`

Os 31 targets MIG-001E4 devem permanecer unchanged.

## 10. Chunking

Máximo operacional inicial: **100 registros por chunk**.

Cada registro deve ser tratado de forma determinística.

O batch marker não pertence aos chunks; é etapa final única.

## 11. Gates antes da primeira escrita

Nenhuma escrita E6 real antes de:

1. Blueprint/Plano homologados;
2. implementação mock-only;
3. testes E6;
4. CI E6;
5. commit/PR/merge;
6. full preflight real READ-ONLY;
7. 3.154 targets classificados;
8. exatamente 3.134 missing e 20 unchanged;
9. zero blockers;
10. fingerprints protegidos corretos;
11. 31 targets E4 unchanged.

## 12. Critérios de sucesso

Ao final:

- 1.051 history presentes e hash-correct;
- 1.051 staging presentes e hash-correct;
- 1.051 journals E6 presentes e hash-correct;
- batch marker E6 presente e hash-correct;
- 31 targets piloto preservados;
- probe E5 ausente;
- `acoes` e `contadores` invariantes;
- rerun integral = zero writes;
- nenhuma escrita em `acoes`/`contadores`.
## 13. Refinamento B1 — journal determinístico

O termo "outcome-aware" do A1 foi refinado para evitar conteúdo dependente da tentativa.

O journal persistido E6 é **determinístico e policy-aware**:

- `writePolicy: CREATE_ONLY`;
- `rollbackEligible: false`;
- `recoveryMode: resume_forward`;
- hashes de staging/history;
- identidade histórica;
- `transientAttemptOutcomePersisted: false`.

Resultados transitórios como `created`, `unchanged` ou `unchanged_after_race` NÃO entram no payload persistido do journal. Esses resultados pertencem ao relatório operacional da execução.

Motivo: em um resume após falha parcial, um documento originalmente criado passa a ser observado como `unchanged`. Persistir o outcome transitório produziria um journal diferente para o mesmo registro e quebraria a idempotência.

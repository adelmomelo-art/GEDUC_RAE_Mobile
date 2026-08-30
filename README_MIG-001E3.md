# MIG-001E3 — Importador administrativo do histórico Google Forms

## Estado desta entrega

**B2 — writer REST create-only implementado e testado apenas com mocks.**

Esta etapa não possui capacidade de escrita no Firestore. O argumento `--apply`
é reconhecido apenas para falhar de forma fechada com
`MIG001E3_APPLY_LOCKED_UNTIL_B2`.

## Fonte oficial

- Spreadsheet ID: `1HgTRMpBPItqoAbRKUujQs7481HhjPZfhsuM4s80jYJE`
- Sheet: `Respostas ao formulário 1`
- Snapshot: `MIG_001D_FONTE_RELATORIO_GEDUC_RAE_20260829.json`
- SHA256: `19a80508161dea5a3fe5d610a8a95ee9470e28e9536c56c492840a7bc7a20a00`
- Registros: `1051`
- Campos: `22`

## Invariantes

1. Histórico não entra em `/acoes`.
2. Histórico não recebe número de RAE.
3. `/contadores` não é tocado.
4. ID: `gf_<sha256>` calculado sem número de linha.
5. O e-mail bruto do respondente não é persistido no documento final.
6. Métrica só vira inteiro quando for número inteiro nativo ou texto
   integralmente numérico.
7. Texto semântico ou ambíguo permanece `raw`, com `known=false`.
8. Escritas futuras são limitadas à allowlist:
   - `migration_google_forms_staging`
   - `migration_batches/.../changes`
   - `acoes_historicas`
9. `acoes`, `contadores`, usuários, equipe e catálogos estão na denylist.
10. Primeira carga será CREATE-ONLY.

## Execução B1

```powershell
node .\tools\migration\mig001e3_importer.mjs `
  --source "$HOME\Downloads\MIG_001D_FONTE_RELATORIO_GEDUC_RAE_20260829.json" `
  --dry-run
```

Pilot dry-run determinístico:

```powershell
node .\tools\migration\mig001e3_importer.mjs `
  --source "$HOME\Downloads\MIG_001D_FONTE_RELATORIO_GEDUC_RAE_20260829.json" `
  --dry-run `
  --pilot 10 `
  --batch-id mig001e3_preview
```

## Próximo passo

MIG-001E3-B2 adicionará o writer administrativo autenticado por ADC,
create-only, verificação de conteúdo existente, journal e fingerprints de
`/acoes` e `/contadores`. Nenhuma escrita real será executada antes do
MIG-001E4 (pilot controlado).
## B2 — writer REST create-only

O B2 adiciona `tools/migration/mig001e3_firestore_rest.mjs`.

Contrato:

- `GET` pontual para verificar existência e `contentHash`.
- `POST createDocument` com `documentId` explícito quando ausente.
- Documento existente com mesmo hash → `unchanged`.
- Documento existente com hash diferente → `changed_pending_review`.
- Corrida entre GET e POST (`409`) → relê somente o hash e classifica.
- Nenhum `PATCH`, update ou delete existe na superfície do writer.
- `acoes` e `contadores` são rejeitados antes de qualquer chamada HTTP.
- Token e `fetch` são injetados; os testes usam somente doubles locais.
- Nenhum teste B2 acessa Firestore real.

O CLI `--apply` continua bloqueado até MIG-001E4.
## B2-R1 — idempotência do documento de batch

O documento `migration_batches/{batchId}` também é comparável por hash:

- `idSetHash`: SHA256 do conjunto ordenado de IDs históricos.
- `contentSetHash`: SHA256 do conjunto ordenado de `contentHash`.
- `contentHash`: SHA256 canônico dos metadados do próprio batch.

Assim, o lote inteiro segue a mesma política CREATE-ONLY:
mesmo hash → `unchanged`; hash diferente → `changed_pending_review`.
## B2-R2 — hash canônico por documento

Cada documento persistível possui `contentHash` calculado do seu próprio
payload, excluindo apenas o campo `contentHash`:

- `migration_batches/{batchId}` → hash do batch.
- `migration_google_forms_staging/{id}` → hash do staging.
- `acoes_historicas/{id}` → hash do histórico.
- `migration_batches/{batchId}/changes/{id}` → hash do journal.

O journal guarda ainda `targetContentHash`, que aponta para o hash do
documento histórico criado. Isso evita usar o hash do alvo como se fosse o
hash do próprio journal.
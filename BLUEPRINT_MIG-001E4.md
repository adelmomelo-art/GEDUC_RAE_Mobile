# BLUEPRINT MIG-001E4 — Piloto real controlado de migração histórica

## Baseline
- Base oficial: `3968fcd229e633bbb76cf7b4550f64bb0127b803`
- Fonte SHA256: `19a80508161dea5a3fe5d610a8a95ee9470e28e9536c56c492840a7bc7a20a00`
- Registros disponíveis: `1051`
- Piloto: `10`
- Batch ID reservado: `mig001e4_pilot_v1`

## Princípio central
O MIG-001E4 é o primeiro estágio autorizado a tocar o Firestore real. A escrita
não será habilitada antes de implementação, testes, CI, merge e preflight
read-only real.

## Arquitetura
```text
snapshot oficial
  -> validação SHA/schema
  -> transformação determinística
  -> seleção estratificada determinística de 10
  -> preflight dos 31 alvos CREATE_ONLY
  -> fingerprint PRE de /acoes e /contadores
  -> executor pilot-only
       -> staging (10)
       -> acoes_historicas (10)
       -> journal changes (10)
       -> batch marker por último (1)
  -> fingerprint POS de /acoes e /contadores
  -> reconciliação
```

## Componentes novos

### ADC Token Provider
Obtém token por Google Application Default Credentials via
`gcloud auth application-default print-access-token`.

Regras:
- token nunca é impresso;
- token nunca é persistido;
- token nunca entra em relatório;
- testes usam runner mockado.

### Read-only Fingerprinter
Serviço separado do writer, com read allowlist estrita:
- `acoes`
- `contadores`

Não possui métodos de escrita.

### Pilot Executor
Não haverá `--apply` genérico. Única capacidade real nesta etapa:
```text
--pilot-apply 10
--batch-id mig001e4_pilot_v1
--confirm-project geduc-rae-mobile
```

### Preflight de alvos
Antes da primeira escrita, os 31 targets serão consultados.
Permitidos:
- missing;
- existing com mesmo contentHash.

Bloqueantes:
- hash divergente;
- documento existente sem hash comparável;
- erro HTTP;
- target fora da allowlist.

## Ordem das escritas
1. staging por registro;
2. histórico por registro;
3. journal por registro;
4. `migration_batches/mig001e4_pilot_v1` por último.

## Invariantes críticas
- zero write em `acoes`;
- zero write em `contadores`;
- zero RAE gerado;
- zero alteração de contador;
- zero raw responder email persistido;
- zero PATCH/PUT/DELETE;
- somente POST createDocument;
- fingerprint PRE == POS para `acoes` e `contadores`.

## Quantidade esperada
- staging: 10
- histórico: 10
- journal: 10
- batch: 1
- total máximo: 31 creates
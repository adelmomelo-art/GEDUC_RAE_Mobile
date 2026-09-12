# BUG-RAE-002E.2D.2B.1B — Seed Planner local e fail-closed

Status: **LOCAL ONLY / sem superfície de escrita remota**

## Objetivo

Preparar um plano determinístico de carga da coleção `projetos` a partir do manifesto
institucional homologado em `BUG-RAE-002E.2D.2A-v1`.

## Contrato desta etapa

- `--project-id geduc-rae-mobile` é obrigatório e explícito.
- `--dry-run` é o único modo aceito.
- `--apply` falha fechado.
- SHA256 do manifesto deve ser exatamente:
  `C109703987A86B6D22C34CB0C1072CE434BB1E1CFAF6F01A43D40630EDB2A43C`.
- Total obrigatório: 53 registros.
- Cada item gera uma intenção `CREATE_ONLY`.
- Cada payload recebe `contentHash` determinístico calculado sem o próprio hash.
- `id` é usado como document ID e não é duplicado dentro do payload.
- `regionalIds` e `equipeIds` continuam vazios.
- Nenhum ADC, gcloud, fetch, leitura Firestore ou escrita Firestore é executado.

## Decisão arquitetural

A infraestrutura histórica `MIG-001E` não deve ser alterada para liberar `projetos`.
Seu allowlist/denylist foi desenhado para a migração histórica e bloqueia essa raiz
intencionalmente. Este seed mantém uma fronteira própria.

Nesta etapa reaproveitamos apenas os princípios de segurança já homologados:
hash determinístico, fail-closed, project confirmation, create-only e testes por
injeção. A integração REST/ADC será tratada em etapa separada e continuará limitada
exclusivamente à coleção `projetos`.

## Execução local

```powershell
node tools/catalogos/projeto_catalog_seed.mjs `
  --dry-run `
  --project-id geduc-rae-mobile
```

Resultado esperado: JSON de resumo com `records = 53`,
`writesAvailable = false`, `firestoreReads = 0` e `firestoreWrites = 0`.

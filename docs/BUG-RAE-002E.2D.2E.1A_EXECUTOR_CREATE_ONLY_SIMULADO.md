# BUG-RAE-002E.2D.2E.1A — Executor CREATE_ONLY simulado

Status: **IMPLEMENTAÇÃO LOCAL / SEM ADAPTADOR REMOTO**

## Objetivo

Homologar a lógica de execução dos 53 projetos institucionais antes de existir qualquer
ponte entre o executor e o Firestore real.

## Garantias

- o plano vem exclusivamente do `projeto_catalog_seed.mjs`;
- exatamente 53 destinos na coleção `projetos`;
- preflight completo dos 53 ocorre antes do primeiro `createOnly`;
- `changed_pending_review` e ausência de hash comparável bloqueiam antes da execução;
- somente resultados `created`, `unchanged` e `unchanged_after_race` são aceitos;
- rerun é idempotente;
- falha operacional interrompe imediatamente a execução;
- o writer aceito possui superfície estreita: `getExistingContentHash` + `createOnly`;
- métodos genéricos `create`, `set`, `update`, `patch`, `put` e `delete` são proibidos;
- o módulo não importa REST, ADC nem o preflight remoto;
- CLI oferece apenas `--simulate-empty`;
- `--apply`, `--remote` e `--remote-apply` são bloqueados.

## Simulação local

```powershell
node tools/catalogos/projeto_catalog_executor.mjs `
  --simulate-empty `
  --project-id geduc-rae-mobile
```

A primeira passagem deve simular 53 criações. A segunda passagem, usando o mesmo
writer em memória, deve convergir para 53 `unchanged`.

## Limite desta etapa

Nenhuma chamada de rede existe neste módulo. O adaptador remoto CREATE_ONLY será
uma etapa posterior e separada, depois desta implementação, testes, regressão e commit.

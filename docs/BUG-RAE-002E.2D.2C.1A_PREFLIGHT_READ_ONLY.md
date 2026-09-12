# BUG-RAE-002E.2D.2C.1A — Preflight remoto READ-ONLY do catálogo

Status: **IMPLEMENTAÇÃO LOCAL / NÃO EXECUTAR REMOTO NESTA ETAPA**

## Objetivo

Criar um leitor REST estritamente read-only para a coleção `projetos`, separado da
infraestrutura histórica MIG-001E, que mantém `projetos` em denylist de escrita.

## Garantias

- coleção permitida: somente `projetos`;
- projeto permitido: somente `geduc-rae-mobile`;
- modo remoto exige `--remote-read-only`;
- `--apply` é proibido;
- único verbo HTTP implementado: `GET`;
- nenhum método create/update/patch/delete;
- ADC é utilizado apenas quando o CLI remoto for explicitamente executado;
- testes usam `fetchFn` e token provider injetados;
- esta etapa não executa acesso remoto.

## Classificações

- `missing`: documento do manifesto ainda não existe;
- `unchanged`: documento existe com o mesmo `contentHash`;
- `exists_without_comparable_hash`: existe sem hash comparável — bloqueador;
- `changed_pending_review`: hash remoto diverge — bloqueador;
- `unexpected_remote_document`: documento remoto fora do manifesto — bloqueador.

O preflight só fica `ready = true` quando não existem bloqueadores.

## Próxima etapa

Após testes, regressão e commit local, executar separadamente o CLI:

```powershell
node tools/catalogos/projeto_catalog_preflight.mjs `
  --remote-read-only `
  --project-id geduc-rae-mobile
```

Essa execução fará somente leitura do Firestore e será tratada como etapa própria.

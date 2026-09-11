# BUG-RAE-002E.2D.2E.1F — Entrypoint operacional bloqueado

Status: **ENTRYPOINT PRESENTE / EXECUÇÃO REMOTA INDISPONÍVEL**

## Objetivo

Criar o arquivo que futuramente será o único ponto de entrada operacional para o seed
dos 53 projetos, sem ligar ainda esse entrypoint às dependências remotas.

## Estado atual

O entrypoint possui somente o modo:

```powershell
node tools/catalogos/projeto_catalog_seed_entrypoint.mjs `
  --status `
  --project-id geduc-rae-mobile
```

O resultado deve declarar:

- projeto `geduc-rae-mobile`;
- coleção `projetos`;
- 53 documentos esperados;
- dupla trava implementada;
- readiness runner implementado;
- executor CREATE_ONLY implementado;
- `remoteExecutionAvailable = false`;
- `adcInvoked = false`;
- `networkInvoked = false`;
- `firestoreReads = 0`;
- `firestoreWrites = 0`;
- `seedExecuted = false`.

## Bloqueio de execução

Os argumentos abaixo falham imediatamente:

- `--execute-remote`
- `--apply`
- `--seed`

Erro esperado:

`BUGRAE002E_ENTRYPOINT_REMOTE_EXECUTION_DISABLED`

## Ausências deliberadas

O entrypoint ainda não importa:

- ADC/gcloud;
- `fetch`;
- adaptador Firestore CREATE_ONLY;
- composição remota;
- execução do double lock.

Portanto, mesmo que alguém tente executar o arquivo diretamente, não existe caminho
de rede ou escrita.

## Próxima etapa

Depois de homologação, regressão e commit deste entrypoint bloqueado, a ativação remota
deverá ser uma mudança separada e auditável.

Essa futura ativação deverá:

1. importar ADC existente;
2. auditar o ruleset ativo;
3. executar preflight remoto READ-ONLY dos 53;
4. exigir as duas confirmações;
5. instanciar o adaptador CREATE_ONLY;
6. executar novo preflight do executor antes da primeira criação;
7. parar no primeiro bloqueador;
8. realizar prova pós-seed READ-ONLY;
9. nunca implementar UPDATE/PATCH/DELETE.

A existência do entrypoint não constitui autorização para seed.

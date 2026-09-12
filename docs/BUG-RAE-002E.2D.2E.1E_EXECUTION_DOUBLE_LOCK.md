# BUG-RAE-002E.2D.2E.1E — Camada final de execução com dupla trava

Status: **IMPLEMENTAÇÃO LOCAL + MOCKS / NÃO EXECUTAR REMOTO**

## Objetivo

Homologar a lógica final que poderá, em etapa futura e separada, autorizar o executor
CREATE_ONLY depois de todos os gates de readiness.

Esta etapa **não possui CLI, ADC, fetch ou adaptador Firestore real**.

## Dupla trava

Para a função de execução ser alcançada, duas confirmações literais diferentes precisam
estar presentes:

1. `AUTORIZO SEED CREATE_ONLY DOS 53 PROJETOS`
2. `CONFIRMO EXECUCAO REMOTA CREATE_ONLY DOS 53 PROJETOS`

Se qualquer uma faltar ou divergir, o fluxo falha **antes de qualquer gate remoto**.

## Sequência protegida

Com as duas confirmações válidas:

1. executa `runProtectedSeedReadiness`;
2. valida o ruleset esperado;
3. valida o preflight remoto READ-ONLY dos 53 destinos;
4. exige zero blockers;
5. somente então chama `executeCatalogCreateOnly`;
6. o próprio executor executa **novo preflight completo dos 53** antes da primeira escrita;
7. somente a superfície `createOnly` é aceita;
8. rerun converge para `unchanged`.

Assim, há duas camadas de proteção temporal:

- preflight remoto do readiness;
- novo preflight do executor imediatamente antes da fase de CREATE_ONLY.

## Testes

Todos os testes usam writers e readers em memória.

São comprovados:

- falta da autorização primária bloqueia;
- falta da segunda confirmação bloqueia;
- ruleset divergente bloqueia;
- preflight com blocker bloqueia;
- os 53 destinos são lidos pelo executor antes do primeiro create;
- primeira simulação cria 53;
- rerun produz 53 `unchanged` e zero novas escritas;
- writers com métodos genéricos de atualização são rejeitados.

## Ausências deliberadas

O módulo não contém:

- `process.argv`;
- CLI;
- ADC/gcloud;
- `fetch`;
- adaptador Firestore real;
- POST/PUT/PATCH/DELETE;
- execução remota automática.

## Próxima etapa

Após homologação, regressão e commit deste guard, poderá ser criado um **entrypoint
operacional separado**. Esse entrypoint será a única peça capaz de compor ADC + adaptador
real + este guard.

A criação desse entrypoint não equivale à autorização para executá-lo. O seed remoto
só deverá ocorrer em uma etapa separada, depois de nova auditoria do ruleset e coleção e
de autorização explícita do usuário no momento da operação.

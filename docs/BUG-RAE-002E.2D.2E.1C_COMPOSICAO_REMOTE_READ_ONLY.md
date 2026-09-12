# BUG-RAE-002E.2D.2E.1C — Composição remota READ-ONLY

Status: **IMPLEMENTAÇÃO LOCAL + TESTES COM MOCKS / ESCRITA REMOTA INDISPONÍVEL**

## Objetivo

Compor os componentes já homologados sem abrir ainda um caminho operacional para o seed:

1. `mig001e4_adc.mjs` — provedor ADC existente;
2. `projeto_catalog_seed.mjs` — plano institucional de 53 projetos;
3. `projeto_catalog_executor.mjs` — preflight completo dos 53;
4. `projeto_catalog_firestore_create_only.mjs` — adaptador Firestore estreito.

## Superfície exportada

A composição devolve somente:

- `runReadOnlyPreflight()`
- `remoteWriteEnabled = false`

Ela **não expõe**:

- o adaptador interno;
- `createOnly`;
- executor de escrita;
- CLI;
- `--apply`;
- qualquer comando remoto de seed.

## Garantia central

Mesmo que o adaptador interno possua `createOnly`, a composição o envolve em uma visão
READ-ONLY. O método interno `createOnly` dessa visão é um fail-closed que lança
`BUGRAE002E_COMPOSITION_REMOTE_WRITE_DISABLED`.

O preflight continua verificando todos os 53 destinos, mas somente
`getExistingContentHash()` pode atingir o adaptador Firestore.

## ADC

A factory de produção usa o helper já existente:

`tools/migration/mig001e4_adc.mjs`

O token provider é memoizado durante a composição para evitar executar `gcloud` uma vez
por documento. Uma falha de obtenção do token não é mantida em cache.

Nos testes, a factory ADC e `fetchFn` são injetados com mocks. Assim:

- gcloud real não é executado;
- ADC real não é executado;
- rede real não é executada;
- Firestore real não é lido;
- Firestore real não é escrito.

## Próxima etapa

Somente depois desta composição ser homologada e commitada poderá existir um runner
operacional separado. Esse runner deverá, antes de qualquer POST:

1. conferir branch/HEAD e árvore limpa;
2. conferir manifesto/hash;
3. conferir ruleset ativo e hash esperado;
4. executar preflight remoto completo imediatamente antes da escrita;
5. exigir autorização explícita para o seed;
6. usar somente CREATE_ONLY;
7. parar no primeiro resultado divergente;
8. realizar prova pós-seed READ-ONLY.

Esta etapa 1C não implementa esse runner.

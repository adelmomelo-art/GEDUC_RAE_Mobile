# SEC-R2-002A.6G - Status operacional R2

## Estado oficial

A etapa SEC-R2-002A.6G permanece aberta apenas na fronteira de
infraestrutura remota Cloudflare.

A implementacao versionada e a homologacao local do subsistema R2 estao
concluidas. O bloqueio atual nao e de codigo, arquitetura, testes ou
seguranca.

Status consolidado:

- A.6F: HOMOLOGADA, PUBLICADA E INTEGRADA;
- PR A.6F: #85;
- merge A.6F: `573532cab2a9938c47e1b538574b1d9db14015ca`;
- A.6G-LAB: HOMOLOGADA;
- A.6G remota: PENDENCIA EXTERNA ISOLADA;
- causa externa: entitlement/billing necessario para habilitar Cloudflare R2;
- bucket remoto: NAO CRIADO;
- deploy remoto: NAO EXECUTADO;
- remoteStorageEnabled: FALSE.

## Tentativa remota A.6G

Em 2026-09-15 o Wrangler 4.131.1 autenticou corretamente na conta
Cloudflare e confirmou que o bucket planejado nao existia.

A primeira operacao de criacao de bucket foi recusada pela API Cloudflare:

```text
Please enable R2 through the Cloudflare Dashboard.
code: 10042
```

A operacao parou antes da criacao do bucket e antes de qualquer deploy.

Nenhum recurso remoto foi criado nessa tentativa.

## Homologacao A.6G-LAB

A homologacao local foi executada sobre:

- main: `573532cab2a9938c47e1b538574b1d9db14015ca`;
- Worker: `fenix-evidence-api`;
- binding: `EVIDENCE_BUCKET`;
- bucket logico: `fenix-evidence-private-prod`;
- modo: R2 LOCAL / MINIFLARE;
- Wrangler: 4.131.1.

Resultados:

- testes focados: 65/65 PASS;
- TypeScript typecheck: PASS;
- adapter R2: PASS;
- idempotencia: PASS;
- conflito sem sobrescrita: PASS;
- upload validation: PASS;
- wiring/index: PASS;
- health local: PASS;
- remoteStorageBound=true: PASS;
- remoteStorageEnabled=false: PASS;
- PUT sem validator produtivo: HTTP 503 / validator_unavailable;
- R2 local PUT/GET: PASS;
- persistencia entre processos Wrangler: PASS;
- R2 local DELETE: PASS;
- restart Worker/Miniflare: PASS;
- encerramento Wrangler/Workerd: PASS;
- porta 8791 liberada: PASS;
- repositorio ao final: CLEAN;
- Cloudflare remoto durante LAB: NAO ACESSADO;
- bucket remoto durante LAB: NAO CRIADO;
- deploy durante LAB: NAO EXECUTADO.

Prova de bytes do simulador:

- tamanho: 4096 bytes;
- SHA-256: `12F51875C1545AFAC5B3BD4B3FD5131A9ED9F50FF248B84B01986D0934716F68`.

Evidencia operacional local:

`tools/output/SEC-R2-002A-A6G-LAB/SEC-R2-002A_6G_LAB_RESULTADO.txt`

SHA-256 do relatorio local na data deste registro:

`E24901BABEA3D7488391F90D70F970122485C6A06F4B9D8858AAB9E5E50CA70F`

O arquivo de evidencia permanece em `tools/output` e nao e versionado.

## Decisao de engenharia

A pendencia de billing/entitlement nao bloqueia a evolucao da Plataforma
Fenix.

O desenvolvimento pode continuar normalmente desde que:

1. `remoteStorageEnabled` permaneca `false`;
2. nenhum fluxo produtivo dependa do bucket R2 remoto;
3. a ativacao remota A.6G seja retomada como intervencao isolada;
4. a retomada use a main vigente naquele momento, e nao assuma a baseline
   antiga deste documento;
5. antes da criacao real sejam revalidados conta Cloudflare, entitlement,
   inexistencia/estado do bucket, binding e invariantes fail-closed.

## Condicao para retomada A.6G remota

A retomada sera permitida quando houver um metodo de pagamento valido e o
R2 estiver habilitado na conta Cloudflare.

Na retomada deve ser gerado um novo pacote operacional contra a main vigente.

A sequencia continua sendo:

```text
R2 entitlement habilitado
        |
        v
revalidar main e configuracao
        |
        v
confirmar bucket remoto ausente/seguro
        |
        v
criar fenix-evidence-private-prod
        |
        v
manter bucket privado
        |
        v
deploy fenix-evidence-api
        |
        v
GET /health
remoteStorageBound=true
remoteStorageEnabled=false
        |
        v
PUT fail-closed
503 validator_unavailable
```

## Fronteira preservada

Esta pendencia nao autoriza:

- ativar `remoteStorageEnabled=true`;
- instalar validator/auth/grant produtivos sem etapa propria;
- introduzir credencial R2 permanente no Flutter;
- expor o bucket por r2.dev ou custom domain;
- criar CORS sem necessidade arquitetural;
- reutilizar automaticamente um bucket preexistente desconhecido.

Status final deste registro:

**A.6G-LAB HOMOLOGADA / A.6G REMOTA PENDENTE EXTERNAMENTE / ENGENHARIA LIBERADA PARA PROSSEGUIR.**

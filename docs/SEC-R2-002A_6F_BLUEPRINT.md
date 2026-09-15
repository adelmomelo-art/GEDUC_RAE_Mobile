# SEC-R2-002A.6F - Blueprint de Preparacao da Infraestrutura R2

## Baseline

- repositorio: `adelmomelo-art/GEDUC_RAE_Mobile`;
- main: `ec217fa42244ef28a0b1fd275f7b10b85b0209db`;
- branch: `security/sec-r2-002a-6f-r2-infra`;
- bucket planejado: `fenix-evidence-private-prod`;
- binding: `EVIDENCE_BUCKET`.

## Objetivo

Preparar a configuracao versionada para a ativacao controlada do Cloudflare R2
sem habilitar ainda o fluxo produtivo de evidencias.

A A.6F adiciona o binding R2 ao `wrangler.jsonc` e separa explicitamente:

- `remoteStorageBound`: o runtime recebeu o binding R2;
- `remoteStorageEnabled`: o fluxo remoto foi liberado para uso produtivo.

Nesta etapa, `remoteStorageEnabled` permanece obrigatoriamente `false`.

## Configuracao R2

O Worker recebe exatamente um binding:

- binding: `EVIDENCE_BUCKET`;
- bucket: `fenix-evidence-private-prod`.

O bucket deve permanecer privado. Nenhum `r2.dev`, custom domain ou CORS e
habilitado. O Worker usa o binding nativo; nenhuma Access Key ou Secret Key R2
e adicionada ao codigo ou ao aplicativo.

## Fail-closed preservado

Mesmo com o binding presente:

- Firebase verifier produtivo default continua desabilitado;
- emissor produtivo de grant default continua desabilitado;
- validador produtivo do PUT default continua desabilitado;
- PUT externo nao alcanca o R2 sem validacao;
- `remoteStorageEnabled=false`.

## Metodo de engenharia

A A.6F passa a ser aplicada e testada em worktree Git isolado. O checkout
principal permanece limpo. O escopo e medido pelo diff contra o baseline e por
arquivos untracked nao ignorados, com relatorio explicito de MISSING e EXTRA.

A ausencia de `.gitattributes` foi identificada no preflight, mas a
normalizacao global de EOL nao pertence a A.6F para evitar diff transversal.
Essa melhoria devera ser tratada em etapa de engenharia separada.

## Fronteira

A aplicacao local desta etapa:

- altera apenas arquivos do manifesto A.6F;
- executa testes e typecheck no worktree;
- nao cria bucket real;
- nao executa deploy;
- nao cria secret;
- nao publica branch ou PR;
- nao habilita storage remoto no Flutter.

## Criterios

- binding R2 exato no Wrangler;
- health distingue binding de feature habilitada;
- binding simulado nao contorna o validator;
- `remoteStorageEnabled=false`;
- acesso publico/CORS/custom domain ausentes;
- suite Evidence Worker PASS;
- typecheck PASS;
- Flutter Test PASS;
- Flutter Analyze PASS;
- diff check PASS;
- MISSING=0 e EXTRA=0.

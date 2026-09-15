# SEC-R2-002A - Blueprint Backend de Evidencias + Cloudflare R2

## Objetivo

Implementar o backend autorizador de evidencias com Cloudflare Worker e bucket R2 privado.

remoteStorageEnabled permanece false durante toda esta etapa.

## Decisao arquitetural v1

O upload nao sera realizado diretamente pelo aplicativo para uma URL presignada do R2.

Fluxo adotado:

Flutter -> Cloudflare Worker -> R2 privado

Motivos:

- validar os bytes reais no backend;
- recalcular SHA-256 server-side;
- comparar o hash real com o contrato do cliente;
- validar tamanho e MIME;
- aplicar ACL antes do armazenamento;
- evitar credenciais permanentes do R2 no aplicativo;
- utilizar R2 Binding no Worker.

## Endpoint de grant

POST /v1/evidencias/upload-grant

Responsabilidades:

- validar Firebase ID Token;
- validar usuario ativo;
- carregar dados autoritativos do usuario e do RAE;
- aplicar ACL server-side;
- validar autorUserId;
- validar contentType, tamanhoBytes e sha256;
- derivar objectKey no backend;
- emitir capability de upload de curta duracao.

## Endpoint de upload

PUT /v1/evidencias/upload/{capability}

Responsabilidades:

- validar capability e expiracao;
- validar Content-Type;
- aplicar limite real de bytes;
- calcular SHA-256 dos bytes recebidos;
- comparar SHA-256 real com o esperado;
- verificar idempotencia;
- gravar no R2 pelo binding;
- informar SHA-256 ao R2 como checksum;
- retornar objectKey e metadados da gravacao.

## Object key

Formato:

evidencias/v1/{acaoId}/{evidenciaId}/{sha256}.{ext}

A extensao e derivada pelo backend a partir do MIME permitido.

O cliente nunca define a objectKey.

## Idempotencia

Identidade:

acaoId + evidenciaId + sha256

Se o objeto ja existir com identidade, tamanho e checksum equivalentes,
a operacao devera ser considerada sucesso idempotente.

Divergencia para a mesma objectKey devera gerar conflito e nunca sobrescrita silenciosa.

## Autenticacao

Firebase Authentication identifica o chamador.

O UID autenticado e independente de autorUserId.

autorUserId representa o autor ou captor original da evidencia.

## App Check

O verificador sera previsto na arquitetura.

O enforcement produtivo permanece desabilitado ate homologacao especifica.

## ACL

Nenhum perfil, permissao ou escopo enviado pelo cliente sera considerado autoridade.

O Worker devera obter dados autoritativos e recalcular a autorizacao.

As regras atuais do Firestore nao substituem a ACL do backend.

## R2

Bucket privado.

Sem acesso publico.

Acesso produtivo somente pelo Worker via R2 Binding.

Nenhuma credencial R2 no Flutter ou APK.

## Seguranca operacional

- nenhuma URL permanente;
- capability com expiracao curta;
- sem segredo em repositorio;
- sem segredo no APK;
- sem confiar em SHA informado sem verificacao;
- sem sobrescrita silenciosa;
- armazenamento local continua obrigatorio.

## Fora do escopo desta subetapa

- criar bucket R2;
- criar Worker na Cloudflare;
- criar secrets;
- deploy;
- habilitar armazenamento remoto;
- alterar remoteStorageEnabled.

## Estado das subetapas

- A.1 a A.6A: homologadas e integradas na `main` pelo PR #80;
- A.6B: homologada e integrada na `main` pelo PR #81;
- A.6C: homologada e integrada na `main` pelo PR #82;
- A.6D: homologada e integrada na `main` pelo PR #83;
- A.6E: homologada e integrada na `main` pelo PR #84;
- A.6F: preparacao versionada do binding R2, mantendo storage remoto desabilitado.

<!-- SEC-R2-002A-A6A-HOMOLOGADO -->
## Registro de implementação — A.1 a A.6A

- Status: implementado e homologado.
- Evidence Worker criado em backend/evidence-worker.
- Contrato HTTP e scaffold validados.
- Contrato de evidência validado.
- ACL de evidências validada.
- Autenticação do caller validada.
- Capability HMAC-SHA256 validada.
- Teste focado da capability: 7/7.
- Suíte consolidada: 47/47.
- TypeScript typecheck: PASS.
- Flutter Analyze: PASS, 0 issues.
- Git diff check: PASS.
- Correção WebCrypto R1 homologada sem cast inseguro.

## Continuidade apos PR #80

- A.1 a A.6A integradas na `main` pelo merge
  `38682e679144d0b0c05439b698cce8ca049d7111`;
- A.6B conecta o pipeline ja homologado para emitir o grant;
- endpoint PUT, R2, secrets, deploy e feature flag permanecem fora do escopo.

<!-- SEC-R2-002A-A6B-HOMOLOGADO -->
## Registro de implementacao - A.6B

- Status: implementado, homologado e integrado em 2026-09-13.
- Branch: `security/sec-r2-002a-6b-grant-capability`.
- Baseline: `38682e679144d0b0c05439b698cce8ca049d7111`.
- Grant emitido somente apos autenticacao, contrato e ACL.
- Verificacao autoritativa de `autorUserId` obrigatoria e fail-closed.
- Caller autenticado e autor da evidencia permanecem identidades distintas.
- Capability HMAC-SHA256 com TTL maximo de 300 segundos.
- `objectKey` e chave de idempotencia derivadas no backend.
- Response compativel com `EvidenceAccessGrant` do Flutter.
- Testes focados: 23/23.
- Suite Evidence Worker: 57/57.
- Flutter Test: 971/971.
- TypeScript typecheck e Flutter Analyze: PASS.
- PUT/R2 permanece `501` e `remoteStorageEnabled=false`.
- Nenhum deploy, bucket, binding ou secret executado.
- PR #81 integrado pelo merge
  `4ed6dadd1dc0ba9362874b62d1a13de49dc61f28`.
<!-- SEC-R2-002A-A6B-END -->

<!-- SEC-R2-002A-A6C-HOMOLOGADO -->
## Registro de implementacao - A.6C

- Baseline: merge `4ed6dadd1dc0ba9362874b62d1a13de49dc61f28`.
- Branch: `security/sec-r2-002a-6c-put-validation`.
- Capability rejeita emissao futura e TTL acima de 300 segundos.
- Limite operacional compartilhado: 10 MiB.
- PUT valida MIME, idempotencia, tamanho, JPEG e SHA-256 reais.
- `objectKey` e novamente derivada e comparada server-side.
- Testes focados: 53/53.
- Suite Evidence Worker: 80/80.
- TypeScript typecheck, Flutter Test e Flutter Analyze: PASS.
- Registrants EOL, hashes, diff check e escopo: PASS.
- Persistencia R2 permanece ausente e o PUT valido termina em `501`.
- `remoteStorageEnabled=false` permanece inalterado.
- Nenhum bucket, binding, secret ou deploy pertence a A.6C.
- PR #82 integrado pelo merge
  `987ae5a534b9bff1b1299cd437822052a688713c`.
- Status: HOMOLOGADO, INTEGRADO E ENCERRADO.
<!-- SEC-R2-002A-A6C-HOMOLOGADO-END -->

<!-- SEC-R2-002A-A6D-HOMOLOGADO -->
## Registro de implementacao - A.6D

- Baseline: merge `987ae5a534b9bff1b1299cd437822052a688713c`.
- Branch: `security/sec-r2-002a-6d-idempotency-port`.
- Porta privada desacoplada de provedor.
- Criacao atomica obrigatoria por `createIfAbsent`.
- Caller e autor permanecem identidades distintas.
- Identidade existente integralmente equivalente produz sucesso idempotente.
- Qualquer divergencia produz conflito sem sobrescrita.
- Ausencia ou falha da porta produz `503` fail-closed.
- Nenhuma URL ou detalhe de storage e devolvido ao cliente.
- Testes focados: 53/53.
- Suite Evidence Worker: 99/99.
- TypeScript typecheck: PASS.
- Flutter Test e Flutter Analyze: PASS.
- Registrants EOL, hashes, diff check e escopo: PASS.
- R2 Binding, bucket, secret e deploy: ausentes.
- `remoteStorageEnabled=false` permanece inalterado.
- PR #83 integrado pelo merge
  `34d71d540fd12ba2f04c24124e9c02910c25e069`.
- Status: HOMOLOGADO, INTEGRADO E ENCERRADO.
<!-- SEC-R2-002A-A6D-HOMOLOGADO-END -->

<!-- SEC-R2-002A-A6E-IMPLEMENTADO -->
## Registro de implementacao - A.6E

- Baseline: merge `34d71d540fd12ba2f04c24124e9c02910c25e069`.
- Branch: `security/sec-r2-002a-6e-r2-adapter`.
- Adapter Cloudflare R2 implementa `EvidencePrivateStoragePort`.
- Primeira operacao e PUT condicional com `etagDoesNotMatch: "*"`.
- `head` ocorre somente depois de falha da precondicao.
- MIME, metadados canonicos e checksum SHA-256 sao enviados ao R2.
- Identidade fisica e logica e conferida em criacao e idempotencia.
- Caller e autor permanecem identidades distintas.
- Objeto malformado ou divergente produz conflito sem sobrescrita.
- Falha do provedor permanece `503` generico para o cliente.
- Wiring depende da injecao de `EVIDENCE_BUCKET`.
- `wrangler.jsonc` permanece sem binding R2.
- `remoteStorageEnabled=false` permanece inalterado.
- Bucket, binding real, secret e deploy: ausentes.
- Status: HOMOLOGADO, INTEGRADO E ENCERRADO pelo PR #84; merge `ec217fa42244ef28a0b1fd275f7b10b85b0209db`.
<!-- SEC-R2-002A-A6E-IMPLEMENTADO-END -->

<!-- SEC-R2-002A-A6F-PREPARACAO-START -->
## Registro de preparacao - A.6F

- Baseline: `ec217fa42244ef28a0b1fd275f7b10b85b0209db`.
- Branch: `security/sec-r2-002a-6f-r2-infra`.
- Binding planejado: `EVIDENCE_BUCKET`.
- Bucket privado planejado: `fenix-evidence-private-prod`.
- `remoteStorageBound` separado de `remoteStorageEnabled`.
- `remoteStorageEnabled=false` permanece obrigatorio.
- Binding presente nao contorna o validator.
- Nenhum `r2.dev`, custom domain ou CORS.
- Nenhuma Access Key/Secret Key R2 no Worker ou Flutter.
- Aplicacao/testes executados em worktree isolado.
- Criacao real de bucket e deploy permanecem fora da aplicacao local.
- Status: PREPARADO LOCALMENTE / AGUARDANDO HOMOLOGACAO.
<!-- SEC-R2-002A-A6F-PREPARACAO-END -->

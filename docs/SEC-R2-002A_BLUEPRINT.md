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
- A.6B: homologada localmente para emissao do upload grant;
- proxima fronteira: A.6C, validacao do PUT e dos bytes recebidos.

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

- Status: implementado e homologado localmente em 2026-09-13.
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
<!-- SEC-R2-002A-A6B-END -->

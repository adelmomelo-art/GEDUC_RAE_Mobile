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

## Proxima subetapa

SEC-R2-002A.2 - scaffold local do Worker e testes, ainda sem recursos Cloudflare reais.

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

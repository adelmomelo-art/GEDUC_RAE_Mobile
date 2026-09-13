# SEC-R2-002A — Evidence Worker Backend R2

## Escopo consolidado

Esta entrega reúne os subpassos A.1 a A.6A:

- Blueprint técnico;
- scaffold Cloudflare Worker;
- contrato HTTP inicial;
- contrato de evidências;
- ACL de evidências;
- autenticação do caller;
- capability HMAC-SHA256;
- correção WebCrypto BufferSource R1.

## Segurança

A capability vincula separadamente caller autenticado e autor da
evidência. A verificação rejeita adulteração, chave divergente,
expiração inválida e chaves HMAC inferiores a 256 bits.

A adaptação WebCrypto usa cópia explícita para ArrayBuffer e não
introduz cast inseguro para BufferSource.

## Homologação

- Guard: PASS;
- capability: 7/7 testes;
- suíte Evidence Worker: 47/47 testes;
- npm typecheck: PASS;
- Flutter Analyze: PASS, 0 issues;
- git diff check: PASS;
- registrants gerados: neutralizados somente após confirmação de
  diferença exclusivamente EOL.

## Fronteiras preservadas

- remoteStorageEnabled permanece false;
- nenhuma publicação produtiva foi ativada;
- nenhuma credencial permanente foi adicionada ao cliente;
- regras produtivas de Storage permanecem fora deste subpasso;
- A.1 a A.6A foram integradas na main pelo PR #80;
- A.6B emite somente o grant e mantem PUT/R2 em fail-closed.

## Identificacao A.1 a A.6A

- Branch: security/sec-r2-002a-backend-r2
- Baseline main: 007aab831a6bf60807de2cedff0b7c2995591dcf
- Data de homologação: 2026-09-12 15:14:52 -03:00

## Homologacao A.6B

A emissao do upload grant foi conectada a autenticacao, contrato, ACL,
verificacao autoritativa do autor e capability HMAC-SHA256.

Resultado homologado em 2026-09-13:

- testes focados A.6B: 23/23;
- suite Evidence Worker: 57/57;
- Flutter Test: 971/971;
- TypeScript typecheck: PASS;
- Flutter Analyze: PASS, 0 issues;
- hashes, diff check e escopo: PASS;
- caller e autor distintos: preservados;
- TTL maximo do grant: 300 segundos;
- `objectKey` e idempotencia: derivadas server-side;
- registrants gerados: limpos;
- PUT/R2: fail-closed;
- `remoteStorageEnabled=false`.

Identificacao:

- Branch: `security/sec-r2-002a-6b-grant-capability`;
- Baseline: `38682e679144d0b0c05439b698cce8ca049d7111`;
- Infraestrutura Cloudflare produtiva: nao criada;
- Deploy, bucket, binding e secrets: nao executados.

## Proxima fronteira

SEC-R2-002A.6C - validacao da capability e do contrato de bytes no endpoint
PUT, ainda sem habilitacao produtiva.

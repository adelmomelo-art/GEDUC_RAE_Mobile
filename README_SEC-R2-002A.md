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
- merge na main depende de PR e quality gates remotos.

## Identificação

- Branch: security/sec-r2-002a-backend-r2
- Baseline main: 007aab831a6bf60807de2cedff0b7c2995591dcf
- Data de homologação: 2026-09-12 15:14:52 -03:00

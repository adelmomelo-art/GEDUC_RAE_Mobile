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
- PR #81: integrado;
- Merge SHA: `4ed6dadd1dc0ba9362874b62d1a13de49dc61f28`;
- Branches local e remota: removidas apos o merge.

## Homologacao A.6C

SEC-R2-002A.6C implementa a validacao integral da capability e dos bytes no PUT:

- rejeicao de capability expirada, futura ou com TTL acima de 300 segundos;
- limite operacional de 10 MiB aplicado no grant e no stream;
- `Content-Type`, idempotencia e tamanho vinculados ao contrato assinado;
- `objectKey` recalculada server-side;
- assinatura JPEG e SHA-256 real dos bytes recebidos;
- testes focados: 53/53;
- suite Evidence Worker: 80/80;
- TypeScript typecheck: PASS;
- Flutter Test e Flutter Analyze: PASS;
- hashes, registrants, diff check e escopo: PASS.

Mesmo apos uma validacao completa, o endpoint retorna `501` e nao persiste os
bytes. Bucket, binding, secret, deploy, idempotencia contra R2 e habilitacao de
`remoteStorageEnabled` permanecem fora desta subetapa.

Baseline A.6C:

- `main`: `4ed6dadd1dc0ba9362874b62d1a13de49dc61f28`;
- branch: `security/sec-r2-002a-6c-put-validation`;
- PR #82: integrado;
- merge SHA: `987ae5a534b9bff1b1299cd437822052a688713c`;
- branches local e remota: removidas;
- status: HOMOLOGADO, INTEGRADO E ENCERRADO.

## Implementacao A.6D

SEC-R2-002A.6D adiciona a fronteira atomica entre o upload validado e uma
futura implementacao privada de armazenamento:

- contrato `EvidencePrivateStoragePort` sem dependencia do provedor;
- criacao obrigatoria por `createIfAbsent`;
- nenhuma sequencia vulneravel `HEAD` + `PUT`;
- identidade persistida com object key, RAE, evidencia, autor, MIME, tamanho,
  SHA-256 e idempotencia derivados server-side;
- caller preservado separadamente para auditoria;
- objeto identico existente retorna sucesso idempotente sem regravacao;
- qualquer divergencia retorna conflito e proibe sobrescrita silenciosa;
- porta ausente ou falha retorna `503 storage_unavailable`;
- respostas de sucesso nao expoem URL ou detalhe do storage;
- testes focados: 53/53;
- suite Evidence Worker: 99/99;
- TypeScript typecheck: PASS.

A porta produtiva continua ausente. Nenhum adapter R2, bucket, binding, secret
ou deploy e introduzido, e `remoteStorageEnabled=false` permanece obrigatorio.

Baseline A.6D:

- `main`: `987ae5a534b9bff1b1299cd437822052a688713c`;
- branch: `security/sec-r2-002a-6d-idempotency-port`;
- teste focado A.6D: 53/53;
- suite Evidence Worker: 99/99;
- TypeScript typecheck: PASS;
- Flutter Test: PASS;
- Flutter Analyze: PASS, 0 issues;
- registrants EOL: CLEAN;
- hashes, diff check e escopo: PASS;
- `createIfAbsent`: PASS;
- idempotencia integral e bloqueio de sobrescrita: PASS;
- porta produtiva ausente: `503` fail-closed;
- R2 adapter/binding: ausentes;
- `remoteStorageEnabled=false`;
- PR #83: integrado;
- merge SHA: `34d71d540fd12ba2f04c24124e9c02910c25e069`;
- branches local e remota: removidas;
- status: HOMOLOGADO, INTEGRADO E ENCERRADO.

## Implementacao A.6E

SEC-R2-002A.6E implementa localmente o adapter Cloudflare R2:

- PUT condicional `etagDoesNotMatch: "*"` como primeira operacao;
- `head` somente apos falha da precondicao de criacao;
- MIME, metadados canonicos e checksum SHA-256 enviados ao R2;
- validacao da identidade fisica e logica do objeto;
- repeticao equivalente idempotente;
- conflito para objeto malformado ou divergente, sem sobrescrita;
- wiring opcional por `EVIDENCE_BUCKET` injetado;
- falha do provedor convertida em `503` generico.

O `wrangler.jsonc` continua sem `r2_buckets`, o health permanece
`remoteStorageEnabled=false` e nenhum bucket, binding real, secret ou deploy
pertence a esta subetapa.

Baseline A.6E:

- `main`: `34d71d540fd12ba2f04c24124e9c02910c25e069`;
- branch: `security/sec-r2-002a-6e-r2-adapter`;
- status: IMPLEMENTADO LOCALMENTE / AGUARDANDO HOMOLOGACAO.

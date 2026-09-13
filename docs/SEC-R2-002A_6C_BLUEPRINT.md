# SEC-R2-002A.6C - Blueprint de Validacao do PUT e dos Bytes

## Objetivo

Validar integralmente a capability, o contrato HTTP e os bytes recebidos pelo
endpoint `PUT /v1/evidencias/upload/{capability}` antes de qualquer acesso ao
Cloudflare R2.

O armazenamento produtivo permanece desabilitado. Depois de uma validacao bem
sucedida, o Worker responde `501` de forma deliberada, pois persistencia,
idempotencia contra o bucket e binding R2 pertencem a uma etapa posterior.

## Fronteira confiavel

O PUT aceita apenas capability HMAC-SHA256 valida e vigente. A verificacao
independente rejeita:

- assinatura ou codificacao invalidas;
- capability expirada ou emitida no futuro;
- TTL superior a 300 segundos;
- claims fora do contrato canonico;
- `objectKey` diferente da chave novamente derivada no backend.

`callerUid` e `autorUserId` continuam vinculados separadamente na capability.
O PUT nao tenta substituir o caller pelo autor e nao aceita identidade enviada
novamente em headers, query string ou corpo auxiliar.

## Contrato HTTP

- metodo exclusivo: `PUT`;
- query string adicional: proibida;
- `Content-Type`: exatamente `image/jpeg`;
- `X-Fenix-Idempotency-Key`: obrigatoria e identica ao valor derivado;
- `Content-Length`: quando presente, deve ser inteiro canonico e coincidir com
  o tamanho assinado;
- `Content-Encoding`: ausente ou `identity`;
- `Content-Range`: proibido nesta versao.

## Contrato real dos bytes

- limite maximo: 10 MiB (`10 * 1024 * 1024` bytes);
- leitura por stream limitada ao tamanho autorizado;
- corpo menor ou maior que `tamanhoBytes`: rejeitado;
- assinatura JPEG: SOI/marker inicial e EOI final obrigatorios;
- SHA-256 recalculado pelo Worker sobre os bytes exatos recebidos;
- hash real diferente da capability: rejeitado;
- nenhum byte e enviado ao R2 nesta subetapa.

O limite tambem e aplicado na emissao do grant, impedindo que o backend assine
uma capability acima da politica operacional.

## Respostas fail-closed

- capability invalida ou expirada: `401`;
- validador produtivo ausente: `503`;
- payload acima do limite: `413`;
- MIME, codificacao ou assinatura JPEG invalidos: `415`;
- idempotencia divergente: `409`;
- tamanho ou SHA-256 divergente: `422`;
- contrato HTTP invalido: `400`;
- validacao completa sem storage configurado: `501` com
  `SEC_R2_002A_6C_STORAGE_FAIL_CLOSED`.

As respostas nao expõem chaves, assinaturas, bytes ou detalhes internos.

## Fora do escopo

- consultar objeto existente no R2;
- resolver idempotencia contra armazenamento;
- gravar, sobrescrever ou excluir objetos;
- criar bucket, binding, secret ou Worker produtivo;
- configurar Firebase Admin produtivo;
- executar deploy;
- alterar `remoteStorageEnabled=false`;
- habilitar transporte remoto no Flutter.

## Criterios de homologacao

- capability e janela temporal validadas independentemente;
- caller e autor distintos preservados;
- object key e idempotencia recalculadas server-side;
- tamanho real limitado e comparado;
- JPEG e SHA-256 reais validados;
- PUT continua sem persistencia e fail-closed;
- testes focados, suite completa, typecheck, Flutter Test, Flutter Analyze,
  hashes, diff check e escopo aprovados;
- nenhum commit, push, deploy ou recurso Cloudflare durante a aplicacao.

## Proxima fronteira

SEC-R2-002A.6D - contrato de idempotencia e porta privada de persistencia R2,
ainda sem provisionamento produtivo.

## Homologacao local

Baseline: merge `4ed6dadd1dc0ba9362874b62d1a13de49dc61f28`.

Branch: `security/sec-r2-002a-6c-put-validation`.

Resultado em 2026-09-13:

- teste focado A.6C: 53/53;
- suite Evidence Worker: 80/80;
- TypeScript typecheck: PASS;
- Flutter Test: PASS;
- Flutter Analyze: PASS, 0 issues;
- registrants EOL: CLEAN;
- hashes, diff check e escopo: PASS;
- PUT apos validacao: `501` fail-closed;
- R2 Binding: ausente;
- `remoteStorageEnabled=false`;
- nenhum deploy, bucket, binding ou secret executado.

Status: HOMOLOGADO, INTEGRADO E ENCERRADO.

- PR #82: merged;
- merge na `main`:
  `987ae5a534b9bff1b1299cd437822052a688713c`;
- branches local e remota: removidas;
- working tree apos fechamento: limpa.

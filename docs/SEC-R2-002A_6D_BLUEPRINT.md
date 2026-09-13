# SEC-R2-002A.6D - Blueprint de Idempotencia e Porta Privada

## Objetivo

Definir e integrar o contrato atomico de idempotencia entre o upload validado
e uma futura implementacao privada de armazenamento Cloudflare R2.

A subetapa nao cria adapter R2, bucket, binding, secret ou deploy. A porta
produtiva permanece ausente e o Worker responde de forma fail-closed quando
nao recebe uma implementacao autorizada por injecao de dependencia.

## Decisao de concorrencia

A persistencia usa uma unica operacao `createIfAbsent`. A implementacao futura
da porta deve garantir atomicidade no provedor.

Nao e permitido implementar idempotencia como uma sequencia separada de
consulta e gravacao (`HEAD` seguido de `PUT`), porque duas requisicoes
concorrentes poderiam observar ausencia e sobrescrever o mesmo objeto.

Resultados admitidos pela porta:

- `created`: o objeto foi criado sem substituir outro;
- `already_exists`: o objeto ja existia e sua identidade completa e devolvida
  para comparacao;
- falha: indisponibilidade generica, sem expor detalhes do provedor.

Qualquer outro resultado e invalido e mantem o fluxo fechado.

## Identidade persistida

A identidade imutavel do objeto inclui:

- `objectKey` derivada server-side;
- `acaoId`;
- `evidenciaId`;
- `autorUserId`;
- `Content-Type` canonico;
- tamanho real em bytes;
- SHA-256 real;
- chave de idempotencia derivada server-side.

O `callerUid` identifica quem solicitou a operacao e e enviado separadamente
para auditoria. Ele nao substitui `autorUserId` e nao altera a identidade do
objeto em uma repeticao autorizada.

## Regras de idempotencia

- ausencia do objeto: criacao atomica e resposta HTTP `201`;
- objeto existente com identidade integral equivalente: sucesso idempotente
  HTTP `200`, sem nova gravacao;
- qualquer metadado divergente: conflito HTTP `409`;
- sobrescrita silenciosa: proibida;
- URL publica, credencial ou identificador interno do provedor: nunca retornado
  ao cliente.

## Defesa na fronteira de persistencia

Antes de chamar a porta, o coordenador recalcula a `objectKey` e a chave de
idempotencia, valida novamente o contrato canonico e confere a coerencia entre
claims, SHA-256 validado e tamanho do `ArrayBuffer`.

O hash criptografico dos bytes continua sendo calculado pelo validador A.6C.
A.6D recebe apenas `ValidatedEvidenceUpload` depois dessa verificacao.

## Fail-closed

- validador ausente: `503 validator_unavailable`;
- porta privada ausente ou indisponivel: `503 storage_unavailable`;
- objeto existente divergente: `409 object_conflict`;
- resultado inesperado da porta: `503 storage_unavailable`;
- falha interna inesperada: `503` generico.

O default produtivo nao instala uma porta de persistencia. Assim, mesmo com
capability e bytes validos, nenhum armazenamento remoto ocorre nesta subetapa.

## Fora do escopo

- adapter Cloudflare R2;
- configuracao `R2Bucket` no Worker;
- consulta ou gravacao em bucket real;
- bucket, binding, secret, credencial ou deploy;
- URL publica ou presigned URL;
- habilitar `remoteStorageEnabled` no Flutter;
- remover a obrigatoriedade do original local.

## Criterios de homologacao

- `createIfAbsent` e a unica porta de escrita;
- caller e autor permanecem distintos;
- metadados identicos produzem sucesso idempotente;
- qualquer divergencia produz conflito sem sobrescrita;
- porta ausente ou falha produz `503` generico;
- resposta de sucesso nao expoe URL ou detalhe do storage;
- testes focados, suite completa, typecheck, Flutter Test, Flutter Analyze,
  hashes, diff check e escopo aprovados;
- nenhum recurso remoto ou commit durante a aplicacao.

## Baseline

- `main`: `987ae5a534b9bff1b1299cd437822052a688713c`;
- branch: `security/sec-r2-002a-6d-idempotency-port`;
- estado inicial: A.6C integrada pelo PR #82.

## Proxima fronteira

Uma etapa posterior podera implementar o adapter Cloudflare R2 e seu wiring,
somente depois de autorizacao especifica para infraestrutura e homologacao do
contrato desta A.6D.

## Homologacao local

Resultado em 2026-09-13:

- baseline e hashes: PASS;
- teste focado A.6D: 53/53;
- suite Evidence Worker: 99/99;
- TypeScript typecheck: PASS;
- Flutter Test: PASS;
- Flutter Analyze: PASS, 0 issues;
- registrants EOL: CLEAN;
- `git diff --check` e escopo: PASS;
- criacao atomica `createIfAbsent`: PASS;
- repeticao integralmente identica: HTTP `200` sem regravacao;
- criacao nova: HTTP `201`;
- divergencia: HTTP `409` sem sobrescrita;
- porta produtiva ausente: HTTP `503` fail-closed;
- R2 adapter/binding: ausentes;
- `remoteStorageEnabled=false`;
- nenhum deploy, bucket, binding ou secret executado.

Status: HOMOLOGADO LOCALMENTE / PRE-COMMIT.

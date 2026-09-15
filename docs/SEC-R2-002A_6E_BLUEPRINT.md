# SEC-R2-002A.6E - Blueprint do Adapter Cloudflare R2

## Objetivo

Implementar a porta `EvidencePrivateStoragePort` sobre um binding privado
Cloudflare R2, preservando a criacao atomica, a idempotencia integral e o
bloqueio de sobrescrita definidos na A.6D.

Esta subetapa implementa e testa o adapter e seu wiring local. Ela nao cria
bucket, nao adiciona `r2_buckets` ao `wrangler.jsonc`, nao configura binding ou
secret, nao executa deploy e nao altera `remoteStorageEnabled=false`.

## Operacao atomica

O adapter inicia pela escrita condicional:

- `put(objectKey, bytes, { onlyIf: { etagDoesNotMatch: "*" } })`;
- checksum SHA-256 informado ao R2;
- `Content-Type: image/jpeg` canonico;
- metadados imutaveis derivados server-side.

O wildcard na precondicao representa criacao somente se ausente. Se a
precondicao falhar, o R2 retorna `null`; somente entao o adapter usa `head`
para validar o objeto que venceu a corrida. Portanto, nao existe a sequencia
vulneravel `HEAD` seguido de `PUT`.

## Metadados persistidos

O objeto privado carrega:

- versao de schema `fenix-evidence-private-v1`;
- `acaoId`;
- `evidenciaId`;
- `autorUserId`;
- `Content-Type` canonico;
- tamanho em bytes;
- SHA-256;
- chave de idempotencia;
- `requestedByCallerUid` separado do autor para auditoria.

Na leitura idempotente, o adapter valida a chave fisica, o tamanho fisico, o
HTTP metadata, o checksum SHA-256 retornado pelo R2 e todos os metadados
canonicos. Metadado ausente, malformado ou divergente produz conflito e nunca
autoriza sobrescrita.

## Resultados e fail-closed

- criacao confirmada: `created`, convertido em HTTP `201`;
- precondicao falhou e identidade e integralmente equivalente:
  `already_exists`, convertido em HTTP `200`;
- objeto existente invalido ou divergente: `conflict`, convertido em HTTP
  `409 object_conflict`;
- estado indisponivel apos a precondicao ou falha do provedor: HTTP `503
  storage_unavailable`, sem vazamento de detalhe interno.

Uma resposta de criacao do R2 tambem e validada antes do sucesso. Resposta
fisicamente incoerente fecha o fluxo.

## Wiring controlado

`createR2EvidenceUploadPersister` somente cria o persister quando recebe
`EVIDENCE_BUCKET` por injecao. Sem o binding, o comportamento anterior
permanece `503` fail-closed.

Mesmo com um binding simulado, o validador A.6C continua obrigatorio e ocorre
antes da persistencia. O healthcheck permanece
`remoteStorageEnabled=false`, pois nenhuma infraestrutura produtiva e ativada
nesta entrega.

## Fronteiras operacionais

Permanecem fora da A.6E:

- criar ou consultar bucket real;
- adicionar binding ao `wrangler.jsonc`;
- criar credencial, token ou secret;
- executar deploy;
- habilitar storage remoto no aplicativo;
- remover a obrigatoriedade da evidencia local;
- tornar o bucket ou objetos publicos.

## Criterios de homologacao

- PUT condicional e a primeira operacao;
- `head` ocorre somente apos falha da precondicao;
- checksum SHA-256 e enviado e conferido;
- metadados fisicos e logicos sao conferidos integralmente;
- caller e autor continuam distintos;
- repeticao equivalente e idempotente;
- divergencia nao sobrescreve;
- falhas do R2 sao convertidas em resposta generica;
- binding ausente preserva fail-closed;
- testes focados, suite completa, typecheck, Flutter Test, Flutter Analyze,
  hashes, diff check e escopo aprovados;
- `wrangler.jsonc` permanece sem `r2_buckets`;
- nenhum recurso remoto, commit ou publicacao durante a aplicacao.

## Baseline

- `main`: `34d71d540fd12ba2f04c24124e9c02910c25e069`;
- branch: `security/sec-r2-002a-6e-r2-adapter`;
- estado inicial: A.6D integrada pelo PR #83.

## Referencias oficiais

- Cloudflare R2 Workers API Reference:
  <https://developers.cloudflare.com/r2/api/workers/workers-api-reference/>;
- Cloudflare R2 Workers API Usage:
  <https://developers.cloudflare.com/r2/api/workers/workers-api-usage/>.

## Proxima fronteira

Depois da homologacao, fechamento, PR e merge da A.6E, uma etapa separada
podera propor o provisionamento e a ativacao controlada da infraestrutura.
Essa etapa exigira autorizacao explicita e novos gates operacionais.

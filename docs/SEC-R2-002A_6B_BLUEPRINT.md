# SEC-R2-002A.6B - Blueprint de Emissao do Upload Grant

## Objetivo

Conectar autenticacao, contrato, ACL e capability HMAC-SHA256 para emitir
um `EvidenceAccessGrant` de upload compativel com o aplicativo Flutter.

`remoteStorageEnabled` permanece `false`. O endpoint PUT e o R2 real
continuam bloqueados nesta subetapa.

## Fluxo autorizado

1. autenticar o caller pelo Firebase ID Token;
2. validar o contrato de entrada;
3. aplicar ACL server-side sobre o RAE;
4. validar `autorUserId` por fonte autoritativa;
5. derivar `objectKey` e chave de idempotencia no backend;
6. emitir capability HMAC-SHA256 com expiracao maxima de cinco minutos;
7. retornar grant HTTPS sem credencial permanente.

## Separacao de identidades

`callerUid` identifica quem solicita o grant.

`autorUserId` identifica quem originou ou capturou a evidencia.

As identidades podem ser diferentes. A emissao exige um
`EvidenceAuthorBindingVerifier` autoritativo e nunca presume igualdade entre
caller e autor. Ausencia, negativa ou indisponibilidade dessa verificacao
mantem o fluxo fechado.

## Contrato de resposta

O grant retorna:

- `uri`: endpoint HTTPS temporario contendo a capability;
- `operation`: `upload`;
- `expiresAt`: instante UTC ISO-8601;
- `objectKey`: chave derivada pelo backend;
- `requiredHeaders`: `Content-Type` e chave de idempotencia;
- `uploadIdentity`: `acaoId`, `evidenciaId` e `sha256`.

## Capability

A capability assinada vincula:

- caller autenticado;
- autor da evidencia;
- RAE e evidencia;
- MIME, tamanho e SHA-256 declarados;
- objectKey autoritativa;
- emissao e expiracao.

O TTL e inteiro positivo e nunca superior a 300 segundos. A origem publica
deve ser HTTPS, sem credenciais, path, query ou fragmento.

## Fail-closed

- verificador de autor ausente ou indisponivel: grant negado;
- autor sem vinculo autoritativo: grant negado;
- emissor nao configurado: grant indisponivel;
- falha inesperada do emissor: resposta generica sem vazamento interno;
- PUT `/v1/evidencias/upload/{capability}`: permanece `501`;
- nenhum bucket, binding, secret ou deploy e criado;
- `remoteStorageEnabled=false` permanece inalterado.

## Fora do escopo

- validar a capability no endpoint PUT;
- receber ou inspecionar bytes;
- recalcular SHA-256 server-side;
- implementar idempotencia contra R2;
- gravar no bucket;
- configurar Firebase Admin, fonte autoritativa ou secrets produtivos;
- habilitar armazenamento remoto.

## Criterios de homologacao

- grant compativel com `EvidenceAccessGrant`;
- caller e autor distintos preservados;
- verificacao autoritativa do autor obrigatoria;
- objectKey e idempotencia derivadas server-side;
- capability HMAC valida e curta;
- negativas e indisponibilidades fail-closed;
- PUT/R2 e feature flag continuam bloqueados;
- testes focados, suite, typecheck, Flutter Test, Flutter Analyze e diff check
  aprovados.

## Proxima fronteira

SEC-R2-002A.6C - validacao da capability e do contrato de bytes no endpoint
PUT, ainda sem habilitacao produtiva.

## Homologacao

Status em 2026-09-13: HOMOLOGADO LOCALMENTE / PRE-COMMIT.

- testes focados: 23/23;
- suite Evidence Worker: 57/57;
- Flutter Test: 971/971;
- TypeScript typecheck: PASS;
- Flutter Analyze: PASS, 0 issues;
- hashes e escopo controlado: PASS;
- registrants EOL: CLEAN;
- PUT/R2: fail-closed;
- armazenamento remoto: desabilitado.

# AUD-L2-R5.4-E — Upload Failure Hardening

## Objetivo

Endurecer o contrato de erro do upload remoto antes da introdução de HTTP real
e antes da integração com o futuro `SyncService`.

## Decisão arquitetural

O transporte executa exatamente **uma tentativa HTTP por chamada**.

Ele não implementa retry automático.

A política de nova tentativa pertence ao orquestrador de sincronização, porque
uma nova tentativa pode exigir:

- revalidar conectividade;
- observar backoff;
- renovar um grant expirado ou próximo da expiração;
- impedir loops silenciosos;
- registrar telemetria/auditoria;
- decidir quando preservar a evidência apenas localmente.

## Erros tipados

`RemoteEvidenceUploadException` distingue:

- `invalidRequest`;
- `invalidGrant`;
- `missingContentType`;
- `contentTypeMismatch`;
- `httpRejected`;
- `transportFailure`.

O chamador não precisa interpretar strings de `StateError`.

## Retry candidate

A exceção apenas classifica se uma falha **pode** admitir retry pelo
orquestrador.

São candidatos:

- falha de transporte;
- HTTP 408;
- HTTP 425;
- HTTP 429;
- HTTP 5xx.

Demais falhas de pré-condição e 4xx comuns não são candidatas.

Essa classificação não dispara retry.

## Fora do escopo

- retry automático;
- backoff;
- fila de sincronização;
- pacote `http`;
- Dio;
- tráfego HTTP real;
- Worker/backend;
- Cloudflare R2 real;
- renovação real de grant;
- credenciais no APK.

## Baseline

`7d17cfb5c3f67295ded46cdea4ce5004f99584aa`

Status: HOMOLOGADO LOCALMENTE — NÃO COMMITADO / NÃO PUBLICADO.
## Validação final

- testes focados R5.4-E/R1: aprovados;
- regressão Flutter completa: aprovada;
- `flutter analyze`: 0 issues;
- `git diff --check`: aprovado;
- escopo final: 7 caminhos Git previstos confirmados;
- falhas de upload: tipadas por `RemoteEvidenceUploadException`;
- request inválido: rejeitado antes do HTTP;
- grant inválido/expirado: rejeitado antes do HTTP;
- `Content-Type` ausente/divergente: rejeitado antes do HTTP;
- HTTP 403/4xx comum: não candidato a retry;
- HTTP 408/425/429/5xx: candidato a retry externo;
- falha de transporte: candidata a retry externo;
- retry automático no transporte: não;
- tentativas HTTP por chamada: exatamente 1;
- política de retry/backoff: futura responsabilidade do `SyncService`/orquestrador;
- HTTP real: não;
- Worker/backend produtivo: não;
- Cloudflare R2 real: não;
- credenciais no APK: nenhuma.
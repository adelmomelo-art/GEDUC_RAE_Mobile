# AUD-L2-R5.4-F — Integration Closure

## Objetivo

Fechar tecnicamente o bloco AUD-L2-R5.4 consolidando os contratos introduzidos
nas subetapas A-E antes de iniciar o R5.5.

Esta etapa nao cria novo adapter de producao e nao introduz HTTP real.

## Decisao arquitetural

O R5.4-F funciona como gate de integracao.

Ele confirma que o plano de dados remoto permanece dividido em fronteiras
claras:

```text
Flutter / futura sincronizacao
        |
        | solicita grant
        v
EvidenceAccessBroker / backend confiavel
        |
        | EvidenceAccessGrant
        v
RemoteEvidenceTransport
        |
        | SignedUrlRemoteEvidenceTransport
        v
EvidenceHttpClient
        |
        | PUT autorizado
        v
storage privado
```

## Invariantes consolidados A-E

1. o cliente nao fabrica grant;
2. o cliente nao decide ACL de forma autoritativa;
3. a URL remota precisa ser HTTPS e possuir host;
4. o objectKey vem do grant confiavel;
5. grant expirado ou de operacao incorreta falha antes do HTTP;
6. Content-Type autorizado precisa coincidir com o request;
7. headers assinados sao tratados como opacos;
8. o transporte executa exatamente uma tentativa HTTP por chamada;
9. resposta nao-2xx nao marca sincronizacao;
10. ETag e opcional e nao equivale ao SHA-256;
11. falhas sao tipadas por RemoteEvidenceUploadException;
12. retryCandidate apenas classifica recuperabilidade;
13. retry/backoff pertence ao futuro SyncService/orquestrador;
14. credenciais permanentes nao entram no APK;
15. nenhuma dependencia de Cloudflare R2/B2 e incorporada ao contrato Flutter.

## Escopo

- teste transversal do contrato integrado A-E;
- consolidacao documental da arquitetura R5.4;
- registro do gate para entrada no R5.5.

## Fora do escopo

- HTTP real;
- pacote http;
- Dio;
- Worker/backend produtivo;
- Cloudflare R2 real;
- Backblaze B2 real;
- fila de sincronizacao;
- retry automatico;
- backoff;
- renovacao real de grant;
- download remoto;
- DELETE remoto;
- credenciais no APK.

## Baseline

`766a83a65de7c84e819dc2fd499f86c9d835d3ff`

Status: HOMOLOGADO LOCALMENTE — NÃO COMMITADO / NÃO PUBLICADO.
## Validação final

- teste transversal R5.4-F: aprovado;
- regressão `test/core/storage`: aprovada;
- `flutter analyze`: 0 issues;
- `git diff --check`: aprovado;
- escopo final: exatamente 4 caminhos Git;
- nenhuma alteração adicional em código de produção;
- plano de controle e plano de dados permanecem separados;
- grant continua sendo emitido apenas pela fronteira confiável;
- `objectKey` continua vindo do grant;
- `Content-Type` permanece fail-closed;
- uma única tentativa HTTP por chamada permanece obrigatória;
- `retryCandidate` continua sendo somente classificação;
- retry/backoff permanece fora do transporte;
- HTTP real: não;
- Worker/backend produtivo: não;
- Cloudflare R2/B2 real: não;
- credenciais no APK: nenhuma.

## Gate oficial para R5.5

O R5.5 fica autorizado arquiteturalmente apenas para responsabilidades de
sincronização/orquestração.

O R5.5 poderá tratar:

- fila de sincronização;
- conectividade;
- backoff;
- decisão de nova tentativa;
- renovação de grant por uma fronteira confiável;
- atualização do estado local após confirmação remota.

O R5.5 não deverá assumir:

- credenciais permanentes do provedor;
- assinatura local de URLs;
- ACL autoritativa no cliente;
- fabricação arbitrária de `objectKey`;
- retry interno do adapter;
- dependência obrigatória de Cloudflare R2 ou B2 no domínio Flutter.
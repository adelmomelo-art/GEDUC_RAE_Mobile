# AUD-L2-R5.4-D — Signed URL Remote Transport

## Objetivo

Implementar a ligação entre `RemoteEvidenceTransport` e `EvidenceHttpClient`
consumindo somente um `EvidenceAccessGrant` previamente autorizado.

## Decisão arquitetural

Não é criado um `CloudflareR2Transport`.

O aplicativo não precisa conhecer o provedor quando recebe:

- uma URI HTTPS autorizada;
- headers obrigatórios;
- operação permitida;
- expiração;
- `objectKey` autorizada.

O transporte é, portanto, `SignedUrlRemoteEvidenceTransport`.

Isso mantém Cloudflare R2, Backblaze B2 ou outro provedor fora do núcleo do
aplicativo. A escolha do provedor e a assinatura continuam pertencendo ao
backend confiável.

## Fluxo

```text
EvidenceAccessBroker
        |
        v
EvidenceAccessGrant
        |
        v
SignedUrlRemoteEvidenceTransport
        |
        v
EvidenceHttpClient
        |
        v
resposta HTTP simulada
```

## Regras fail-closed

O upload é rejeitado antes de qualquer chamada HTTP quando:

- o request é inválido;
- o grant não é de upload;
- o grant expirou;
- o grant não autoriza `Content-Type`;
- o `Content-Type` local diverge do autorizado.

Após a chamada HTTP, somente resposta 2xx produz
`RemoteEvidenceUploadResult`.

## Resultado

O resultado:

- usa `objectKey` exclusivamente do grant;
- registra `syncedAt` somente depois do sucesso;
- pode registrar `ETag`, se presente;
- não interpreta `ETag` como SHA-256;
- não inventa `sizeBytes`.

## Fora do escopo

- pacote `http`;
- Dio;
- tráfego de rede real;
- endpoint Cloudflare R2 real;
- Worker/backend produtivo;
- credenciais;
- assinatura SigV4 no APK;
- persistência do signed grant;
- SyncService;
- DELETE remoto.

## Baseline

`75176edfe61b273bb3b95de7d05e1b8cfe1513c6`

Status: HOMOLOGADO LOCALMENTE — NÃO COMMITADO / NÃO PUBLICADO.
## Validação final

- testes focados R5.4-D: aprovados;
- regressão Flutter completa: aprovada;
- `flutter analyze`: 0 issues;
- `git diff --check`: aprovado;
- escopo final: 5 caminhos Git previstos confirmados;
- `SignedUrlRemoteEvidenceTransport`: habilitado somente quando instanciado;
- grant de upload: validado antes do HTTP;
- grant expirado: rejeitado antes do HTTP;
- operação incompatível: rejeitada antes do HTTP;
- `Content-Type`: obrigatório e compatível com o grant;
- URI e headers: preservados a partir do grant;
- HTTP não-2xx: não produz sincronização;
- `objectKey`: exclusivamente do grant;
- `ETag`: opcional, sem equivalência com SHA-256;
- pacote `http`/Dio: não adicionado;
- tráfego HTTP real: não;
- Cloudflare R2 real: não;
- Worker/backend produtivo: não;
- credenciais no APK: nenhuma.
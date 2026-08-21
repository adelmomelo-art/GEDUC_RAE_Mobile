# AUD-L2-R5.4-C — Abstração de transporte HTTP

## Objetivo

Introduzir uma porta HTTP neutra de provedor para o plano de dados de
evidências, sem executar tráfego de rede real.

## Decisão arquitetural

O `EvidenceAccessGrant` passa a transportar também a `objectKey` autorizada pela
fronteira confiável.

Essa alteração resolve uma lacuna do contrato anterior:

- `RemoteEvidenceUploadResult` precisa registrar `objectKey`;
- o cliente não pode derivar a chave a partir da signed URL;
- o cliente não deve transformar `buildObjectKey()` em autoridade remota;
- portanto a chave remota confirmada precisa chegar junto da autorização.

## Contrato HTTP

São introduzidos:

- `EvidenceHttpPutRequest`;
- `EvidenceHttpResponse`;
- `EvidenceHttpClient`.

O contrato HTTP:

- aceita somente HTTPS;
- recebe caminho de arquivo local;
- preserva headers como dados opacos;
- classifica somente respostas 2xx como sucesso;
- permite consulta case-insensitive de headers de resposta.

## Limites de confiança

O cliente HTTP não pode:

- criar ou assinar grants;
- decidir ACL;
- determinar identidade;
- possuir credenciais permanentes;
- conhecer segredo R2;
- inventar `objectKey`.

## Fora do escopo

- pacote `http`;
- Dio;
- tráfego HTTP real;
- Cloudflare R2 real;
- Worker/backend;
- signed URL real;
- upload real;
- DELETE remoto;
- SyncService;
- Providers;
- rotas.

## Baseline

`8c04ba7e661942f212abfd15c840cb54f8ff7d0e`

Status: HOMOLOGADO LOCALMENTE — NÃO COMMITADO / NÃO PUBLICADO.
## Validação final

- testes focados R5.4-C: aprovados;
- regressão Flutter completa: aprovada;
- `flutter analyze`: 0 issues;
- `git diff --check`: aprovado;
- escopo final: 9 caminhos Git previstos confirmados;
- `EvidenceAccessGrant.objectKey`: obrigatória e emitida pela fronteira confiável;
- `EvidenceHttpClient`: abstração somente;
- `EvidenceHttpPutRequest`: HTTPS + host + caminho local;
- `EvidenceHttpResponse`: somente 2xx como sucesso;
- headers de resposta: consulta case-insensitive;
- pacote `http`: não adicionado;
- Dio: não adicionado;
- tráfego HTTP real: não;
- Cloudflare R2 real: não;
- Worker/backend remoto: não;
- credenciais no APK: nenhuma.
# AUD-L2-R5.4-B — Hardening de grants e object keys

## Objetivo

Endurecer duas fronteiras antes da introdução de transporte HTTP real:

1. validade estrutural e temporal de `EvidenceAccessGrant`;
2. normalização segura dos identificadores usados em object keys.

## EvidenceAccessGrant

Um grant somente é considerado válido quando:

- usa `https`;
- possui host não vazio;
- `expiresAt` está estritamente no futuro em relação ao instante informado.

O método `validoPara(...)` acrescenta a verificação da operação esperada,
evitando que um grant de leitura seja aceito como grant de upload ou vice-versa.

## Object key

`buildObjectKey()` continua bloqueando `/` e `\` e passa a rejeitar também os
identificadores reservados:

- `.`
- `..`

A convenção permanece:

```text
evidencias/{acaoId}/{evidenciaId}{ext}
```

A convenção cliente não transforma o cliente em autoridade do caminho remoto.
A autoridade final do object key continuará pertencendo ao backend confiável
quando a integração real for introduzida.

## Fora do escopo

- HTTP real;
- Cloudflare R2 real;
- Worker/backend;
- credenciais;
- signed URL real;
- nova dependência;
- DELETE remoto;
- SyncService;
- Providers;
- rotas.

## Baseline

`ead4fe18b9e5ebb35a508baecbc6242b9d18fd2f`

Status: HOMOLOGADO LOCALMENTE — NÃO COMMITADO / NÃO PUBLICADO.

## Validação final

- testes focados R5.4-B: aprovados;
- regressão Flutter completa: aprovada;
- `flutter analyze`: 0 issues;
- `git diff --check`: aprovado;
- escopo final: 7 caminhos Git previstos confirmados;
- grant exige `https`;
- grant exige host não vazio;
- grant rejeita expiração vencida ou igual ao instante de validação;
- `validoPara(...)` exige operação compatível;
- `buildObjectKey()` rejeita `.` e `..`;
- bloqueio de `/` e `\` preservado;
- HTTP real: não;
- Cloudflare R2 real: não;
- Worker/backend remoto: não;
- nova dependência: não;
- credenciais remotas no APK: nenhuma.
# AUD-L2-R5.2 â€” Evidence Metadata + SHA-256

**Etapa:** R5.2-A/B
**Status:** EM IMPLEMENTAÃ‡ÃƒO / NÃƒO HOMOLOGADO

## Objetivo

Enriquecer cada evidÃªncia local com metadados verificÃ¡veis, sem ativar armazenamento remoto.

## R5.2-A â€” Metadata Core

O `EvidenciaModel` passa a suportar:

- `sha256`;
- `tamanhoBytes`;
- `mimeType`;
- `objectKey`;
- `sincronizadoEm`;
- `autorUserId`.

A desserializaÃ§Ã£o permanece compatÃ­vel com registros legados que nÃ£o possuem esses campos.

## R5.2-B â€” Local Metadata Binding

ApÃ³s a cÃ³pia local definitiva, o `EvidenciaStorageService` calcula:

1. SHA-256;
2. tamanho real em bytes;
3. MIME type.

O arquivo salvo localmente continua sendo a fonte operacional.

## Invariantes

1. SHA-256 Ã© calculado sobre o arquivo local definitivo.
2. `objectKey` permanece vazio enquanto nÃ£o existir confirmaÃ§Ã£o remota.
3. `sincronizadoEm` permanece nulo enquanto local-only.
4. `autorUserId` permanece vazio atÃ© a etapa especÃ­fica de Identity Binding.
5. EvidÃªncias legadas continuam legÃ­veis.
6. O R5.2-A/B nÃ£o altera `AcaoModel`, `SyncService`, Providers ou rotas.
7. Cloudflare R2 nÃ£o Ã© ativado nesta etapa.

## Object key futura

O builder canÃ´nico prepara o formato:

```text
evidencias/{acaoId}/{evidenciaId}.{ext}
```

A existÃªncia da chave calculÃ¡vel nÃ£o significa que o objeto jÃ¡ exista remotamente.
## R5.2-R1 — Nullable semantics + full regression

Correção preventiva aplicada antes do primeiro commit:

- `copyWith` passou a permitir limpeza explícita de `sincronizadoEm`;
- o estado remoto pode voltar para não sincronizado sem ambiguidade;
- regressão Flutter completa é obrigatória antes do commit da etapa.

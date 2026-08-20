# AUD-L2-R5 — Evidence Storage Architecture

**Etapa atual:** R5.1 — Arquitetura híbrida Local + Remote
**Status:** R5.1 HOMOLOGADO LOCALMENTE
**Princípio:** armazenamento local continua obrigatório; armazenamento remoto é opcional e desabilitado por padrão.

## Decisão econômica

As evidências fotográficas não utilizam Firebase Storage no fluxo atual por decisão consciente de custo. O R5 não altera essa decisão e não ativa qualquer serviço remoto pago.

## R5.1 — Objetivo

Criar uma fronteira arquitetural que permita integrar futuramente Cloudflare R2, Backblaze B2 ou outro provedor sem acoplar o restante do aplicativo ao fornecedor.

## Entregas

- `RemoteEvidenceStorage`: contrato neutro para upload, leitura temporária e exclusão;
- `RemoteEvidenceUploadRequest` / `RemoteEvidenceUploadResult`: contratos de transferência;
- `DisabledRemoteEvidenceStorage`: implementação fail-closed enquanto não houver provedor configurado;
- `EvidenceStoragePolicy`: explicita local-first e remoto desligado por padrão;
- testes unitários do contrato e da política.

## Não faz parte do R5.1

- Cloudflare R2 real;
- credenciais;
- URL pré-assinada;
- upload de fotos;
- alteração no `SyncService`;
- alteração no `EvidenciaStorageService`;
- mudança em Providers ou rotas;
- Firebase Storage;
- publicação em produção.

## Arquitetura

```text
Captura
  |
  v
EvidenciaStorageService (LOCAL, existente e obrigatório)
  |
  +--> EvidenciaModel(status: pendente)
  |
  `--> [futuro]
       RemoteEvidenceStorage
             |
             +--> CloudflareR2EvidenceStorage
             +--> BackblazeB2EvidenceStorage
             `--> outro adaptador
```

A ausência de provedor remoto deve falhar de forma fechada e nunca impedir a persistência local da evidência.

## Próximas etapas propostas

- R5.2 — metadados remotos + hash SHA-256;
- R5.3 — serviço autorizador e URLs pré-assinadas;
- R5.4 — adaptador Cloudflare R2;
- R5.5 — sincronização offline de evidências;
- R5.6 — compressão e telemetria de consumo.
## Homologação R5.1

```text
Testes focados:               8/8
flutter analyze:              No issues found
git diff --check:             aprovado
Armazenamento local:          obrigatório
Armazenamento remoto:         desabilitado por padrão
Cloudflare R2:                não integrado
Credenciais remotas:          inexistentes
Upload remoto real:           inexistente
```

### Parecer

O R5.1 está homologado localmente como fundação arquitetural não invasiva. Nenhuma evidência fotográfica passou a depender de serviço remoto. O fluxo operacional existente continua local-first.

Commit, push, Pull Request e qualquer integração real com provedor remoto permanecem etapas separadas.

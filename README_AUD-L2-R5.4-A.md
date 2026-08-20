# AUD-L2-R5.4-A — Refatoração do contrato remoto

## Objetivo

Remover do contrato cliente qualquer responsabilidade de concessão de acesso
remoto e separar definitivamente:

- **plano de controle**: `EvidenceAccessBroker`;
- **plano de dados**: `RemoteEvidenceTransport`.

## Alteração principal

O contrato legado `RemoteEvidenceStorage` foi substituído por
`RemoteEvidenceTransport`.

O transporte possui somente uma responsabilidade:

> executar transferência usando um `EvidenceAccessGrant` previamente emitido.

O transporte não pode:

- criar URL assinada;
- assinar requisições com credenciais permanentes;
- decidir ACL;
- determinar identidade;
- autorizar exclusão;
- carregar segredo R2 dentro do APK.

## Contrato R5.4-A

```dart
abstract interface class RemoteEvidenceTransport {
  bool get enabled;

  Future<RemoteEvidenceUploadResult> upload({
    required EvidenceAccessGrant grant,
    required RemoteEvidenceUploadRequest request,
  });
}
```

## Exclusão remota

Continua fora do contrato e bloqueada.

## Leitura remota

Não é implementada nesta subetapa. O fluxo de leitura será especificado
posteriormente sem devolver ao transporte autoridade para fabricar grants.

## Invariantes preservadas

- armazenamento local obrigatório;
- remoto desligado por padrão;
- nenhum Worker;
- nenhum Cloudflare R2 real;
- nenhuma credencial;
- nenhuma nova dependência;
- nenhum HTTP real;
- nenhuma alteração em Provider, rotas, `SyncService` ou `AcaoModel`.

## Baseline

`8d4e0c2`

Status: HOMOLOGADO LOCALMENTE — NÃO COMMITADO / NÃO PUBLICADO.

## Validação final

- testes focados R5.3 + R5.4-A: aprovados;
- regressão Flutter completa: aprovada;
- `flutter analyze`: 0 issues;
- `git diff --check`: aprovado;
- escopo final: 9 caminhos Git previstos confirmados;
- contrato legado `RemoteEvidenceStorage`: removido;
- `createReadUri()` no plano de dados: removido;
- `delete()` no plano de dados: removido;
- HTTP real: não;
- Cloudflare R2 real: não;
- Worker/backend remoto: não;
- nova dependência: não;
- credenciais remotas no APK: nenhuma.
# AUD-L2-R5.3 — Autorização Remota e URLs Assinadas

## Objetivo

Estabelecer a fronteira de autorização para o futuro acesso remoto às
evidências sem introduzir credenciais, assinatura ou autoridade de bucket no
aplicativo Flutter.

## Trust boundary

```text
Flutter
  |
  | token autenticado
  v
EvidenceAccessBroker
  |
  v
Backend confiável futuro
  |
  +-- valida identidade
  +-- valida ACL do RAE
  +-- define operação
  +-- emite grant temporário
  |
  v
Armazenamento privado
```

## Invariantes

1. O APK não contém segredo de assinatura nem credencial de provedor.
2. O cliente não prova identidade enviando `autorUserId`.
3. A identidade será derivada pelo backend a partir do token autenticado.
4. Leitura remota futura deverá exigir autorização equivalente a
   `Permission.consultarRae`.
5. Upload futuro deverá exigir autorização equivalente a `Permission.editarRae`.
6. Exclusão remota permanece fora do R5.3 e deve falhar fechado.
7. O armazenamento local continua obrigatório e independente da nuvem.
8. O broker padrão permanece desabilitado.

## Componentes

- `EvidenceRemoteOperation`;
- `EvidenceReadAccessRequest`;
- `EvidenceUploadAccessRequest`;
- `EvidenceAccessGrant`;
- `EvidenceAccessBroker`;
- `DisabledEvidenceAccessBroker`.

## Fora do escopo

- Cloudflare Worker real;
- bucket Cloudflare R2;
- credenciais R2;
- Firebase token verification no backend;
- HTTP upload/download real;
- SyncService;
- deploy;
- URLs assinadas reais.

Status: HOMOLOGADO LOCALMENTE — NÃO COMMITADO / NÃO PUBLICADO.

## Validação final

- testes focados R5.1 + R5.3: aprovados;
- regressão Flutter completa: aprovada;
- `flutter analyze`: 0 issues;
- `git diff --check`: aprovado;
- escopo final: 8 arquivos previstos confirmados;
- integração R2 ativa: não;
- Worker/backend remoto: não;
- credenciais remotas no APK: nenhuma.
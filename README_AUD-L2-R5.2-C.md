# AUD-L2-R5.2-C — Identity Binding das Evidências

Fonte canônica: `AuthorizationService.usuarioAtual.id`.

Regras:
- evidência nova exige identidade operacional válida;
- sem fallback por nome ou e-mail;
- `EvidenciaStorageService` não depende de Firebase Auth/Firestore;
- `autorUserId` é normalizado e persistido no `EvidenciaModel`;
- legados com `autorUserId == ''` continuam legíveis;
- Cloudflare R2, SyncService, AcaoModel, rotas e novos Providers ficam fora do escopo.

Status: HOMOLOGADO LOCALMENTE — NÃO COMMITADO / NÃO PUBLICADO.

## Validação

- testes focados R5.2-C/R1: aprovados;
- regressão Flutter completa: aprovada;
- `flutter analyze`: 0 issues;
- `git diff --check`: aprovado;
- escopo final antes da documentação: 5 arquivos previstos confirmados.
# AUD-L2-R3 — Operational Identity & Legacy Integrity

## Objetivo

Saneamento dos achados de integridade operacional identificados na auditoria pós-implementação do Lote 2 — Equipe Operacional / Recursos Operacionais.

## Alterações implementadas

### R3.1 — Coordenador elegível

O coordenador da ação somente é considerado válido quando:

- possui identidade resolvida na Equipe Operacional;
- está ativo;
- possui `podeCoordenar = true`.

Coordenadores inativos ou sem habilitação administrativa não permitem avanço no fluxo de Recursos Operacionais.

### R3.2-A — Identidade canônica

A resolução por `id` ou `usuarioId` é tratada como identidade canônica.

O fallback por nome permanece disponível exclusivamente para compatibilidade histórica, mas não autoriza avanço do fluxo até regularização do vínculo de identidade.

### R3.2-B — Proteção de registros legados

RAEs antigos que possuem somente quantitativos de agentes e terceirizados continuam sendo lidos sem alteração.

Antes da conversão para equipe nominal, o usuário recebe confirmação explícita informando que os quantitativos históricos serão substituídos pela nova seleção nominal.

Cancelar a operação preserva integralmente o registro legado.

### R3.3 — Preservação do anoRAE

A persistência remota não recalcula mais o exercício com base na data da sincronização.

Regra aplicada:

- se `anoRAE > 0`, o valor existente é preservado;
- se `anoRAE == 0`, o ano é derivado de `dataAcao.year`.

Isso protege ações sincronizadas posteriormente, inclusive em virada de exercício.

## Arquivos alterados

- `lib/core/services/firebase_acao_service.dart`
- `lib/modules/recursos/recursos_operacionais_page.dart`
- `test/core/services/firebase_acao_service_test.dart`
- `test/modules/recursos/recursos_operacionais_page_test.dart`
- `test/support/acao_fixture.dart`

## Validação

- Recursos Operacionais: 11 testes aprovados
- FirebaseAcaoService: 6 testes aprovados
- Suíte completa Flutter: 699 testes aprovados
- `flutter analyze`: No issues found
- `git diff --check`: sem inconsistências

## Resultado

AUD-L2-R3 homologado tecnicamente para commit e PR.

## Próxima etapa

AUD-L2-R4 — ACL Application Readiness.
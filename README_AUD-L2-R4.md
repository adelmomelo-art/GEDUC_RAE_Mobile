# AUD-L2-R4 — ACL operacional e Send Gate

**Data de fechamento:** 19/08/2026
**Status:** HOMOLOGADO
**Escopo:** fortalecimento da classificação ACL dos RAEs, identidade canônica, resolução determinística de escopo e gate final de envio.

## 1. Objetivo

Eliminar decisões de autorização baseadas em identidade nominal ou escopo ambíguo e garantir que um RAE novo somente possa ser enviado quando sua classificação ACL estiver íntegra e consistente.

## 2. Entregas

### R4.1 — ACL Core
- classificador central `RaeAclClassifier`;
- normalização dos cinco identificadores ACL;
- `aclClassificacaoCompleta` somente quando todos os identificadores obrigatórios estão presentes;
- `aclScopeKey` canônica no formato `r:<regional>|e:<equipe>|p:<projeto>`;
- compatibilidade preservada com a API histórica `classify()`.

### R4.2 — Identity Binding
- responsável vinculado por `responsavelUserId`;
- coordenador autorizado somente por identidade canônica;
- resolução por `MembroEquipeModel.usuarioId`;
- fallback por nome restrito a compatibilidade visual, sem poder de autorização;
- mudança de identidade invalida classificação ACL persistida.

### R4.3 — Scope Resolver
- resolução determinística de Regional, Equipe e Projeto;
- zero candidatos: não resolvido;
- um candidato: resolvido;
- múltiplos candidatos: ambíguo;
- nenhuma escolha arbitrária do primeiro candidato;
- escopos vazios ou incompatíveis falham de forma fechada;
- catálogo preserva `doc.id` do Firestore.

### R4.4-A — Final Classification
- classificação final centralizada no controller;
- persistência de `aclClassificacaoCompleta` e `aclScopeKey`;
- alteração posterior de Regional, identidade, Equipe ou Projeto invalida classificação anterior;
- compatibilidade com os contratos de R4.1 preservada.

### R4.4-B — Send Gate
- todo RAE em `rascunho` exige ACL completa antes do envio;
- `aclScopeKey` persistida é recalculada logicamente e comparada com a chave esperada;
- ACL persistida inconsistente bloqueia o envio;
- uma ACL já persistida e adulterada não é corrigida silenciosamente;
- registros históricos fora de `rascunho` não recebem bloqueio ACL retroativo.

## 3. Arquivos principais

### Produção
- `lib/core/security/rae_acl_classifier.dart`
- `lib/core/security/rae_identity_resolver.dart`
- `lib/core/security/rae_scope_resolver.dart`
- `lib/core/services/rae_scope_catalog_service.dart`
- `lib/modules/acoes/controllers/acao_controller.dart`
- `lib/modules/recursos/recursos_operacionais_page.dart`

### Testes
- `test/core/security/rae_acl_classifier_test.dart`
- `test/core/security/rae_identity_resolver_test.dart`
- `test/core/security/rae_scope_resolver_test.dart`
- `test/modules/acoes/controllers/acao_controller_acl_test.dart`
- `test/modules/acoes/controllers/acao_controller_acl_final_test.dart`
- `test/modules/acoes/controllers/acao_controller_acl_send_gate_test.dart`
- `test/modules/recursos/recursos_operacionais_page_test.dart`

## 4. Evidências de homologação

- `RaeAclClassifier`: 8/8
- `AcaoController ACL`: 9/9
- `R4.4-A Final Classification`: 7/7
- `R4.4-B Send Gate`: 5/5
- regressão completa: **755/755 testes aprovados**
- `flutter analyze`: **No issues found**
- `git diff --check`: sem erro de whitespace; somente aviso LF/CRLF do ambiente Windows, sem bloqueio técnico

## 5. Parecer

```text
R4.1 ACL Core:                 APROVADO
R4.2 Identity Binding:         APROVADO
R4.3 Scope Resolver:           APROVADO
R4.4-A Final Classification:   APROVADO
R4.4-B Send Gate:              APROVADO
Regressao completa:            755/755
Flutter Analyze:               0 issues
AUD-L2-R4:                     HOMOLOGADO
```

## 6. Limites do escopo

Este lote não publica regras Firebase, não altera dados remotos e não executa migração retroativa de RAEs históricos. A compatibilidade de registros legados é preservada no gate de envio.
## 7. Correção R1 — Regional Scope Enforcement

A revisão do PR #40 identificou que a resolução de escopo ainda não validava `AccessScope.regionalIds`. A R1 passa a exigir simultaneamente Regional, Equipe e Projeto no escopo permitido. Regional ausente ou fora do escopo falha de forma fechada.

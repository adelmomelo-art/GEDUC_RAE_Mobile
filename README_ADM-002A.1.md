# ADM-002A.1 — Fundação de Tipos de Ações

## Objetivo

Consolidar a fundação de domínio e dados do módulo Tipos de Ações, sem alterar ainda a interface administrativa homologável.

## Alterações

- modelo tolerante a documentos legados;
- uso prioritário do `document.id`;
- normalização de textos e materiais;
- validação de campos e públicos;
- chave normalizada para detecção de duplicidade;
- data source abstrato para testes;
- Firestore restrito ao service;
- criação de ID e timestamps no service;
- repository com criar, atualizar, status e duplicidade;
- controller com loading, saving, erro e filtros;
- compatibilidade com `carregarTipos`, `tipos` e `carregando`;
- tokens globais `FenixVisualTokens` derivados da PV-007B-R3;
- Home preservada por aliases de compatibilidade;
- testes unitários de modelo e controller.

## Limites desta etapa

- a página atual ainda não é reescrita;
- a Nova Ação ainda não é integrada;
- as regras Firestore ainda não recebem validação rígida de schema;
- não há exclusão física;
- não há migração de materiais.

## Quality gates

```powershell
flutter test .\test\data\models\tipo_acao_model_test.dart
flutter test .\test\modules\admin\controllers\tipo_acao_controller_test.dart
flutter test .\test\modules\home\widgets\home_operacional_compacta_test.dart
flutter analyze
git diff --check
```

Resultado obrigatório:

- testes novos aprovados;
- 15 testes da Home preservados;
- `flutter analyze` com 0 issues;
- `git diff --check` aprovado.

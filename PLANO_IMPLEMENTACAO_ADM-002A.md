# PLANO DE IMPLEMENTAÇÃO ADM-002A — Tipos de Ações

## Estratégia

A implementação será incremental. Cada pacote será aplicado, analisado, testado e homologado antes do seguinte.

## ADM-002A.1 — Fundação de domínio e dados

### Objetivo

Consolidar o caminho único Controller → Repository → Service → Firestore sem alterar ainda a experiência visual principal.

### Alterações previstas

- fortalecer `TipoAcaoModel`;
- tornar `TipoAcaoService` injetável e responsável por timestamps;
- ampliar `TipoAcaoRepository`;
- mover ou reorganizar `TipoAcaoController` para o módulo correto;
- implementar estados de loading, saving e error;
- adicionar normalização e validação;
- criar testes unitários;
- introduzir `FenixVisualTokens` globais sem alterar visualmente a Home.

### Gate

- testes unitários aprovados;
- 15 testes da Home preservados;
- `flutter analyze` com 0 issues;
- `git diff --check` aprovado.

## ADM-002A.2 — Listagem e formulário responsivos

### Objetivo

Substituir a tela direta e o diálogo por uma experiência administrativa completa.

### Alterações previstas

- reescrever `TiposAcoesPage`;
- criar `TipoAcaoFormPage`;
- criar argumentos de formulário;
- usar Provider;
- filtros e indicadores;
- edição;
- ativação/inativação com confirmação;
- estados de erro, vazio e recarregamento;
- padrão cromático R3;
- testes de widget para A05 e Tab S6.

### Gate

- nenhum import de Firestore nas páginas;
- cadastro, edição e status aprovados;
- zero overflow;
- testes de widget aprovados;
- `flutter analyze` com 0 issues.

## ADM-002A.3 — Integração operacional

### Objetivo

Conectar o catálogo administrativo ao fluxo Nova Ação.

### Alterações previstas

- remover leitura direta de `tipos_acoes` da `NovaAcaoPage`;
- carregar somente ativos;
- preservar seleção legada em rascunhos;
- validar padrões de público;
- remover ou aposentar `nova_acao_page1.dart` somente após comprovação de que não é referenciado;
- testes de regressão do fluxo.

### Gate

- item inativo não pode ser selecionado em nova ação;
- rascunho legado não perde o valor;
- fluxo de Nova Ação permanece funcional;
- `flutter analyze` com 0 issues.

## ADM-002A.4 — Hardening Firestore

### Pré-requisito

Inventário de documentos reais de `tipos_acoes`, incluindo presença e tipos de:

```text
id
nomeAcao
tipoAcao
publicoEstimadoPadrao
publicoMinimoPadrao
materiaisSugeridos
ativo
criadoEm
atualizadoEm
```

### Alterações previstas

- função `tipoAcaoValido()` em `firestore.rules`;
- imutabilidade de criação;
- validação de tipos e campos;
- testes no emulador;
- compatibilidade com registros existentes;
- documentação da baseline.

### Gate

- suíte de regras existente aprovada;
- novos testes de Tipos de Ações aprovados;
- nenhuma regressão de permissão;
- `flutter analyze` com 0 issues.

## ADM-002A.5 — Encerramento

- auditoria Git;
- CPB;
- homologação no APK de teste;
- Samsung A05;
- Samsung Tab S6;
- documentação técnica;
- commit;
- push;
- Pull Request;
- quality gates CI;
- merge;
- validação pós-merge.

## Ordem de arquivos para a primeira implementação

Pacote ADM-002A.1 deverá conter, no mínimo:

```text
lib/core/theme/fenix_visual_tokens.dart
lib/modules/home/theme/home_visual_tokens.dart
lib/data/models/tipo_acao_model.dart
lib/core/services/tipo_acao_service.dart
lib/repositories/tipo_acao_repository.dart
lib/modules/tipos_acoes/controllers/tipo_acao_controller.dart
lib/app.dart
test/data/models/tipo_acao_model_test.dart
test/modules/tipos_acoes/controllers/tipo_acao_controller_test.dart
README_ADM-002A.1.md
tools/manifestos/ADM-002A.1-FUNDACAO-TIPOS-ACOES.txt
```

## Pendência necessária antes do hardening

O pacote de auditoria não contém amostra dos documentos reais da coleção. Portanto, não é seguro impor imediatamente `keys().hasOnly(...)` ou obrigatoriedade de novos timestamps. A implementação funcional pode começar, mas a ADM-002A.4 depende desse inventário.

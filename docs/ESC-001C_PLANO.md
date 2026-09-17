# ESC-001C — PLANO DE IMPLEMENTAÇÃO

## 1. Preflight

- `main` na baseline exata;
- checkout principal limpo;
- worktree isolado;
- branch nova;
- branch remota ausente.

## 2. Contratos Dart

Criar modelos para:

- configuração da escala;
- perfil operacional da escala;
- escala diária;
- atividade;
- alocação;
- indisponibilidade;
- evidência administrativa;
- execução de missão.

Criar política de acesso específica do módulo.

## 3. Firestore Rules

Adicionar funções de autorização isoladas do ACL legado e regras para as sete coleções da escala.

Não alterar a função global `perfilReconhecido()`.

## 4. Testes

- round-trip dos modelos;
- QTR separado de QTH;
- carga horária como atributo operacional;
- agente responsável gerencia escala;
- agente comum somente leitura estrutural;
- Gerente gerencia e designa responsável;
- Gestor permanece leitura nesta matriz;
- Coordenador executa, mas não altera escala;
- participante registra missão administrativa;
- ação educativa exige RAE;
- missão administrativa aceita evidência;
- férias/sobreposição não bloqueiam server-side;
- exclusão client-side negada.

## 5. Gates

- Dart format;
- Flutter focused tests;
- Flutter Test;
- Flutter Analyze;
- Firestore Rules (baseline + ESC-001C);
- `git diff --check`;
- escopo exato;
- CPB;
- stage/commit/push/PR;
- seis Quality Gates GitHub;
- merge com SHA lock;
- sincronização e limpeza.

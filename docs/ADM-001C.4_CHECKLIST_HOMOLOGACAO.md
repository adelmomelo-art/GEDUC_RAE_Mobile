# ADM-001C.4 — Checklist de Homologação Integrada

## Identificação

- Data: 01/08/2026
- Branch: `feature/adm-001c-identidade-seguranca`
- Baseline revisada: `2129355`
- Status: Code Review Arquitetural aprovada — merge pendente

## A. Evidências técnicas obrigatórias

- [x] ADM-001C.1 registrada no commit `072c5a5`.
- [x] ADM-001C.2 registrada no commit `fc575a0`.
- [x] ADM-001C.3 registrada no commit `42e3560`.
- [x] Correção R1 da Code Review registrada no commit `2129355`.
- [x] Branch sincronizada com `origin` após ADM-001C.3.
- [x] Branch sincronizada com `origin` após a correção R1.
- [x] Firestore: 15/15 testes aprovados no emulador após Code Review.
- [x] Estrutura mínima e `createdAt` de `domains` protegidos por testes negativos.
- [x] Testes negativos produziram `PERMISSION_DENIED` esperado.
- [x] `firebase-tools` 15.25.1.
- [x] Vulnerabilidades npm altas: zero.
- [x] Vulnerabilidades npm críticas: zero.
- [x] `flutter analyze`: `No issues found!`.
- [x] Regras remotas não publicadas.

## B. Homologação funcional acumulada

- [x] Login administrativo.
- [x] Identidade e nome apresentados na Home.
- [x] Sessão restaurada após reinício.
- [x] Administração apresenta os seis módulos.
- [x] Navegação Voltar funciona.
- [x] Logout limpa a identidade apresentada.
- [x] Novo login recupera a identidade correta.
- [x] Ausência de tela branca após correção R1.
- [x] Atalho Administração usa permissão central.
- [x] Usuários carrega e atualiza sem duplicação ou travamento.

## C. Teste integrado final no tablet

- [x] 1. Abrir o aplicativo sem sessão e confirmar a tela de login.
- [x] 2. Entrar com a conta administrativa e confirmar nome correto.
- [x] 3. Confirmar carregamento normal da Home e dos indicadores.
- [x] 4. Abrir Administração e confirmar os seis módulos.
- [x] 5. Abrir Usuários e atualizar a lista.
- [x] 6. Voltar para Administração e depois para a Home.
- [x] 7. Encerrar a sessão e confirmar retorno ao login.
- [x] 8. Entrar novamente e confirmar que não houve reutilização visual incorreta.
- [x] 9. Reiniciar o aplicativo e confirmar retomada da sessão.
- [x] 10. Confirmar ausência de tela branca, exceção ou travamento.

## D. Cobertura por identidade e perfil

| Cenário | Evidência | Resultado |
|---|---|---|
| não autenticado | roteamento global + teste final | aprovado |
| autenticado sem documento | estado explícito no cliente + regras no emulador | aprovado tecnicamente |
| usuário inativo | estado explícito no cliente + regras no emulador | aprovado tecnicamente |
| perfil desconhecido | política central + regras no emulador | aprovado tecnicamente |
| administrador | tablet + emulador | aprovado |
| gestor | matriz cliente auditada + emulador | aprovado tecnicamente |
| coordenador | rota homologada anteriormente + emulador | aprovado tecnicamente |
| agente | rota direta homologada anteriormente + emulador | aprovado tecnicamente |

## E. Critérios posteriores

- [x] CPB final 7/7 e CPB corretivo 11/11 íntegros.
- [x] Commits documentais, corretivo e respectivos pushes concluídos.
- [x] Pull Request nº 3 aberto contra `main`.
- [x] Code Review Arquitetural aprovada após a correção R1.
- [ ] Merge concluído.
- [ ] `flutter analyze` pós-merge com zero issues.
- [ ] Working tree limpa na `main`.

## Controle de publicação

Este checklist não autoriza publicação das regras. Antes de qualquer deploy
serão exigidos backup da regra remota, autorização expressa, publicação
controlada, teste de fumaça e registro do resultado.

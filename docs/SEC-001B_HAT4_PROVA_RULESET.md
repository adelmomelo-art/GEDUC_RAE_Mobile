# SEC-001B-HAT4 — Prova do ruleset concluída

## 1. Configuração submetida à prova

| Controle | Configuração |
| --- | --- |
| Ruleset | `main-quality-gates` |
| Identificador | `20301322` |
| Estado | `Active` |
| Branch alvo | default branch (`main`) |
| Bypass | vazio |
| Pull Request obrigatório | sim |
| Aprovações obrigatórias | `0` |
| Resolução de conversas | obrigatória |
| Branch atualizada com a base | obrigatória |
| Check Flutter | `Quality Gate - Flutter Analyze` |
| Check Firestore | `Quality Gate - Firestore Rules` |
| Restrição de exclusão | ativa |
| Bloqueio de force push | ativo |
| Histórico linear | não exigido |

## 2. Objeto da prova

O Pull Request nº 9 utilizou uma alteração exclusivamente documental para
submeter o ruleset a uma validação real, sem modificar código funcional,
`firestore.rules`, dependências ou workflow.

| Item | Identificador |
| --- | --- |
| Baseline | `1d279e9` |
| Branch | `docs/sec-001b-hat4-prova-ruleset` |
| Commit | `7ce49d9` |
| Pull Request | nº 9 |
| Merge | `a45c142` |

## 3. Evidências remotas

### Evento `pull_request`

| Check obrigatório | Resultado | Duração |
| --- | --- | --- |
| `Quality Gate - Firestore Rules` | sucesso | 34 s |
| `Quality Gate - Flutter Analyze` | sucesso | 48 s |

Os dois checks foram exibidos com a marca `Required`. O ruleset avaliou a
branch atualizada com a `main` e o merge somente foi concluído após os dois
resultados verdes. A lista de bypass permaneceu vazia e nenhum bypass foi
utilizado.

### Evento `push` pós-merge

- workflow: `Quality Gates`;
- branch: `main`;
- commit: `a45c142`;
- execução: nº 5;
- resultado: sucesso;
- duração total: 59 segundos;
- artefatos: não aplicável.

## 4. Evidências locais pós-merge

```text
Branch: main
HEAD: a45c142
Relação remota: main...origin/main
Flutter analyze: No issues found! (135,1 s)
Working tree: limpa
```

## 5. Resultado dos critérios

| Critério | Resultado |
| --- | --- |
| alteração da `main` somente por Pull Request | aprovado |
| checks obrigatórios visíveis | aprovado |
| merge condicionado aos checks | aprovado |
| dois checks concluídos com sucesso | aprovado |
| execução sem bypass | aprovado |
| workflow automático pós-merge | aprovado |
| sincronização local e working tree limpa | aprovado |

## 6. Parecer

```text
HAT-4: APROVADA
Ressalvas técnicas: nenhuma
Ruleset: ativo e efetivo
Quality gates: obrigatórios e operacionais
Baseline técnica final: a45c142
```

## 7. Limite da conclusão

A prova valida o mecanismo de proteção e os checks configurados. Ela não inclui
correção de dependências npm, ampliação de testes, deploy Firebase, build de
aplicativo ou exigência de revisão por segundo colaborador.

# SEC-001B-HAT4 — Prova controlada do ruleset da main

## Estado

Prova concluída e aprovada sem ressalvas técnicas. O ruleset
`main-quality-gates` protegeu um Pull Request real, exigiu os dois quality gates
e permitiu o merge somente após o sucesso de ambos.

## Configuração provada

- ruleset: `main-quality-gates`;
- identificador: `20301322`;
- enforcement: `Active`;
- bypass: vazio;
- branch protegida: default branch (`main`);
- Pull Request obrigatório;
- branch atualizada com a base;
- resolução de conversas obrigatória;
- exclusão e force push bloqueados;
- checks obrigatórios:
  - `Quality Gate - Flutter Analyze`;
  - `Quality Gate - Firestore Rules`.

## Rastreabilidade

| Marco | Valor |
| --- | --- |
| Baseline de entrada | `1d279e9` |
| Branch da prova | `docs/sec-001b-hat4-prova-ruleset` |
| Commit da prova | `7ce49d9` |
| Pull Request | nº 9 |
| Merge commit | `a45c142` |
| Baseline pós-merge | `main` em `a45c142` |

## Evidência do Pull Request nº 9

- alteração exclusivamente documental: 3 arquivos e 139 inserções;
- Firestore Rules: `Required`, sucesso em 34 segundos;
- Flutter Analyze: `Required`, sucesso em 48 segundos;
- merge automático tecnicamente possível somente após os dois sucessos;
- bypass não utilizado;
- Pull Request integrado e encerrado.

## Evidência pós-merge

- evento automático: `push` na `main`;
- workflow: `Quality Gates`;
- commit: `a45c142`;
- resultado: sucesso;
- duração total: 59 segundos;
- `flutter analyze` local: `No issues found!` em 135,1 segundos;
- working tree: limpa e sincronizada com `origin/main`.

## Conclusão

Os seis critérios definidos para a HAT-4 foram atendidos:

1. atualização da `main` realizada por Pull Request;
2. checks exibidos como obrigatórios;
3. merge condicionado ao resultado dos checks;
4. dois jobs aprovados;
5. merge concluído sem bypass;
6. execução pós-merge da `main` iniciada automaticamente e aprovada.

A HAT-4 está encerrada. Os resultados são consolidados na sincronização
documental final da SEC-001B.

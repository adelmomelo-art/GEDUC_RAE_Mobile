# SEC-001B-HAT4 — Roteiro de prova do ruleset

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

## 2. Evidências anteriores

- PR nº 8 integrado à `main` pelo merge commit `1d279e9`;
- workflow executado no PR com os dois jobs em sucesso;
- `flutter analyze` local pós-merge com zero issues;
- execução manual do workflow na `main` em sucesso, duração total de 46
  segundos;
- ruleset criado e confirmado como ativo na interface do GitHub.

## 3. Prova controlada

Este próprio documento origina um Pull Request exclusivamente documental. A
sequência de homologação será:

1. abrir o Pull Request contra a `main`;
2. observar o bloqueio do merge enquanto os checks estiverem pendentes;
3. confirmar a execução automática dos dois jobs no evento `pull_request`;
4. confirmar sucesso dos dois jobs;
5. confirmar a liberação do merge pelo ruleset;
6. integrar por merge commit;
7. confirmar a execução automática dos dois jobs no evento `push` da `main`.

## 4. Critérios da HAT-4

- nenhuma atualização direta da `main` fora de Pull Request;
- ambos os checks exibidos como obrigatórios;
- merge indisponível enquanto houver check pendente ou falho;
- merge disponível somente após os dois sucessos;
- push pós-merge da `main` inicia o workflow automaticamente;
- nenhuma utilização de bypass;
- working tree local limpa após sincronização pós-merge.

## 5. Encerramento posterior

Os identificadores do Pull Request de prova, do merge commit e das execuções
remotas serão consolidados no pacote documental final da SEC-001B após a
conclusão desta prova.

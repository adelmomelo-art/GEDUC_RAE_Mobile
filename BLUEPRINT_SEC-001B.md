# Blueprint SEC-001B — Automação de testes de segurança e quality gates

| Campo | Valor |
| --- | --- |
| Data | 03/08/2026 |
| Baseline Git | `main` em `e5dd019` |
| Branch planejada | `security/sec-001b-quality-gates-ci` |
| Projeto de testes | `geduc-rae-mobile-test` |
| Projeto de produção | `geduc-rae-mobile` — não acessado pelo workflow |
| Risco principal | regressão de autorização ou quebra estática integrada sem gate automático |
| Estado | fase 1 preparada; proteção remota ainda não aplicada |

## 1. Problema

Os testes das regras do Firestore e o analisador Flutter são executáveis e
estão aprovados localmente, mas o repositório ainda não possui `.github` nem
workflows. Assim, um Pull Request pode ser integrado sem evidência automática
dessas duas validações.

## 2. Decisão arquitetural

Será criado um único workflow denominado `Quality Gates`, com dois jobs
independentes e nomes estáveis:

| Job | Comando principal | Toolchain |
| --- | --- | --- |
| `Quality Gate - Flutter Analyze` | `flutter analyze` | Flutter `3.44.4` stable |
| `Quality Gate - Firestore Rules` | `npm run test:rules` | Node `24.18.0`, Java `21`, Firebase CLI `15.25.1` |

A independência dos jobs torna o diagnóstico direto e permite que cada check
seja exigido separadamente na proteção da branch.

## 3. Eventos

O workflow será executado em:

- `pull_request` destinado à `main`;
- `push` na `main`;
- acionamento manual por `workflow_dispatch`.

Não serão usados filtros de caminho. Quando um workflow exigido é ignorado por
filtro, o check pode permanecer pendente e bloquear o Pull Request.

## 4. Reprodutibilidade

- `npm ci` consumirá o `package-lock.json` versionado;
- o Node será fixado em `24.18.0`;
- o Flutter será fixado em `3.44.4` no canal stable;
- o Java será fixado na linha LTS `21`, distribuição Temurin;
- as actions serão referenciadas por SHA completo e anotadas com a tag
  auditada;
- o runner será `ubuntu-24.04`;
- os jobs terão limite de 20 minutos.

## 5. Controles de segurança

- permissões do `GITHUB_TOKEN` reduzidas a `contents: read`;
- credenciais não serão persistidas pelo checkout;
- nenhuma variável secreta será requerida;
- nenhum login Firebase será executado;
- nenhum deploy será executado;
- o script continuará usando o emulador local e o project ID isolado
  `geduc-rae-mobile-test`;
- o evento `pull_request_target` não será usado;
- execuções antigas do mesmo ref serão canceladas por controle de concorrência.

## 6. Proteção da branch

A exigência remota dos checks é deliberadamente posterior à homologação do
workflow:

1. integrar a fase 1;
2. observar os dois checks verdes no Pull Request e na `main`;
3. confirmar os nomes exatos apresentados pelo GitHub;
4. aplicar a proteção/ruleset exigindo ambos;
5. validar que um PR de prova não pode ser integrado com check pendente ou
   falho.

## 7. Fora do escopo

- alteração de `firestore.rules`;
- ampliação dos casos de teste;
- deploy Firebase;
- uso de credenciais ou service accounts;
- testes Android instrumentados;
- build de APK/AAB;
- ativação imediata de branch protection.

## 8. Critérios de aceitação

### HAT-1 — desenho e baseline

- baseline `e5dd019` confirmada;
- arquivos de regras/testes/lockfiles presentes;
- toolchain auditada;
- ausência de workflow confirmada;
- desenho de dois jobs independentes aprovado.

### HAT-2 — validação local do pacote

- `npm ci` aprovado;
- 15/15 testes das regras aprovados;
- `flutter analyze` com zero issues;
- `git diff --check` sem erros;
- escopo do diff limitado aos seis arquivos do pacote.

### HAT-3 — validação remota

- ambos os jobs executados no Pull Request;
- ambos os jobs concluídos com sucesso;
- ausência de segredos, login e deploy confirmada nos logs;
- revisão e merge controlados.

### HAT-4 — proteção da main

- checks exatos configurados como obrigatórios;
- Pull Request de prova bloqueado enquanto pendente/falho;
- merge permitido somente após sucesso;
- documentação final sincronizada com o merge commit oficial.

# Blueprint SEC-001B — Automação de testes de segurança e quality gates

| Campo | Valor |
| --- | --- |
| Data | 03/08/2026 |
| Baseline de entrada | `main` em `e5dd019` |
| Baseline técnica final | `main` em `a45c142` |
| Branch da implementação | `security/sec-001b-quality-gates-ci` |
| Branch da prova | `docs/sec-001b-hat4-prova-ruleset` |
| Projeto de testes | `geduc-rae-mobile-test` |
| Projeto de produção | `geduc-rae-mobile` — não acessado pelo workflow |
| Risco principal tratado | regressão de autorização ou quebra estática integrada sem gate automático |
| Estado | HAT-1 a HAT-4 aprovadas; sincronização documental final preparada |

## 1. Problema tratado

Os testes das regras do Firestore e o analisador Flutter já eram executáveis e
estavam aprovados localmente, mas o repositório não possuía workflow nem gate
remoto. Um Pull Request podia ser integrado sem evidência automática dessas
duas validações.

## 2. Solução implementada

Foi criado um único workflow denominado `Quality Gates`, com dois jobs
independentes e nomes estáveis:

| Job | Comando principal | Toolchain |
| --- | --- | --- |
| `Quality Gate - Flutter Analyze` | `flutter analyze` | Flutter `3.44.4` stable |
| `Quality Gate - Firestore Rules` | `npm run test:rules` | Node `24.18.0`, Java `21`, Firebase CLI `15.25.1` |

A independência dos jobs fornece diagnóstico direto e permite exigir cada
controle separadamente no ruleset.

## 3. Eventos homologados

O workflow foi validado em:

- `pull_request` destinado à `main`;
- `push` na `main`;
- `workflow_dispatch` manual.

Não existem filtros de caminho. Assim, os checks obrigatórios são iniciados em
todo Pull Request destinado à `main`, inclusive quando a alteração é somente
documental.

## 4. Reprodutibilidade

- `npm ci` consome o `package-lock.json` versionado;
- Node fixado em `24.18.0`;
- Flutter fixado em `3.44.4` no canal stable;
- Java fixado na linha LTS `21`, distribuição Temurin;
- actions referenciadas por SHA completo;
- runner `ubuntu-24.04`;
- limite de 20 minutos por job.

## 5. Controles de segurança

- permissões do `GITHUB_TOKEN` reduzidas a `contents: read`;
- credenciais não persistidas pelo checkout;
- nenhuma variável secreta requerida;
- nenhum login ou deploy Firebase;
- emulador local com project ID isolado `geduc-rae-mobile-test`;
- evento `pull_request_target` ausente;
- concorrência configurada para cancelar execuções antigas do mesmo ref.

## 6. Ruleset da main

| Controle | Valor homologado |
| --- | --- |
| Ruleset | `main-quality-gates` |
| ID | `20301322` |
| Estado | `Active` |
| Alvo | default branch (`main`) |
| Bypass | vazio |
| Pull Request obrigatório | sim |
| Aprovações obrigatórias | `0` |
| Resolução de conversas | obrigatória |
| Branch atualizada | obrigatória |
| Check 1 | `Quality Gate - Flutter Analyze` |
| Check 2 | `Quality Gate - Firestore Rules` |
| Restrição de exclusão | ativa |
| Bloqueio de force push | ativo |

## 7. Evidência de integração

| Fase | Commit | Pull Request | Resultado |
| --- | --- | --- | --- |
| Implementação | `f7db380` | nº 8 | dois jobs verdes; merge `1d279e9` |
| Prova do ruleset | `7ce49d9` | nº 9 | dois checks `Required`; merge `a45c142` |

O evento `push` da `main` após o Pull Request nº 9 executou o workflow
automaticamente e concluiu com sucesso em 59 segundos.

## 8. Critérios de aceitação

| HAT | Resultado |
| --- | --- |
| HAT-1 — desenho e baseline | aprovada |
| HAT-2 — validação local | aprovada: 15/15 testes e analyze sem issues |
| HAT-3 — validação remota do workflow | aprovada no PR nº 8 |
| HAT-4 — proteção da `main` | aprovada no PR nº 9 |

## 9. Fora do escopo preservado

- alteração de `firestore.rules`;
- ampliação dos casos de teste;
- deploy Firebase;
- uso de credenciais ou service accounts;
- build de APK/AAB;
- correção automática de vulnerabilidades npm.

## 10. Débito controlado

O `npm ci` registrou seis vulnerabilidades moderadas e avisos de scripts de
instalação para três pacotes. A análise e eventual atualização serão tratadas
em pacote independente, com testes de regressão e sem uso automático de
`npm audit fix --force`.

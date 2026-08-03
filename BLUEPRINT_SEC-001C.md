# Blueprint SEC-001C — Hardening da cadeia de dependências npm

| Campo | Valor |
| --- | --- |
| Data | 03/08/2026 |
| Baseline de entrada | `main` em `3400563` |
| Branch prevista | `security/sec-001c-hardening-supply-chain` |
| Node homologado | `24.18.0` |
| npm homologado | `11.16.0` |
| Firebase CLI | `15.25.1` |
| Risco tratado | dependências vulneráveis e scripts de instalação não governados |
| Estado inicial | HAT-1 aprovada; implementação preparada |

## 1. Objetivo

Reduzir e governar a superfície de supply chain do conjunto Node.js usado para
testar as regras do Firestore, sem introduzir downgrade, atualização major ou
correção automática destrutiva.

## 2. Baseline comprovada

| Controle | Resultado local |
| --- | --- |
| `git status -sb` | `main...origin/main`, limpa |
| Commit | `3400563` |
| `npm audit` | seis moderadas; saída `1` |
| `npm audit --audit-level=high` | seis moderadas; saída `0` |
| `npm outdated` | somente `rules-unit-testing` `4.0.1` → `5.0.1` |
| Scripts pendentes | três; inspeção com saída `0` |

## 3. Cadeias vulneráveis

| Componente | Origem | Decisão |
| --- | --- | --- |
| `re2@1.24.1` | opcional de `superstatic` | atualizar para `1.26.1` |
| `@opentelemetry/core@1.30.1` | `@google-cloud/pubsub` | exceção moderada temporária |
| `uuid@9.0.1` | `gaxios` | exceção moderada temporária |

As duas exceções não possuem correção compatível disponibilizada pela árvore
atual do Firebase CLI. O caminho sugerido com `--force` faria downgrade para
`firebase-tools@14.23.0` e não será adotado.

## 4. Avaliação de alcance

No workflow atual, o Firebase CLI é usado com `--only firestore` e com projeto
isolado de emulador. Não há Pub/Sub, Hosting, autenticação remota, credenciais ou
entrada não confiável para buffers UUID.

Portanto, o alcance prático das vulnerabilidades remanescentes é baixo no fluxo
homologado. Essa avaliação reduz prioridade operacional, mas não elimina o
risco: os avisos permanecem registrados e sujeitos ao gate de severidade.

## 5. Arquitetura do controle

### 5.1 Correção compatível

O lockfile é atualizado sem `--force`, elevando somente a subárvore necessária
ao `re2@1.26.1`. Dependências diretas permanecem inalteradas.

### 5.2 Gate de severidade

O script `audit:security` executa:

```text
npm audit --audit-level=high
```

O relatório continua exibindo ocorrências moderadas, mas o processo só falha
quando surgir vulnerabilidade alta ou crítica. A execução ocorre antes do
`npm ci`, evitando executar scripts quando o lockfile já estiver acima do
limiar aceito.

### 5.3 Política de scripts de instalação

Foram revisados e aprovados com versão fixada:

| Pacote | Script | Justificativa |
| --- | --- | --- |
| `@firebase/util@1.12.1` | `postinstall` | gera defaults locais da biblioteca Firebase |
| `fsevents` | `install` | negado; pacote opcional exclusivo de macOS |
| `protobufjs@7.6.5` | `postinstall` | valida convenção de versão de dependentes |
| `re2@1.26.1` | `install` | obtém ou compila o módulo nativo necessário |

A configuração `strict-allow-scripts=true` impede instalação caso uma versão
nova ou outro pacote tente executar script ainda não revisado.

## 6. Integração com o ruleset

O audit é incorporado ao job `Quality Gate - Firestore Rules`, que já é
obrigatório no ruleset `main-quality-gates`. Assim, o novo gate torna-se
efetivo sem alterar o identificador do check nem exigir bypass ou nova regra.

## 7. Critérios de aceitação

| HAT | Critério |
| --- | --- |
| HAT-1 | baseline e risco inventariados sem alterar o repositório |
| HAT-2 | `npm ci`, scripts, audit, 15 testes e analyze aprovados localmente |
| HAT-3 | Pull Request com os dois checks obrigatórios verdes |
| HAT-4 | execução `push` da `main` verde e validação pós-merge limpa |

## 8. Controles negativos

- nenhum `npm audit fix --force`;
- nenhum downgrade;
- nenhuma atualização major;
- nenhuma credencial, login ou deploy;
- nenhuma alteração em regras ou código funcional;
- nenhuma ocultação das ocorrências moderadas.

## 9. Monitoramento

As exceções de `@opentelemetry/core` e `uuid` devem ser reavaliadas quando uma
nova versão compatível do Firebase CLI atualizar suas dependências transitivas.
Qualquer mudança dos pacotes com scripts exigirá nova aprovação versionada.

# SEC-001C — Hardening da cadeia de dependências npm

## Estado

Implementação, homologação local, validação remota e pós-merge concluídas e
aprovadas sem ressalvas impeditivas. A baseline oficial da SEC-001C é a `main`
no merge commit `6b53c8f`.

A sincronização SEC-001C-R1 é exclusivamente documental. Ela registra os
resultados já homologados e não modifica dependências, workflow, regras do
Firestore, código Flutter ou dados remotos.

## Problema confirmado

O `npm audit` local registrou seis ocorrências moderadas e nenhuma ocorrência
alta ou crítica. As causas pertencem à cadeia transitiva do
`firebase-tools@15.25.1`:

- `@opentelemetry/core`, por `@google-cloud/pubsub`;
- `re2`, dependência opcional de `superstatic`;
- `uuid`, por `gaxios`.

O `firebase-tools` já está na versão corrente adotada pelo projeto. A correção
forçada indicada pelo npm instalaria `firebase-tools@14.23.0`, um downgrade com
quebra potencial, e foi rejeitada.

## Resultado implementado

1. atualização segura do `re2` de `1.24.1` para `1.26.1` no lockfile;
2. gate `npm audit --audit-level=high` antes da instalação no job obrigatório
   de Firestore Rules;
3. aprovação explícita e fixada por versão dos três scripts de instalação
   auditados, com negação do script opcional de `fsevents`;
4. política `strict-allow-scripts=true`, que transforma novo script não
   revisado em falha de instalação;
5. manutenção das dependências diretas e do escopo funcional.

## Arquivos da implementação homologada

- `.github/workflows/quality-gates.yml`;
- `.npmrc`;
- `package.json`;
- `package-lock.json`;
- `README_SEC-001C.md`;
- `BLUEPRINT_SEC-001C.md`;
- `PLANO_IMPLEMENTACAO_SEC-001C.md`;
- `docs/SEC-001C_REFERENCIAS_SUPPLY_CHAIN.md`;
- `tools/manifestos/SEC-001C-HARDENING-SUPPLY-CHAIN.txt`.

O pacote SEC-001C-R1 atualiza este README, o Blueprint, o Plano, as referências,
a Arquitetura e o Engineering Log, acompanhados de manifesto próprio.

## Comportamento homologado

- cinco vulnerabilidades moderadas remanescentes continuam visíveis no log;
- `npm run audit:security` retorna `0` enquanto não houver ocorrência alta ou
  crítica;
- `npm ci` falha se uma nova dependência introduzir script de instalação não
  coberto pela política;
- `npm run audit:scripts` não lista pendências;
- os 15 testes das regras do Firestore e o `flutter analyze` permanecem
  aprovados.

## Rastreabilidade Git

| Marco | Identificador |
| --- | --- |
| Baseline de entrada | `3400563` |
| Branch | `security/sec-001c-hardening-supply-chain` |
| Commit da implementação | `2c16d4d` |
| Pull Request | nº 11 |
| Merge / baseline técnica final | `6b53c8f` |

## Homologações

### HAT-1 — auditoria

- Node `24.18.0`, npm `11.16.0` e Firebase CLI `15.25.1` confirmados;
- seis ocorrências moderadas iniciais e nenhuma alta ou crítica;
- correção não forçada disponível somente para `re2`;
- três scripts de instalação pendentes inventariados;
- working tree preservada limpa.

### HAT-2 — validação local

- `npm ci`: aprovado;
- `re2@1.26.1`: instalado;
- scripts não revisados: nenhum;
- audit: cinco moderadas e gate de severidade alta com saída `0`;
- Firestore Rules: 15/15 testes aprovados;
- `flutter analyze`: zero issues em 156,9 segundos;
- CPB revisado e homologado com 9/9 arquivos.

### HAT-3 — Pull Request nº 11

- Firestore Rules: sucesso em 32 segundos e check `Required`;
- Flutter Analyze: sucesso em 53 segundos e check `Required`;
- workflow do Pull Request: sucesso em 56 segundos;
- ausência de conflitos e bypass;
- merge concluído em `6b53c8f`.

### HAT-4 — pós-merge

- execução automática `push` da `main`: sucesso em 43 segundos;
- scripts pendentes: nenhum;
- gate de severidade alta: aprovado;
- Firestore Rules: 15/15 testes aprovados;
- `flutter analyze`: zero issues em 143,1 segundos;
- working tree limpa e sincronizada com `origin/main`.

## Risco residual controlado

As cinco ocorrências moderadas remanescentes pertencem às cadeias de
`@opentelemetry/core` e `uuid` no Firebase CLI. A única correção sugerida pelo
npm exige downgrade com quebra potencial e permanece rejeitada. O gate bloqueia
automaticamente qualquer ocorrência futura de severidade alta ou crítica.

## Fora do escopo

- `npm audit fix --force`;
- downgrade do Firebase CLI;
- migração de `@firebase/rules-unit-testing` para a versão major `5`;
- alteração de `firestore.rules` ou dos testes existentes;
- deploy ou acesso ao Firebase de produção;
- supressão das vulnerabilidades moderadas remanescentes.

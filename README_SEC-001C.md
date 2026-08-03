# SEC-001C — Hardening da cadeia de dependências npm

## Estado

HAT-1 de auditoria concluída em 03/08/2026 sobre a `main` no commit
`3400563`. Este pacote implementa o tratamento seguro da dependência corrigível,
a política explícita de scripts de instalação e o bloqueio automático de
vulnerabilidades altas ou críticas.

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

## Arquivos do pacote

- `.github/workflows/quality-gates.yml`;
- `.npmrc`;
- `package.json`;
- `package-lock.json`;
- `README_SEC-001C.md`;
- `BLUEPRINT_SEC-001C.md`;
- `PLANO_IMPLEMENTACAO_SEC-001C.md`;
- `docs/SEC-001C_REFERENCIAS_SUPPLY_CHAIN.md`;
- `tools/manifestos/SEC-001C-HARDENING-SUPPLY-CHAIN.txt`.

## Comportamento esperado

- as vulnerabilidades moderadas remanescentes continuam visíveis no log;
- `npm run audit:security` retorna `0` enquanto não houver ocorrência alta ou
  crítica;
- `npm ci` falha se uma nova dependência introduzir script de instalação não
  coberto pela política;
- `npm run audit:scripts` não deve listar pendências;
- os 15 testes das regras do Firestore e o `flutter analyze` devem permanecer
  aprovados.

## Fora do escopo

- `npm audit fix --force`;
- downgrade do Firebase CLI;
- migração de `@firebase/rules-unit-testing` para a versão major `5`;
- alteração de `firestore.rules` ou dos testes existentes;
- deploy ou acesso ao Firebase de produção;
- supressão das vulnerabilidades moderadas remanescentes.

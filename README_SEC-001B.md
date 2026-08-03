# SEC-001B — Automação de testes de segurança e quality gates

## Estado

Implementação da fase 1 preparada para aplicação controlada sobre a branch
`main` no commit `e5dd019`.

Este pacote não publica regras, não acessa o projeto Firebase remoto, não usa
segredos e não altera a proteção da branch `main`.

## Objetivo

Criar o workflow `Quality Gates` para executar automaticamente, em Pull
Requests destinados à `main` e em pushes na `main`:

1. `flutter analyze`;
2. os 15 testes locais das regras do Firestore via Emulator Suite.

## Conteúdo do pacote

- `.github/workflows/quality-gates.yml`;
- `README_SEC-001B.md`;
- `BLUEPRINT_SEC-001B.md`;
- `PLANO_IMPLEMENTACAO_SEC-001B.md`;
- `docs/SEC-001B_REFERENCIAS_CI.md`;
- `tools/manifestos/SEC-001B-QUALITY-GATES-CI.txt`.

## Premissas confirmadas

- baseline Git: `main` em `e5dd019`;
- working tree limpa e sincronizada com `origin/main`;
- 15 testes de regras existentes em `test/firestore.rules.test.js`;
- dependências Node fixadas pelo `package-lock.json`;
- `@firebase/rules-unit-testing` em `4.0.1`;
- `firebase-tools` em `15.25.1`;
- Node local em `24.18.0`;
- Java local em `21`;
- Flutter local em `3.44.4`;
- `flutter analyze` pós-merge da SEC-001A-R1 aprovado com zero issues.

## Separação obrigatória em duas fases

### Fase 1 — workflow

Aplicar este pacote, validar localmente, abrir Pull Request e observar os dois
checks remotos:

- `Quality Gate - Flutter Analyze`;
- `Quality Gate - Firestore Rules`.

### Fase 2 — proteção da main

Somente após os dois checks existirem e concluírem com sucesso, configurar a
regra de proteção ou ruleset para torná-los obrigatórios. Essa separação evita
exigir checks ainda inexistentes e reduz o risco de bloqueio administrativo da
branch.

## Aplicação controlada

```powershell
Set-Location C:\Projetos\GEDUC_RAE_Mobile
git switch main
git pull --ff-only origin main
git status -sb
git rev-parse --short HEAD
git switch -c security/sec-001b-quality-gates-ci
```

Antes de extrair o ZIP, confirme que o `HEAD` é `e5dd019` e que a working tree
está limpa. Extraia o pacote na raiz do repositório e valide:

```powershell
npm ci
npm run test:rules
flutter pub get
flutter analyze
git diff --check
git status --short
```

As ações de commit, push, Pull Request e configuração da proteção da `main`
permanecem condicionadas às homologações descritas no plano.

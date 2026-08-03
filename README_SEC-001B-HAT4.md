# SEC-001B-HAT4 — Prova controlada do ruleset da main

## Estado

Pacote documental preparado para validar o ruleset `main-quality-gates` em um
Pull Request real, sem alterar código funcional, regras do Firestore ou
configuração do workflow.

## Baseline

- branch de entrada: `main`;
- commit de entrada: `1d279e9`;
- PR de implantação do workflow: nº 8;
- ruleset: `main-quality-gates`;
- identificador do ruleset: `20301322`;
- enforcement: `Active`;
- bypass: vazio;
- branch protegida: default branch (`main`).

## Branch da prova

```text
docs/sec-001b-hat4-prova-ruleset
```

## Escopo

O pacote adiciona somente:

- `README_SEC-001B-HAT4.md`;
- `docs/SEC-001B_HAT4_PROVA_RULESET.md`;
- `tools/manifestos/SEC-001B-HAT4-PROVA-RULESET.txt`.

## Objetivo da prova

O Pull Request desta branch deve demonstrar que:

1. alterações na `main` exigem Pull Request;
2. o merge permanece bloqueado enquanto os checks estão pendentes;
3. `Quality Gate - Flutter Analyze` é obrigatório;
4. `Quality Gate - Firestore Rules` é obrigatório;
5. o merge é liberado somente depois que os dois checks passam;
6. após o merge, o evento `push` da `main` inicia automaticamente o workflow.

## Aplicação

```powershell
Set-Location C:\Projetos\GEDUC_RAE_Mobile
git switch main
git pull --ff-only origin main
git status -sb
git rev-parse --short HEAD
git switch -c docs/sec-001b-hat4-prova-ruleset
```

Extraia o ZIP na raiz do repositório e valide:

```powershell
git status --short
git diff --check
git diff --stat
git diff --name-only
flutter analyze
git status --short
```

Não realizar commit ou push antes da homologação local do escopo.

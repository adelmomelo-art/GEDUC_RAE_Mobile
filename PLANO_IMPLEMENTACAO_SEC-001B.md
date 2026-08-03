# Plano de implementação SEC-001B

## 1. Entrada controlada

```powershell
Set-Location C:\Projetos\GEDUC_RAE_Mobile
git switch main
git pull --ff-only origin main
git status -sb
git rev-parse --short HEAD
```

Resultado exigido:

- branch `main` sincronizada;
- `HEAD` em `e5dd019`;
- working tree limpa.

## 2. Criar branch

```powershell
git switch -c security/sec-001b-quality-gates-ci
```

## 3. Aplicar o pacote

Calcule o hash SHA-256 do ZIP recebido, registre-o e extraia-o na raiz do
repositório:

```powershell
$pacote = Join-Path `
  $env:USERPROFILE `
  "Downloads\SEC-001B_QUALITY_GATES_CI.zip"

Test-Path $pacote
Get-FileHash $pacote -Algorithm SHA256
Expand-Archive `
  -LiteralPath $pacote `
  -DestinationPath C:\Projetos\GEDUC_RAE_Mobile `
  -Force
```

## 4. Conferir o escopo

```powershell
git status --short
git diff --check
git diff --stat
git diff --name-only
```

O diff deve conter somente:

```text
.github/workflows/quality-gates.yml
BLUEPRINT_SEC-001B.md
PLANO_IMPLEMENTACAO_SEC-001B.md
README_SEC-001B.md
docs/SEC-001B_REFERENCIAS_CI.md
tools/manifestos/SEC-001B-QUALITY-GATES-CI.txt
```

## 5. Homologação local — HAT-2

```powershell
npm ci
npm run test:rules
flutter pub get
flutter analyze
git diff --check
git status --short
```

Critérios:

- `npm ci` sem erro;
- 15 testes aprovados e zero falhas;
- `flutter analyze` com `No issues found!`;
- nenhuma alteração não planejada.

## 6. Stage e inspeção

```powershell
git add -- `
  .github/workflows/quality-gates.yml `
  BLUEPRINT_SEC-001B.md `
  PLANO_IMPLEMENTACAO_SEC-001B.md `
  README_SEC-001B.md `
  docs/SEC-001B_REFERENCIAS_CI.md `
  tools/manifestos/SEC-001B-QUALITY-GATES-CI.txt

git diff --cached --check
git diff --cached --stat
git diff --cached --name-only
```

## 7. Commit e push

Executar somente após aprovação da HAT-2:

```powershell
git commit -m `
  "ci(security): automatiza testes e quality gates"

git push -u origin security/sec-001b-quality-gates-ci
```

## 8. Pull Request — HAT-3

Título sugerido:

```text
ci(security): automatiza testes e quality gates
```

Validar no Pull Request:

- `Quality Gate - Flutter Analyze` em sucesso;
- `Quality Gate - Firestore Rules` em sucesso;
- logs sem acesso ao Firebase remoto;
- diff limitado ao escopo aprovado;
- revisão sem ressalvas técnicas.

Não habilitar ainda os checks obrigatórios caso os nomes exatos ainda não
estejam disponíveis no seletor de proteção do GitHub.

## 9. Merge e pós-merge

Após a HAT-3:

```powershell
git switch main
git pull --ff-only origin main
git status -sb
git rev-parse --short HEAD
git log -3 --oneline
flutter analyze
git status -sb
```

Confirmar no GitHub Actions que o push da `main` também executou e aprovou os
dois jobs.

## 10. Fase 2 — proteção da main

Somente depois da comprovação pós-merge:

1. abrir a regra de proteção ou ruleset aplicável à `main`;
2. exigir Pull Request antes do merge;
3. exigir os checks exatos observados no GitHub;
4. impedir bypass não planejado;
5. validar o bloqueio com um Pull Request de prova;
6. registrar a configuração e a evidência no encerramento documental.

## 11. Encerramento

- remover a branch de trabalho local e remota após o merge;
- registrar PR, commits, execuções e resultado da proteção;
- sincronizar os documentos arquiteturais somente com identificadores reais;
- gerar CPB final e executar a homologação documental.

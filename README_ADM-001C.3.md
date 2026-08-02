# ADM-001C.3 — Firestore Security Baseline

## Resultado

A política de dados passa a negar por padrão, exigir identidade ativa e reconhecida e usar exclusivamente o campo oficial `perfilAcesso`.

A correção R1 da Code Review preserva a estrutura mínima de `domains`, valida
tipos essenciais e impede alteração de `createdAt`.

## Arquivos do pacote

- `firestore.rules`
- `firebase.json`
- `package.json`
- `package-lock.json`
- `test/firestore.rules.test.js`
- `docs/ADM-001C.3_INVENTARIO_FIRESTORE.md`
- `README_ADM-001C.3.md`
- `tools/manifestos/ADM-001C.3-AUDITORIA-FIRESTORE.txt`
- `tools/manifestos/ADM-001C.3-FIRESTORE-SECURITY-BASELINE.txt`

## Instalação dos testes

Na raiz do projeto:

```powershell
npm ci
```

Esse comando instala apenas ferramentas locais de teste e não publica regras.
O pacote fixa `firebase-tools` 15.25.1 ou superior da mesma linha principal,
eliminando as ocorrências de severidade alta e crítica detectadas na versão 14.

## Validação local obrigatória

```powershell
npm run test:rules
flutter analyze
git status --short
```

Critérios:

- todos os testes das regras aprovados;
- `flutter analyze` com `No issues found!`;
- nenhum arquivo inesperado no Git.
- `npm audit` sem vulnerabilidade alta ou crítica nas ferramentas locais.

## Proibição de publicação

Não executar `firebase deploy`, `firebase deploy --only firestore:rules` ou comando equivalente. A publicação remota depende de autorização expressa após testes locais, revisão do diff e registro da regra anterior.

## Observação sobre `package-lock.json`

O arquivo é gerado e versionado para tornar reproduzível a instalação das ferramentas de teste. A pasta `node_modules` não deve ser versionada.

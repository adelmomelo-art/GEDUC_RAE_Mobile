# ADM-001C.3-R1 — Correção da Code Review do PR nº 3

## Motivo

A revisão arquitetural identificou que a baseline inicial de
`firestore.rules` removeu, sem decisão explícita, validações anteriormente
existentes em `domains`.

## Correção

- campos mínimos exigidos na criação;
- tipos essenciais validados;
- `grupo`, `codigo` e `nome` não podem ser vazios;
- `createdAt` e `updatedAt` devem ser timestamps;
- `createdAt` permanece imutável na atualização;
- administrador e gestor continuam autorizados conforme a matriz homologada;
- teste negativo para documento incompleto;
- teste negativo para alteração de `createdAt`;
- teste positivo para atualização válida.

## Validação obrigatória

```powershell
npm run test:rules
flutter analyze
git status --short
```

Resultado esperado:

- Firestore: 15/15 testes aprovados;
- Flutter: `No issues found!`;
- nenhuma publicação remota.

## Controle

Não executar `firebase deploy`. O PR nº 3 somente será liberado para merge
após a nova validação, CPB corretivo, commit e push.

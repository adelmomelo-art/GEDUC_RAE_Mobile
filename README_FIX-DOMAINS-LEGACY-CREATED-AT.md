# Correção — atualização de domínios legados

## Problema

Domínios criados antes da introdução de `createdAt` podem ser lidos, mas não
editados ou inativados pelas regras atuais do Firestore. A tentativa resulta
em `cloud_firestore/permission-denied`.

## Correção

- detectar documentos legados sem `createdAt` durante edição ou alteração de
  status;
- preencher `createdAt` com timestamp do servidor nessa primeira atualização;
- permitir nas regras somente essa regularização controlada;
- preservar a imutabilidade de `createdAt` após o documento ser regularizado.

## Segurança

A correção não amplia os perfis autorizados. Somente administrador e gestor
continuam autorizados a criar e atualizar domínios. Exclusão permanece negada.

## Validação

- `flutter analyze --no-pub`: sem apontamentos;
- 522 testes Flutter aprovados;
- 16 testes de regras do Firestore aprovados;
- cenário de regularização única do domínio legado aprovado;
- tentativa posterior de alteração de `createdAt` corretamente negada.

## Observação operacional

Valores como `Teste22` são exibidos quando estão ativos no grupo cadastrado.
Após a regularização, a Central de Domínios poderá corrigir ou inativar esses
registros normalmente.

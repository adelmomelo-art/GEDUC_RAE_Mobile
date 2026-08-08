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

## Publicação

Concluída em 08/08/2026:

- PR #17 integrado à `main` no commit
  `15c888f400d0c981804836bfd2805c3799a95e5d`;
- deploy restrito a `firestore:rules` no projeto `geduc-rae-mobile`;
- regras compiladas e liberadas com sucesso;
- SHA-256 da baseline anterior:
  `DC1C7E634B560AE96C7D9360D52C2E8D6EF8A876BE3563586EE49937D4AF9DBD`;
- SHA-256 da regra publicada:
  `398350A08B825D8FF932FE912BB46FF307645EDB0C7B02108D9FD8973E542641`;
- APK não gerado nesta etapa por decisão do responsável.

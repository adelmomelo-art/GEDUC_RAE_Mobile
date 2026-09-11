# BUG-RAE-002E.2D.2E.1B — Adaptador remoto estreito CREATE_ONLY

Status: **IMPLEMENTAÇÃO LOCAL + TESTES COM MOCKS / NÃO EXECUTAR REMOTO**

## Objetivo

Criar a ponte mínima entre o executor institucional já homologado e a API REST do
Firestore, sem disponibilizar CLI remoto, ADC ou execução automática.

## Superfície pública

O adaptador expõe somente:

- `getExistingContentHash(collectionPath, documentId)`
- `createOnly({ collectionPath, documentId, payload, intendedContentHash })`

Não expõe `createDocument`, `set`, `update`, `patch`, `put`, `delete` ou qualquer
método genérico de escrita.

## Guardas

- projeto aceito: somente `geduc-rae-mobile`;
- coleção aceita: somente `projetos`;
- document ID validado;
- payload precisa conter `contentHash` idêntico ao hash pretendido;
- documento existente com mesmo hash: `unchanged`;
- documento existente com hash divergente: `changed_pending_review`;
- documento sem hash comparável: bloqueado;
- documento ausente: GET seguido de POST com `documentId`;
- conflito 409: relê o hash, nunca atualiza;
- nenhum PUT, PATCH ou DELETE existe;
- erros HTTP inesperados falham fechado.

## Importante

Este módulo é tecnicamente capaz de usar um `fetchFn` real quando composto por outra
camada, porém nesta etapa:

- não existe CLI remoto;
- não existe import de ADC/gcloud;
- todos os testes usam `fetchFn` e token provider falsos;
- nenhuma chamada de rede é executada;
- nenhum documento Firestore é criado.

A futura camada de execução remota será separada e deverá exigir confirmação explícita,
revalidar ruleset ativo e preflight remoto imediatamente antes de qualquer POST.

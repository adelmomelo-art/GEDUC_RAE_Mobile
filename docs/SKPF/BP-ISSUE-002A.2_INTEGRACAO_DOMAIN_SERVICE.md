# BP-ISSUE-002A.2 — Integração do DomainService com o Firestore

## 1. Objetivo

Conectar o `DomainService` à infraestrutura persistente criada na
ISSUE-002A.1, preservando sua API pública e evitando alterações no
`DomainRepository` e nas telas consumidoras.

## 2. Situação anterior

```text
DomainListPage
      ↓
DomainRepository
      ↓
DomainService
      ↓
List<DomainModel> em memória
```

Os registros existiam somente durante a execução da aplicação.

## 3. Arquitetura implementada

```text
DomainListPage
      ↓
DomainRepository
      ↓
DomainService
      ↓
DomainDataSource
      ↓
FirestoreDomainDataSource
      ↓
Cloud Firestore / domains
```

## 4. Decisões arquiteturais

### 4.1 Injeção da fonte de dados

O `DomainService` recebe opcionalmente um `DomainDataSource`.

Quando nenhuma implementação é informada, utiliza:

```dart
FirestoreDomainDataSource()
```

Isso mantém o uso atual:

```dart
DomainService()
```

e permite futuramente injetar fontes alternativas ou doubles de teste.

### 4.2 API pública preservada

Foram mantidos os métodos:

- `listarTodos`;
- `listarPorGrupo`;
- `buscarPorId`;
- `buscarPorCodigo`;
- `salvar`;
- `salvarTodos`;
- `ativar`;
- `desativar`;
- `limparCache`.

O `DomainRepository` não precisa ser alterado nesta etapa.

### 4.3 Compatibilidade de `limparCache`

O método foi preservado como operação sem efeito, pois ainda não existe
cache local nesta fase. A implementação de cache e modo offline será
tratada em pacote próprio.

## 5. Impacto funcional

A tela administrativa ainda mantém sua carga de sementes nesta etapa.
Como o serviço agora usa o Firestore, essa carga passa a persistir na
coleção `domains`.

A remoção da semente da camada de interface será realizada na
ISSUE-002A.3.

## 6. Riscos controlados

- As regras do Firestore devem permitir leitura e escrita da coleção
  `domains` para o perfil autorizado.
- A aplicação necessita de conexão na primeira carga enquanto o cache
  offline próprio ainda não foi implementado.
- A operação de sementes continua idempotente porque os documentos usam
  IDs determinísticos e escrita com `merge`.

## 7. Critérios de homologação

- `flutter analyze` sem issues;
- aplicação inicia sem regressão;
- tela de domínios abre sem exceção;
- documentos são gravados na coleção `domains`;
- atualização do status ativo/inativo persiste após recarregar a tela;
- Git limpo após commit e push.

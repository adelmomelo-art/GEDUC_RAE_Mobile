# BP-CE-031B — Cadastro e Edição de Domínios

## Objetivo

Permitir que a Central Administrativa de Domínios realize cadastro, edição,
duplicação e controle de status diretamente no Firestore.

## Arquitetura

```text
DomainListPage
    ↓ abre
DomainFormPage
    ↓ valida
DomainRepository
    ↓
DomainService
    ↓
FirestoreDomainDataSource
    ↓
Firestore / domains
```

## Entregas

- formulário de novo domínio;
- formulário de edição;
- geração automática do código;
- normalização do código;
- validação de campos obrigatórios;
- validação de ordem;
- bloqueio de código duplicado dentro do mesmo grupo;
- confirmação antes de descartar alterações;
- persistência no Firestore;
- duplicação com dados pré-preenchidos;
- feedback de sucesso e falha;
- atualização automática da lista após salvar.

## Regra de identidade

### Novo domínio

O identificador é formado por:

```text
grupo_codigo
```

### Edição

O `id` original é preservado, mesmo que grupo ou código sejam alterados. Isso
evita criar um segundo documento durante uma edição.

## Exclusão

Não existe exclusão física. O registro é mantido e pode ser inativado.

## Bootstrap

A semente permanece temporariamente na `DomainListPage`. Sua remoção continua
planejada para a CE-031E.

## Critérios de homologação

- novo domínio é salvo;
- domínio aparece após retornar à lista;
- edição persiste;
- código duplicado no mesmo grupo é bloqueado;
- mesmo código em grupo diferente é permitido;
- cancelar com alterações solicita confirmação;
- ativar/inativar continua funcionando;
- duplicar abre formulário pré-preenchido;
- `flutter analyze` sem issues.

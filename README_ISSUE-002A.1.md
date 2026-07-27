# ISSUE-002A.1 — Infraestrutura Persistente de Domínios

## Objetivo

Criar a infraestrutura de persistência dos domínios no Cloud Firestore sem alterar, nesta etapa, o comportamento da tela administrativa nem substituir o `DomainService` atual.

## Arquivos criados

- `lib/data/datasources/domain_data_source.dart`
- `lib/data/datasources/firestore_domain_data_source.dart`

## Coleção oficial

`domains`

Cada documento utiliza o `id` do `DomainModel` como identificador do documento.

## Operações implementadas

- listar todos;
- listar por grupo;
- buscar por ID;
- buscar por grupo e código;
- salvar um domínio;
- salvar vários domínios com batch;
- ativar;
- desativar.

## Decisões técnicas

- O `DomainModel` não foi alterado.
- Datas do Firestore são convertidas de `Timestamp` para `DateTime`.
- Escritas utilizam `SetOptions(merge: true)`.
- `updatedAt` é preenchido com horário do servidor.
- A integração do `DomainService` com este data source será feita na ISSUE-002A.2.
- A tela `DomainListPage` continua inalterada nesta etapa.

## Validação

Execute:

```powershell
flutter analyze
git status
```

Após homologação:

```powershell
git add lib/data/datasources/domain_data_source.dart `
        lib/data/datasources/firestore_domain_data_source.dart `
        README_ISSUE-002A.1.md

git commit -m "feat(domain): cria infraestrutura persistente no Firestore (ISSUE-002A.1)"
git push
```

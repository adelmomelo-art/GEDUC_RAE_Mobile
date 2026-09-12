# BUG-RAE-002E.2D.2E.1I — Plano de Mutação IAM em Dry-Run

Status: **PLANO LOCAL / NENHUMA MUTAÇÃO REMOTA**

## Objetivo

Transformar o blueprint IAM least-privilege em uma sequência de operações auditável,
reversível e **não executável** nesta etapa.

O módulo gera arrays de argumentos equivalentes a comandos `gcloud`, mas não importa
`child_process`, não possui CLI, não chama rede e não executa nenhum comando.

## Identidade dedicada

Service account proposta:

`fenix-project-catalog-seed@geduc-rae-mobile.iam.gserviceaccount.com`

Custom role proposta:

`projects/geduc-rae-mobile/roles/FenixProjectCatalogSeedCreateOnly`

Permissões da custom role:

- `datastore.entities.get`
- `datastore.entities.create`

Continuam ausentes:

- `datastore.entities.list`
- `datastore.entities.update`
- `datastore.entities.delete`
- `datastore.entities.allocateIds`

## Principal operador

O plano **não inventa** qual usuário ou service account poderá impersonar a identidade
de seed.

A futura execução exigirá um principal explícito no formato IAM, por exemplo:

- `user:...`
- `serviceAccount:...`
- `group:...`

O valor real deverá ser determinado e homologado em etapa própria.

## Ordem de mutação proposta

1. criar a service account dedicada;
2. criar a custom role;
3. vincular a custom role à service account no projeto;
4. conceder ao operador `roles/iam.serviceAccountTokenCreator` na service account alvo.

O binding de impersonação deve ser feito no **recurso da service account alvo**, e não
como concessão ampla no projeto.

## Rollback proposto

Na ordem inversa:

1. remover o binding `roles/iam.serviceAccountTokenCreator`;
2. remover o binding da custom role no projeto;
3. excluir a custom role, se continuar exclusiva desta intervenção;
4. excluir a service account, se continuar sem dependência aprovada.

Esse rollback se refere somente à infraestrutura IAM.

Nenhum documento da coleção `projetos` faz parte do rollback destrutivo.

## Invariantes

- nenhuma chave persistente de service account;
- nenhuma permissão UPDATE;
- nenhuma permissão DELETE;
- nenhuma permissão LIST;
- nenhuma `allocateIds`;
- nenhuma mutação IAM nesta etapa;
- nenhuma leitura ou escrita Firestore nesta etapa;
- nenhum seed nesta etapa.

## Próxima etapa

Após homologação e commit deste plano, a próxima etapa deve ser uma auditoria
READ-ONLY do ambiente IAM para descobrir:

- se a service account proposta já existe;
- se a custom role proposta já existe;
- se há bindings conflitantes;
- qual é o principal operador que será autorizado a impersonar;
- se existe algum recurso prévio que deva ser preservado.

Somente depois dessa auditoria deverá ser considerada uma mutação IAM real e
explicitamente autorizada.

# ADM-001C.3 — Inventário e matriz de acesso do Firestore

## Baseline auditada

O código cliente utiliza oito coleções. A ausência de regra específica implica negação.

| Coleção | Operações encontradas | Leitura | Criação/atualização | Exclusão |
|---|---|---|---|---|
| `usuarios` | `get`, `list` | próprio documento: autenticado; lista: administrador/gestor ativos | negada | negada |
| `domains` | `get`, `list`, `create`, `update` | todos os perfis ativos | administrador/gestor | negada |
| `tipos_acoes` | `get`, `list`, `create`, `update` | todos os perfis ativos | administrador/gestor | negada |
| `coordenadores` | `get`, `list`, `create`, `update` | todos os perfis ativos | administrador | negada |
| `regionais` | `get`, `list`, `create`, `update` | todos os perfis ativos | administrador | negada |
| `materiais` | `get`, `list`, `create`, `update` | todos os perfis ativos | administrador | negada |
| `acoes` | `get`, `list`, `create`, `update`, `delete` | todos os perfis ativos | todos os perfis ativos | administrador |
| `contadores` | `get`, `create`, `update` em transação | todos os perfis ativos, somente documento | todos os perfis ativos | negada |

## Perfis reconhecidos

- `administrador`
- `gestor`
- `coordenador`
- `agente`

O campo oficial é `perfilAcesso`. A identidade só é operacional quando o documento `usuarios/{uid}` existe, `ativo == true` e contém um perfil reconhecido.

## Decisões de segurança

1. `usuarios/{uid}` pode ser lido pelo próprio autenticado mesmo quando inativo, pois o cliente precisa identificar e apresentar esse estado.
2. Nenhuma escrita em `usuarios` é liberada até existir fluxo específico, auditado e homologado para administrar identidade.
3. Domínios e tipos de ações seguem a matriz cliente: administrador e gestor gerenciam.
4. Coordenadores, regionais e materiais são administrados somente pelo perfil administrador.
5. Todos os perfis ativos utilizam os catálogos operacionais e registram ações.
6. Exclusão de ação é restrita ao administrador. Cadastros administrativos são inativados, não excluídos.
7. `contadores` não permite consulta da coleção nem exclusão.
8. Coleções não inventariadas são bloqueadas por regra final de negação.

## Limitação conhecida

A coleção `acoes` ainda não possui um campo de autoria imutável e confiável. Por isso, esta baseline não consegue restringir atualização ao criador sem quebrar o fluxo atual. A inclusão de `criadoPorUid` e regras de propriedade deverá ser tratada em pacote próprio.

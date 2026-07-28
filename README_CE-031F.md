# CE-031F — Hardening da Central de Domínios

## Objetivo

Encerrar os riscos de persistência identificados na auditoria da Central de
Domínios, sem alterar o layout homologado.

## Alterações

### Persistência

- Removido o bootstrap automático da tela.
- Cadastro separado de atualização.
- Cadastro executado em transação e bloqueado quando o ID já existe.
- Atualização executada apenas quando o documento existe.
- Ativação e inativação não criam documentos incompletos.
- Inclusão automática de `createdAt` no cadastro.
- Atualização automática de `updatedAt`.
- ID técnico preservado durante edição.

### Interface

- Novo e duplicar utilizam `repository.criar`.
- Editar utiliza `repository.atualizar`.
- Ativar e inativar utilizam métodos específicos.
- Layout e filtros preservados.

### Segurança

Foi criado `firestore.rules` para versionamento inicial.

A regra considera administrador o usuário cujo documento seja:

```text
usuarios/{uid}
perfil: administrador
```

## Atenção

Não publique `firestore.rules` antes de confirmar que o campo e o valor usados
no cadastro de usuários são exatamente:

```text
perfil = administrador
```

Caso o projeto utilize `admin`, `Administrador`, `role` ou custom claims, a
função `administrador()` deverá ser ajustada antes do deploy.

## Arquivos

Criar na raiz:

- `firestore.rules`

Substituir:

- `lib/data/datasources/domain_data_source.dart`
- `lib/data/datasources/firestore_domain_data_source.dart`
- `lib/core/services/domain_service.dart`
- `lib/repositories/domain_repository.dart`
- `lib/modules/admin/domain_form_page.dart`
- `lib/modules/admin/domain_list_page.dart`

Preservar:

- `lib/modules/admin/domain_form_args.dart`

## Comandos

```bash
dart format lib/data/datasources/domain_data_source.dart
dart format lib/data/datasources/firestore_domain_data_source.dart
dart format lib/core/services/domain_service.dart
dart format lib/repositories/domain_repository.dart
dart format lib/modules/admin/domain_form_page.dart
dart format lib/modules/admin/domain_list_page.dart
flutter analyze
```

## Homologação

1. Abrir a Central de Domínios.
2. Atualizar a tela e confirmar que dados editados não são restaurados.
3. Cadastrar domínio.
4. Editar domínio.
5. Duplicar domínio.
6. Tentar cadastrar novamente o mesmo grupo e código.
7. Confirmar bloqueio de duplicidade.
8. Ativar domínio.
9. Inativar domínio.
10. Pesquisar e filtrar.
11. Fechar e reabrir a tela.
12. Confirmar persistência das alterações.
13. Confirmar 0 issues no `flutter analyze`.

## Deploy das regras

Somente após validar o perfil administrativo:

```bash
firebase deploy --only firestore:rules
```

Esse comando não integra a homologação inicial do CE-031F.

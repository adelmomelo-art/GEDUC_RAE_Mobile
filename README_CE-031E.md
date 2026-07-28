# CE-031E — Correção arquitetural do BUG-007

## Objetivo

Corrigir a falha ao duplicar domínios na Central de Domínios da Plataforma Fênix.

## Causa

O formulário utilizava apenas `domain != null` para diferenciar cadastro e edição.
Na duplicação, era enviado um objeto preenchido com `id` vazio. O formulário entrava
em modo de edição e tentava persistir um documento sem identificador válido.

## Arquivos

Criar:

- `lib/modules/admin/domain_form_args.dart`

Substituir:

- `lib/modules/admin/domain_form_page.dart`
- `lib/modules/admin/domain_list_page.dart`

## Validação técnica

```bash
dart format lib/modules/admin/domain_form_args.dart
dart format lib/modules/admin/domain_form_page.dart
dart format lib/modules/admin/domain_list_page.dart
flutter analyze
```

Resultado esperado:

```text
No issues found!
```

## Homologação funcional

1. Confirmar que o layout da Central de Domínios foi preservado.
2. Cadastrar um novo domínio.
3. Editar o domínio cadastrado.
4. Duplicar um domínio existente.
5. Confirmar o título `Duplicar domínio`.
6. Confirmar o nome com `— Cópia`.
7. Confirmar o código com `_copia`.
8. Salvar e confirmar `Domínio duplicado com sucesso.`
9. Confirmar original e cópia na lista.
10. Duplicar novamente sem alterar o código e validar o bloqueio de conflito.
11. Alterar o código e salvar uma segunda cópia.
12. Revalidar ativação, inativação, pesquisa, filtros e retorno da tela.

## Status

- BUG-006: preservado.
- BUG-007: aguardando análise e homologação.
- Sprint CE-031: ainda não encerrada.

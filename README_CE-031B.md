# CE-031B — Cadastro e Edição de Domínios

## Instalação

Substitua integralmente:

```text
lib/modules/admin/domain_list_page.dart
```

Adicione:

```text
lib/modules/admin/domain_form_page.dart
docs/SKPF/BP-CE-031B_CADASTRO_EDICAO_DOMINIOS.md
```

## Validação técnica

```powershell
flutter analyze
```

Resultado esperado:

```text
No issues found!
```

## Teste funcional

1. Abra `Administração > Central de Domínios`.
2. Clique em `Novo`.
3. Cadastre um domínio de teste.
4. Confirme que ele aparece na lista.
5. Reabra o domínio e altere nome, descrição ou ordem.
6. Atualize a tela e confirme a persistência.
7. Tente repetir o mesmo código no mesmo grupo.
8. Confirme que a duplicidade é bloqueada.
9. Use o menu do registro e teste `Duplicar`.
10. Teste ativar e inativar.
11. Inicie uma edição, altere um campo e pressione voltar.
12. Confirme a mensagem para descartar alterações.

## Git após homologação

```powershell
git add lib/modules/admin/domain_list_page.dart `
        lib/modules/admin/domain_form_page.dart `
        docs/SKPF/BP-CE-031B_CADASTRO_EDICAO_DOMINIOS.md `
        README_CE-031B.md

git commit -m "feat(domain): adiciona cadastro e edicao CE-031B"

git push
```

# CE-031A — Central Administrativa de Domínios

## Substituir

`lib/modules/admin/domain_list_page.dart`

## Adicionar

`docs/SKPF/BP-CE-031A_CENTRAL_ADMINISTRATIVA_DOMINIOS.md`

## Validar

```powershell
flutter analyze
```

Resultado esperado:

```text
No issues found!
```

## Teste funcional

1. Abra Administração > Central de Domínios.
2. Confira os quatro indicadores.
3. Teste pesquisa, seletor de grupo e chips.
4. Use Limpar filtros.
5. Atualize a tela.
6. Altere o status de um domínio.
7. Recarregue e confirme a persistência.
8. Clique em Novo; deve aparecer a mensagem da CE-031B.

## Commit após homologação

```powershell
git add lib/modules/admin/domain_list_page.dart `
        docs/SKPF/BP-CE-031A_CENTRAL_ADMINISTRATIVA_DOMINIOS.md `
        README_CE-031A.md

git commit -m "feat(domain): consolida painel administrativo CE-031A"
git push
```

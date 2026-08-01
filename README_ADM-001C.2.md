# ADM-001C.2 — Política Única de Autorização

## Objetivo

Eliminar decisões administrativas duplicadas e fazer interface, rotas e telas consumirem a política central de autorização da Plataforma Fênix.

## Alterações

- `AtalhosWidget` consulta `AuthorizationService` e `Permission.acessarAdministracao`.
- `AtalhosWidget` não recebe mais `UsuarioModel` nem compara nomes de perfil.
- `HomePage` utiliza o novo contrato do atalho.
- `/admin-legado` redireciona para `/admin`, eliminando o painel paralelo como caminho funcional.
- `UsuariosPage` utiliza o `UsuarioController` global fornecido por `app.dart`.
- a tela de usuários não instancia mais `UsuarioService` diretamente.
- `UsuarioController` passa a tratar carregamento, atualização e falhas.
- a listagem preserva dados existentes se uma atualização falhar.

## Arquivos alterados

- `lib/core/routes/app_routes.dart`
- `lib/modules/home/home_page.dart`
- `lib/modules/home/widgets/atalhos_widget.dart`
- `lib/modules/admin/controllers/usuario_controller.dart`
- `lib/modules/usuarios/usuarios_page.dart`

## Validação técnica

```powershell
flutter analyze
git status --short
```

Critério obrigatório:

```text
No issues found!
```

## Homologação funcional

1. Administrador visualiza o atalho Administração.
2. Administração apresenta os seis módulos autorizados.
3. URL/rota `/admin-legado` conduz ao painel oficial.
4. Usuários abre pela cadeia Provider → Controller → Repository → Service.
5. Atualizar usuários não duplica registros nem trava a tela.
6. Falha de leitura apresenta orientação e nova tentativa.
7. Botão Voltar retorna corretamente.
8. Login, Home e logout permanecem sem regressão.

## Restrições

- A matriz de perfis e permissões não foi ampliada.
- `firestore.rules` não foi alterado nem publicado.
- O arquivo legado `admin_page.dart` foi preservado no repositório, mas deixou de ser alcançável pelas rotas.
- Não avançar para ADM-001C.3 antes da homologação.


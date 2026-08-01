# ADM-001B.1 — Fundação Administrativa

## Objetivo

Centralizar a definição dos módulos administrativos da Plataforma Fênix, eliminar rotas literais do painel principal e preparar a evolução da autorização por perfil sem alterar os CRUDs existentes.

## Arquivos novos

- `lib/modules/admin/domain/admin_module.dart`
- `lib/modules/admin/domain/admin_module_catalog.dart`
- `lib/modules/admin/domain/admin_module_status.dart`
- `lib/modules/admin/domain/admin_permission.dart`
- `lib/modules/admin/widgets/admin_module_card.dart`

## Arquivos substituídos

- `lib/modules/admin/admin_home_page.dart`
- `lib/core/routes/app_routes.dart`
- `lib/core/navigation/navigation_manager.dart`

## Decisões arquiteturais

1. `AdminModuleCatalog` é a fonte única do menu administrativo.
2. `AppRoutes` é a fonte única dos caminhos de navegação.
3. O painel administrativo não cria listas locais de módulos.
4. A política de permissão é apenas fundacional; o bloqueio de rota ficará em pacote próprio.
5. `AdminPage` permanece como legado e não deve receber novas funcionalidades.
6. Nenhuma regra do Firestore foi modificada.

## Instalação

Copie os diretórios `lib` e `tools` deste pacote para a raiz do projeto, permitindo a substituição dos arquivos existentes.

## Validação técnica

Execute:

```powershell
dart format lib/core/routes/app_routes.dart lib/core/navigation/navigation_manager.dart lib/modules/admin
flutter analyze
git status
```

Resultado obrigatório:

```text
No issues found!
```

## Homologação funcional

1. Entrar na Plataforma Fênix.
2. Abrir a Administração.
3. Confirmar a exibição de seis módulos.
4. Confirmar os estados `Disponível` e `Em evolução`.
5. Abrir Central de Domínios e retornar.
6. Abrir Usuários e retornar.
7. Abrir Tipos de Ações e retornar.
8. Abrir Coordenadores e retornar.
9. Abrir Regionais e retornar.
10. Abrir Materiais e retornar.
11. Testar o painel em janela estreita e larga.
12. Confirmar que o botão Voltar retorna ao Centro de Operações.

## Limites do pacote

Este pacote não implementa autorização definitiva por perfil, não altera documentos de usuário e não modifica regras do Firestore.

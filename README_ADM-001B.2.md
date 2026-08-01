# ADM-001B.2 — Instalação e validação

## Instalação
Copie o conteúdo do pacote para a raiz do projeto, autorizando substituições.

## Formatação controlada
```powershell
dart format `
  lib/app.dart `
  lib/core/security `
  lib/core/routes/app_routes.dart `
  lib/core/routes/route_guard.dart `
  lib/modules/admin/access_denied_page.dart `
  lib/modules/admin/admin_home_page.dart `
  lib/modules/admin/domain
```

## Validação técnica
```powershell
flutter analyze
git status
git diff --stat
git diff --check
```

Resultado obrigatório: `No issues found!`.

## Homologação funcional
1. Administrador abre Administração e vê seis módulos.
2. Gestor abre Administração e vê Domínios, Usuários e Tipos de Ações.
3. Coordenador é redirecionado para Acesso não autorizado.
4. Agente é redirecionado para Acesso não autorizado.
5. Acesso direto a rota sem permissão é bloqueado.
6. Usuário não autenticado é redirecionado para Login.
7. Central de Domínios continua operacional.
8. Usuários, Tipos, Coordenadores, Regionais e Materiais não apresentam regressão para administrador.
9. Botão Voltar da tela de acesso negado retorna ao Centro de Operações.
10. Janela estreita e larga mantêm responsividade.

## Atenção
A matriz depende de `usuarios/{uid}.perfilAcesso`. Perfis fora da matriz são negados por padrão.

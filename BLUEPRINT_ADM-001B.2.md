# ADM-001B.2 — Camada de Autorização Administrativa

## Objetivo
Centralizar decisões de autorização por perfil, protegendo rotas administrativas e filtrando módulos visíveis sem alterar Firestore ou `UsuarioModel`.

## Fluxo
Firebase Auth → `AuthorizationService` → `UsuarioService` → `AuthorizationPolicy` → `RouteGuard` / Administração.

## Perfis iniciais
- administrador: todos os módulos administrativos;
- gestor: Administração, Domínios, Usuários e Tipos de Ações;
- coordenador: sem acesso administrativo nesta primeira matriz;
- agente: sem acesso administrativo.

## Decisões
- `AuthorizationService` é singleton e `ChangeNotifier`;
- o perfil é carregado pelo UID autenticado;
- o guard do GoRouter aceita decisão assíncrona;
- acesso negado possui rota e tela explícitas;
- o catálogo usa `Permission`, sem strings literais;
- `AdminPermission` permanece somente como ponte de compatibilidade.

## Fora do escopo
Regras Firestore, permissões dinâmicas, auditoria, MFA e estrutura organizacional.

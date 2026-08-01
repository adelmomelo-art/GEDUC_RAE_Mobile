# ADM-001C.1 — Identidade Confiável

## Objetivo

Centralizar a identidade operacional no `AuthorizationService` e negar acesso funcional quando a conta estiver sem cadastro, inativa, com perfil inválido ou com falha de validação.

## Arquivos novos

- `lib/core/security/identity_status.dart`
- `lib/modules/auth/account_access_page.dart`

## Arquivos alterados

- `lib/data/models/usuario_model.dart`
- `lib/core/services/usuario_service.dart`
- `lib/core/security/authorization_policy.dart`
- `lib/core/security/authorization_service.dart`
- `lib/core/routes/app_routes.dart`
- `lib/modules/auth/login_page.dart`
- `lib/modules/home/home_page.dart`
- `lib/modules/home/controllers/home_controller.dart`
- `lib/modules/home/models/home_state.dart`
- `lib/modules/home/services/home_loader_service.dart`

## Comportamento implementado

- Firebase Auth autentica; `usuarios/{uid}` habilita o acesso operacional.
- `ativo` ausente ou diferente de `true` bloqueia a conta.
- perfil ausente ou desconhecido bloqueia o acesso funcional.
- resultados atrasados pertencentes a outra sessão são descartados.
- logout limpa a identidade antes de encerrar a sessão Firebase.
- login e Home não consultam mais o usuário de forma independente.
- cache da Home permanece exclusivamente operacional.

## Instalação

Extraia o pacote na raiz do projeto, preservando a estrutura de diretórios e substituindo os arquivos existentes.

## Validação técnica

```powershell
flutter analyze
git status --short
```

Critério obrigatório:

```text
No issues found!
```

## Homologação funcional mínima

1. Usuário ativo com perfil reconhecido entra na Home.
2. Usuário sem documento é direcionado para “Cadastro operacional não localizado”.
3. Usuário inativo é direcionado para “Conta inativa”.
4. Perfil inválido é bloqueado.
5. “Tentar novamente” repete a validação.
6. “Sair” encerra a sessão e retorna ao login.
7. Logout pela Home não preserva nome nem permissão anterior.
8. Home online e cache offline continuam operacionais para usuário válido.

## Restrições

- Não publicar `firestore.rules` nesta etapa.
- Não avançar para ADM-001C.2 antes da homologação.
- Não realizar commit antes da análise do CPB de implementação.


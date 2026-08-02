# ADM-001C.1-R1 — Correção de recursão no roteamento

## Sintoma

Tela branca no Android acompanhada de `Unhandled Exception: Stack Overflow`.

## Causa

O `AuthorizationService` executava `notifyListeners()` no início de `_carregarUsuario`, antes de `garantirUsuarioAtual()` concluir a atribuição da Future em andamento. O `GoRouter`, inscrito no serviço, iniciava imediatamente um novo redirecionamento e repetia a validação de identidade de forma recursiva.

## Correção

Removida a notificação intermediária de `_carregarUsuario`. O estado de carregamento já é publicado pelos pontos que iniciam ou renovam a sessão. A notificação permanece ao final da validação, quando existe um resultado estável.

## Arquivo substituído

- `lib/core/security/authorization_service.dart`

## Validação

```powershell
flutter analyze
flutter run -d ID_DO_TABLET
```

Critérios:

- zero issues no analyze;
- ausência de `Stack Overflow`;
- login ou restauração da sessão sem tela branca;
- redirecionamento para Home ou para a página de situação da conta.


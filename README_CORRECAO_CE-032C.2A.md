# Correção de compatibilidade — CE-032C.2A

## Causa

O `home_state.dart` da CE-032C.2A substituiu indevidamente a máquina de estados
criada na CE-032C.1. O `HomeController` e a `HomePage` ainda dependem de:

- `HomeStatus`
- parâmetro `status`
- `removerMensagem`
- getters `estaOffline` e `possuiErro`

## Correção

A máquina de estados da CE-032C.1 foi preservada e recebeu os novos campos:

- `dadosEmCache`
- `cacheDisponivel`
- `atualizadoEm`

O `HomeController` também passa os metadados retornados pelo
`HomeLoaderService` para o `HomeState`.

## Validação

```powershell
dart format lib/modules/home
flutter analyze
```

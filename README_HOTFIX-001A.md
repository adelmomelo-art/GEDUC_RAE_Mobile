# HOTFIX-001A — Correção da tela de Localização

## Causa técnica

`Size.fromHeight(...)` cria um tamanho com largura `double.infinity`.

Na versão horizontal da `LocalizacaoActionBar`, os botões eram filhos não flexíveis
de uma `Row`. Isso fazia o Flutter receber uma largura mínima infinita e lançar:

- `BoxConstraints forces an infinite width`
- `RenderBox was not laid out`

## Correção

Foram substituídas apenas as três ocorrências:

```dart
minimumSize: const Size.fromHeight(altura...)
```

por:

```dart
minimumSize: const Size(0, altura...)
```

Nenhuma lógica funcional, rota, serviço ou estado foi alterado.

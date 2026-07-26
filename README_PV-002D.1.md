# PV-002D.1 — Refinamento visual da Localização

## Objetivo

Eliminar a repetição entre a orientação da Faxita e o card de escolha do modo de localização.

## Arquivo para substituição

```text
lib/modules/localizacao/localizacao_page.dart
```

## Alteração realizada

Foi removido do card de modo de localização o bloco com:

- “Como deseja informar o local?”;
- “Use o GPS no local ou pesquise e selecione no mapa.”;
- ícone e divisor vinculados ao cabeçalho repetido.

O card agora apresenta diretamente as opções:

- Sim, estou no local;
- Não estou no local.

O resumo da localização e todas as funcionalidades homologadas nos pacotes PV-002A, PV-002B, PV-002C e PV-002D foram preservados.

## Validação

Após substituir o arquivo, execute:

```bash
flutter analyze
```

Teste visualmente os modos GPS e localização remota, confirmando também o resumo e a persistência ao navegar.

# PV-002A — Estabilização da Localização

## Objetivo

Garantir o cumprimento do RF-021 no retorno da tela de Localização para a tela Nova Ação.

## Arquivo alterado

`lib/modules/localizacao/localizacao_page.dart`

## Implementação

- Sincroniza todos os campos atuais da localização com o `AcaoController` antes de voltar.
- Mantém `localizacaoValidada: false` quando o usuário retorna sem confirmar a etapa.
- Aplica a mesma regra no botão do AppBar, no botão inferior e no botão Voltar do sistema/navegador.
- Preserva endereço, bairro, Regional, nome do local, ponto de referência, coordenadas, precisão, origem e data/hora da captura.

## Substituição

Copie o arquivo completo para:

`lib/modules/localizacao/localizacao_page.dart`

## Validação técnica

Execute:

```bash
flutter analyze
```

## Homologação funcional

1. Abra Nova Ação e preencha os dados.
2. Avance para Localização.
3. Digite ou altere os campos de localização.
4. Volte para Nova Ação.
5. Entre novamente em Localização.
6. Confirme que os dados permanecem preenchidos.
7. Repita usando o botão Voltar do sistema ou navegador.

## Commit sugerido após homologação

```bash
git add lib/modules/localizacao/localizacao_page.dart README_PV-002A.md
git commit -m "fix: preserva dados da localizacao ao voltar PV-002A"
```

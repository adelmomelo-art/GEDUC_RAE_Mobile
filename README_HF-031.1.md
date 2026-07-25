# HF-031.1 — Correção da Regional Manual

## Correção
Uma resposta tardia da consulta automática podia limpar ou substituir a
Regional digitada manualmente. O hotfix invalida a consulta pendente assim
que o usuário edita o campo Regional.

## Arquivos
- `lib/modules/localizacao/controllers/localizacao_controller.dart`
- `lib/modules/localizacao/localizacao_page.dart`
- `lib/modules/localizacao/widgets/localizacao_form_card.dart`

## Validação
1. Substitua os três arquivos.
2. Execute `flutter analyze`.
3. Informe um bairro sem correspondência.
4. Aguarde a mensagem de Regional não identificada.
5. Digite a Regional manualmente.
6. Confirme e avance.

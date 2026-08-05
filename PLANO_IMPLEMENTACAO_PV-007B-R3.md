# PLANO DE IMPLEMENTAÇÃO — PV-007B-R3
## Alinhamento cromático da Home Operacional

## Escopo de alteração

1. Centralizar a nova paleta em `home_visual_tokens.dart`.
2. Aplicar o gradiente laranja e controles azul-marinho/grafite ao cabeçalho.
3. Reclassificar as cores dos atalhos principais e secundários.
4. Aplicar fundo creme e ação verde-petróleo ao card da Faixita.
5. Ajustar a semântica cromática dos indicadores.
6. Acrescentar teste de regressão para os tokens cromáticos aprovados.

## Arquivos modificados

- `lib/modules/home/theme/home_visual_tokens.dart`
- `lib/modules/home/widgets/centro_operacoes_header.dart`
- `lib/modules/home/widgets/atalhos_widget.dart`
- `lib/modules/home/widgets/faixita_operacional_card.dart`
- `lib/modules/home/widgets/indicadores_widget.dart`
- `test/modules/home/widgets/home_operacional_compacta_test.dart`

## Arquivos documentais adicionados

- `BLUEPRINT_PV-007B-R3.md`
- `PLANO_IMPLEMENTACAO_PV-007B-R3.md`
- `README_PV-007B-R3.md`
- `tools/manifestos/PV-007B-R3-ALINHAMENTO-CROMATICO.txt`

## Validação obrigatória

```powershell
dart format `
  .\lib\modules\home\theme\home_visual_tokens.dart `
  .\lib\modules\home\widgets\centro_operacoes_header.dart `
  .\lib\modules\home\widgets\atalhos_widget.dart `
  .\lib\modules\home\widgets\faixita_operacional_card.dart `
  .\lib\modules\home\widgets\indicadores_widget.dart `
  .\test\modules\home\widgets\home_operacional_compacta_test.dart

flutter test `
  .\test\modules\home\widgets\home_operacional_compacta_test.dart

flutter analyze
git diff --check
git status -sb
```

## Homologação funcional e visual

- Samsung A05: verificar cabeçalho, atalhos, card da Faixita e indicadores sem corte.
- Samsung Tab S6: verificar distribuição em múltiplas colunas e consistência cromática.
- Conferir atualização, saída, Nova Ação, Consultar RAE e Administração.
- Não realizar commit antes da homologação visual nos dois dispositivos.

# OBS-REL-001 - Blueprint PDF Unicode

## Objetivo

Eliminar a dependencia implicita de Helvetica Type1 no relatorio RAE e
garantir suporte deterministico a acentuacao e Unicode latino em modo offline.

## Causa raiz

`PdfRelatorioService` cria o documento sem tema tipografico explicito.
O pacote `pdf` usa a familia Type1 padrao quando nenhuma fonte TrueType e
fornecida. Os testes historicos registraram avisos de Helvetica sem suporte
Unicode.

## Decisao

Empacotar Noto Sans localmente e aplicar `pw.ThemeData.withFont` ao
`pw.Document`:

- Regular;
- Bold;
- Italic;
- BoldItalic.

As fontes sao carregadas por `rootBundle`, sem dependencia de rede durante a
geracao do PDF.

## Fonte e licenca

- Familia: Noto Sans;
- versao: 2.015;
- origem: `notofonts/latin-greek-cyrillic`;
- licenca: SIL Open Font License 1.1;
- `OFL.txt` versionado junto das fontes.

## Invariantes

- duas paginas A4 preservadas;
- cabecalho institucional preservado;
- rodape preservado;
- QR Code preservado;
- imagens/evidencias preservadas;
- regras de compactacao de texto preservadas;
- nenhum acesso de rede necessario para a fonte;
- nenhum `PdfGoogleFonts` em runtime;
- nenhuma mudanca em Firestore, R2 ou App Check.

## Homologacao

1. fonte local presente no bundle;
2. cenarios PDF existentes aprovados;
3. cenario Unicode com acentos e caracteres latinos;
4. ausencia de warning Helvetica/Unicode;
5. suite Flutter completa;
6. `flutter analyze`;
7. `git diff --check`;
8. inspecao visual de `RAE_CENARIO_UNICODE.pdf`.

Commit, push e PR somente depois da prova visual.

## Courier residual do QR Code

Apos a correcao da Helvetica, o gate detectou um warning Courier.

A causa foi localizada em `pw.BarcodeWidget`, que define Courier para seu
texto humano. No QR do RAE, esse texto nao possui funcao operacional.

Decisao:
- preservar `pw.Barcode.qrCode()`;
- preservar `_gerarConteudoQr(acao)`;
- definir `drawText: false`;
- exigir ausencia de qualquer warning `has no Unicode support`.

## Gate visual de campos longos

A homologacao visual deve confirmar que os campos longos da pagina 1 nao ficam
em branco apos a troca de Helvetica por Noto Sans.

Ajuste:
- `_celulaCampo`: `height: 27` -> `height: 32`.

A decisao preserva a grade de tres colunas, o conteudo e as duas paginas A4.

## Fechamento da homologacao visual

A R8 ampliou `_celulaCampo` de 27 para 32 pontos para acomodar as metricas
da Noto Sans em valores longos.

A amostra final foi homologada com:
- duas paginas A4;
- nenhum campo longo em branco;
- nenhum warning Type1 sem Unicode;
- QR preservado sem texto humano Courier;
- identidade visual institucional preservada.

SHA-256 da amostra homologada:
`807481D7D18A895BFF17BC941C9D5C77D304E258E2D9B17A5B41A1F51DAC12CE`

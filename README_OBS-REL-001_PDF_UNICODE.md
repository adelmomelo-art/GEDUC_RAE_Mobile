# OBS-REL-001 - PDF Unicode

## Correcao

O relatorio RAE passa a usar Noto Sans empacotada no aplicativo em vez de
depender do fallback Type1 Helvetica.

A geracao permanece offline e deterministica.

## Preservado

- duas paginas A4;
- identidade visual;
- QR Code;
- fotos;
- assinaturas;
- campos e metricas;
- Faixita;
- gerar e compartilhar PDF.

## Gate visual

Amostra:

`tools/output/OBS-REL-001-PDF-UNICODE/samples/RAE_CENARIO_UNICODE.pdf`

Inspecionar acentos, cedilha, til, `nº`, travessao, nomes proprios, ausencia
de quadrados/glifos faltantes e preservacao do layout.

## QR Code e Courier

A homologacao intermediaria identificou que `BarcodeWidget` utiliza Courier
para o texto humano do codigo de barras.

O RAE usa esse widget exclusivamente como QR Code de validacao e nao precisa
desenhar texto redundante abaixo do simbolo. Por isso o QR usa
`drawText: false`.

O payload produzido por `_gerarConteudoQr(acao)` permanece integralmente
codificado no QR.

## Ajuste visual de campos longos

A primeira amostra Unicode confirmou a tipografia, mas revelou que alguns
valores longos da grade da pagina 1 ficavam em branco com a nova metrica da
Noto Sans.

Foram observados especialmente:
- Nome da acao;
- Ponto de referencia;
- Instituicao parceira.

A altura da celula da grade foi ajustada de 27 para 32 pontos. A pagina 1
possui margem vertical suficiente e continua limitada a uma pagina A4.

## Homologacao visual final R8

Status: PASS.

Amostra homologada:
`tools/output/OBS-REL-001-PDF-UNICODE/samples/RAE_CENARIO_UNICODE.pdf`

SHA-256:
`807481D7D18A895BFF17BC941C9D5C77D304E258E2D9B17A5B41A1F51DAC12CE`

Resultado visual:
- duas paginas A4 preservadas;
- Noto Sans Unicode sem Helvetica/Courier textual;
- Nome da acao longo visivel em duas linhas;
- Ponto de referencia longo visivel em duas linhas;
- Instituicao parceira longa visivel em duas linhas;
- acentos, cedilha, til, `nº` e travessao preservados;
- QR Code preservado com `drawText: false`;
- cabecalho, rodape, Faixita e assinaturas preservados.

OBS-REL-001 encontra-se tecnicamente e visualmente homologada.

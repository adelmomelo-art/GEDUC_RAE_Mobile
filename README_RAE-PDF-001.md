# RAE-PDF-001 - Homologacao de conteudo real

## Objetivo

Validar o relatorio RAE timbrado em cenarios representativos antes da geracao do APK de release.

## Cenarios cobertos

1. Relatorio sem fotografias, preservando os tres espacos de evidencias.
2. Relatorio com tres fotografias.
3. Relatorio com textos extensos nos campos de planejamento, localizacao, integracao, avaliacao e evidencias.

Todos os cenarios permanecem em duas paginas A4 e preservam cabecalho institucional, faixa de rodape, QR Code e assinaturas.

## Ajuste preventivo

Campos extensos usam fonte compacta e abreviacao com reticencias somente quando ultrapassam o espaco fisico da celula. Isso evita campos em branco sem alterar a estrutura homologada do documento.

## Validacoes executadas

- `flutter analyze --no-pub`: sem problemas.
- Testes dedicados do gerador: 3 aprovados.
- Suite completa: 526 testes aprovados.
- Inspecao visual das seis paginas renderizadas.

## Estado de publicacao

Etapa validada localmente. Commit, push, PR e APK de release dependem de autorizacao posterior.

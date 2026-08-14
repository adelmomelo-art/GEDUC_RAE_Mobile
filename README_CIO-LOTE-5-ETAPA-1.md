# CIO Lote 5 — Etapa 1

## Fundação cartográfica oficial

**Data:** 13/08/2026
**Branch:** `feature/cio-mapa-territorial-seguro-lote5`
**Baseline:** `main @ 1a6019f2dae0cd8fd884c0e423f460986f0c179b`

## Entrega

- GeoJSON oficial dos 121 bairros incorporado como ativo Flutter;
- manifesto com fonte, CRS, atribuição, contagem e SHA-256;
- ferramenta reprodutível que rejeita fonte divergente antes de gerar ativos;
- repositório local com validação de manifesto, hash, feições, nomes e códigos;
- modelos cartográficos imutáveis;
- SHA-256 implementado sem nova dependência;
- serviço ponto-em-polígono compatível com Polygon, MultiPolygon, furos e bordas;
- prova de correspondência exata com os 121 bairros do catálogo canônico.

## Fonte

- provedor: IPLANFOR — Prefeitura de Fortaleza;
- conjunto: Bairros de Fortaleza;
- CRS de distribuição utilizado: EPSG:4326;
- feições: 121;
- SHA-256 do GeoJSON:
  `D04B16BBAD3DD205AA19C616CD8CB4D4061917234E656AEF3DF18159CAEF0CCE`;
- página oficial:
  `https://mapas.fortaleza.ce.gov.br/mapa/21/bairros-de-fortaleza`.

## Verificações

- vetor conhecido do algoritmo SHA-256: aprovado;
- carregamento e hash do ativo oficial: aprovado;
- 121 nomes e códigos únicos: aprovado;
- correspondência com catálogo canônico: 121/121;
- ponto interno e sobre borda: aprovados;
- ponto externo e dentro de furo: rejeitados corretamente;
- `flutter analyze --no-pub`: sem problemas.

## Limites preservados

- nenhuma interface alterada;
- mapa executivo ainda desativado;
- nenhuma rota, Provider ou dependência adicionada;
- nenhum RAE ou documento do Firestore alterado;
- nenhuma regra de elegibilidade ou exclusão G1/G2 implementada nesta etapa;
- nenhum commit ou publicação realizado.

## Próxima etapa

Etapa 2 — política de elegibilidade, registro explícito de G1/G2 e agregação por
bairro e Regional, sem coordenadas no resultado.

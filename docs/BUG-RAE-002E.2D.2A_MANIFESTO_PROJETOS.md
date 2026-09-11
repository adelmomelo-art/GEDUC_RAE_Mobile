# BUG-RAE-002E.2D.2A — Manifesto institucional dos projetos

Status: **LOCAL / READ-ONLY em relação ao Firestore remoto**

Este pacote consolida os 53 itens do documento institucional da AMC em um manifesto determinístico para futura carga controlada da coleção `projetos`.

## Fonte institucional
- Documento: AUTARQUIA MUNICIPAL DE TRÂNSITO E CIDADANIA – AMC — PORTFÓLIO DE PROJETOS E AÇÕES DE EDUCAÇÃO PARA O TRÂNSITO — FORTALEZA – CE — 2026
- Google Docs ID: `1dY23YWic_-oH0IjCI2f-IuNfKYPIdyDPa6AZr78MHJ0`
- Revisão consultada: `ANLCKQn4KDuus0KxHMDfq6MqKTmFxZZnDA703EAnplSTPC9ZCyQwVH4e95h0usPewqGjMeOehtVsrxrVQnwt6BAnxRNKK1ldjjCjr_7zKyM`
- Ano: 2026

## Contagem
- Ação Educativa: 8
- Comando Educativo: 14
- Curso: 6
- Palestra: 16
- Roda de Conversa: 1
- Treinamento Institucional: 6
- Workshop: 2
- Total: **53**

## Decisões
- IDs e códigos são category-aware para impedir colisões nominais.
- `regionalIds` e `equipeIds` permanecem `[]` por compatibilidade de schema.
- `equipeIds` não representa equipe operacional do RAE.
- `objetivo` só foi preenchido quando a própria redação institucional explicita finalidade/efeito pretendido.
- `aliases` só foram usados quando aparecem explicitamente no documento.
- Este pacote **não contém seed remoto**, credenciais, deploy de Rules ou gravação no Firestore.

## SHA256
`tools/catalogos/projetos_institucionais_2026.json`

`C109703987A86B6D22C34CB0C1072CE434BB1E1CFAF6F01A43D40630EDB2A43C`

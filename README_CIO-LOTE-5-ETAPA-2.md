# CIO Lote 5 — Etapa 2

## Elegibilidade e agregação territorial

**Data:** 13/08/2026
**Branch:** `feature/cio-mapa-territorial-seguro-lote5`

## Entrega

- manifesto versionado com os oito bloqueios homologados;
- quatro exclusões G1 por coordenada não homologada;
- quatro exclusões G2 por registro de teste sem evidência territorial;
- carregamento validado com portão obrigatório 4/4;
- política conservadora de elegibilidade cartográfica;
- agregação por bairro e Regional;
- aplicação do mesmo recorte temporal e dos filtros do Dashboard;
- resultado imutável sem latitude, longitude ou dados pessoais.

## Critérios cumulativos de elegibilidade

Um RAE somente é agregado quando:

1. seu ID não consta no manifesto G1/G2;
2. possui número operacional;
3. possui `regionalId`;
4. possui coordenadas mundiais válidas e diferentes de zero;
5. está contido em exatamente um bairro oficial;
6. o bairro textual coincide com a geometria;
7. a Regional textual coincide com a geometria.

Falhar em qualquer critério exclui o registro do agregado e contabiliza o
motivo, sem alterar o RAE.

## Privacidade

O resultado expõe somente:

- bairro;
- Regional;
- quantidade agregada;
- totais de elegíveis e excluídos;
- contagem por motivo de rejeição.

Não fazem parte do resultado coordenadas, endereço, nome da ação, responsáveis,
horários ou identificadores de RAEs elegíveis.

## Verificações

- manifesto G1/G2: oito IDs únicos e composição 4/4;
- registro coerente: aprovado;
- ID explicitamente bloqueado: excluído;
- número ausente: excluído;
- bairro ou Regional divergente: excluído;
- agregação por bairro e Regional: aprovada;
- filtros e janela de 30 dias: aprovados;
- ausência de coordenadas no modelo agregado: aprovada;
- nenhuma interface, rota, Provider, dependência ou Firestore alterado.

## Portão do conjunto homologado

O baseline humano já aprovado permanece 32 RAEs elegíveis e oito exclusões
G1/G2. A prova automatizada contra a leitura real será executada quando o
`DashboardController` passar a carregar a fundação na Etapa 3; até lá, o mapa
continua desativado.

## Próxima etapa

Etapa 3 — integração protegida no Dashboard e representação agregada dos
polígonos oficiais, ainda sob configuração desativada.

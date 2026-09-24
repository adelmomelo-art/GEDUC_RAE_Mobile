# ESC-001H.4 — Indicadores operacionais e Faixita

## Objetivo

Apresentar uma leitura explicável da execução da escala a partir das horas já
consolidadas pela ESC-001H.1/H.2/H.3.

## Entregas

- cobertura dos registros de horas;
- aderência entre horas realizadas e planejadas;
- faixas descritivas abaixo, compatível ou acima do planejado;
- orientação determinística da Faixita;
- integração na tela de histórico de horas.

## Limites

- não cria nota, ranking ou comparação entre pessoas;
- horas extras e banco de horas não representam maior produtividade;
- pendências são apresentadas antes de qualquer interpretação;
- não calcula valores financeiros;
- não grava documentos e não altera regras do Firebase;
- usa somente escalas publicadas e a matriz de acesso existente.

## Cálculos

- cobertura = registros com horas coerentes / total de alocações;
- aderência = minutos realizados / minutos planejados;
- abaixo do planejado: menos de 90%;
- compatível com o planejado: de 90% a 110%, inclusive;
- acima do planejado: mais de 110%.

As faixas são alertas operacionais, não juízo de desempenho.

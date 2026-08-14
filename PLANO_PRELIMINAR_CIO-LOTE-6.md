# Plano preliminar — CIO Lote 6

## Objetivo

Evoluir a leitura territorial do CIO com indicadores de intensidade e preparar,
em trilha separada, uma solução operacional segura para pinos.

## Trilha A — Intensidade territorial agregada

- definir a métrica de intensidade: volume, pessoas alcançadas, recorrência ou
  indicador composto;
- normalizar a intensidade para evitar comparação enganosa entre territórios;
- representar faixas por polígonos de Bairro e Regional;
- oferecer legenda, período, filtros e estado sem dados;
- manter agregação, exclusões G1/G2 e funcionamento offline;
- validar contraste, acessibilidade e desempenho no Samsung Galaxy A05.

Esta trilha não usa pinos individuais. O resultado esperado é um mapa
coroplético de intensidade, preservando a governança homologada no Lote 5.

## Trilha B — Pinos operacionais restritos

A necessidade de pinos é real, mas exige uma atualização controlada antes da
implementação. O Blueprint deverá definir:

- finalidade e perfis autorizados;
- quais registros podem aparecer e em qual precisão;
- ocultação ou redução de precisão para casos sensíveis;
- separação entre CIO gerencial e módulo operacional;
- trilha de auditoria e comportamento de captura de tela/exportação;
- limites de zoom, seleção, detalhes e retenção;
- regras online/offline e revogação de acesso;
- testes de autorização, vazamento e regressão.

Nenhum pino será implementado até a aprovação desse Blueprint e da matriz de
privacidade.

## Etapas propostas

1. auditoria de dados, perfis e métricas;
2. Blueprint e matriz de riscos;
3. protótipo da intensidade agregada;
4. implementação e testes técnicos;
5. homologação física no A05;
6. Blueprint específico dos pinos operacionais;
7. decisão independente sobre implementação e publicação dos pinos.

## Portões de qualidade sugeridos

- 100% dos acessos a pinos cobertos por autorização automatizada;
- zero coordenadas individuais no painel gerencial agregado;
- 100% dos G1/G2 bloqueados enquanto não forem reclassificados;
- zero exposição de dados pessoais na legenda, seleção ou telemetria;
- testes funcionais, privacidade, offline e desempenho aprovados;
- homologação humana obrigatória no Samsung Galaxy A05.

## Estado

Planejamento preliminar registrado. Auditoria e Blueprint do Lote 6 dependem de
autorização própria. Este documento não autoriza implementação dos indicadores
nem dos pinos.

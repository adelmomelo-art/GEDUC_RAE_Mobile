# ESC-001E.4 — Horas realizadas e evidências na UX

Entrega da quarta etapa da execução operacional da Escala GEDUC.

## Incluído

- registro e edição de início/fim reais na própria alocação publicada;
- cálculo automático de `minutosRealizados` no controller;
- confirmação transacional de titularidade e escala publicada no repositório;
- atualização local da consulta sem recarregar toda a escala;
- resumo visual das horas efetivamente realizadas;
- inclusão e remoção de metadados de evidência na missão em andamento;
- aviso explícito de que não existe upload físico nesta etapa;
- testes de controller e widgets para os novos fluxos.

## Mantido fora do escopo

- alteração de QTR, QTH, equipe, jornada ou minutos previstos;
- lançamento de horas de terceiros;
- Storage, R2 e enforcement de App Check;
- financeiro;
- Escala → RAE, reservada à ESC-001F.

## Baseline

`1aa4177f496c63e52b629b689df09f1bacaf1940`

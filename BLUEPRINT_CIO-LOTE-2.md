# BLUEPRINT CIO — Lote 2

## Inteligência operacional integrada

**Baseline:** `6e8da998`

**Branch:** `feature/cio-inteligencia-operacional-lote2`

**Status:** implementação técnica

## Objetivo

Conectar o Dashboard CIO ao `CIOAnalyticsService`, fazendo com que filtros,
KPIs, ranking regional, insights, alertas e recomendações sejam produzidos a
partir do mesmo conjunto de RAEs.

## Arquitetura

```text
CioDashboardFilters
        ↓
DashboardController
        ↓
DashboardCIOBridge
        ├─ DashboardService (agregação operacional existente)
        └─ CIOAnalyticsService (inteligência institucional)
        ↓
DashboardCIOResult
        ↓
Dashboard CIO
```

O `DashboardCIOBridge` é a fachada única da tela. Nenhum widget realiza
cálculos próprios.

## Decisões

- Controller mantido no escopo da tela; nenhum Provider global novo.
- Rotas, Firestore, dependências e fluxo do RAE permanecem inalterados.
- Comparação temporal usa a mesma fachada do período principal.
- Ranking inicial por regional, normalizado pelo melhor resultado do conjunto.
- A política de acesso do CIO permanece inalterada até decisão institucional.

## Critérios de aceite

- filtros do Lote 1 preservados;
- resultado vazio tratado sem exceção;
- indicadores e inteligência recalculados em conjunto;
- ranking, insights, alertas e recomendações visíveis e responsivos;
- testes do bridge e do painel aprovados;
- análise estática sem erros.

## Fora do escopo

Predição, novas coleções Firestore, novas dependências, exportação, mudanças no
BI Executivo e alterações no formulário RAE.

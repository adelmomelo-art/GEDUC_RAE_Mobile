# BLUEPRINT CIO — Lote 3

## Inteligência histórica e territorial

**Baseline:** `27667c96`

**Branch prevista:** `feature/cio-historico-territorial-lote3`

**Status:** proposto para aprovação

## Objetivo

Evoluir o Dashboard CIO homologado com leitura histórica e territorial dos RAEs,
preservando os filtros e indicadores do Lote 2 e explicitando a qualidade dos
dados usados em cada análise.

## Arquitetura

```text
CioDashboardFilters
        ↓
DashboardController
        ↓
DashboardCIOBridge
        ├─ EducacaoAnalyticsAdapter
        ├─ AnalyticsEngine
        ├─ CioTemporalAnalysis
        ├─ CioTerritorialAnalysis
        └─ CioDataQualityReport
        ↓
DashboardCIOResult
        ├─ série histórica contínua
        ├─ comparação equivalente
        ├─ ranking territorial normalizado
        ├─ diagnóstico de qualidade
        └─ drilldown rastreável aos RAEs
        ↓
Dashboard CIO oficial (/dashboard)
```

O bridge permanece como fachada única. Todo número exibido deve ser derivável do
mesmo conjunto filtrado e rastreável aos registros que o compõem.

## Escopo funcional

### 1. Série histórica oficial

- exibir ações, pessoas alcançadas, veículos e credenciais ao longo do tempo;
- completar períodos sem registro com valor zero;
- usar granularidade diária até 31 dias, mensal até 24 meses e anual acima
  desse intervalo;
- preservar o intervalo e os filtros selecionados no Lote 2;
- oferecer estado vazio e indicação do período efetivamente coberto.

### 2. Comparação e tendência descritiva

- comparar o intervalo atual com a janela imediatamente anterior e equivalente;
- calcular variação absoluta e percentual;
- classificar crescimento, estabilidade ou redução somente quando houver ao
  menos três buckets válidos em cada janela;
- quando a amostra for insuficiente, informar isso sem projetar resultados.

### 3. Inteligência territorial

- agrupar prioritariamente por `regionalId` reconhecido no catálogo;
- usar nome normalizado apenas como fallback explícito para registros legados;
- apresentar ranking, participação no total e principais indicadores;
- permitir drilldown da regional para os RAEs filtrados correspondentes;
- nunca combinar identidades territoriais ambíguas silenciosamente.

### 4. Qualidade visível

- informar cobertura temporal, identificação regional e geolocalização;
- distinguir dados válidos, legados e não resolvidos;
- impedir que alertas ou visualizações territoriais ocultem baixa cobertura.

## Mapa geográfico condicionado

O mapa não integra o núcleo obrigatório deste Lote 3. Sua ativação depende de:

1. relatório executado sobre dados reais;
2. regra quantitativa de aceite aprovada;
3. fonte oficial de geometria ou coordenadas territoriais;
4. tratamento documentado para RAEs sem localização válida;
5. homologação específica no Samsung Galaxy A05.

Enquanto essas condições não forem satisfeitas, a representação oficial será
ranking e matriz territorial, sem pontos ou regiões simuladas.

## Decisões arquiteturais

- nenhum Provider global novo;
- nenhuma rota nova;
- nenhuma coleção ou regra Firestore nova;
- nenhuma dependência nova;
- nenhuma alteração no fluxo de criação/fechamento do RAE;
- nenhum cálculo dentro de widgets;
- nenhum uso dos valores simulados de `DashboardExecutivoPage`;
- acesso atual preservado até decisão institucional sobre perfil CIO.

## Arquivos protegidos

- `lib/app.dart`
- `lib/core/routes/app_routes.dart`
- `firestore.rules`
- `pubspec.yaml`
- fluxo de criação e fechamento do RAE
- gerador de PDF e relatórios RAE

## Critérios de aceite

- filtros e indicadores homologados no Lote 2 permanecem funcionais;
- todos os gráficos derivam do conjunto filtrado do bridge;
- buckets ausentes aparecem como zero, sem fabricar RAEs;
- comparação usa janelas equivalentes e regra de amostra mínima;
- regional oficial usa chave estável e legado é identificado;
- drilldown reconcilia seu total com o indicador de origem;
- nenhum valor demonstrativo aparece na rota oficial;
- interface funciona em 320, 360, 412 e 800 px e escala de texto 1,3;
- análise estática e suíte de regressão aprovadas;
- homologação física realizada somente no Samsung Galaxy A05, salvo nova
  autorização de escopo.

## Fora do escopo

- previsão ou aprendizado de máquina;
- recomendação automática de alocação de equipes;
- IA generativa;
- mapa sem aprovação do portão de qualidade;
- novas coleções Firestore;
- exportação, PDF ou alteração do relatório RAE;
- alteração da política de acesso;
- reformulação visual externa ao Dashboard CIO.

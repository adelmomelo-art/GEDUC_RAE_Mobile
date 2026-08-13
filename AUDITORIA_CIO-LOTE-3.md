# Auditoria técnica — CIO Lote 3

## Base auditada

- Repositório: `GEDUC_RAE_Mobile`
- Branch de origem: `main`
- Baseline: `27667c96eba768a95ddb94ce10c69f3c2f9e26e5`
- Situação inicial: árvore limpa e sincronizada com `origin/main`
- Natureza desta entrega: auditoria, Blueprint e plano; sem alteração funcional

## Resumo executivo

O Lote 3 pode evoluir o Dashboard CIO homologado no Lote 2 sem criar uma nova
arquitetura. O projeto já possui registros temporais, fachada analítica, filtros,
ranking regional e componentes gráficos reutilizáveis.

O principal risco está na qualidade territorial. Os RAEs aceitam `regional`,
`regionalId`, bairro, latitude e longitude, mas o adaptador analítico publica
apenas os nomes de regional e bairro. O catálogo de regionais não possui
geometria, e a base de código contém nomenclaturas heterogêneas, como `I`, `II`,
`VI`, `XII`, `CENTRO` e exemplos no formato `SER 09`.

Por isso, o escopo seguro é: série histórica oficial, ranking territorial
normalizado, diagnóstico de qualidade, comparação entre períodos e drilldown.
Um mapa geográfico real fica condicionado à aprovação do portão de qualidade.

## Providers

- O `DashboardController` permanece local à tela do Dashboard.
- O `DashboardCIOBridge` já é a fachada única entre UI e serviços analíticos.
- Não há necessidade de novo Provider global.
- Widgets não devem consultar Firestore nem calcular indicadores diretamente.

**Decisão:** preservar a composição homologada no Lote 2.

## Rotas e acesso

- O Dashboard oficial continua na rota `/dashboard`.
- Não é necessária nova rota para série, ranking ou drilldown.
- A política atual permite acesso ao Dashboard por identidade ativa e não possui
  permissão específica de CIO.
- `DashboardExecutivoPage` não integra a rota oficial e contém valores
  demonstrativos; não pode ser promovida nem usada como fonte de verdade.

**Decisão:** implementar o Lote 3 dentro do Dashboard oficial e manter a política
de acesso. Uma restrição gerencial exige decisão institucional separada.

## Dependências

- A série histórica pode usar a infraestrutura gráfica já instalada.
- O projeto já possui suporte cartográfico, mas isso não resolve a ausência de
  geometria e a qualidade incerta das coordenadas.
- Não são necessárias novas coleções Firestore nem novas dependências.

**Decisão:** `pubspec.yaml` e `firestore.rules` permanecem protegidos.

## Contratos de dados

### Temporal

- `AcaoModel.dataAcao` fornece a data de ocorrência.
- `DashboardService` já produz `DashboardSerieTemporalItem`.
- A implementação atual só retorna períodos que contêm registros; lacunas não
  aparecem como zero e podem distorcer a leitura de continuidade.
- A granularidade atual depende do filtro legado e precisa ser formalizada para
  intervalos personalizados.

### Territorial

- `AcaoModel` contém `regional`, `regionalId`, `tipoRegional`, bairro, latitude,
  longitude e campos de validação da localização.
- `RegionalModel` contém identidade, nome, código, tipo e bairros, mas não possui
  polígono ou centroide.
- `EducacaoAnalyticsAdapter` não expõe `regionalId`, `tipoRegional`, latitude ou
  longitude para o núcleo analítico.
- Agrupar somente pelo nome visível pode fragmentar uma mesma regional ou unir
  registros distintos indevidamente.

## Riscos e tratamentos

| Risco | Nível | Tratamento proposto |
|---|---:|---|
| Tela executiva demonstrativa ser confundida com dado oficial | Alto | Não reutilizar seus valores; manter fora da rota oficial |
| Regionais equivalentes com nomes diferentes | Alto | Usar `regionalId` como chave; fallback nominal marcado como legado |
| Série omitir períodos sem registro | Alto | Completar buckets vazios com zero |
| Coordenadas ausentes ou inválidas | Alto | Portão de qualidade antes de mapa |
| Comparações com amostra insuficiente | Médio | Exibir “dados insuficientes”, sem classificar tendência |
| Cálculo duplicado em widgets | Médio | Concentrar tudo no bridge/serviço analítico |
| Alteração acidental do Lote 2 homologado | Médio | Testes de regressão e arquivos protegidos |

## Portão de qualidade territorial

Antes de liberar qualquer mapa, o conjunto filtrado deverá informar:

- percentual de RAEs com `regionalId` reconhecido;
- percentual com bairro preenchido;
- percentual com latitude e longitude válidas;
- percentual com localização validada;
- quantidade de identidades territoriais legadas ou não resolvidas;
- intervalo temporal efetivamente coberto.

O mapa só poderá entrar no escopo após regra de aceite aprovada e evidência em
dados reais. Até lá, a visão territorial oficial será tabular/gráfica, com
ranking e detalhamento por regional.

## Lacunas para implementação

1. Normalizador territorial com chave estável e classificação de legado.
2. Relatório determinístico de qualidade dos registros filtrados.
3. Série temporal contínua, incluindo períodos sem ocorrências.
4. Comparação com janela anterior equivalente.
5. Política explícita de granularidade e amostra mínima.
6. Drilldown de regional para os RAEs que compõem o resultado.
7. Estados de vazio, parcialidade e dados insuficientes na interface.

## Conclusão

O Lote 3 é tecnicamente viável sem mudança de Provider, rota, Firestore ou
dependência. A implementação deve iniciar pela qualidade e normalização dos
dados; mapa e alertas só podem refletir evidência real, nunca conteúdo simulado.

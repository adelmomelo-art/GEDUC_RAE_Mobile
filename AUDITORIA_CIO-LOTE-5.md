# Auditoria técnica — CIO Lote 5

## Mapa territorial seguro

**Baseline:** `main @ 1a6019f2dae0cd8fd884c0e423f460986f0c179b`
**Branch:** `feature/cio-mapa-territorial-seguro-lote5`
**Data:** 13/08/2026

## Objetivo

Auditar a viabilidade de substituir a visualização simulada do CIO por uma
representação territorial oficial, agregada e segura, sem expor coordenadas
individuais e sem reabrir o saneamento encerrado após o Lote 4.

Esta auditoria não autoriza implementação, alteração visual, escrita no
Firestore, ativação do mapa ou publicação.

## Providers

O aplicativo registra Providers globais para autorização, ações, domínios,
usuários e tipos de ação. O Dashboard cria e descarta seu próprio
`DashboardController`, que já aceita serviços injetáveis no construtor.

**Decisão:** não criar Provider global no Lote 5. A leitura da geometria, a
elegibilidade cartográfica e a agregação territorial devem entrar como serviços
injetáveis no `DashboardController`. Isso preserva o ciclo de vida atual e reduz
o alcance da mudança.

## Rotas

O CIO já é servido por `AppRoutes.dashboardPath` e `DashboardPage`. O mapa
operacional de captura pertence à jornada independente de localização.

**Decisão:** não criar rota. O mapa territorial será uma seção do Dashboard CIO.
O componente de captura de localização não será reutilizado, pois permite
seleção e mostra coordenadas individuais.

## Dependências

O projeto já contém:

- `flutter_map ^7.0.2`;
- `latlong2 ^0.9.1`;
- `provider`, `cloud_firestore`, `connectivity_plus` e armazenamento local.

**Decisão:** nenhuma dependência nova. O processamento ponto-em-polígono deve ser
implementado como código Dart testável e a geometria oficial deve ser embarcada
como ativo versionado.

## Componentes existentes

### Reaproveitáveis

- filtros e carregamento do `DashboardController`;
- `CioTerritorialGovernanceService` e seu validador de limite injetável;
- catálogo de Regionais e dados já saneados;
- infraestrutura responsiva e cromática do Dashboard;
- `flutter_map` para renderização;
- padrão de atribuição já usado no mapa operacional.

### Não reutilizáveis diretamente

- `CoverageMapCard`: é uma simulação estática e apresenta pontos fictícios;
- `MapaLocalizacaoWidget`: permite seleção, mostra marcador e coordenadas do RAE;
- validação mundial de latitude/longitude: não comprova bairro nem município;
- mensagem atual do portão: ainda descreve fonte, licença e limite como ausentes.

## Baseline territorial aprovado

- 12 Regionais;
- 121 bairros oficiais;
- 39 territórios;
- 40 RAEs dentro de Fortaleza;
- 32 RAEs elegíveis e coerentes em bairro e Regional;
- quatro registros G1 com coordenadas não homologadas;
- quatro registros de teste G2 sem evidência territorial;
- mapa ainda bloqueado.

## Lacunas

1. GeoJSON oficial ainda não integra os ativos do Flutter.
2. Não existe repositório cartográfico local com verificação de versão e hash.
3. Não existe política de elegibilidade separada da validade cadastral.
4. G1/G2 não possuem bloqueio explícito na aplicação.
5. O painel não produz agregados por polígono oficial.
6. Não há fallback cartográfico quando tiles não carregam.
7. Não há política de zoom, precisão ou supressão de pontos individuais no CIO.
8. A atribuição IPLANFOR ainda não existe na interface.
9. Não há testes de geometria, privacidade, semântica ou desempenho no A05.

## Riscos

| Risco | Nível | Tratamento obrigatório |
|---|---|---|
| Expor a localização exata de uma ação | Crítico | Somente polígonos e agregados; nenhum marcador individual |
| G1/G2 entrarem no mapa | Alto | Registro de exclusões versionado e política testada |
| Sugerir precisão inexistente | Alto | Legenda de agregação e ausência de pontos |
| Tiles indisponíveis ou bloqueados | Alto | Polígonos oficiais continuam visíveis sobre fundo neutro |
| Fonte oficial mudar silenciosamente | Alto | Versão, SHA-256 e teste de 121 feições |
| Regressão no mapa operacional | Médio | Não alterar `MapaLocalizacaoWidget` |
| Desempenho insuficiente no A05 | Alto | Simplificação controlada e portão físico |
| Atribuição incompleta | Alto | IPLANFOR e OpenStreetMap sempre visíveis conforme a camada usada |
| Exclusão baseada apenas em número vazio | Alto | Não usar heurística genérica; aplicar registro explícito de exceções |

## Conclusão

A implementação é tecnicamente viável sem novas dependências, Providers ou
rotas. O desenho seguro é um mapa coroplético agregado por bairro ou Regional,
com geometria oficial local, elegibilidade explícita e fallback sem tiles.

O mapa não deve exibir marcadores de RAEs, permitir seleção, revelar coordenadas
ou considerar G1/G2. A ativação final depende dos portões do Blueprint e da
homologação física no Samsung Galaxy A05.

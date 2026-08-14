# Blueprint — CIO Lote 5

## Mapa territorial seguro

**Baseline:** `main @ 1a6019f2dae0cd8fd884c0e423f460986f0c179b`
**Branch prevista:** `feature/cio-mapa-territorial-seguro-lote5`
**Estado:** homologado em 13/08/2026

## Resultado esperado

Entregar no Dashboard CIO uma representação oficial da cobertura territorial de
Fortaleza, agregada por polígono, com privacidade por construção, exclusão de
G1/G2, funcionamento degradado offline e atribuição institucional completa.

O mapa permanecerá desativado por configuração até que os testes automatizados
e a homologação no A05 sejam aprovados.

## Princípios

1. nenhum ponto ou coordenada individual no CIO;
2. geometria oficial e versionada, sem desenho simulado;
3. agregação mínima por bairro, com opção de Regional;
4. G1/G2 excluídos por registro explícito e auditável;
5. nenhum RAE alterado automaticamente;
6. fallback honesto sem tiles;
7. atribuição visível e permanente;
8. ativação somente por portão homologado.

## Arquitetura proposta

### Ativos

- `assets/geo/bairros_fortaleza_ipplanfor.geojson`;
- `assets/geo/manifesto_bairros_fortaleza.json` com fonte, data, CRS, 121
  feições e SHA-256;
- `assets/geo/exclusoes_cartograficas_lote5.json` com os oito IDs homologados,
  grupo, motivo e vigência.

O manifesto de exclusões contém apenas IDs técnicos e justificativas; não deve
conter coordenadas, nomes de pessoas ou outros dados operacionais.

### Domínio cartográfico

- `CioGeometryRepository`: carrega e valida o ativo oficial;
- `CioPointInPolygonService`: resolve município e bairro de forma determinística;
- `CioCartographicEligibilityPolicy`: aceita somente RAEs não excluídos, com
  coordenadas válidas, número operacional e coerência geométrica;
- `CioTerritorialAggregationService`: produz contagens agregadas por bairro e
  Regional sem reter coordenadas no resultado;
- modelos imutáveis para feições, agregados, fonte e estado do portão.

### Integração

- serviços injetados no `DashboardController`;
- cálculo aplicado ao mesmo recorte temporal e filtros do CIO;
- nova seção cartográfica dentro de `DashboardPage`;
- nenhuma nova rota ou Provider global;
- nenhum acesso adicional ao Firestore;
- nenhuma alteração no fluxo de localização da ação.

## Experiência prevista

### Estado aprovado

- mapa de Fortaleza com limites oficiais;
- bairros coloridos por faixas de quantidade ou cobertura;
- alternância Bairro/Regional;
- legenda textual e acessível;
- total de RAEs elegíveis e excluídos;
- atribuição “IPLANFOR — Fortaleza em Mapas”;
- atribuição “© OpenStreetMap contributors” somente quando tiles forem usados.

### Estado sem rede

- polígonos oficiais sobre fundo neutro;
- mensagem “Mapa-base indisponível; limites oficiais preservados”;
- agregados e legenda continuam disponíveis;
- nenhuma tentativa de representar tiles como carregados.

### Estado bloqueado

- motivo específico do bloqueio;
- nenhuma visualização simulada;
- diagnóstico consultivo preservado;
- ativação proibida enquanto qualquer portão crítico falhar.

## Privacidade

- proibição de `MarkerLayer` para RAEs no CIO;
- proibição de latitude/longitude em texto, semântica, tooltip ou log;
- interação limitada ao agregado do bairro/Regional;
- mínimo de uma unidade por agregado nesta primeira versão, sem detalhamento do
  RAE de origem dentro do mapa;
- dados detalhados continuam somente nos fluxos autorizados já existentes.

## Portões de qualidade

| Portão | Critério mínimo |
|---|---:|
| Integridade do ativo | 121/121 feições e SHA-256 esperado |
| Códigos e nomes | 121 únicos, zero ausência ou duplicidade |
| Contenção municipal | 40/40 pontos reconhecidos dentro de Fortaleza |
| Elegibilidade | 32/32 RAEs aprovados incluídos |
| Exclusões | 8/8 G1/G2 ausentes dos agregados |
| Coerência elegível | 32/32 bairro e Regional coincidentes |
| Privacidade automatizada | zero coordenadas ou marcadores individuais |
| Atribuição | 100% dos estados aplicáveis com fonte visível |
| Testes específicos | 100% aprovados |
| Suíte completa e analyze | 100% aprovados |
| Responsividade | 320, 360, 412 e 800 px |
| A05 | abertura, interação e rolagem aprovadas |
| Desempenho A05 | primeira renderização sem travamento perceptível |
| Offline A05 | polígonos e mensagem degradada aprovados |

## Testes obrigatórios

1. leitura do GeoJSON e validação do manifesto;
2. polígonos e multipolígonos, incluindo furos e bordas;
3. correspondência dos 121 bairros com o catálogo canônico;
4. exclusão individual dos oito IDs G1/G2;
5. agregação preservando o total de 32 elegíveis;
6. aplicação dos filtros do Dashboard;
7. ausência de marcadores, coordenadas e dados pessoais;
8. estados carregando, aprovado, bloqueado, erro e offline;
9. atribuições IPLANFOR/OSM;
10. responsividade e semântica;
11. regressão do portão territorial existente;
12. regressão do mapa operacional de localização.

## Fora de escopo

- mapa de calor por coordenada;
- rastreamento em tempo real;
- rotas ou deslocamentos de equipes;
- edição de localização pelo CIO;
- correção automática de bairro ou Regional;
- exclusão produtiva de G2;
- recaptura produtiva de G1;
- clustering de marcadores;
- mudança nas regras do Firestore;
- nova dependência cartográfica.

## Condição de encerramento

O Lote 5 somente poderá ser homologado quando todos os portões automatizados
estiverem aprovados e os cenários físicos no Samsung Galaxy A05 forem aceitos.
Até lá, o mapa deve permanecer protegido por configuração desativada.

## Homologação humana

O Blueprint, seus limites, a arquitetura proposta, os percentuais dos portões de
qualidade e o plano em cinco etapas foram homologados em 13/08/2026. Esta
homologação aprova o planejamento, mas não autoriza implementação, alteração do
Firestore, commit, APK ou publicação.

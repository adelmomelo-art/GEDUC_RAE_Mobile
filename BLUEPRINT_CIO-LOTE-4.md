# BLUEPRINT CIO — Lote 4

## Qualidade e governança territorial

**Baseline:** `1a23910`

**Branch prevista:** `feature/cio-qualidade-governanca-territorial-lote4`

**Status:** proposto para aprovação

## Objetivo

Validar institucionalmente as identidades territoriais usadas pelo CIO,
mensurar a qualidade dos RAEs e produzir uma fila rastreável de saneamento antes
de qualquer ativação de mapa executivo.

## Arquitetura proposta

```text
RegionalService / catálogo Firestore (somente leitura)
        ↓
CioTerritorialCatalogSnapshot
        ↓
CioTerritorialValidator
        ├─ ID existente e ativo
        ├─ tipologia compatível
        ├─ bairro único ou ambíguo
        ├─ coordenada válida e dentro do limite
        └─ coerência entre fontes
        ↓
CioTerritorialQualityReport
        ├─ válidos
        ├─ legados
        ├─ órfãos
        ├─ ambíguos
        ├─ fora do limite
        └─ divergentes
        ↓
DashboardCIOBridge
        ↓
Painel de qualidade + fila consultiva
```

Nenhum widget consulta Firestore ou corrige registros. O relatório deve ser
reproduzível a partir do snapshot do catálogo e do conjunto filtrado de RAEs.

## Contratos

### Snapshot do catálogo

- data/hora de leitura;
- regionais ativas e inativas necessárias à classificação histórica;
- identidade, nome, código, tipo e bairros;
- versão/fonte geográfica quando disponíveis;
- conflitos de catálogo detectados.

### Classificação do RAE

- `valid`: ID reconhecido, ativo e coerente;
- `legacy`: sem ID, com nome aproveitável;
- `orphan`: ID inexistente no snapshot;
- `inactive`: ID conhecido, porém inativo;
- `ambiguous`: bairro associado a múltiplas regionais;
- `outOfBounds`: coordenada fora do limite aprovado;
- `divergent`: bairro, ID e coordenada não concordam;
- `unresolved`: dados insuficientes.

Uma mesma ação pode possuir mais de um apontamento, mas deve ter uma classificação
primária determinística.

## Entregas funcionais

1. Relatório de integridade do catálogo.
2. Relatório de qualidade dos RAEs filtrados.
3. Indicadores de cobertura institucional, não apenas preenchimento.
4. Lista consultiva de registros que exigem saneamento.
5. Evidência do portão do mapa, com cada critério aprovado ou bloqueado.
6. Exportação técnica local do diagnóstico, sem dados pessoais desnecessários.

## Decisões

- nenhum Provider global novo;
- nenhuma rota nova no núcleo inicial;
- nenhuma escrita automática em `acoes` ou `regionais`;
- nenhuma coleção Firestore nova;
- nenhuma dependência nova;
- política de acesso atual preservada;
- mapa executivo bloqueado durante o Lote 4;
- geometria e provedor cartográfico tratados como decisão institucional.

## Arquivos protegidos

- `lib/app.dart`;
- `lib/core/routes/app_routes.dart`;
- `firestore.rules`;
- `pubspec.yaml`;
- fluxo de criação e fechamento do RAE;
- gerador de PDF e relatórios RAE.

## Critérios de aceite

- resultado determinístico para o mesmo catálogo e conjunto de RAEs;
- IDs inexistentes e inativos não contam como cobertura válida;
- duplicidades de bairros aparecem como conflito;
- nenhuma correção é gravada automaticamente;
- totais do diagnóstico reconciliam com o conjunto filtrado;
- vazio e catálogo indisponível são estados seguros;
- nenhum mapa simulado ou sem fonte aparece no CIO;
- testes de catálogo, classificação, limites e responsividade aprovados;
- análise estática e suíte completa aprovadas;
- homologação física no Samsung Galaxy A05.

## Condições para um ciclo posterior de mapa

- fonte territorial oficial aprovada;
- geometrias ou centroides versionados;
- regra de limite municipal definida;
- gate quantitativo aprovado com dados reais;
- atribuição, licença, cache e provedor conformes;
- tratamento visível para registros excluídos da camada oficial.

## Fora do escopo

Mapa executivo, migração em massa, alteração de permissões, predição, IA
generativa, novas coleções, PDF e mudanças no fluxo do RAE.

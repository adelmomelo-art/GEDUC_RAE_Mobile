# CIO Lote 5 — Etapa 3

## Interface cartográfica protegida

**Data:** 13/08/2026
**Branch:** `feature/cio-mapa-territorial-seguro-lote5`

## Integração

- fundação cartográfica carregada em paralelo pelo `DashboardController`;
- falha de geometria ou exclusões isolada do restante do Dashboard;
- agregação recalculada com o mesmo período e filtros do CIO;
- painel cartográfico incluído na jornada existente, sem nova rota ou Provider;
- visualização simulada não foi reutilizada;
- nenhuma consulta adicional ao Firestore.

## Estados

### Protegido — padrão de execução

O aplicativo exibe apenas que a fundação oficial está instalada e que a
ativação depende da Etapa 4 e da homologação no A05. O mapa real não é montado.

### Habilitado em teste

- 121 limites oficiais renderizados por `PolygonLayer`;
- alternância Bairro/Regional;
- cores por quantidade agregada;
- totais de elegíveis e excluídos;
- atribuição do IPLANFOR;
- atribuição do OpenStreetMap quando os tiles são utilizados;
- zoom e deslocamento, sem seleção de localização.

### Offline

- nenhum tile externo solicitado;
- polígonos oficiais preservados sobre fundo neutro;
- mensagem explícita de mapa-base indisponível;
- atribuição IPLANFOR mantida.

### Fundação inválida

Nenhuma simulação é exibida. O painel informa que a geometria ou a política de
elegibilidade não pôde ser validada.

## Privacidade

- nenhum `MarkerLayer` de RAE;
- nenhuma latitude ou longitude em texto, tooltip ou semântica;
- nenhuma seleção de ponto;
- somente bairro, Regional e quantidade agregada;
- G1/G2 continuam excluídos pela política da Etapa 2.

## Validação local

- estado protegido por padrão: aprovado;
- modo offline em largura de 360 px: aprovado;
- ausência de `MarkerLayer`: aprovada;
- atribuição IPLANFOR offline: aprovada;
- atribuição OSM omitida quando tiles não são usados: aprovada;
- `flutter analyze --no-pub`: sem problemas.

## Limites

- a ativação permanece desligada na execução normal;
- nenhuma escrita no Firestore;
- nenhuma dependência, rota ou Provider novo;
- APK e homologação física não integram esta etapa;
- commit e publicação não realizados.

## Próxima etapa

Etapa 4 — testes específicos ampliados, responsividade, suíte completa, análise
estática e revisão técnica do diff.

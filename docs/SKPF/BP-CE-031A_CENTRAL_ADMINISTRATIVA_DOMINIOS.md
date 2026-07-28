# BP-CE-031A — Central Administrativa de Domínios

## Objetivo

Transformar a tela existente em painel administrativo consolidado, mantendo o fluxo:

DomainListPage → DomainRepository → DomainService → DomainDataSource → FirestoreDomainDataSource → Firestore/domains.

## Entregas

- painel responsivo;
- indicadores de total, ativos, inativos e grupos;
- distribuição por grupo;
- filtros por texto e grupo;
- limpeza de filtros;
- atualização manual e pull-to-refresh;
- tratamento de carregamento e erro;
- controle de ativação/inativação;
- preparação para cadastro e edição na CE-031B.

## Decisões

- Sem novas dependências.
- `_dominiosSemente()` permanece temporariamente e será removido na CE-031E.
- Cadastro e edição seguem bloqueados até a CE-031B.

## Critérios de homologação

- Tela abre sem exceções.
- Indicadores coerentes.
- Pesquisa e filtros funcionando.
- Atualização funcionando.
- Ativação/inativação persistindo.
- `flutter analyze` sem issues.

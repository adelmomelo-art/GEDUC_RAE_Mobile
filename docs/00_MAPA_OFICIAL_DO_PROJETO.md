# PLATAFORMA FÊNIX

> **Sistema de Conhecimento da Plataforma Fênix (SKPF)**

------------------------------------------------------------------------

## Status do Documento

  Item             Informação
  ---------------- -------------------------------------------
  Documento        00_MAPA_OFICIAL_DO_PROJETO.md
  Categoria        Portal Oficial do Sistema de Conhecimento
  Versão           2.0
  Status           Oficial
  Última Revisão   06/10/2026
  Responsável      Arquitetura da Plataforma Fênix

------------------------------------------------------------------------

# Apresentação

Bem-vindo à **Plataforma Fênix**.

Este documento constitui a porta de entrada oficial do **Sistema de
Conhecimento da Plataforma Fênix (SKPF)**.

Seu objetivo é orientar arquitetos, desenvolvedores, gestores e
colaboradores sobre onde localizar cada conhecimento produzido durante a
evolução da Plataforma.

O SKPF possui a mesma importância do código-fonte.

Todo conhecimento estratégico da Plataforma deverá ser ser preservado
neste conjunto documental.

------------------------------------------------------------------------

# Missão da Plataforma

Transformar dados operacionais em inteligência para apoiar gestores na
tomada de decisão, promovendo eficiência, transparência e evolução
contínua dos processos educacionais.

------------------------------------------------------------------------

# Visão

Consolidar a Plataforma Fênix como referência em inteligência
operacional aplicada à gestão pública, permitindo que decisões sejam
orientadas por dados confiáveis, indicadores e conhecimento
institucional.

------------------------------------------------------------------------

# Estado Atual da Plataforma

  Componente                Situação
  ------------------------- -------------------------
  Arquitetura               🟢 Em Consolidação
  Sprint Atual              Sprint Arquitetural 1.0
  Sistema de Conhecimento   Implantação
  Fênix Analytics Engine    Auditoria Estrutural
  Faxita                    Evolução Arquitetural
  Dashboard Executivo       Consolidação
  Flutter Analyze           Homologado

------------------------------------------------------------------------

# Estrutura Oficial do Sistema de Conhecimento

## Constituição

-   00_ENGINEERING_CHARTER.md

## Arquitetura

-   01_PLATFORM_ARCHITECTURE.md
-   ARCHITECTURE/

## Engenharia

-   06_ENGINEERING_LOG.md
-   08_GUIA_DE_DESENVOLVIMENTO.md

## Inteligência

-   Fênix Analytics Engine (FAE)
-   Faxita
-   Dashboard Executivo
-   Centro de Inteligência Operacional (CIO)

## Auditorias

-   ARCHITECTURE/AUDITS/

## ADR

-   ARCHITECTURE/ADR/

## Blueprints

-   ARCHITECTURE/BLUEPRINTS/

------------------------------------------------------------------------

# Fluxo Oficial de Desenvolvimento

``` text
Arquitetura
      ↓
Implementação
      ↓
Flutter Analyze
      ↓
Homologação
      ↓
Atualização do SKPF
      ↓
Git Commit
```

------------------------------------------------------------------------

# Princípios do SKPF

1.  O conhecimento pertence à Plataforma.
2.  Nenhuma decisão estratégica existirá apenas em conversas.
3.  Todo componente estratégico deverá possuir documentação
    correspondente.
4.  A arquitetura governa a implementação.
5.  Código e conhecimento evoluem juntos.
6.  Toda alteração estrutural deverá atualizar o SKPF.

------------------------------------------------------------------------

# Ordem Recomendada de Leitura

1.  00_MAPA_OFICIAL_DO_PROJETO.md
2.  00_ENGINEERING_CHARTER.md
3.  01_PLATFORM_ARCHITECTURE.md
4.  08_GUIA_DE_DESENVOLVIMENTO.md
5.  ADR
6.  Auditorias
7.  Blueprints

------------------------------------------------------------------------

# Sprint Arquitetural Atual

**Sprint:** Sprint Arquitetural 1.0

**Fase:** AE-001 -- Auditoria Estrutural

**Objetivo:** Consolidar a arquitetura, preservar o conhecimento
institucional e estabelecer a governança técnica permanente da
Plataforma Fênix.

------------------------------------------------------------------------

# Controle de Evolução

## Agenda Operacional — AGO-001

- [Implementação, dados e homologação](AGO-001_AGENDA_OPERACIONAL.md)
- [R3: segurança das ferramentas npm](AGO-001_R3_SEGURANCA_NPM.md)
- Fluxo: planejamento privado → escala diária → consulta pela equipe.
- Status: concluída em 06/10/2026; PR #112/main, CI, regras publicadas,
  web e A05 build 4 homologados PASS.

## Calendário por ação — AGO-002

- [Implementação e fechamento em produção](AGO-002_CALENDARIO_ACOES.md)
- Status: concluída em 06/10/2026; PR #113/main, CI e web/A05 build 5 PASS.
- Nomes clicáveis, cores por ação e sete colunas no layout móvel.
- Próxima etapa de planejamento: consolidar novas propostas para a escala.
  Escopo de nova implementação ainda não definido.

  ------------------------------------------------------------------------
  Versão                 Data              Descrição
  ---------------------- ----------------- -------------------------------
  2.0                    27/07/2026        Reestruturação do documento
                                           como Portal Oficial do SKPF.

  ------------------------------------------------------------------------

- AGO-001 R5 — homologação web local: `docs/AGO-001_HOMOLOGACAO_LOCAL.md`.

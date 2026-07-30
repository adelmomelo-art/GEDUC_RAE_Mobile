# ARQUITETURA DA PLATAFORMA FÊNIX

> Documento Oficial de Arquitetura do Sistema de Conhecimento da
> Plataforma Fênix (SKPF)

------------------------------------------------------------------------

## Controle do Documento

  Item        Valor
  ----------- ----------------------------------------
  Documento   01_PLATFORM_ARCHITECTURE.md
  Versão      2.1
  Status      Oficial
  Sprint      EST-005D — Consolidação Arquitetural

------------------------------------------------------------------------

# 1. Objetivo

Este documento define a arquitetura oficial da Plataforma Fênix.

Seu propósito é orientar toda evolução técnica, garantindo que novas
funcionalidades sejam incorporadas sem comprometer a integridade, a
estabilidade, a rastreabilidade e a capacidade de evolução da solução.

------------------------------------------------------------------------

# 2. Princípios Arquiteturais

-   Arquitetura antes da implementação.
-   Causa raiz antes da correção de sintomas.
-   Componentes desacoplados.
-   Serviços reutilizáveis.
-   Estado compartilhado com escopo explicitamente definido.
-   Dados como ativo estratégico.
-   Inteligência centralizada.
-   Evolução incremental.
-   Auditoria antes de grandes refatorações.
-   Homologação técnica e funcional antes do commit.
-   Documentação sincronizada com o código.

------------------------------------------------------------------------

# 3. Visão Geral

``` text
                Usuário
                   │
             Interface Flutter
                   │
      ┌────────────┴────────────┐
      │                         │
 Controladores             Providers
      │                         │
      └────────────┬────────────┘
                   │
               Serviços
                   │
             Repositórios
                   │
          Fontes de Dados
                   │
     ┌─────────────┼─────────────┐
     │             │             │
 Firebase     Armazenamento   Integrações
                  local         externas
                   │
          Fênix Analytics Engine
                   │
     ┌─────────────┼─────────────┐
     │             │             │
  Faixita      Dashboard      Indicadores
```

------------------------------------------------------------------------

# 4. Camadas da Arquitetura

## 4.1 Apresentação

Responsável pelas telas, experiência do usuário, navegação, componentes
visuais e interação com o estado exposto pelos controladores e
providers.

As páginas não devem criar dependências compartilhadas de longa duração
quando essas dependências precisam permanecer disponíveis em rotas
independentes.

## 4.2 Aplicação

Responsável por controladores, providers, validações, regras de negócio,
estado de fluxo e orquestração entre apresentação, serviços e
repositórios.

Providers com uso transversal devem ser registrados acima das rotas que
os consomem. Providers estritamente locais podem permanecer próximos da
subárvore correspondente, desde que seu ciclo de vida seja limitado e
documentado.

## 4.3 Serviços

Responsável por integrações, persistência, sincronização, comunicação
externa e acesso coordenado às fontes de dados.

## 4.4 Repositórios

Responsável por abstrair as operações de domínio e impedir que as telas
dependam diretamente da implementação de persistência.

## 4.5 Fontes de Dados

Responsável pela comunicação concreta com Firebase, armazenamento local,
APIs e outras infraestruturas persistentes.

## 4.6 Inteligência

Responsável pelo Fênix Analytics Engine, incluindo cálculos,
indicadores, modelos matemáticos, projeções e suporte à decisão.

## 4.7 Dados

Compreende Cloud Firestore, armazenamento local, sincronização e demais
mecanismos de persistência utilizados pela plataforma.

------------------------------------------------------------------------

# 5. Arquitetura de Estado e Providers

## 5.1 Regra de escopo

O escopo de cada provider deve acompanhar o alcance real do estado que
ele administra:

-   provider local: estado exclusivo de uma tela ou subárvore;
-   provider de fluxo: estado compartilhado por páginas do mesmo fluxo;
-   provider global: estado ou serviço consumido por rotas independentes
    da aplicação.

A definição incorreta do escopo pode causar perda de estado,
reinstanciações desnecessárias ou `ProviderNotFoundException`.

## 5.2 Registro global

Providers transversais são registrados no `MultiProvider` principal da
aplicação, em `lib/app.dart`, acima do `MaterialApp` e da árvore de
rotas.

``` text
main.dart
   ↓
App
   ↓
MultiProvider
   ├── providers globais
   └── MaterialApp
          ↓
        Rotas
          ↓
        Páginas
```

## 5.3 DomainProvider

O `DomainProvider` é um provider global da aplicação.

Ele centraliza o acesso aos domínios utilizados por páginas e widgets
que podem ser alcançados por rotas diferentes, incluindo
Caracterização e Avaliação.

``` text
App / MultiProvider
        ↓
  DomainProvider
        ↓
 DomainRepository
        ↓
  DomainService
        ↓
 DomainDataSource
        ↓
Cloud Firestore / domains
```

A instância não deve ser criada e descartada dentro de
`CaracterizacaoAcaoPage`, pois `AvaliacaoPage` é acessada por rota
independente e necessita do mesmo provider disponível acima da
navegação.

## 5.4 Ciclo de vida

O ciclo de vida dos providers globais é administrado pelo
`ChangeNotifierProvider` registrado na raiz da aplicação.

Páginas consumidoras devem utilizar `context.read`, `context.watch`,
`Consumer` ou componentes equivalentes, sem executar descarte manual da
instância global.

------------------------------------------------------------------------

# 6. Componentes Estratégicos

## Faixita

Assistente inteligente da Plataforma responsável pela orientação
operacional, apoio educativo aos gestores e interpretação dos resultados
produzidos pelo motor analítico.

## Fênix Analytics Engine

Camada única de inteligência responsável por indicadores, estatísticas,
projeções e suporte à decisão.

## Dashboard Executivo

Camada de apresentação dos indicadores produzidos pelo Analytics Engine.

## Centro de Inteligência Operacional

Ambiente de consolidação das informações operacionais e estratégicas.

## Central de Domínios

Componente responsável pela administração e distribuição dos valores
padronizados utilizados nos formulários e fluxos da plataforma.

------------------------------------------------------------------------

# 7. Fluxo Arquitetural

``` text
Coleta
   ↓
Validação
   ↓
Estado da Aplicação
   ↓
Persistência
   ↓
Analytics Engine
   ↓
Faixita
   ↓
Dashboard
   ↓
Gestor
```

------------------------------------------------------------------------

# 8. Navegação e Dependências Compartilhadas

Rotas independentes não devem depender de providers criados dentro de
outras páginas.

Antes de implementar ou corrigir uma dependência compartilhada, devem
ser inspecionados:

1. árvore de providers;
2. árvore de rotas;
3. direção das dependências;
4. ciclo de vida das instâncias;
5. pontos reais de consumo.

Essa inspeção é obrigatória para evitar correções locais que apenas
mascarem falhas de arquitetura.

------------------------------------------------------------------------

# 9. Governança Arquitetural

Toda alteração estrutural deverá possuir:

-   inspeção da árvore de providers;
-   inspeção das rotas;
-   inspeção das dependências;
-   Blueprint correspondente;
-   plano de implementação;
-   HAT-1 antes da implementação;
-   `flutter analyze` sem issues;
-   homologação funcional;
-   HAT-2 antes do commit;
-   registro no Engineering Log;
-   documentação atualizada;
-   rastreabilidade no Git;
-   pacote CPB correspondente.

------------------------------------------------------------------------

# 10. Root Cause First

Toda correção estrutural deve responder:

1. Qual é o erro observado?
2. Onde ele se origina?
3. Por que a arquitetura permitiu sua ocorrência?
4. Qual alteração elimina a causa raiz, em vez de apenas o sintoma?

Na EST-005B, o erro observado foi um
`ProviderNotFoundException` em `AvaliacaoPage`. A causa raiz foi o
registro local do `DomainProvider` em `CaracterizacaoAcaoPage`, fora do
alcance da rota independente de Avaliação. A solução definitiva foi
promover o provider para o `MultiProvider` global.

------------------------------------------------------------------------

# 11. Evolução

A arquitetura deverá evoluir por pacotes incrementais, preservando
compatibilidade e estabilidade do sistema.

Mudanças estruturais deverão ser precedidas por auditoria técnica e
encerradas somente após atualização documental, commit e push.

------------------------------------------------------------------------

# 12. Relação com o SKPF

Este documento integra o Sistema de Conhecimento da Plataforma Fênix e
deve ser utilizado como referência principal para decisões de
arquitetura.

Documentos relacionados:

-   `docs/00_ENGINEERING_CHARTER.md`;
-   `docs/06_ENGINEERING_LOG.md`;
-   `docs/08_GUIA_DE_DESENVOLVIMENTO.md`;
-   `docs/SKPF/BP-ISSUE-002A.2_INTEGRACAO_DOMAIN_SERVICE.md`.

------------------------------------------------------------------------

# 13. Registro da EST-005B

A EST-005B consolidou as seguintes decisões:

-   promoção do `DomainProvider` para escopo global;
-   remoção do ciclo de vida local em
    `CaracterizacaoAcaoPage`;
-   disponibilidade do provider em rotas independentes;
-   preservação da integração
    `DomainProvider → DomainRepository → DomainService`;
-   homologação funcional dos seis cenários previstos;
-   `flutter analyze` com 0 issues;
-   HAT-1 e HAT-2 aprovadas;
-   commit `35d41f6`;
-   push para `origin/release/estabilizacao-pv006`.

------------------------------------------------------------------------

──────────────────────────────────────────────

**Sistema de Conhecimento da Plataforma Fênix (SKPF)**

Documento Oficial

Arquitetura da Plataforma Fênix

Versão 2.1

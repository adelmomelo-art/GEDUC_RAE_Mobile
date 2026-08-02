# ARQUITETURA DA PLATAFORMA FÊNIX

> Documento Oficial de Arquitetura do Sistema de Conhecimento da
> Plataforma Fênix (SKPF)

------------------------------------------------------------------------

## Controle do Documento

  Item        Valor
  ----------- ----------------------------------------
  Documento   01_PLATFORM_ARCHITECTURE.md
  Versão      2.3
  Status      Oficial
  Sprint      ADM-001C — Identidade e Segurança

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


------------------------------------------------------------------------

# 14. Fundação Administrativa — ADM-001B.1

A sprint ADM-001B.1 consolidou a Fundação Administrativa da Plataforma
Fênix.

## 14.1 Objetivo

Estabelecer uma base administrativa modular, rastreável e preparada para
crescimento incremental, sem alterar os CRUDs existentes nem ampliar
permissões do Firestore.

## 14.2 Componentes

``` text
AdminHomePage
   ↓
AdminModuleCatalog
   ↓
AdminModule
   ├── identificação
   ├── título
   ├── descrição
   ├── rota
   ├── ícone
   ├── status
   └── permissão
```

Foram consolidados:

- catálogo central de módulos administrativos;
- modelo imutável de módulo;
- estados de disponibilidade;
- cartão administrativo reutilizável;
- navegação administrativa centralizada;
- preparação inicial para controle de acesso.

## 14.3 Módulos administrativos

A fundação contempla:

- Central de Domínios;
- Usuários;
- Tipos de Ações;
- Coordenadores;
- Regionais;
- Materiais.

## 14.4 Decisão arquitetural

A página administrativa não deve manter uma lista própria e paralela de
módulos. O catálogo oficial é a fonte única para apresentação,
navegação, status e autorização.

------------------------------------------------------------------------

# 15. Camada de Autorização Administrativa — ADM-001B.2

A sprint ADM-001B.2 introduziu a primeira camada centralizada de
autorização da Plataforma Fênix.

## 15.1 Princípio

``` text
A interface não decide.
A rota não contém a política.
O AuthorizationService centraliza a decisão.
```

## 15.2 Fluxo

``` text
Firebase Authentication
          ↓
AuthorizationService
          ↓
UsuarioService
          ↓
usuarios/{uid}.perfilAcesso
          ↓
AuthorizationPolicy
          ↓
RouteGuard / Administração
```

## 15.3 Componentes

- `Permission`: catálogo tipado de permissões;
- `AuthorizationPolicy`: matriz entre perfis e permissões;
- `AuthorizationResult`: resultado imutável da avaliação;
- `AuthorizationService`: ponto central de decisão;
- `RouteGuard`: proteção das rotas administrativas;
- `AccessDeniedPage`: resposta explícita para acesso negado.

## 15.4 Matriz inicial

| Perfil | Escopo administrativo |
|---|---|
| `administrador` | Todos os módulos |
| `gestor` | Administração, Domínios, Usuários e Tipos de Ações |
| `coordenador` | Sem acesso administrativo nesta matriz |
| `agente` | Sem acesso administrativo nesta matriz |

Perfis desconhecidos ou documentos de usuário ausentes são negados por
padrão.

## 15.5 Proteção em profundidade

Ocultar um botão não constitui autorização. O controle ocorre em dois
níveis:

1. apresentação: módulos e atalhos compatíveis com o perfil;
2. navegação: `RouteGuard` bloqueia acesso direto por rota.

A segurança persistente dos dados permanece responsabilidade das regras
do Firestore.

## 15.6 Homologação

Foram homologados:

- administrador em Android;
- gestor em Android;
- coordenador em Android;
- agente em Android;
- acesso direto protegido no Flutter Web;
- tela de acesso não autorizado;
- retorno ao Centro de Operações;
- ausência de regressões na Central de Domínios.

`flutter analyze`: **No issues found!**

------------------------------------------------------------------------

# 16. Governança de Engenharia — PF-ENG 003/2026

Mudanças estruturais e de segurança passam a seguir obrigatoriamente:

``` text
Inspeção
   ↓
Blueprint
   ↓
Plano de implementação
   ↓
Feature branch
   ↓
Implementação
   ↓
flutter analyze: 0 issues
   ↓
Homologação
   ↓
CPB
   ↓
Commit e push
   ↓
Pull Request
   ↓
Code Review Arquitetural
   ↓
Merge na main
   ↓
Validação pós-merge
   ↓
Atualização documental
```

Pull Request e Code Review são obrigatórios para alterações de:

- arquitetura;
- segurança;
- autenticação e autorização;
- roteamento;
- modelos de dados;
- providers globais;
- infraestrutura compartilhada.

------------------------------------------------------------------------

# 17. Baseline oficial pós-ADM-001B.2

``` text
Pull Request: #1
ADM-001B.1: 6049e7d
ADM-001B.2: ff32e74
Merge na main: 08f969d
Branch principal: main
flutter analyze: 0 issues
working tree: clean
```

A baseline oficial da Plataforma Fênix passa a ser o commit
`08f969d`.

------------------------------------------------------------------------

# 18. Arquitetura de identidade e segurança

## 18.1 Identidade operacional

O Firebase Auth estabelece a sessão autenticada. O documento
`usuarios/{uid}` estabelece a identidade operacional e somente é válido
quando existe, contém `ativo == true` e possui um `perfilAcesso`
reconhecido.

O `AuthorizationService` é a fonte única do usuário corrente no cliente.
Login, Home, atalhos e rotas não devem manter cópias independentes dessa
identidade.

Estados de cadastro ausente, conta inativa, perfil inválido e falha de
validação são explícitos e impedem acesso funcional.

## 18.2 Autorização no cliente

A matriz oficial permanece em `AuthorizationPolicy`, baseada em valores
de `Permission`. Widgets não decidem acesso comparando nomes de perfil.

As rotas administrativas aplicam `RouteGuard`. A rota legada
`/admin-legado` conduz ao painel oficial `/admin`, sem criar caminho
paralelo de autorização.

## 18.3 Autoridade de dados

O campo oficial de perfil é:

``` text
perfilAcesso
```

As regras versionadas do Firestore exigem identidade ativa e perfil
reconhecido, possuem decisão explícita para as oito coleções inventariadas
e terminam com negação por padrão.

As regras foram aprovadas em 15 testes positivos e negativos no Firebase
Emulator Suite. A Code Review preservou campos mínimos, tipos essenciais e a
imutabilidade de `createdAt` em `domains`. Elas ainda não foram publicadas no Firebase remoto. A
publicação exige autorização expressa, registro da versão anterior e teste
de fumaça posterior.

## 18.4 Cadeia administrativa de usuários

A listagem de usuários segue:

``` text
Provider → UsuarioController → UsuarioRepository → UsuarioService → Firestore
```

Falhas de atualização preservam os dados já carregados e oferecem nova
tentativa.

------------------------------------------------------------------------

# 19. Baseline da ADM-001C

``` text
ADM-001C.1: 072c5a5 — Identidade Confiável
ADM-001C.2: fc575a0 — Política Única de Autorização
ADM-001C.3: 42e3560 — Firestore Security Baseline
Branch: feature/adm-001c-identidade-seguranca
Regras locais: 15/15 testes aprovados
Flutter analyze: 0 issues
Firestore remoto: não publicado
```

## 19.1 Débitos controlados

- a matriz de permissões permanece estática no cliente;
- `acoes` ainda não possui autoria imutável por UID, impedindo política de
  propriedade individual sem evolução do modelo;
- publicação e teste de fumaça das regras remotas permanecem em procedimento
  separado;
- integração ao `main` depende de Pull Request e Code Review Arquitetural.

──────────────────────────────────────────────

**Sistema de Conhecimento da Plataforma Fênix (SKPF)**

Documento Oficial

Arquitetura da Plataforma Fênix

Versão 2.3

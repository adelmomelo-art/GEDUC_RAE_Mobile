# ARQUITETURA DA PLATAFORMA FÃŠNIX

> Documento Oficial de Arquitetura do Sistema de Conhecimento da
> Plataforma FÃªnix (SKPF)

------------------------------------------------------------------------

## Controle do Documento

  Item        Valor
  ----------- ----------------------------------------
  Documento   01_PLATFORM_ARCHITECTURE.md
  VersÃ£o      2.7
  Status      Oficial
  Sprint      SEC-001B-R1 â€” Quality Gates e ProteÃ§Ã£o da Main

------------------------------------------------------------------------

# 1. Objetivo

Este documento define a arquitetura oficial da Plataforma FÃªnix.

Seu propÃ³sito Ã© orientar toda evoluÃ§Ã£o tÃ©cnica, garantindo que novas
funcionalidades sejam incorporadas sem comprometer a integridade, a
estabilidade, a rastreabilidade e a capacidade de evoluÃ§Ã£o da soluÃ§Ã£o.

------------------------------------------------------------------------

# 2. PrincÃ­pios Arquiteturais

-   Arquitetura antes da implementaÃ§Ã£o.
-   Causa raiz antes da correÃ§Ã£o de sintomas.
-   Componentes desacoplados.
-   ServiÃ§os reutilizÃ¡veis.
-   Estado compartilhado com escopo explicitamente definido.
-   Dados como ativo estratÃ©gico.
-   InteligÃªncia centralizada.
-   EvoluÃ§Ã£o incremental.
-   Auditoria antes de grandes refatoraÃ§Ãµes.
-   HomologaÃ§Ã£o tÃ©cnica e funcional antes do commit.
-   DocumentaÃ§Ã£o sincronizada com o cÃ³digo.

------------------------------------------------------------------------

# 3. VisÃ£o Geral

``` text
                UsuÃ¡rio
                   â”‚
             Interface Flutter
                   â”‚
      â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
      â”‚                         â”‚
 Controladores             Providers
      â”‚                         â”‚
      â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                   â”‚
               ServiÃ§os
                   â”‚
             RepositÃ³rios
                   â”‚
          Fontes de Dados
                   â”‚
     â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
     â”‚             â”‚             â”‚
 Firebase     Armazenamento   IntegraÃ§Ãµes
                  local         externas
                   â”‚
          FÃªnix Analytics Engine
                   â”‚
     â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
     â”‚             â”‚             â”‚
  Faixita      Dashboard      Indicadores
```

------------------------------------------------------------------------

# 4. Camadas da Arquitetura

## 4.1 ApresentaÃ§Ã£o

ResponsÃ¡vel pelas telas, experiÃªncia do usuÃ¡rio, navegaÃ§Ã£o, componentes
visuais e interaÃ§Ã£o com o estado exposto pelos controladores e
providers.

As pÃ¡ginas nÃ£o devem criar dependÃªncias compartilhadas de longa duraÃ§Ã£o
quando essas dependÃªncias precisam permanecer disponÃ­veis em rotas
independentes.

## 4.2 AplicaÃ§Ã£o

ResponsÃ¡vel por controladores, providers, validaÃ§Ãµes, regras de negÃ³cio,
estado de fluxo e orquestraÃ§Ã£o entre apresentaÃ§Ã£o, serviÃ§os e
repositÃ³rios.

Providers com uso transversal devem ser registrados acima das rotas que
os consomem. Providers estritamente locais podem permanecer prÃ³ximos da
subÃ¡rvore correspondente, desde que seu ciclo de vida seja limitado e
documentado.

## 4.3 ServiÃ§os

ResponsÃ¡vel por integraÃ§Ãµes, persistÃªncia, sincronizaÃ§Ã£o, comunicaÃ§Ã£o
externa e acesso coordenado Ã s fontes de dados.

## 4.4 RepositÃ³rios

ResponsÃ¡vel por abstrair as operaÃ§Ãµes de domÃ­nio e impedir que as telas
dependam diretamente da implementaÃ§Ã£o de persistÃªncia.

## 4.5 Fontes de Dados

ResponsÃ¡vel pela comunicaÃ§Ã£o concreta com Firebase, armazenamento local,
APIs e outras infraestruturas persistentes.

## 4.6 InteligÃªncia

ResponsÃ¡vel pelo FÃªnix Analytics Engine, incluindo cÃ¡lculos,
indicadores, modelos matemÃ¡ticos, projeÃ§Ãµes e suporte Ã  decisÃ£o.

## 4.7 Dados

Compreende Cloud Firestore, armazenamento local, sincronizaÃ§Ã£o e demais
mecanismos de persistÃªncia utilizados pela plataforma.

------------------------------------------------------------------------

# 5. Arquitetura de Estado e Providers

## 5.1 Regra de escopo

O escopo de cada provider deve acompanhar o alcance real do estado que
ele administra:

-   provider local: estado exclusivo de uma tela ou subÃ¡rvore;
-   provider de fluxo: estado compartilhado por pÃ¡ginas do mesmo fluxo;
-   provider global: estado ou serviÃ§o consumido por rotas independentes
    da aplicaÃ§Ã£o.

A definiÃ§Ã£o incorreta do escopo pode causar perda de estado,
reinstanciaÃ§Ãµes desnecessÃ¡rias ou `ProviderNotFoundException`.

## 5.2 Registro global

Providers transversais sÃ£o registrados no `MultiProvider` principal da
aplicaÃ§Ã£o, em `lib/app.dart`, acima do `MaterialApp` e da Ã¡rvore de
rotas.

``` text
main.dart
   â†“
App
   â†“
MultiProvider
   â”œâ”€â”€ providers globais
   â””â”€â”€ MaterialApp
          â†“
        Rotas
          â†“
        PÃ¡ginas
```

## 5.3 DomainProvider

O `DomainProvider` Ã© um provider global da aplicaÃ§Ã£o.

Ele centraliza o acesso aos domÃ­nios utilizados por pÃ¡ginas e widgets
que podem ser alcanÃ§ados por rotas diferentes, incluindo
CaracterizaÃ§Ã£o e AvaliaÃ§Ã£o.

``` text
App / MultiProvider
        â†“
  DomainProvider
        â†“
 DomainRepository
        â†“
  DomainService
        â†“
 DomainDataSource
        â†“
Cloud Firestore / domains
```

A instÃ¢ncia nÃ£o deve ser criada e descartada dentro de
`CaracterizacaoAcaoPage`, pois `AvaliacaoPage` Ã© acessada por rota
independente e necessita do mesmo provider disponÃ­vel acima da
navegaÃ§Ã£o.

## 5.4 Ciclo de vida

O ciclo de vida dos providers globais Ã© administrado pelo
`ChangeNotifierProvider` registrado na raiz da aplicaÃ§Ã£o.

PÃ¡ginas consumidoras devem utilizar `context.read`, `context.watch`,
`Consumer` ou componentes equivalentes, sem executar descarte manual da
instÃ¢ncia global.

------------------------------------------------------------------------

# 6. Componentes EstratÃ©gicos

## Faixita

Assistente inteligente da Plataforma responsÃ¡vel pela orientaÃ§Ã£o
operacional, apoio educativo aos gestores e interpretaÃ§Ã£o dos resultados
produzidos pelo motor analÃ­tico.

## FÃªnix Analytics Engine

Camada Ãºnica de inteligÃªncia responsÃ¡vel por indicadores, estatÃ­sticas,
projeÃ§Ãµes e suporte Ã  decisÃ£o.

## Dashboard Executivo

Camada de apresentaÃ§Ã£o dos indicadores produzidos pelo Analytics Engine.

## Centro de InteligÃªncia Operacional

Ambiente de consolidaÃ§Ã£o das informaÃ§Ãµes operacionais e estratÃ©gicas.

## Central de DomÃ­nios

Componente responsÃ¡vel pela administraÃ§Ã£o e distribuiÃ§Ã£o dos valores
padronizados utilizados nos formulÃ¡rios e fluxos da plataforma.

------------------------------------------------------------------------

# 7. Fluxo Arquitetural

``` text
Coleta
   â†“
ValidaÃ§Ã£o
   â†“
Estado da AplicaÃ§Ã£o
   â†“
PersistÃªncia
   â†“
Analytics Engine
   â†“
Faixita
   â†“
Dashboard
   â†“
Gestor
```

------------------------------------------------------------------------

# 8. NavegaÃ§Ã£o e DependÃªncias Compartilhadas

Rotas independentes nÃ£o devem depender de providers criados dentro de
outras pÃ¡ginas.

Antes de implementar ou corrigir uma dependÃªncia compartilhada, devem
ser inspecionados:

1. Ã¡rvore de providers;
2. Ã¡rvore de rotas;
3. direÃ§Ã£o das dependÃªncias;
4. ciclo de vida das instÃ¢ncias;
5. pontos reais de consumo.

Essa inspeÃ§Ã£o Ã© obrigatÃ³ria para evitar correÃ§Ãµes locais que apenas
mascarem falhas de arquitetura.

------------------------------------------------------------------------

# 9. GovernanÃ§a Arquitetural

Toda alteraÃ§Ã£o estrutural deverÃ¡ possuir:

-   inspeÃ§Ã£o da Ã¡rvore de providers;
-   inspeÃ§Ã£o das rotas;
-   inspeÃ§Ã£o das dependÃªncias;
-   Blueprint correspondente;
-   plano de implementaÃ§Ã£o;
-   HAT-1 antes da implementaÃ§Ã£o;
-   `flutter analyze` sem issues;
-   homologaÃ§Ã£o funcional;
-   HAT-2 antes do commit;
-   registro no Engineering Log;
-   documentaÃ§Ã£o atualizada;
-   rastreabilidade no Git;
-   pacote CPB correspondente.

------------------------------------------------------------------------

# 10. Root Cause First

Toda correÃ§Ã£o estrutural deve responder:

1. Qual Ã© o erro observado?
2. Onde ele se origina?
3. Por que a arquitetura permitiu sua ocorrÃªncia?
4. Qual alteraÃ§Ã£o elimina a causa raiz, em vez de apenas o sintoma?

Na EST-005B, o erro observado foi um
`ProviderNotFoundException` em `AvaliacaoPage`. A causa raiz foi o
registro local do `DomainProvider` em `CaracterizacaoAcaoPage`, fora do
alcance da rota independente de AvaliaÃ§Ã£o. A soluÃ§Ã£o definitiva foi
promover o provider para o `MultiProvider` global.

------------------------------------------------------------------------

# 11. EvoluÃ§Ã£o

A arquitetura deverÃ¡ evoluir por pacotes incrementais, preservando
compatibilidade e estabilidade do sistema.

MudanÃ§as estruturais deverÃ£o ser precedidas por auditoria tÃ©cnica e
encerradas somente apÃ³s atualizaÃ§Ã£o documental, commit e push.

------------------------------------------------------------------------

# 12. RelaÃ§Ã£o com o SKPF

Este documento integra o Sistema de Conhecimento da Plataforma FÃªnix e
deve ser utilizado como referÃªncia principal para decisÃµes de
arquitetura.

Documentos relacionados:

-   `docs/00_ENGINEERING_CHARTER.md`;
-   `docs/06_ENGINEERING_LOG.md`;
-   `docs/08_GUIA_DE_DESENVOLVIMENTO.md`;
-   `docs/SKPF/BP-ISSUE-002A.2_INTEGRACAO_DOMAIN_SERVICE.md`.

------------------------------------------------------------------------

# 13. Registro da EST-005B

A EST-005B consolidou as seguintes decisÃµes:

-   promoÃ§Ã£o do `DomainProvider` para escopo global;
-   remoÃ§Ã£o do ciclo de vida local em
    `CaracterizacaoAcaoPage`;
-   disponibilidade do provider em rotas independentes;
-   preservaÃ§Ã£o da integraÃ§Ã£o
    `DomainProvider â†’ DomainRepository â†’ DomainService`;
-   homologaÃ§Ã£o funcional dos seis cenÃ¡rios previstos;
-   `flutter analyze` com 0 issues;
-   HAT-1 e HAT-2 aprovadas;
-   commit `35d41f6`;
-   push para `origin/release/estabilizacao-pv006`.

------------------------------------------------------------------------


------------------------------------------------------------------------

# 14. FundaÃ§Ã£o Administrativa â€” ADM-001B.1

A sprint ADM-001B.1 consolidou a FundaÃ§Ã£o Administrativa da Plataforma
FÃªnix.

## 14.1 Objetivo

Estabelecer uma base administrativa modular, rastreÃ¡vel e preparada para
crescimento incremental, sem alterar os CRUDs existentes nem ampliar
permissÃµes do Firestore.

## 14.2 Componentes

``` text
AdminHomePage
   â†“
AdminModuleCatalog
   â†“
AdminModule
   â”œâ”€â”€ identificaÃ§Ã£o
   â”œâ”€â”€ tÃ­tulo
   â”œâ”€â”€ descriÃ§Ã£o
   â”œâ”€â”€ rota
   â”œâ”€â”€ Ã­cone
   â”œâ”€â”€ status
   â””â”€â”€ permissÃ£o
```

Foram consolidados:

- catÃ¡logo central de mÃ³dulos administrativos;
- modelo imutÃ¡vel de mÃ³dulo;
- estados de disponibilidade;
- cartÃ£o administrativo reutilizÃ¡vel;
- navegaÃ§Ã£o administrativa centralizada;
- preparaÃ§Ã£o inicial para controle de acesso.

## 14.3 MÃ³dulos administrativos

A fundaÃ§Ã£o contempla:

- Central de DomÃ­nios;
- UsuÃ¡rios;
- Tipos de AÃ§Ãµes;
- Coordenadores;
- Regionais;
- Materiais.

## 14.4 DecisÃ£o arquitetural

A pÃ¡gina administrativa nÃ£o deve manter uma lista prÃ³pria e paralela de
mÃ³dulos. O catÃ¡logo oficial Ã© a fonte Ãºnica para apresentaÃ§Ã£o,
navegaÃ§Ã£o, status e autorizaÃ§Ã£o.

------------------------------------------------------------------------

# 15. Camada de AutorizaÃ§Ã£o Administrativa â€” ADM-001B.2

A sprint ADM-001B.2 introduziu a primeira camada centralizada de
autorizaÃ§Ã£o da Plataforma FÃªnix.

## 15.1 PrincÃ­pio

``` text
A interface nÃ£o decide.
A rota nÃ£o contÃ©m a polÃ­tica.
O AuthorizationService centraliza a decisÃ£o.
```

## 15.2 Fluxo

``` text
Firebase Authentication
          â†“
AuthorizationService
          â†“
UsuarioService
          â†“
usuarios/{uid}.perfilAcesso
          â†“
AuthorizationPolicy
          â†“
RouteGuard / AdministraÃ§Ã£o
```

## 15.3 Componentes

- `Permission`: catÃ¡logo tipado de permissÃµes;
- `AuthorizationPolicy`: matriz entre perfis e permissÃµes;
- `AuthorizationResult`: resultado imutÃ¡vel da avaliaÃ§Ã£o;
- `AuthorizationService`: ponto central de decisÃ£o;
- `RouteGuard`: proteÃ§Ã£o das rotas administrativas;
- `AccessDeniedPage`: resposta explÃ­cita para acesso negado.

## 15.4 Matriz inicial

| Perfil | Escopo administrativo |
|---|---|
| `administrador` | Todos os mÃ³dulos |
| `gestor` | AdministraÃ§Ã£o, DomÃ­nios, UsuÃ¡rios e Tipos de AÃ§Ãµes |
| `coordenador` | Sem acesso administrativo nesta matriz |
| `agente` | Sem acesso administrativo nesta matriz |

Perfis desconhecidos ou documentos de usuÃ¡rio ausentes sÃ£o negados por
padrÃ£o.

## 15.5 ProteÃ§Ã£o em profundidade

Ocultar um botÃ£o nÃ£o constitui autorizaÃ§Ã£o. O controle ocorre em dois
nÃ­veis:

1. apresentaÃ§Ã£o: mÃ³dulos e atalhos compatÃ­veis com o perfil;
2. navegaÃ§Ã£o: `RouteGuard` bloqueia acesso direto por rota.

A seguranÃ§a persistente dos dados permanece responsabilidade das regras
do Firestore.

## 15.6 HomologaÃ§Ã£o

Foram homologados:

- administrador em Android;
- gestor em Android;
- coordenador em Android;
- agente em Android;
- acesso direto protegido no Flutter Web;
- tela de acesso nÃ£o autorizado;
- retorno ao Centro de OperaÃ§Ãµes;
- ausÃªncia de regressÃµes na Central de DomÃ­nios.

`flutter analyze`: **No issues found!**

------------------------------------------------------------------------

# 16. GovernanÃ§a de Engenharia â€” PF-ENG 003/2026

MudanÃ§as estruturais e de seguranÃ§a passam a seguir obrigatoriamente:

``` text
InspeÃ§Ã£o
   â†“
Blueprint
   â†“
Plano de implementaÃ§Ã£o
   â†“
Feature branch
   â†“
ImplementaÃ§Ã£o
   â†“
flutter analyze: 0 issues
   â†“
HomologaÃ§Ã£o
   â†“
CPB
   â†“
Commit e push
   â†“
Pull Request
   â†“
Code Review Arquitetural
   â†“
Merge na main
   â†“
ValidaÃ§Ã£o pÃ³s-merge
   â†“
AtualizaÃ§Ã£o documental
```

Pull Request e Code Review sÃ£o obrigatÃ³rios para alteraÃ§Ãµes de:

- arquitetura;
- seguranÃ§a;
- autenticaÃ§Ã£o e autorizaÃ§Ã£o;
- roteamento;
- modelos de dados;
- providers globais;
- infraestrutura compartilhada.

------------------------------------------------------------------------

# 17. Baseline oficial pÃ³s-ADM-001B.2

``` text
Pull Request: #1
ADM-001B.1: 6049e7d
ADM-001B.2: ff32e74
Merge na main: 08f969d
Branch principal: main
flutter analyze: 0 issues
working tree: clean
```

A baseline oficial da Plataforma FÃªnix passa a ser o commit
`08f969d`.

------------------------------------------------------------------------

# 18. Arquitetura de identidade e seguranÃ§a

## 18.1 Identidade operacional

O Firebase Auth estabelece a sessÃ£o autenticada. O documento
`usuarios/{uid}` estabelece a identidade operacional e somente Ã© vÃ¡lido
quando existe, contÃ©m `ativo == true` e possui um `perfilAcesso`
reconhecido.

O `AuthorizationService` Ã© a fonte Ãºnica do usuÃ¡rio corrente no cliente.
Login, Home, atalhos e rotas nÃ£o devem manter cÃ³pias independentes dessa
identidade.

Estados de cadastro ausente, conta inativa, perfil invÃ¡lido e falha de
validaÃ§Ã£o sÃ£o explÃ­citos e impedem acesso funcional.

## 18.2 AutorizaÃ§Ã£o no cliente

A matriz oficial permanece em `AuthorizationPolicy`, baseada em valores
de `Permission`. Widgets nÃ£o decidem acesso comparando nomes de perfil.

As rotas administrativas aplicam `RouteGuard`. A rota legada
`/admin-legado` conduz ao painel oficial `/admin`, sem criar caminho
paralelo de autorizaÃ§Ã£o.

## 18.3 Autoridade de dados

O campo oficial de perfil Ã©:

``` text
perfilAcesso
```

As regras versionadas do Firestore exigem identidade ativa e perfil
reconhecido, possuem decisÃ£o explÃ­cita para as oito coleÃ§Ãµes inventariadas
e terminam com negaÃ§Ã£o por padrÃ£o.

As regras foram aprovadas em 15 testes positivos e negativos no Firebase
Emulator Suite. A Code Review preservou campos mÃ­nimos, tipos essenciais e a
imutabilidade de `createdAt` em `domains`.

A baseline foi publicada no projeto `geduc-rae-mobile` em 02/08/2026, apÃ³s
autorizaÃ§Ã£o expressa, preservaÃ§Ã£o da versÃ£o anterior e confirmaÃ§Ã£o do hash
candidato. A fonte remota foi integralmente comparada com `firestore.rules` e
o smoke test pÃ³s-deploy foi aprovado sem regressÃ£o crÃ­tica.

## 18.4 Cadeia administrativa de usuÃ¡rios

A listagem de usuÃ¡rios segue:

``` text
Provider â†’ UsuarioController â†’ UsuarioRepository â†’ UsuarioService â†’ Firestore
```

Falhas de atualizaÃ§Ã£o preservam os dados jÃ¡ carregados e oferecem nova
tentativa.

------------------------------------------------------------------------

# 19. Baseline final da ADM-001C

``` text
ADM-001C.1: 072c5a5 â€” Identidade ConfiÃ¡vel
ADM-001C.2: fc575a0 â€” PolÃ­tica Ãšnica de AutorizaÃ§Ã£o
ADM-001C.3: 42e3560 â€” Firestore Security Baseline
ADM-001C.3-R1: 2129355 â€” restauraÃ§Ã£o das invariantes de domains
ADM-001C.4: 0d3d831 â€” homologaÃ§Ã£o integrada e encerramento
Code Review: 7cd1104 â€” aprovaÃ§Ã£o apÃ³s correÃ§Ã£o R1
PR nÂº 3 / merge: 21f8ea2 â€” integraÃ§Ã£o da ADM-001C
PR nÂº 4 / merge: b0738ef â€” encerramento documental pÃ³s-merge
PR nÂº 5 / merge: 6a6794d â€” sincronizaÃ§Ã£o arquitetural pÃ³s-merge
Branch oficial: main
Flutter analyze pÃ³s-merge: 0 issues
Firebase Emulator Suite: 15/15 testes
Working tree pÃ³s-merge: clean
Firestore remoto: baseline segura publicada em 02/08/2026
```

A baseline oficial da Plataforma FÃªnix apÃ³s a conclusÃ£o da ADM-001C Ã© o
commit `6a6794d` da branch `main`.

A feature branch `feature/adm-001c-identidade-seguranca` e a branch
documental `docs/enc-adm-001c-seguranca` foram removidas apÃ³s os merges,
conforme o procedimento de encerramento.

## 19.1 DÃ©bitos controlados

- a matriz de permissÃµes permanece estÃ¡tica no cliente;
- `acoes` ainda nÃ£o possui autoria imutÃ¡vel por UID, impedindo polÃ­tica de
  propriedade individual sem evoluÃ§Ã£o do modelo;
- o repositÃ³rio ainda nÃ£o possui status checks ou workflows automatizados;
- App Check, Cloud Audit Logs, alertas de seguranÃ§a e status checks ainda
  exigem avaliaÃ§Ã£o e pacotes prÃ³prios de defesa em profundidade.

## 19.2 Controle de publicaÃ§Ã£o

As regras de seguranÃ§a aprovadas no Firebase Emulator Suite foram publicadas
no Firebase remoto em 02/08/2026, exclusivamente no escopo `firestore:rules`.

O procedimento utilizou projeto explÃ­cito, CLI local versionada, preservaÃ§Ã£o da
regra anterior, hash candidato, rollback condicionado, verificaÃ§Ã£o integral da
fonte remota e smoke test nÃ£o destrutivo. A homologaÃ§Ã£o foi aprovada sem
ressalvas tÃ©cnicas e nÃ£o hÃ¡ indicaÃ§Ã£o de rollback.

## 19.3 SincronizaÃ§Ã£o arquitetural pÃ³s-merge

A ADM-001C.4-R3 corrige a divergÃªncia documental identificada apÃ³s o
encerramento R2. O Engineering Log jÃ¡ registrava os merges e a validaÃ§Ã£o
pÃ³s-merge, enquanto esta arquitetura ainda indicava integraÃ§Ã£o pendente.

A arquitetura oficial passa a refletir o estado real do Git e do GitHub:

- Pull Request nÂº 3 integrado Ã  `main`;
- Pull Request nÂº 4 integrado Ã  `main`;
- baseline final da sincronizaÃ§Ã£o `6a6794d`;
- branches da ADM-001C encerradas;
- validaÃ§Ãµes pÃ³s-merge aprovadas;
- regras remotas publicadas e homologadas pela SEC-001A.

------------------------------------------------------------------------

# 20. Baseline remota de seguranÃ§a â€” SEC-001A

## 20.1 Estado publicado

``` text
Projeto Firebase: geduc-rae-mobile
Banco: Cloud Firestore (default)
Data: 02/08/2026
Regra: firestore.rules
SHA-256: 8838A3F097168C342289F51D2746B265AA540457C59AA226819EB730B2CA3BFD
ComparaÃ§Ã£o remota/local: exit code 0
Smoke test pÃ³s-deploy: aprovado
Rollback: nÃ£o indicado
```

## 20.2 PrincÃ­pios de seguranÃ§a

A autoridade persistente estÃ¡ no Firestore, e nÃ£o na visibilidade de widgets
Flutter. Cada requisiÃ§Ã£o exige autenticaÃ§Ã£o, documento operacional existente,
conta ativa, perfil reconhecido e permissÃ£o compatÃ­vel com a coleÃ§Ã£o.

A arquitetura aplica:

- separaÃ§Ã£o entre autenticaÃ§Ã£o e autorizaÃ§Ã£o;
- validaÃ§Ã£o no backend em toda requisiÃ§Ã£o;
- menor privilÃ©gio;
- negaÃ§Ã£o por padrÃ£o;
- identidade imutÃ¡vel pelo cliente;
- validaÃ§Ã£o estrutural de `domains`;
- testes automatizados positivos e negativos;
- publicaÃ§Ã£o versionada, verificÃ¡vel e reversÃ­vel somente por decisÃ£o humana.

## 20.3 ReferÃªncias arquiteturais

A baseline foi confrontada com a documentaÃ§Ã£o oficial do Firebase Security
Rules, o OWASP Authorization Cheat Sheet, o OWASP Top 10:2025 A01 e o NIST SP
800-207. O mapeamento completo estÃ¡ em
`docs/SEC-001A_PUBLICACAO_HOMOLOGACAO_REFERENCIAS.md`.

Firebase App Check, Cloud Audit Logs, alertas e automaÃ§Ã£o de CI foram
classificados como defesas complementares a avaliar. Nenhum deles substitui a
matriz de autorizaÃ§Ã£o publicada.

## 20.4 Encerramento Git e baseline oficial

``` text
Baseline de entrada da SEC-001A: 6a6794d
Commit preparatÃ³rio: 9da5c94
Commit documental: 1ba5ba3
Pull Request: nÂº 6
Merge na main: c8d2d95
Branch oficial: main
Working tree pÃ³s-merge: clean
Branch da SEC-001A: removida local e remotamente
```

O commit `6a6794d` permanece como baseline histÃ³rica de entrada da SEC-001A e
como encerramento da ADM-001C. ApÃ³s a publicaÃ§Ã£o, homologaÃ§Ã£o, revisÃ£o e merge
do Pull Request nÂº 6, a baseline oficial da Plataforma FÃªnix passou a ser o
commit `c8d2d95` da branch `main`.

A sincronizaÃ§Ã£o SEC-001A-R1 Ã© exclusivamente documental. Ela nÃ£o modifica as
regras publicadas, o modelo de dados, o cÃ³digo Flutter ou a configuraÃ§Ã£o do
Firebase e nÃ£o autoriza nova publicaÃ§Ã£o remota.

------------------------------------------------------------------------

# 21. Quality gates e proteÃ§Ã£o da main â€” SEC-001B

## 21.1 Pipeline oficial

O repositÃ³rio possui o workflow `Quality Gates`, versionado em
`.github/workflows/quality-gates.yml`. Ele Ã© executado em Pull Requests
destinados Ã  `main`, em pushes na `main` e por acionamento manual.

``` text
Pull Request ou push na main
            â”‚
       Quality Gates
        â”Œâ”€â”€â”€â”´â”€â”€â”€â”
        â”‚       â”‚
Flutter Analyze Firestore Rules
        â”‚       â”‚
        â””â”€â”€â”€â”¬â”€â”€â”€â”˜
            â”‚
      Ruleset da main
```

Os jobs oficiais sÃ£o:

- `Quality Gate - Flutter Analyze`, executando `flutter analyze`;
- `Quality Gate - Firestore Rules`, executando os 15 testes no Firebase
  Emulator Suite.

## 21.2 Reprodutibilidade e isolamento

``` text
Runner: ubuntu-24.04
Flutter: 3.44.4 stable
Node: 24.18.0
Java: 21 Temurin
Firebase CLI: 15.25.1
Projeto do emulador: geduc-rae-mobile-test
PermissÃµes do token: contents: read
Actions: fixadas por SHA completo
Deploy Firebase: ausente
```

O workflow nÃ£o utiliza secrets, service accounts, login Firebase ou
`pull_request_target`. O checkout nÃ£o persiste credenciais e as execuÃ§Ãµes
antigas do mesmo ref sÃ£o canceladas por controle de concorrÃªncia.

## 21.3 Ruleset da branch oficial

O ruleset `main-quality-gates`, identificador `20301322`, estÃ¡ `Active` e tem
como alvo a default branch (`main`). A lista de bypass estÃ¡ vazia.

SÃ£o exigidos:

- Pull Request antes do merge;
- resoluÃ§Ã£o de conversas;
- branch atualizada com a base;
- `Quality Gate - Flutter Analyze` em sucesso;
- `Quality Gate - Firestore Rules` em sucesso;
- restriÃ§Ã£o de exclusÃ£o;
- bloqueio de force push.

O nÃºmero de aprovaÃ§Ãµes obrigatÃ³rias Ã© `0`, compatÃ­vel com a manutenÃ§Ã£o atual
por um Ãºnico responsÃ¡vel. Essa configuraÃ§Ã£o nÃ£o reduz a obrigatoriedade dos
dois checks tÃ©cnicos.

## 21.4 HomologaÃ§Ã£o

``` text
Commit do workflow: f7db380
Pull Request do workflow: nÂº 8
Merge do workflow: 1d279e9
Commit da prova: 7ce49d9
Pull Request da prova: nÂº 9
Merge da prova: a45c142
HAT-1: aprovada
HAT-2: aprovada â€” 15/15 testes e analyze sem issues
HAT-3: aprovada â€” dois jobs remotos em sucesso
HAT-4: aprovada â€” dois checks Required e merge sem bypass
```

ApÃ³s o Pull Request nÂº 9, o push da `main` executou automaticamente o workflow
e foi aprovado em 59 segundos. A validaÃ§Ã£o local pÃ³s-merge confirmou
`flutter analyze` sem issues, working tree limpa e sincronizaÃ§Ã£o com
`origin/main`.

## 21.5 Baseline e limites

A baseline tÃ©cnica oficial apÃ³s a implantaÃ§Ã£o e a prova dos quality gates Ã© o
commit `a45c142` da branch `main`.

A SEC-001B nÃ£o altera a matriz de autorizaÃ§Ã£o, as regras publicadas do
Firestore, o cÃ³digo Flutter ou os dados remotos. As seis vulnerabilidades npm
de severidade moderada identificadas durante `npm ci` permanecem registradas
como dÃ­vida de supply chain para tratamento independente.

# 22. Hardening da cadeia npm â€” SEC-001C

## 22.1 Objetivo e limite arquitetural

A SEC-001C endurece a instalaÃ§Ã£o e a auditoria das dependÃªncias usadas nos
testes das regras do Firestore. O fluxo nÃ£o modifica o cÃ³digo Flutter, as
regras publicadas, os dados remotos nem a matriz de autorizaÃ§Ã£o.

## 22.2 PolÃ­tica de scripts de instalaÃ§Ã£o

O npm opera com `strict-allow-scripts=true`. Scripts de instalaÃ§Ã£o somente
podem executar quando o pacote e a versÃ£o estiverem registrados em
`allowScripts`:

- `@firebase/util@1.12.1`;
- `protobufjs@7.6.5`;
- `re2@1.26.1`.

O pacote opcional `fsevents`, exclusivo de macOS, permanece explicitamente
negado. MudanÃ§as de versÃ£o exigem nova revisÃ£o e aprovaÃ§Ã£o.

## 22.3 Gate de vulnerabilidades

O job obrigatÃ³rio `Quality Gate - Firestore Rules` executa
`npm run audit:security` antes do `npm ci`. O limiar `high` permite registrar
ocorrÃªncias moderadas, mas bloqueia automaticamente severidades alta e crÃ­tica
antes da instalaÃ§Ã£o e dos testes.

A atualizaÃ§Ã£o segura do `re2`, de `1.24.1` para `1.26.1`, reduziu o relatÃ³rio
de seis para cinco ocorrÃªncias moderadas. O uso de `npm audit fix --force`
permanece proibido porque a soluÃ§Ã£o proposta pelo npm exige downgrade para
`firebase-tools@14.23.0`.

## 22.4 HomologaÃ§Ã£o

```text
Baseline de entrada: 3400563
Commit da SEC-001C: 2c16d4d
Pull Request: nÂº 11
Merge / baseline final: 6b53c8f
HAT-1: aprovada
HAT-2: aprovada â€” 15/15 testes e analyze sem issues
HAT-3: aprovada â€” dois checks Required em sucesso
HAT-4: aprovada â€” workflow pÃ³s-merge verde em 43 s
```

Na validaÃ§Ã£o pÃ³s-merge, a polÃ­tica de scripts nÃ£o apresentou pendÃªncias, o
audit de severidade retornou sucesso, os 15 testes das regras foram aprovados e
o `flutter analyze` terminou sem issues. A working tree permaneceu limpa.

## 22.5 Risco residual

As cinco ocorrÃªncias moderadas remanescentes sÃ£o transitivas da cadeia do
Firebase CLI, associadas a OpenTelemetry e UUID. Elas continuam visÃ­veis nos
logs, nÃ£o dispensam monitoramento e deverÃ£o ser corrigidas quando houver
atualizaÃ§Ã£o compatÃ­vel sem regressÃ£o da toolchain.

------------------------------------------------------------------------


â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

**Sistema de Conhecimento da Plataforma FÃªnix (SKPF)**

Documento Oficial

Arquitetura da Plataforma FÃªnix

VersÃ£o 2.8

------------------------------------------------------------------------

## AUD-L2-R4 â€” ACL operacional e Send Gate

**Data:** 19/08/2026
**Status:** Homologado

A Plataforma FÃªnix passa a possuir uma cadeia ACL explÃ­cita para RAEs novos:

```text
AuthorizationService / identidade autenticada
        |
        v
R4.2 Identity Binding
        |
        +--> responsavelUserId
        +--> coordenadorUserId canonico
        |
        v
R4.3 Scope Resolver
        |
        +--> regionalId
        +--> equipeId
        +--> projetoId
        |
        v
R4.4 RaeAclClassifier
        |
        +--> aclClassificacaoCompleta
        +--> aclScopeKey
        |
        v
R4.4-B Send Gate
```

### Invariantes arquiteturais

1. Nome de coordenador nÃ£o autoriza avanÃ§o; somente identidade canÃ´nica.
2. Escopo ambÃ­guo nÃ£o Ã© resolvido por escolha arbitrÃ¡ria.
3. ACL completa exige Regional, responsÃ¡vel, coordenador, Equipe e Projeto.
4. A chave canÃ´nica Ã© `r:<regional>|e:<equipe>|p:<projeto>`.
5. AlteraÃ§Ã£o em qualquer dimensÃ£o classificatÃ³ria invalida a classificaÃ§Ã£o anterior.
6. RAE novo em `rascunho` nÃ£o pode ser enviado com ACL incompleta ou inconsistente.
7. ACL persistida inconsistente nÃ£o pode ser silenciosamente normalizada durante o envio.
8. Registros histÃ³ricos fora de `rascunho` preservam compatibilidade e nÃ£o recebem bloqueio retroativo.

### Componentes introduzidos

- `RaeAclClassifier`
- `RaeIdentityResolver`
- `RaeScopeResolver`
- `RaeScopeCatalogService`

A integraÃ§Ã£o permanece concentrada em `AcaoController` e `RecursosOperacionaisPage`, sem transferÃªncia de decisÃ£o de seguranÃ§a para a interface.
### R4-R1 â€” Regional Scope Enforcement

A dimensÃ£o Regional do `AccessScope` passa a ser obrigatÃ³ria na resoluÃ§Ã£o do escopo ACL. Antes de avaliar Equipe e Projeto, o `regionalId` do RAE deve estar presente em `AccessScope.regionalIds`. Escopo regional vazio ou incompatÃ­vel falha de forma fechada.
------------------------------------------------------------------------

## AUD-L2-R5.1 â€” Arquitetura hÃ­brida de evidÃªncias

**Data:** 19/08/2026
**Status:** Homologado localmente

A Plataforma FÃªnix adota uma fronteira arquitetural para armazenamento remoto de evidÃªncias sem alterar a decisÃ£o operacional vigente de manter as fotografias no dispositivo.

### PrincÃ­pio local-first

O `EvidenciaStorageService` permanece responsÃ¡vel pelo armazenamento local e continua sendo obrigatÃ³rio. A indisponibilidade ou ausÃªncia de armazenamento remoto nÃ£o pode impedir a captura, persistÃªncia ou continuidade de uma aÃ§Ã£o educativa.

```text
Captura da evidÃªncia
        |
        v
EvidenciaStorageService
        |
        +--> armazenamento local obrigatÃ³rio
        |
        +--> EvidenciaModel(status: pendente)
        |
        `--> integraÃ§Ã£o remota futura e opcional
                 |
                 v
          RemoteEvidenceStorage
                 |
                 +--> Cloudflare R2
                 +--> Backblaze B2
                 `--> outro adaptador
```

### Contratos introduzidos

- `RemoteEvidenceStorage`: contrato neutro de fornecedor;
- `RemoteEvidenceUploadRequest`: dados mÃ­nimos para futura transferÃªncia;
- `RemoteEvidenceUploadResult`: resultado neutro da sincronizaÃ§Ã£o remota;
- `DisabledRemoteEvidenceStorage`: implementaÃ§Ã£o fail-closed quando nÃ£o existe provedor configurado;
- `EvidenceStoragePolicy`: polÃ­tica explÃ­cita local-first com remoto desligado por padrÃ£o.

### Invariantes

1. O armazenamento local Ã© obrigatÃ³rio.
2. O armazenamento remoto Ã© opcional.
3. Nenhuma credencial de provedor remoto pode ser embutida no APK.
4. A ausÃªncia de nuvem nÃ£o pode impedir a operaÃ§Ã£o de campo.
5. O contrato do aplicativo nÃ£o deve depender diretamente de Cloudflare, Backblaze, Firebase ou outro fornecedor.
6. O R5.1 nÃ£o altera `SyncService`, Providers, rotas ou o fluxo atual de evidÃªncias.
7. Cloudflare R2 e Backblaze B2 sÃ£o candidatos futuros, nÃ£o dependÃªncias atuais.
8. Firebase Storage permanece fora do fluxo de fotografias por decisÃ£o arquitetural e econÃ´mica vigente.

### HomologaÃ§Ã£o

```text
Testes R5.1:                   8/8
flutter analyze:               0 issues
git diff --check:              aprovado
IntegraÃ§Ã£o remota ativa:       nÃ£o
MudanÃ§a no fluxo de produÃ§Ã£o:  nÃ£o
```

------------------------------------------------------------------------

## AUD-L2-R5.2 / R5.2-C â€” Integridade e autoria canÃ´nica das evidÃªncias

**Data:** 20/08/2026
**Status:** Homologado localmente

A camada local de evidÃªncias passa a registrar metadados de integridade e
autoria operacional sem alterar a invariante local-first.

### Metadados de integridade

Cada nova evidÃªncia pode registrar:

- `sha256`;
- `tamanhoBytes`;
- `mimeType`;
- `objectKey`;
- `sincronizadoEm`;
- `autorUserId`.

O SHA-256 e o tamanho sÃ£o calculados sobre o arquivo local definitivo apÃ³s a
cÃ³pia. `objectKey` permanece vazio enquanto nÃ£o houver confirmaÃ§Ã£o remota e
`sincronizadoEm` permanece nulo enquanto a evidÃªncia for somente local.

### Identity Binding

A fonte canÃ´nica de autoria Ã©:

```text
AuthorizationService
        |
        v
usuarioAtual.id
        |
        v
EvidenciasPage
        |
        v
autorUserId obrigatÃ³rio
        |
        v
EvidenciaStorageService
        |
        v
EvidenciaModel.autorUserId
```

O `AuthorizationService` resolve `usuarios/{uid}` a partir da sessÃ£o
autenticada. NÃ£o existe fallback por nome, e-mail, cargo ou outro campo
descritivo.

### Invariantes

1. EvidÃªncia nova exige identidade operacional vÃ¡lida.
2. `EvidenciaStorageService` nÃ£o depende diretamente de Firebase Auth ou Firestore.
3. `autorUserId` vazio Ã© rejeitado antes do salvamento.
4. EvidÃªncias legadas com `autorUserId == ''` permanecem legÃ­veis.
5. Armazenamento local continua obrigatÃ³rio.
6. Cloudflare R2, upload remoto, URLs assinadas e `SyncService` permanecem fora deste escopo.
7. `AcaoModel`, Providers e rotas nÃ£o sÃ£o alterados pelo R5.2-C.

### HomologaÃ§Ã£o

```text
R5.2-A/B testes focados:       17/17
R5.2-A/B regressÃ£o completa:   775/775
R5.2-C testes focados:         aprovados
R5.2-C regressÃ£o completa:     aprovada
flutter analyze:               0 issues
git diff --check:              aprovado
```
------------------------------------------------------------------------

## AUD-L2-R5.3 â€” Fronteira de autorizaÃ§Ã£o de evidÃªncias remotas

**Data:** 20/08/2026
**Status:** Homologado localmente

O acesso remoto futuro Ã s evidÃªncias passa a possuir uma fronteira explÃ­cita
entre o cliente Flutter e a autoridade capaz de conceder acesso temporÃ¡rio.

```text
Flutter / identidade operacional
        |
        v
EvidenceAccessBroker
        |
        v
Backend confiÃ¡vel futuro
        |
        +--> valida token
        +--> resolve UID canÃ´nico
        +--> valida usuÃ¡rio ativo e perfil
        +--> valida ACL do RAE
        +--> determina operaÃ§Ã£o
        |
        v
Grant temporÃ¡rio
        |
        v
Armazenamento privado
```

### DecisÃµes

1. Nenhuma credencial de armazenamento ou segredo de assinatura pode existir no APK.
2. O cliente nÃ£o pode fabricar grants ou URLs assinadas.
3. `autorUserId` Ã© metadado de auditoria e nÃ£o prova identidade ao backend.
4. A identidade deve ser derivada pelo backend a partir da sessÃ£o autenticada.
5. Leitura remota futura corresponde semanticamente a `Permission.consultarRae`.
6. Upload remoto futuro corresponde semanticamente a `Permission.editarRae`.
7. ExclusÃ£o remota nÃ£o Ã© autorizada pelo R5.3.
8. `DisabledEvidenceAccessBroker` Ã© a implementaÃ§Ã£o padrÃ£o fail-closed.
9. Cloudflare R2 e Worker permanecem candidatos futuros, nÃ£o dependÃªncias deste pacote.
10. A invariante local-first permanece intacta.
### HomologaÃ§Ã£o

```text
Testes focados R5.1 + R5.3:    aprovados
RegressÃ£o Flutter completa:    aprovada
flutter analyze:               0 issues
git diff --check:              aprovado
Escopo final:                  8 arquivos
IntegraÃ§Ã£o R2 ativa:           nÃ£o
Worker/backend remoto:         nÃ£o
Credenciais remotas no APK:    nenhuma
```

A homologaÃ§Ã£o confirma apenas a fronteira arquitetural e os contratos
fail-closed. Nenhum grant real, URL assinada, upload remoto ou segredo de
provedor foi introduzido no aplicativo.
------------------------------------------------------------------------

## AUD-L2-R5.4-A â€” SeparaÃ§Ã£o entre autorizaÃ§Ã£o e transporte remoto

**Data:** 20/08/2026
**Baseline:** `8d4e0c2`
**Status:** Homologado localmente

A arquitetura remota passa a separar formalmente o plano de controle do plano
de dados.

```text
PLANO DE CONTROLE

Flutter
   |
   v
EvidenceAccessBroker
   |
   v
backend confiÃ¡vel futuro
   |
   v
EvidenceAccessGrant


PLANO DE DADOS

arquivo local
   |
   | EvidenceAccessGrant
   v
RemoteEvidenceTransport
   |
   v
provedor remoto futuro
```

### DecisÃµes

1. `RemoteEvidenceStorage` deixa de existir como contrato cliente.
2. `RemoteEvidenceTransport` nÃ£o cria grants nem URLs assinadas.
3. O upload exige um `EvidenceAccessGrant` previamente emitido.
4. `createReadUri()` Ã© removido do plano de dados.
5. `delete()` Ã© removido do contrato e permanece nÃ£o autorizado.
6. O transporte nÃ£o conhece ACL, identidade operacional ou credenciais R2.
7. `DisabledRemoteEvidenceTransport` Ã© a implementaÃ§Ã£o padrÃ£o fail-closed.
8. Nenhuma integraÃ§Ã£o HTTP ou Cloudflare Ã© introduzida no R5.4-A.
9. A polÃ­tica local-first permanece obrigatÃ³ria.
### HomologaÃ§Ã£o

```text
Testes focados R5.3 + R5.4-A:  aprovados
RegressÃ£o Flutter completa:    aprovada
flutter analyze:               0 issues
git diff --check:              aprovado
Escopo final:                  9 caminhos Git
Contrato legado:               removido
HTTP real:                     nÃ£o
Cloudflare R2 real:            nÃ£o
Worker/backend remoto:         nÃ£o
Credenciais no APK:            nenhuma
```

A homologaÃ§Ã£o confirma que o plano de dados perdeu qualquer autoridade para
fabricar grants, URLs assinadas ou exclusÃµes remotas. O transporte apenas
consome um `EvidenceAccessGrant` previamente emitido.
------------------------------------------------------------------------

## AUD-L2-R5.4-B â€” Hardening de grants e object keys

**Data:** 20/08/2026
**Baseline:** `ead4fe18b9e5ebb35a508baecbc6242b9d18fd2f`
**Status:** Homologado localmente

Antes da camada HTTP real, a fronteira de acesso remoto recebe endurecimento
estrutural e temporal.

### Grant

`EvidenceAccessGrant` Ã© vÃ¡lido somente se:

1. o esquema for exatamente `https`;
2. existir host;
3. a expiraÃ§Ã£o estiver estritamente no futuro;
4. quando usado via `validoPara(...)`, a operaÃ§Ã£o do grant coincidir com a
   operaÃ§Ã£o esperada.

### Object key

Os identificadores de RAE e evidÃªncia continuam sem aceitar separadores de
caminho e passam a rejeitar explicitamente `.` e `..`.

A regra impede ambiguidades de normalizaÃ§Ã£o antes que qualquer chave seja
submetida a um backend ou provedor remoto.

Nenhum HTTP, Worker, R2 real ou credencial Ã© introduzido nesta subetapa.
### HomologaÃ§Ã£o

```text
Testes focados R5.4-B:          aprovados
RegressÃ£o Flutter completa:    aprovada
flutter analyze:               0 issues
git diff --check:              aprovado
Escopo final:                  7 caminhos Git
HTTPS obrigatÃ³rio:             sim
Host obrigatÃ³rio:              sim
ExpiraÃ§Ã£o futura obrigatÃ³ria:  sim
OperaÃ§Ã£o compatÃ­vel:           sim
"." e ".." bloqueados:         sim
HTTP real:                     nÃ£o
Cloudflare R2 real:            nÃ£o
Worker/backend remoto:         nÃ£o
Credenciais no APK:            nenhuma
```

A homologaÃ§Ã£o confirma o endurecimento das prÃ©-condiÃ§Ãµes de acesso remoto
antes da introduÃ§Ã£o de qualquer transporte HTTP real.
------------------------------------------------------------------------

## AUD-L2-R5.4-C â€” AbstraÃ§Ã£o de transporte HTTP

**Data:** 21/08/2026
**Baseline:** `8c04ba7e661942f212abfd15c840cb54f8ff7d0e`
**Status:** Homologado localmente

A camada remota passa a possuir uma porta HTTP neutra de provedor, sem
implementaÃ§Ã£o de rede real.

```text
CONTROL PLANE

EvidenceAccessBroker
        |
        v
EvidenceAccessGrant
  - uri
  - operation
  - expiresAt
  - objectKey
  - requiredHeaders

DATA PLANE

RemoteEvidenceTransport
        |
        v
EvidenceHttpClient
        |
        v
HTTP real futuro
```

### Autoridade da objectKey

A `objectKey` usada apÃ³s sincronizaÃ§Ã£o deve ser a chave autorizada pela
fronteira confiÃ¡vel e retornada no grant.

O cliente nÃ£o deve inferir a chave pela URL assinada nem tratar
`EvidenceMetadataCalculator.buildObjectKey()` como autoridade remota.

### Contrato HTTP

`EvidenceHttpClient` Ã© apenas uma porta. Nesta subetapa:

- nenhum pacote HTTP Ã© adicionado;
- nenhum socket Ã© aberto;
- nenhum endpoint Cloudflare Ã© chamado;
- nenhum segredo Ã© conhecido pelo aplicativo;
- headers do grant continuam opacos para o cliente.
### HomologaÃ§Ã£o R5.4-C

```text
Testes focados R5.4-C:          aprovados
RegressÃ£o Flutter completa:    aprovada
flutter analyze:               0 issues
git diff --check:              aprovado
Escopo final:                  9 caminhos Git
objectKey no grant:            sim
HTTP client concreto:          nÃ£o
Pacote http/Dio:               nÃ£o
HTTP real:                     nÃ£o
Cloudflare R2 real:            nÃ£o
Worker/backend remoto:         nÃ£o
Credenciais no APK:            nenhuma
```

A homologaÃ§Ã£o confirma que a aplicaÃ§Ã£o passa a possuir somente a porta HTTP
necessÃ¡ria para a futura transferÃªncia remota. A autoridade de `objectKey`
permanece fora do cliente, e nenhum trÃ¡fego HTTP real foi introduzido.
------------------------------------------------------------------------

## AUD-L2-R5.4-D â€” Signed URL Remote Transport

**Data:** 21/08/2026
**Baseline:** `75176edfe61b273bb3b95de7d05e1b8cfe1513c6`
**Status:** Homologado localmente

A implementaÃ§Ã£o concreta do plano de dados permanece neutra de provedor.

```text
CONTROL PLANE

Trusted backend
      |
      v
EvidenceAccessGrant

DATA PLANE

SignedUrlRemoteEvidenceTransport
      |
      v
EvidenceHttpClient
      |
      v
HTTP real futuro
```

### Regra de desacoplamento

NÃ£o existe motivo tÃ©cnico para criar um adapter Cloudflare R2 no APK quando
o transporte recebe uma signed URL completa e headers opacos.

Cloudflare R2 e Backblaze B2 permanecem detalhes do backend que emite grants.

### Fail-closed

Antes da transferÃªncia, o transporte exige:

1. `RemoteEvidenceUploadRequest` vÃ¡lido;
2. grant vÃ¡lido para `upload`;
3. grant ainda nÃ£o expirado;
4. `Content-Type` explicitamente autorizado;
5. igualdade entre `Content-Type` autorizado e o arquivo local.

Somente HTTP 2xx pode gerar resultado de sincronizaÃ§Ã£o.

`objectKey` vem do grant. `ETag` Ã© metadado opcional e nÃ£o representa
automaticamente SHA-256.
### HomologaÃ§Ã£o R5.4-D

```text
Testes focados R5.4-D:          aprovados
RegressÃ£o Flutter completa:    aprovada
flutter analyze:               0 issues
git diff --check:              aprovado
Escopo final:                  5 caminhos Git
Transporte concreto:           SignedUrlRemoteEvidenceTransport
Grant upload vÃ¡lido:           obrigatÃ³rio
Grant expirado:                rejeitado
OperaÃ§Ã£o incompatÃ­vel:         rejeitada
Content-Type autorizado:       obrigatÃ³rio
HTTP nÃ£o-2xx:                  nÃ£o sincroniza
objectKey:                     somente do grant
ETag = SHA-256:                nÃ£o
Pacote http/Dio:               nÃ£o
HTTP real:                     nÃ£o
Cloudflare R2 real:            nÃ£o
Worker/backend produtivo:      nÃ£o
Credenciais no APK:            nenhuma
```

A homologaÃ§Ã£o confirma que o plano de dados remoto possui agora um adapter
concreto e neutro de provedor, mas ainda totalmente testado com cliente HTTP
fake. Nenhuma dependÃªncia operacional de Cloudflare R2 foi introduzida no APK.
------------------------------------------------------------------------

## AUD-L2-R5.4-E â€” Upload Failure Hardening

**Data:** 21/08/2026
**Baseline:** `7d17cfb5c3f67295ded46cdea4ce5004f99584aa`
**Status:** Homologado localmente

O transporte remoto passa a expor falhas de domÃ­nio tipadas por
`RemoteEvidenceUploadException`.

### Regra de retry

```text
SignedUrlRemoteEvidenceTransport
        |
        | 1 tentativa por chamada
        v
EvidenceHttpClient

NÃƒO existe retry automÃ¡tico no transporte.

Falha potencialmente recuperÃ¡vel
        |
        v
futuro SyncService / orquestrador
        |
        +--> backoff
        +--> conectividade
        +--> renovaÃ§Ã£o de grant
        +--> nova tentativa explÃ­cita
```

A propriedade `retryCandidate` Ã© somente uma classificaÃ§Ã£o para a camada
superior. Ela nÃ£o executa repetiÃ§Ã£o.

### ClassificaÃ§Ã£o

Candidatos a retry externo:

- falha de transporte;
- HTTP 408;
- HTTP 425;
- HTTP 429;
- HTTP 5xx.

NÃ£o candidatos:

- request invÃ¡lido;
- grant invÃ¡lido ou expirado;
- Content-Type ausente/divergente;
- 4xx comuns.

Isso preserva a fronteira fail-closed e impede que o adapter esconda ciclos de
retry ou reutilize grants sem decisÃ£o explÃ­cita da camada de sincronizaÃ§Ã£o.
### HomologaÃ§Ã£o R5.4-E

```text
Testes focados R5.4-E/R1:       aprovados
RegressÃ£o Flutter completa:    aprovada
flutter analyze:               0 issues
git diff --check:              aprovado
Escopo final:                  7 caminhos Git
Erro de upload tipado:         sim
Retry automÃ¡tico transporte:   nÃ£o
Tentativas HTTP por chamada:   1
Retry candidate:
  transportFailure             sim
  HTTP 408                     sim
  HTTP 425                     sim
  HTTP 429                     sim
  HTTP 5xx                     sim
  4xx comum                    nÃ£o
  invalidRequest               nÃ£o
  invalidGrant                 nÃ£o
  missingContentType           nÃ£o
  contentTypeMismatch          nÃ£o
HTTP real:                     nÃ£o
Cloudflare R2 real:            nÃ£o
Worker/backend produtivo:      nÃ£o
Credenciais no APK:            nenhuma
```

A homologaÃ§Ã£o fixa que `SignedUrlRemoteEvidenceTransport` nÃ£o implementa
retry automÃ¡tico. Ele produz uma classificaÃ§Ã£o de falha suficiente para que
a futura camada de sincronizaÃ§Ã£o decida backoff, renovaÃ§Ã£o de grant e nova
tentativa explÃ­cita.

A camada de transporte permanece provider-neutral e nÃ£o recebe responsabilidade
por polÃ­tica operacional de fila ou sincronizaÃ§Ã£o.

------------------------------------------------------------------------

## AUD-L2-R5.4-F â€” Integration Closure

**Data:** 21/08/2026
**Baseline:** `766a83a65de7c84e819dc2fd499f86c9d835d3ff`
**Status:** Homologado localmente

O R5.4-F fecha o bloco de adapter remoto sem adicionar nova responsabilidade de
produÃ§Ã£o.

### Gate integrado A-E

```text
CONTROL PLANE
Flutter
  -> EvidenceAccessBroker
  -> backend confiavel
  -> ACL/autorizacao
  -> EvidenceAccessGrant

DATA PLANE
arquivo local
  + EvidenceAccessGrant
  -> RemoteEvidenceTransport
  -> SignedUrlRemoteEvidenceTransport
  -> EvidenceHttpClient
  -> endpoint HTTPS autorizado
```

Invariantes de fechamento:

- grant vem da fronteira confiavel;
- objectKey vem do grant;
- URI precisa ser HTTPS;
- operacao e expiracao sao verificadas antes do HTTP;
- Content-Type autorizado deve coincidir com o arquivo;
- headers assinados sao opacos;
- existe uma tentativa HTTP por chamada;
- nao-2xx nunca representa sincronizacao concluida;
- ETag nao substitui SHA-256;
- falhas sao tipadas;
- retryCandidate nao executa retry;
- retry/backoff pertence ao futuro R5.5;
- transporte continua neutro de provedor;
- nenhuma credencial permanente existe no APK.

### Gate para R5.5

O R5.5 somente deve assumir orquestracao de sincronizacao.

Nao deve mover para o SyncService:

- assinatura de URL;
- credenciais R2/B2;
- decisao ACL autoritativa;
- fabricacao de objectKey;
- retry interno do adapter.

HTTP real permanece uma decisao separada de infraestrutura.
### HomologaÃ§Ã£o R5.4-F

```text
Teste transversal R5.4-F:      aprovado
RegressÃ£o test/core/storage:   aprovada
flutter analyze:               0 issues
git diff --check:              aprovado
Escopo final:                  4 caminhos Git
CÃ³digo de produÃ§Ã£o alterado:   nÃ£o
HTTP real:                     nÃ£o
Retry automÃ¡tico:              nÃ£o
Credenciais no APK:            nenhuma
```

O R5.4 Ã© considerado tecnicamente fechado.

A fronteira consolidada permanece:

```text
CONTROL PLANE
Flutter
  -> broker
  -> backend confiÃ¡vel
  -> grant

DATA PLANE
arquivo local
  + grant
  -> RemoteEvidenceTransport
  -> SignedUrlRemoteEvidenceTransport
  -> EvidenceHttpClient
  -> endpoint autorizado
```

#### Gate de entrada no R5.5

O R5.5 poderÃ¡ introduzir orquestraÃ§Ã£o de sincronizaÃ§Ã£o, fila, conectividade,
backoff e decisÃ£o de nova tentativa.

Continuam proibidos na camada Flutter:

- assinatura local de URL;
- credenciais permanentes R2/B2;
- ACL autoritativa;
- fabricaÃ§Ã£o arbitrÃ¡ria de `objectKey`;
- retry automÃ¡tico dentro do adapter;
- acoplamento do domÃ­nio ao provedor de storage.

HTTP real e infraestrutura de backend permanecem decisÃµes separadas.

------------------------------------------------------------------------

## AUD-L2-R5.5-A â€” Durable Evidence Sync Queue

**Data:** 21/08/2026
**Baseline:** `b9bfe53640e9417f236e9c9b4ef913e1d79f1e93`
**Status:** Em implementaÃ§Ã£o local

A primeira etapa do R5.5 nao conecta o transporte ao `SyncService`.

Foi identificado que a fila offline de RAEs e persistente, enquanto o estado
rico de evidencias e mantido em memoria pelo `EvidenciaStorageService`.

Para preservar o offline-first, a sincronizacao remota passa a exigir uma fila
duravel propria.

```text
Evidencia local + metadados
        |
        v
EvidenceSyncJob
        |
        v
EvidenceSyncStore
        |
        v
SharedPreferencesEvidenceSyncStore
        |
        +--> sobrevive ao restart
        +--> nao executa rede
        +--> nao conhece R2/B2
```

A fila de evidencia permanece separada da fila de RAE.

R5.5-B podera consumir esta fila por meio de um orquestrador dependente de
`EvidenceAccessBroker` e `RemoteEvidenceTransport`.

### Homologacao R5.5-A

R5.5-A foi homologado localmente com:

- teste focado aprovado;
- regressao `test/core/sync` aprovada;
- `flutter analyze` com 0 issues;
- `git diff --check` aprovado;
- escopo final limitado a 7 caminhos.

A fila persistente de evidencia passa a ser o gate obrigatorio para qualquer
orquestracao remota posterior.

O R5.5-B deve apenas orquestrar estados e dependencias ja definidas, sem mover
autoridade de ACL, assinatura ou credenciais para o cliente Flutter.

------------------------------------------------------------------------

## AUD-L2-R5.5-B â€” Evidence Sync Queue Orchestrator

**Data:** 21/08/2026
**Baseline:** `bd55ba7f8df7d177a4e684c91c322e8ac6c063e0`
**Status:** Implementacao local

R5.5-B introduz uma camada provider-neutral de selecao da fila persistida no
R5.5-A.

```text
EvidenceSyncStore
       |
       v
EvidenceSyncOrchestrator
       |
       +--> valida fila fail-closed
       +--> pending => elegivel
       +--> retryScheduled vencido => elegivel
       +--> synced/blocked => excluido
       +--> ordenacao deterministica
       |
       v
candidato para etapa posterior
```

A selecao nao altera estado e nao executa efeitos remotos.

`autorUserId` continua sendo dado de auditoria, nunca fonte de autorizacao.

Broker, grant, transporte, retry/backoff e conectividade permanecem fora desta
etapa.

### Homologacao R5.5-B

R5.5-B foi homologado localmente com:

- teste focado aprovado;
- regressao `test/core/sync` aprovada;
- `flutter analyze` com 0 issues;
- `git diff --check` aprovado;
- escopo final limitado a 5 caminhos.

A camada de selecao permanece sem side effects e sem rede.

O proximo gate, R5.5-C, podera solicitar grant ao broker confiavel, mantendo:
ACL autoritativa no backend, `objectKey` confiavel no grant e ausencia de
credenciais permanentes no cliente Flutter.

------------------------------------------------------------------------

## AUD-L2-R5.5-C â€” Evidence Grant Acquisition

**Data:** 21/08/2026
**Baseline:** `d92200e9c8ac7f00330253a0fbd3a95d83448f5e`
**Status:** Implementacao local

R5.5-C conecta o plano de orquestracao ao plano de autorizacao, mas ainda nao
ao plano de dados.

```text
EvidenceSyncOrchestrator
        |
        v
EvidenceSyncJob elegivel
        |
        v
EvidenceUploadAccessRequest
        |
        v
EvidenceAccessBroker
        |
        v
EvidenceAccessGrant
        |
        +--> upload
        +--> HTTPS
        +--> expiracao futura
        +--> objectKey autoritativo
        |
        v
EvidenceSyncGrantPreparation
```

O contexto `job + grant` existe apenas em memoria e nao altera a fila.

A autorizacao continua pertencendo ao backend. O cliente somente valida se o
grant recebido e utilizavel para a operacao esperada.

Nenhum transporte HTTP e executado no R5.5-C.

### Homologacao R5.5-C

R5.5-C foi homologado localmente com:

- teste focado aprovado;
- regressao `test/core/sync` aprovada;
- `flutter analyze` com 0 issues;
- `git diff --check` aprovado;
- escopo final limitado a 5 caminhos.

A etapa confirma a separacao entre:

1. selecao do candidato;
2. solicitacao do grant;
3. validacao local do grant;
4. futura transferencia de dados.

O grant permanece efemero e somente em memoria.

Nenhuma autoridade de ACL, assinatura, `objectKey` ou credencial permanente foi
movida para o cliente Flutter.

O proximo gate, R5.5-D, fica restrito ao consumo do contexto `job + grant` para
uma unica tentativa de transporte, sem retry automatico.

------------------------------------------------------------------------

## AUD-L2-R5.5-D â€” Evidence Upload + Persisted Confirmation

**Data:** 24/08/2026
**Baseline:** `6ea5aaae6cf46734ae559af91448a4b6f2e71936`
**Status:** Implementacao local

R5.5-D fecha a primeira passagem controlada pelo plano de dados:

```text
EvidenceSyncGrantPreparation
          |
          v
RemoteEvidenceUploadRequest
          |
          v
RemoteEvidenceTransport.upload()   [1 tentativa]
          |
          v
RemoteEvidenceUploadResult
          |
          +--> objectKey == grant.objectKey
          +--> sizeBytes coerente, quando informado
          |
          v
releitura EvidenceSyncStore
          |
          +--> snapshot inalterado?
          |
          v
status = synced
objectKey = confirmado
syncedAt = confirmado
attemptCount += 1
lastAttemptAt = inicio da tentativa
```

O transporte continua sem autoridade de ACL e sem poder fabricar grant.

A fila somente registra sucesso depois da confirmacao remota.

### Janela remoto -> persistencia

O upload remoto e a gravacao local nao formam uma transacao atomica.

Portanto, falha de persistencia depois de sucesso remoto pode deixar o job
localmente pendente. A estrategia de retry/reconciliacao deve reutilizar o
mesmo `objectKey` confiavel e o mesmo snapshot SHA, evitando criar objetos
alternativos para a mesma evidencia.

R5.5-E sera responsavel pela politica de retry/backoff/conectividade; R5.5-F
devera fechar as invariantes de idempotencia e reconciliacao.

### Homologacao R5.5-D

R5.5-D foi homologado localmente com:

- teste focado aprovado;
- regressao `test/core/sync` aprovada;
- `flutter analyze` com 0 issues;
- `git diff --check` aprovado;
- escopo final limitado a 5 caminhos.

A confirmacao persistida de sucesso agora exige simultaneamente:

1. transporte habilitado;
2. grant valido para upload;
3. request local valido;
4. uma tentativa concluida pelo transporte;
5. `objectKey` do resultado igual ao grant confiavel;
6. `sizeBytes` coerente, quando presente;
7. snapshot persistido ainda igual ao que originou o upload.

Somente depois dessas verificacoes o job passa a `synced`.

A janela entre efeito remoto e persistencia local permanece explicitamente nao
atomica e devera ser absorvida pela politica de reconciliacao/idempotencia do
R5.5-E/F.

------------------------------------------------------------------------

## AUD-L2-R5.5-E â€” Retry, Backoff, Connectivity e Reconciliacao

**Data:** 24/08/2026
**Baseline:** `57767c55d16e9dd8a02945d60df3c320f83e3e78`
**Status:** Implementacao local

R5.5-E torna explicita a camada dona da politica de tentativa.

```text
EvidenceSyncConnectivityProbe
          |
          +-- sem rede --> nao conta tentativa
          |
          v
EvidenceSyncGrantCoordinator
          |
          v
grant + job
          |
          +-- reconciliationObjectKey != grant.objectKey --> BLOCKED
          |
          v
EvidenceSyncUploadCoordinator
          |
          +-- sucesso --> SYNCED
          |
          +-- retryable --> RETRY_SCHEDULED
          |
          +-- nao retryable --> BLOCKED
          |
          +-- persistencia local falhou apos efeito remoto
                         |
                         v
                  RETRY_SCHEDULED
                  mesma chave remota
```

### Identidade de reconciliacao

`EvidenceSyncJob.reconciliationObjectKey` e uma chave temporaria de seguranca.

Ela pode existir em `retryScheduled` ou `blocked`, mas nunca substitui
`objectKey`. O `objectKey` final continua permitido apenas em `synced`.

A chave de reconciliacao deve ter origem no grant confiavel.

### Backoff

A politica inicial e exponencial, deterministica e limitada:

30 s -> 60 s -> 120 s -> ... -> teto de 30 min.

O limite padrao e 6 tentativas.

### Regra de idempotencia

Quando uma tentativa anterior pode ter produzido efeito remoto, a proxima
tentativa somente pode enviar se o novo grant preservar exatamente o mesmo
`objectKey`.

O snapshot SHA continua fazendo parte da solicitacao ao broker.

Isso transforma a repeticao em reconciliacao sobre a mesma identidade remota,
nao em criacao de uma nova evidencia.

### Concorrencia

R5.5-E nao introduz claim/lock distribuido.

A protecao de R5.5-D contra overwrite de snapshot alterado continua ativa.
Paralelismo real de workers permanece fora do escopo.

### Homologacao R5.5-E

R5.5-E foi homologado localmente apos dois ajustes de validacao:

- R1 removeu `const` de `EvidenceSyncRetryPolicy`, preservando os asserts em
  runtime;
- R2 alinhou a regressao do R5.5-D ao novo contrato
  `EvidenceSyncConfirmationException`.

Gates finais:

- teste legado R5.5-D: aprovado;
- teste focado R5.5-E: aprovado;
- regressao `test/core/sync`: aprovada;
- `flutter analyze`: 0 issues;
- `git diff --check`: aprovado;
- escopo final: 11 caminhos.

A arquitetura consolidada mantem quatro fronteiras:

1. conectividade funciona apenas como gate antecipado;
2. transporte executa exatamente uma tentativa;
3. politica de retry/backoff pertence ao coordenador de resiliencia;
4. reconciliacao exige estabilidade da identidade remota confiavel.

`reconciliationObjectKey` nao equivale a sucesso. O campo registra apenas a
identidade remota que deve permanecer estavel quando uma tentativa anterior
pode ter causado efeito remoto sem confirmacao local duravel.

O `objectKey` definitivo continua exclusivo de jobs em `synced`.

Riscos ainda abertos:

- ausencia de transacao atomica remoto/local;
- ausencia de claim/lock distribuido;
- ausencia de jitter;
- ausencia de backend remoto real;
- dependencia futura de semantica idempotente para PUT na mesma chave e mesmo
  snapshot SHA.

## AUD-L2-R5.5-F â€” Idempotencia e fechamento de integracao

R5.5-F introduz `EvidenceUploadIdentity`, composta por `acaoId`, `evidenciaId`
e `sha256`.

Requests de upload possuem uma chave logica deterministica de idempotencia,
mas o cliente continua proibido de fabricar `objectKey`.

Grants usados pelo sync devem ecoar a identidade solicitada. O Grant
Coordinator falha fechado quando o binding estiver ausente ou divergente.

O backend futuro fica obrigado a preservar a mesma `objectKey` para a mesma
identidade canonica, inclusive em renovacoes de grant. Essa regra cobre a janela
em que houve efeito remoto e a persistencia local da reconciliacao tambem
falhou.

`remoteStorageEnabled=true` permanece bloqueado ate o backend real provar esse
contrato.

O Retry Coordinator passa a operar em single-flight por instancia. Isso evita
dois ciclos concorrentes no mesmo processo, sem pretender ser lock distribuido.

### Homologacao R5.5-F

R5.5-F foi homologado localmente com foco em tres garantias:

1. identidade canonica de upload;
2. binding do grant ao snapshot;
3. single-flight local.

A identidade canonica e:

`acaoId + evidenciaId + sha256`

A `idempotencyKey` derivada e apenas um identificador logico deterministico.
Ela nao substitui a `objectKey`, nao autoriza acesso e nao contem credenciais.

O Grant Coordinator exige que o grant de upload ecoe a identidade solicitada.
Ausencia ou divergencia do binding causa falha fechada antes do transporte.

O backend futuro devera preservar a mesma `objectKey` para a mesma identidade
canonica. Essa regra e obrigatoria inclusive quando a tentativa anterior pode
ter produzido efeito remoto sem confirmacao local duravel.

O Retry Coordinator agora opera em single-flight por instancia, impedindo duas
execucoes simultaneas no mesmo processo.

`remoteStorageEnabled=true` permanece bloqueado ate a prova server-side de:

`acaoId + evidenciaId + sha256 -> mesma objectKey`

e de PUT idempotente para o mesmo snapshot.

## AUD-L2-R5.6-A â€” Preparation Contract

### Fronteira de preparacao

A preparacao de evidencias passa a possuir uma fronteira arquitetural explicita
entre o original local e os bytes destinados ao upload.

O original permanece preservado como evidencia operacional/auditavel. Qualquer
transformacao deve produzir um artefato derivado em caminho separado.

### Ordem obrigatoria do snapshot remoto

`original -> prepare -> freeze prepared bytes -> metadata -> identity -> queue`

O SHA-256 usado por `EvidenceUploadIdentity` deve representar exatamente os
bytes preparados que serao enviados. Calcular o hash antes de compressao,
resize, conversao ou normalizacao e proibido.

### Guard fail-closed

`EvidencePreparationGuard` rejeita:

- request incompleto;
- artifact incompleto;
- artifact associado a outro original;
- artifact que reutiliza o mesmo caminho do original.

### Limites

R5.6-A nao adiciona biblioteca concreta de compressao, nao altera o
`EvidenciaStorageService`, nao integra a fila e nao habilita storage remoto.

`remoteStorageEnabled=true` continua bloqueado.
------------------------------------------------------------------------

## AUD-L2-R5.6-C - Pipeline Integration & Artifact Lifecycle

**Data:** 28/08/2026
**Baseline:** `66e51c788d7ca40b0fe7b306521c1df13fdbab84`
**Status:** Homologado localmente - pre-commit

R5.6-C conecta a preparacao deterministica ao snapshot duravel de
sincronizacao sem alterar a evidencia original.

```text
EvidenciaModel / original
          |
          v
EvidencePreparer
          |
          v
prepared JPEG imutavel
          |
          v
EvidenceMetadataCalculator
          |
          v
EvidenceSyncJob
          |
          v
EvidenceSyncStore
          |
          v
R5.5
          |
          v
synced duravel
          |
          v
EvidencePreparedArtifactLifecycle
```

### Separacao de identidades locais

O `EvidenciaModel` continua representando o original operacional/auditavel.

O `EvidenceSyncJob` representa o snapshot exato dos bytes de transporte:

- `localFilePath` = artefato preparado;
- `contentType` = MIME preparado;
- `tamanhoBytes` = bytes preparados;
- `sha256` = hash dos bytes preparados.

E proibido misturar caminho do original com hash/tamanho/MIME do derivado.

### Enrollment

`EvidenceUploadEnrollmentCoordinator` executa:

`prepare -> metadata -> job -> durable store`

antes de qualquer grant ou upload.

Re-enrollment identico preserva o estado duravel existente. Snapshot divergente
para a mesma identidade falha fechado e nao sobrescreve a fila.

### Path resolver

`ApplicationDocumentsEvidencePreparedPathResolver` usa raiz dedicada:

`GEDUC/evidence_upload_artifacts/{acaoId}/{evidenciaId}/evidence-photo-jpeg-v1.jpg`

O caminho e deterministico e identificadores inseguros sao rejeitados.

### Lifecycle

`EvidencePreparedArtifactLifecycle` so remove arquivos `.jpg` contidos na raiz
dedicada de artefatos preparados.

O original em `GEDUC/evidencias/...` nao e elegivel para cleanup.

`EvidenceSyncPipelineCoordinator` solicita cleanup somente depois de resultado
`EvidenceSyncCycleStatus.synced` acompanhado de job em
`EvidenceSyncJobStatus.synced`.

Falha de cleanup e reportada separadamente e nunca converte um upload
confirmado em nova tentativa.

### Limites

- `EvidenceSyncOrchestrator`, Grant Coordinator, Upload Coordinator e Retry
  Coordinator permanecem com suas responsabilidades R5.5;
- `SyncService` de RAE nao absorve a fila de evidencias;
- nenhuma composicao produtiva na UI e ativada nesta etapa;
- `remoteStorageEnabled` permanece `false`;
- nenhum Worker, R2, B2, Firebase Storage ou segredo entra no cliente;
- R5.7 permanece separado.

### Homologacao pre-commit

- testes focais R5.6-C: aprovados;
- regressao `test/core/storage`: aprovada;
- regressao `test/core/sync`: aprovada;
- `flutter test` completo: aprovado;
- `flutter analyze`: 0 issues;
- `git diff --check`: aprovado;
- escopo Git: exatamente 11 caminhos;
- R1A corrigiu exclusivamente sincronizacao de teste async;
- codigo de producao permaneceu inalterado no R1A.

<!-- AUD-L2-R5.7-BEGIN -->
## AUD-L2-R5.7 - Homologacao integrada do subsistema de evidencias

Status: HOMOLOGADO TECNICAMENTE / PRE-COMMIT.

Baseline de abertura: `c151d3934c47809f0a788192e365f5e5b3467a89`.

O R5.7 fecha a validacao transversal dos contratos de evidencias introduzidos
nas etapas R5.4, R5.5 e R5.6 sem alterar codigo de producao.

A composicao homologada em teste e:

```text
original local auditavel
        |
        v
DeterministicImageEvidencePreparer
        |
        v
artefato JPEG preparado
        |
        v
EvidenceUploadEnrollmentCoordinator
        |
        v
SharedPreferencesEvidenceSyncStore
        |
        v
EvidenceSyncOrchestrator
        |
        v
EvidenceSyncGrantCoordinator
        |
        v
EvidenceSyncRetryCoordinator
        |
        +--> EvidenceSyncUploadCoordinator
        |          |
        |          v
        |    RemoteEvidenceTransport
        |
        v
EvidenceSyncPipelineCoordinator
        |
        v
cleanup somente apos synced duravel
```

A homologacao integrada prova happy path, persistencia duravel,
retry/reconciliation, identidade/idempotencia, bloqueio fail-closed,
confirmacao concorrente e protecao do original.

Somente conectividade, broker, transporte remoto e relogio sao controlados
como doubles de teste. Os componentes do pipeline de producao sao exercitados
diretamente.

Invariantes arquiteturais preservadas:

- original local continua obrigatorio e auditavel;
- artefato preparado e separado do original;
- snapshot de upload usa SHA-256/tamanho/MIME dos bytes preparados;
- retry preserva o preparado;
- cleanup so ocorre depois de `synced` duravel;
- lifecycle nao pode remover o original;
- `remoteStorageEnabled` permanece `false`;
- nenhuma credencial permanente de storage entra no cliente;
- nenhuma integracao R2/B2/Firebase Storage foi ativada;
- zero arquivos de producao foram alterados pelo R5.7.

Gates finais homologados: testes integrados R5.7, regressao storage,
regressao sync, `flutter test` completo, `flutter analyze` com 0 issues,
`git diff --check` e validacao exata de escopo.
<!-- AUD-L2-R5.7-END -->

<!-- SEC-R2-002A-EVIDENCE-WORKER -->
## SEC-R2-002A â€” Evidence Worker Backend R2

Foi introduzida a fronteira backend/evidence-worker para evoluÃ§Ã£o
controlada do armazenamento remoto de evidÃªncias.

A fronteira inclui contrato HTTP, validaÃ§Ã£o de evidÃªncias, ACL,
autenticaÃ§Ã£o do caller e capability HMAC-SHA256 com identidade,
autoria, escopo e expiraÃ§Ã£o vinculados.

A implementaÃ§Ã£o nÃ£o ativa publicaÃ§Ã£o produtiva e nÃ£o altera a
invariante remoteStorageEnabled=false no cliente Flutter.

<!-- SEC-R2-002A-A6B-GRANT -->
### SEC-R2-002A.6B - Emissao do upload grant

A fronteira de controle do Evidence Worker passa a emitir um grant de upload
somente depois de quatro validacoes server-side:

1. Firebase ID Token do caller;
2. contrato fechado da requisicao;
3. ACL autoritativa sobre o RAE;
4. vinculo autoritativo de `autorUserId`.

O caller autenticado e o autor da evidencia permanecem identidades distintas.
O backend nao presume igualdade entre elas e falha fechado quando a fonte de
vinculo do autor nega ou fica indisponivel.

O grant retornado e compativel com `EvidenceAccessGrant` e contem URI HTTPS,
operacao de upload, expiracao UTC, `objectKey`, headers obrigatorios e
`uploadIdentity`. A `objectKey` e a chave de idempotencia sao derivadas no
backend.

A capability HMAC-SHA256 vincula caller, autor, RAE, evidencia, MIME, tamanho,
SHA-256, objectKey, emissao e expiracao. O TTL nunca ultrapassa 300 segundos.

Fronteiras preservadas:

- o endpoint PUT permanece fail-closed;
- os bytes ainda nao sao recebidos ou validados;
- nenhum R2 Binding, bucket, secret ou deploy e criado;
- `remoteStorageEnabled=false` permanece obrigatorio.
<!-- SEC-R2-002A-A6B-GRANT-END -->

<!-- SEC-R2-002A-A6C-PUT-VALIDATION -->
### SEC-R2-002A.6C - Validacao do PUT e dos bytes

O plano de dados do Evidence Worker passa a validar a capability e o corpo real
antes de qualquer porta de persistencia.

Fluxo arquitetural homologado:

```text
PUT + capability HMAC
        |
        v
validacao temporal e canonica
        |
        v
headers + objectKey + idempotencia
        |
        v
stream limitado a 10 MiB
        |
        v
assinatura JPEG + SHA-256 real
        |
        v
501 fail-closed sem persistencia
```

Invariantes:

- `callerUid` e `autorUserId` permanecem identidades distintas;
- TTL da capability nunca ultrapassa 300 segundos;
- capabilities futuras ou expiradas sao rejeitadas;
- `objectKey` e idempotencia sao recalculadas no backend;
- tamanho e hash representam exatamente os bytes recebidos;
- corpos parciais, codificados ou acima do limite sao rejeitados;
- nenhum R2 Binding, bucket, secret ou deploy foi introduzido;
- `remoteStorageEnabled=false` permanece obrigatorio.

A validacao bem sucedida nao constitui autorizacao de armazenamento. A porta
privada de persistencia e o contrato de idempotencia contra R2 pertencem a
SEC-R2-002A.6D.
<!-- SEC-R2-002A-A6C-PUT-VALIDATION-END -->

<!-- SEC-R2-002A-A6D-IDEMPOTENCY-PORT -->
### SEC-R2-002A.6D - Idempotencia e porta privada de persistencia

Depois da validacao integral da capability e dos bytes, o Worker usa uma
fronteira provider-neutral antes de qualquer armazenamento produtivo.

Fluxo arquitetural homologado:

```text
ValidatedEvidenceUpload
        |
        v
AtomicEvidenceUploadPersister
        |
        v
EvidencePrivateStoragePort.createIfAbsent
        |
        +--> created: HTTP 201
        +--> identidade igual: HTTP 200
        +--> identidade divergente: HTTP 409
        +--> porta ausente/falha: HTTP 503
```

Invariantes:

- a unica operacao de escrita admitida e `createIfAbsent`;
- nao existe sequencia vulneravel `HEAD` seguida de `PUT`;
- `objectKey`, RAE, evidencia, autor, MIME, tamanho, SHA-256 e idempotencia
  formam a identidade imutavel do objeto;
- `callerUid` permanece separado de `autorUserId` para auditoria;
- repeticao integralmente identica nao regrava o objeto;
- qualquer divergencia impede sobrescrita silenciosa;
- respostas nao expoem URL, credencial ou detalhe interno do storage;
- o default produtivo nao instala adapter e responde `503` fail-closed;
- nenhum R2 Binding, bucket, secret ou deploy foi introduzido;
- `remoteStorageEnabled=false` permanece obrigatorio.

A implementacao de um adapter Cloudflare R2 e o wiring produtivo pertencem a
uma fronteira posterior e exigem autorizacao especifica.
<!-- SEC-R2-002A-A6D-IDEMPOTENCY-PORT-END -->

<!-- SEC-R2-002A-A6E-HOMOLOGADO-START -->
## SEC-R2-002A.6E - Adapter Cloudflare R2 homologado

A camada de evidencias passa a possuir adapter Cloudflare R2 implementado, mas nao ativado produtivamente.

Garantias preservadas:
- PUT condicional create-if-absent via etagDoesNotMatch "*";
- HEAD somente apos falha da precondicao;
- SHA-256 e metadados canonicos enviados ao objeto;
- idempotencia integral;
- caller e autor permanecem distintos;
- divergencia de identidade resulta em conflito sem sobrescrita;
- wiring por injecao de EVIDENCE_BUCKET;
- ausencia de binding retorna 503 fail-closed;
- wrangler.jsonc continua sem r2_buckets;
- remoteStorageEnabled=false;
- nenhum bucket, binding, secret ou deploy foi criado nesta etapa.

Status: HOMOLOGADO LOCALMENTE / FECHAMENTO CONTROLADO.
<!-- SEC-R2-002A-A6E-HOMOLOGADO-END -->

<!-- SEC-R2-002A-A6F-HOMOLOGADO-START -->
## SEC-R2-002A.6F - Infraestrutura R2 preparada para ativacao controlada

A camada de evidencias passa a possuir configuracao versionada de R2 Binding,
sem habilitar ainda o fluxo produtivo.

Garantias:

- binding `EVIDENCE_BUCKET`;
- bucket planejado `fenix-evidence-private-prod`;
- `remoteStorageBound` diferencia binding presente de feature habilitada;
- `remoteStorageEnabled=false`;
- validator, autenticacao e grant defaults permanecem fail-closed;
- nenhuma configuracao `r2.dev`, custom domain ou CORS;
- nenhuma Access Key/Secret Key R2 adicionada ao Worker ou Flutter;
- aplicacao e testes realizados em worktree isolado;
- bucket real e deploy permanecem fora do fechamento de codigo.

Status: HOMOLOGADO LOCALMENTE / PUBLICACAO DE CODIGO CONTROLADA.
<!-- SEC-R2-002A-A6F-HOMOLOGADO-END -->

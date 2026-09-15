# ENGINEERING LOG

> DiÃ¡rio Oficial de Engenharia da Plataforma FÃªnix> Sistema de Conhecimento da Plataforma FÃªnix (SKPF)

------------------------------------------------------------------------

## Controle do Documento

  Item        Valor
  ----------- ----------------------------------------
  Documento   06_ENGINEERING_LOG.md
  VersÃ£o      2.7
  Status      Oficial
  Sprint      SEC-001B-R1 â€” Quality Gates e ProteÃ§Ã£o da Main

------------------------------------------------------------------------

# 1. Finalidade

O Engineering Log Ã© o registro cronolÃ³gico oficial da evoluÃ§Ã£o tÃ©cnica
da Plataforma FÃªnix.

Seu objetivo Ã© preservar o histÃ³rico de decisÃµes, implementaÃ§Ãµes,
auditorias e homologaÃ§Ãµes, permitindo compreender como e por que a
plataforma evoluiu.

------------------------------------------------------------------------

# 2. O que deve ser registrado

Cada entrada deverÃ¡ registrar, sempre que aplicÃ¡vel:

-   Data;
-   Sprint;
-   Pacote ou Commit;
-   Tipo;
-   Objetivo;
-   Causa raiz;
-   DecisÃ£o arquitetural;
-   Arquivos impactados;
-   Resultado do `flutter analyze`;
-   HomologaÃ§Ã£o funcional;
-   HAT-1 e HAT-2;
-   Commit e push;
-   PrÃ³ximos passos;
-   ReferÃªncias para ADRs, Blueprints e Auditorias.

------------------------------------------------------------------------

# 3. Modelo Oficial de Registro

``` text
Data:
Sprint:
Pacote:
Commit:
Branch:
Tipo:
Resumo:

Erro observado:
Causa raiz:
DecisÃ£o arquitetural:

Arquivos alterados:

ValidaÃ§Ã£o:
- flutter analyze
- testes
- homologaÃ§Ã£o funcional
- HAT-1
- HAT-2

Documentos relacionados:

PrÃ³xima aÃ§Ã£o:
```

------------------------------------------------------------------------

# 4. Marcos Arquiteturais

Os seguintes eventos devem receber destaque:

-   criaÃ§Ã£o de novos mÃ³dulos;
-   alteraÃ§Ãµes de arquitetura;
-   integraÃ§Ã£o de serviÃ§os;
-   mudanÃ§as de modelo de dados;
-   criaÃ§Ã£o de componentes estratÃ©gicos;
-   mudanÃ§as de escopo de providers;
-   homologaÃ§Ãµes de sprints;
-   validaÃ§Ã£o ou evoluÃ§Ã£o da metodologia de engenharia.

------------------------------------------------------------------------

# 5. RelaÃ§Ã£o com o Git

O Engineering Log complementa o histÃ³rico do Git.

Enquanto o Git registra alteraÃ§Ãµes de cÃ³digo, este documento registra o
contexto tÃ©cnico e arquitetural dessas alteraÃ§Ãµes.

------------------------------------------------------------------------

# 6. RelaÃ§Ã£o com o SKPF

Sempre que uma decisÃ£o estrutural ocorrer, deverÃ£o ser atualizados:

-   Engineering Log;
-   Documento de Arquitetura;
-   ADR correspondente, quando existir;
-   Blueprint, quando aplicÃ¡vel;
-   Guia de Desenvolvimento, quando houver mudanÃ§a metodolÃ³gica.

------------------------------------------------------------------------

# 7. Registros CronolÃ³gicos

## 7.1 Sprint Arquitetural 1.0

### AE-001.1B

-   HomologaÃ§Ã£o do Portal Oficial do SKPF.

### AE-001.1A

-   HomologaÃ§Ã£o da Carta de Engenharia.

### AE-001.2

-   HomologaÃ§Ã£o da Arquitetura Oficial da Plataforma.

------------------------------------------------------------------------

## 7.2 EST-005A â€” Auditoria da Infraestrutura de Providers

**Data:** 30/07/2026
**Branch:** `release/estabilizacao-pv006`
**Tipo:** Auditoria arquitetural e diagnÃ³stico de causa raiz
**Pacotes:** `EST-005A-INFRA-PROVIDERS` e
`EST-005A-INFRA-PROVIDERS-R1`

### Resumo

A auditoria foi iniciada apÃ³s a ocorrÃªncia de
`ProviderNotFoundException` na tela `AvaliacaoPage`.

Foram inspecionados:

1. Ã¡rvore de providers;
2. Ã¡rvore de rotas;
3. dependÃªncias do `DomainProvider`;
4. pontos de criaÃ§Ã£o, consumo e descarte;
5. construtor e dependÃªncias internas do provider.

### Erro observado

`AvaliacaoPage` nÃ£o localizava uma instÃ¢ncia de `DomainProvider` em sua
Ã¡rvore de contexto.

### Causa raiz

O `DomainProvider` era criado localmente em
`CaracterizacaoAcaoPage`, registrado por
`ChangeNotifierProvider.value` apenas sobre essa pÃ¡gina e descartado no
ciclo de vida local.

Como `AvaliacaoPage` Ã© aberta por rota independente, ela ficava fora do
escopo do provider.

### Por que a arquitetura permitiu o erro

O alcance real da dependÃªncia nÃ£o havia sido refletido no escopo de
injeÃ§Ã£o. Um estado transversal foi tratado como estado local de pÃ¡gina.

### DecisÃ£o da HAT-1

Promover o `DomainProvider` para o `MultiProvider` global em
`lib/app.dart` e remover sua criaÃ§Ã£o e descarte locais da pÃ¡gina de
CaracterizaÃ§Ã£o.

**HAT-1:** aprovada.

------------------------------------------------------------------------

## 7.3 EST-005B â€” GlobalizaÃ§Ã£o do DomainProvider

**Data:** 30/07/2026
**Branch:** `release/estabilizacao-pv006`
**Pacote:** `EST-005B-GLOBAL-DOMAINPROVIDER-HOMOLOGADO`
**Commit:** `35d41f6`
**Tipo:** CorreÃ§Ã£o arquitetural e estabilizaÃ§Ã£o funcional

### Objetivo

Eliminar definitivamente o `ProviderNotFoundException` em
`AvaliacaoPage`, garantindo que o `DomainProvider` esteja disponÃ­vel
para todas as rotas consumidoras.

### ImplementaÃ§Ã£o

-   Registro de `DomainProvider` no `MultiProvider` global de
    `lib/app.dart`.
-   RemoÃ§Ã£o da criaÃ§Ã£o local do provider em
    `CaracterizacaoAcaoPage`.
-   RemoÃ§Ã£o do descarte manual da instÃ¢ncia local.
-   Consumo da instÃ¢ncia global pelas pÃ¡ginas e widgets.
-   PreservaÃ§Ã£o da cadeia:
    `DomainProvider â†’ DomainRepository â†’ DomainService`.

### Arquivos alterados

-   `lib/app.dart`;
-   `lib/modules/acoes/caracterizacao_acao_page.dart`;
-   `lib/modules/avaliacao/avaliacao_page.dart`;
-   `tools/manifestos/EST-005A-INFRA-PROVIDERS.txt`;
-   `tools/manifestos/EST-005A-INFRA-PROVIDERS-R1.txt`;
-   `tools/manifestos/EST-005B-GLOBAL-DOMAINPROVIDER-HOMOLOGADO.txt`.

### ValidaÃ§Ã£o tÃ©cnica

-   Manifesto CPB localizado e processado.
-   10 arquivos incluÃ­dos.
-   0 arquivos ausentes.
-   `flutter analyze`: **No issues found!**
-   HAT-1: aprovada.
-   HAT-2: aprovada.

### HomologaÃ§Ã£o funcional

Foram aprovados os seis cenÃ¡rios funcionais previstos:

-   HF-005B.1;
-   HF-005B.2;
-   HF-005B.3;
-   HF-005B.4;
-   HF-005B.5;
-   HF-005B.6.

O erro visual vermelho deixou de ocorrer e o fluxo de AvaliaÃ§Ã£o passou a
acessar corretamente os domÃ­nios compartilhados.

### Git

``` text
Commit: 35d41f6
Mensagem:
refactor(domains): globaliza DomainProvider e estabiliza fluxo da AvaliaÃ§Ã£o (EST-005B)

Push:
edbd57f..35d41f6
release/estabilizacao-pv006 -> origin/release/estabilizacao-pv006
```

### Resultado

A causa raiz foi eliminada. O provider agora possui escopo compatÃ­vel
com seu uso transversal e permanece disponÃ­vel acima das rotas
independentes.

A EST-005B foi a primeira sprint concluÃ­da integralmente com:

-   inspeÃ§Ã£o arquitetural prÃ©via;
-   princÃ­pio Root Cause First;
-   HAT-1;
-   implementaÃ§Ã£o;
-   homologaÃ§Ã£o funcional estruturada;
-   CPB auditÃ¡vel;
-   HAT-2;
-   commit;
-   push.

### PrÃ³xima aÃ§Ã£o

Executar a EST-005D para sincronizar a arquitetura oficial, o Engineering
Log e o Blueprint da integraÃ§Ã£o de domÃ­nios com a implementaÃ§Ã£o
homologada.

------------------------------------------------------------------------

## 7.4 EST-005D â€” ConsolidaÃ§Ã£o Arquitetural e Documental

**Data:** 30/07/2026
**Branch:** `release/estabilizacao-pv006`
**Tipo:** DocumentaÃ§Ã£o tÃ©cnica

### Objetivo

Atualizar os documentos oficiais apÃ³s a globalizaÃ§Ã£o do
`DomainProvider`.

### Documentos da entrega

-   `docs/01_PLATFORM_ARCHITECTURE.md`;
-   `docs/06_ENGINEERING_LOG.md`;
-   `docs/SKPF/BP-ISSUE-002A.2_INTEGRACAO_DOMAIN_SERVICE.md`.

### Estado

Arquivos completos preparados para substituiÃ§Ã£o direta.

### CritÃ©rios de encerramento

-   revisÃ£o dos arquivos pelo responsÃ¡vel do projeto;
-   inspeÃ§Ã£o do `git diff`;
-   geraÃ§Ã£o do CPB documental;
-   HAT-2 documental;
-   commit e push;
-   working tree clean.

------------------------------------------------------------------------

# 8. Compromisso

Nenhuma alteraÃ§Ã£o estrutural relevante deverÃ¡ permanecer sem registro
neste documento.

------------------------------------------------------------------------


------------------------------------------------------------------------

## 7.5 ADM-001B.1 â€” FundaÃ§Ã£o Administrativa

**Data:** 31/07/2026
**Branch:** `feature/adm-001b1-fundacao-administrativa`
**Commit:** `6049e7d`
**Tipo:** FundaÃ§Ã£o arquitetural administrativa

### Objetivo

Substituir menus administrativos concorrentes por uma fundaÃ§Ã£o modular,
centralizada e preparada para evoluÃ§Ã£o.

### ImplementaÃ§Ã£o

- catÃ¡logo central de mÃ³dulos;
- modelo `AdminModule`;
- estados de disponibilidade;
- permissÃ£o preliminar;
- cartÃ£o administrativo reutilizÃ¡vel;
- rotas administrativas centralizadas;
- pÃ¡gina administrativa responsiva.

### ValidaÃ§Ã£o

- `flutter analyze`: **No issues found!**
- homologaÃ§Ã£o funcional: **13/13 cenÃ¡rios aprovados**;
- Central de DomÃ­nios: aprovada;
- seis mÃ³dulos: aprovados;
- responsividade: aprovada;
- navegaÃ§Ã£o e botÃ£o Voltar: aprovados.

### Resultado

A AdministraÃ§Ã£o deixou de depender de listas literais mantidas
diretamente na pÃ¡gina e passou a possuir catÃ¡logo prÃ³prio.

------------------------------------------------------------------------

## 7.6 ADM-001B.2 â€” Camada de AutorizaÃ§Ã£o Administrativa

**Data:** 31/07/2026
**Branch:** `feature/adm-001b2-autorizacao-administrativa`
**Commit:** `ff32e74`
**Tipo:** SeguranÃ§a, autorizaÃ§Ã£o e proteÃ§Ã£o de rotas

### Objetivo

Centralizar decisÃµes de autorizaÃ§Ã£o por perfil e proteger as rotas
administrativas independentemente da visibilidade dos botÃµes.

### ImplementaÃ§Ã£o

- `Permission`;
- `AuthorizationPolicy`;
- `AuthorizationResult`;
- `AuthorizationService`;
- `RouteGuard`;
- `AccessDeniedPage`;
- filtragem dos mÃ³dulos administrativos;
- integraÃ§Ã£o com o roteador;
- correÃ§Ã£o da visibilidade da AdministraÃ§Ã£o para o perfil gestor.

### Matriz homologada

| Perfil | Resultado |
|---|---|
| Administrador | Acesso total |
| Gestor | DomÃ­nios, UsuÃ¡rios e Tipos de AÃ§Ãµes |
| Coordenador | AdministraÃ§Ã£o oculta e rota bloqueada |
| Agente | AdministraÃ§Ã£o oculta e rota bloqueada |

### ValidaÃ§Ã£o tÃ©cnica

- `flutter analyze`: **No issues found!**
- CPB homologado: 17 arquivos;
- arquivos ausentes: 0;
- `git diff --cached --check`: sem erros.

### HomologaÃ§Ã£o funcional

- Android/tablet: aprovada para os quatro perfis;
- Central de DomÃ­nios: sem regressÃ£o;
- navegaÃ§Ã£o: aprovada;
- tela vermelha: nÃ£o identificada;
- travamentos: nÃ£o identificados.

### HomologaÃ§Ã£o Web

O perfil `agente` tentou acessar diretamente uma rota administrativa no
Flutter Web e foi redirecionado para `Acesso nÃ£o autorizado`.

A tela apresentou corretamente:

- perfil identificado;
- mensagem de bloqueio;
- retorno ao Centro de OperaÃ§Ãµes;
- ausÃªncia de exceÃ§Ãµes no Console.

### Resultado

A interface deixou de ser a Ãºnica barreira de acesso. A Plataforma
FÃªnix passou a possuir proteÃ§Ã£o tambÃ©m na camada de navegaÃ§Ã£o.

------------------------------------------------------------------------

## 7.7 Pull Request nÂº 1 â€” Primeira Code Review Arquitetural

**Data:** 31/07/2026
**Base:** `main`
**Head:** `feature/adm-001b2-autorizacao-administrativa`
**Merge:** `08f969d`

### ConteÃºdo

O Pull Request integrou:

- ADM-001B.1 â€” FundaÃ§Ã£o Administrativa;
- ADM-001B.2 â€” Camada de AutorizaÃ§Ã£o Administrativa.

### RevisÃ£o

Foram avaliados:

- arquitetura;
- seguranÃ§a;
- navegaÃ§Ã£o;
- regressÃµes;
- qualidade;
- documentaÃ§Ã£o;
- homologaÃ§Ãµes;
- rastreabilidade Git.

### Parecer

``` text
Arquitetura: aprovada
SeguranÃ§a: aprovada
NavegaÃ§Ã£o: aprovada
Qualidade: aprovada
HomologaÃ§Ã£o: aprovada
Resultado: aprovado para merge
```

### PÃ³s-merge

- `main` sincronizada com `origin/main`;
- `flutter analyze`: **No issues found!**;
- `working tree clean`;
- nova baseline: `08f969d`.

------------------------------------------------------------------------

## 7.8 PF-ENG 003/2026 â€” PolÃ­tica Oficial de Engenharia

**Data de adoÃ§Ã£o:** 31/07/2026
**Status:** Oficial

### DecisÃ£o

AlteraÃ§Ãµes estruturais passam a exigir:

1. inspeÃ§Ã£o;
2. Blueprint;
3. plano;
4. feature branch;
5. implementaÃ§Ã£o;
6. `flutter analyze` com 0 issues;
7. homologaÃ§Ã£o;
8. CPB;
9. commit;
10. push;
11. Pull Request;
12. Code Review Arquitetural;
13. merge;
14. validaÃ§Ã£o pÃ³s-merge;
15. atualizaÃ§Ã£o documental.

### Finalidade

- impedir alteraÃ§Ãµes estruturais diretamente na `main`;
- preservar rastreabilidade;
- reduzir regressÃµes;
- formalizar revisÃ£o antes da integraÃ§Ã£o;
- manter cÃ³digo e documentaÃ§Ã£o sincronizados.

### Documento relacionado

`docs/PF-ENG-003-2026_POLITICA_DE_ENGENHARIA.md`

------------------------------------------------------------------------

## 7.9 ENC-ADM-001B.2 â€” Encerramento documental

**Data:** 31/07/2026
**Branch:** `docs/enc-adm-001b2-governanca`
**Tipo:** ConsolidaÃ§Ã£o documental

### Objetivo

Sincronizar a arquitetura oficial e o Engineering Log com a baseline
`08f969d`.

### Riscos registrados

- divergÃªncia entre `perfil` e `perfilAcesso`;
- verificaÃ§Ã£o direta residual no atalho AdministraÃ§Ã£o;
- polÃ­tica de permissÃµes ainda estÃ¡tica.

### PrÃ³xima aÃ§Ã£o

Executar auditoria especÃ­fica da identidade, perfis e regras do
Firestore antes de ampliar permissÃµes ou implementar novos mÃ³dulos
administrativos.

------------------------------------------------------------------------

## 7.10 ADM-001C.1 â€” Identidade ConfiÃ¡vel

**Data:** 01/08/2026
**Commit:** `072c5a5`
**Branch:** `feature/adm-001c-identidade-seguranca`

### Resultado

- identidade operacional centralizada no `AuthorizationService`;
- validaÃ§Ã£o de documento, conta ativa e perfil reconhecido;
- estados explÃ­citos para cadastro ausente, conta inativa e falha;
- remoÃ§Ã£o das consultas duplicadas no Login e na Home;
- limpeza da identidade no logout e proteÃ§Ã£o contra resposta de sessÃ£o anterior.

### CorreÃ§Ã£o R1

Foi removida uma notificaÃ§Ã£o prematura que provocava reentrada do GoRouter e
`Stack Overflow`. ApÃ³s a correÃ§Ã£o, os testes no tablet confirmaram login,
Home, AdministraÃ§Ã£o, logout, retomada de sessÃ£o e ausÃªncia de tela branca.

### ValidaÃ§Ã£o

- `flutter analyze`: **No issues found!**;
- homologaÃ§Ã£o funcional no tablet: aprovada;
- commit e push: concluÃ­dos.

------------------------------------------------------------------------

## 7.11 ADM-001C.2 â€” PolÃ­tica Ãšnica de AutorizaÃ§Ã£o

**Data:** 01/08/2026
**Commit:** `fc575a0`
**Branch:** `feature/adm-001c-identidade-seguranca`

### Resultado

- atalho AdministraÃ§Ã£o passou a consumir `Permission`;
- comparaÃ§Ãµes textuais de perfil foram removidas da decisÃ£o da interface;
- `/admin-legado` passou a redirecionar ao painel oficial;
- listagem de usuÃ¡rios passou Ã  cadeia Provider â†’ Controller â†’ Repository â†’ Service;
- carregamento, atualizaÃ§Ã£o e falha passaram a possuir estados explÃ­citos.

### ValidaÃ§Ã£o

- `flutter analyze`: **No issues found!**;
- CPB: 8/8 arquivos;
- homologaÃ§Ã£o funcional no tablet: 10/10 itens;
- commit e push: concluÃ­dos.

------------------------------------------------------------------------

## 7.12 ADM-001C.3 â€” Firestore Security Baseline

**Data:** 01/08/2026
**Commit base:** `42e3560`
**CorreÃ§Ã£o R1:** `2129355`
**Branch:** `feature/adm-001c-identidade-seguranca`

### Auditoria

Foram inventariadas oito coleÃ§Ãµes: `usuarios`, `domains`, `tipos_acoes`,
`coordenadores`, `regionais`, `materiais`, `acoes` e `contadores`.

A regra anterior cobria somente `domains` e consultava o campo incorreto
`perfil`. A baseline passou a utilizar exclusivamente `perfilAcesso`, exigir
usuÃ¡rio ativo e perfil reconhecido e negar por padrÃ£o coleÃ§Ãµes nÃ£o
inventariadas.

### ValidaÃ§Ã£o

- Firebase Emulator Suite com Java 21;
- 15/15 testes positivos e negativos aprovados apÃ³s Code Review;
- `firebase-tools` 15.25.1;
- zero vulnerabilidades npm altas ou crÃ­ticas;
- `flutter analyze`: **No issues found!**;
- commit e push: concluÃ­dos.

### Controle de publicaÃ§Ã£o

As regras estÃ£o versionadas e testadas, porÃ©m nÃ£o foram publicadas no
Firebase remoto. `firebase deploy` permanece condicionado a autorizaÃ§Ã£o
expressa e procedimento prÃ³prio.

### CorreÃ§Ã£o pÃ³s-Code Review

A revisÃ£o do PR nÂº 3 identificou que a primeira baseline havia ampliado a
autorizaÃ§Ã£o de `domains` para gestor, conforme a matriz, mas removido
inadvertidamente duas invariantes anteriores: campos mÃ­nimos na criaÃ§Ã£o e
imutabilidade de `createdAt`.

A R1 restaurou essas proteÃ§Ãµes, acrescentou validaÃ§Ã£o de tipos essenciais e
incluiu testes negativos para documento incompleto e alteraÃ§Ã£o de `createdAt`.

O pacote corretivo foi aprovado com 11/11 arquivos, 15/15 testes no emulador,
`flutter analyze` sem issues e working tree limpa. O commit `2129355` foi
publicado na branch do PR nÂº 3.

------------------------------------------------------------------------

## 7.13 ADM-001C.4 â€” HomologaÃ§Ã£o integrada e encerramento

**Data:** 01/08/2026
**Status:** ConcluÃ­da e validada apÃ³s o merge

### Objetivo

Consolidar as evidÃªncias dos trÃªs pacotes, executar o checklist final,
sincronizar Arquitetura, Engineering Log e documentaÃ§Ã£o de seguranÃ§a e
preparar Pull Request para a `main`.

### Baseline de entrada

``` text
ADM-001C.1: 072c5a5
ADM-001C.2: fc575a0
ADM-001C.3: 42e3560
ADM-001C.3-R1: 2129355
Branch sincronizada com origin
Pull Request: nÂº 3 contra main
```

### HomologaÃ§Ã£o funcional

O checklist integrado no tablet foi concluÃ­do com 10/10 itens aprovados:

- login e identificaÃ§Ã£o;
- Home e indicadores;
- AdministraÃ§Ã£o e seis mÃ³dulos;
- listagem e atualizaÃ§Ã£o de usuÃ¡rios;
- navegaÃ§Ã£o de retorno;
- logout e novo login;
- retomada de sessÃ£o apÃ³s reinÃ­cio;
- ausÃªncia de tela branca, exceÃ§Ã£o ou travamento.

### CritÃ©rio de encerramento

O status somente mudarÃ¡ para concluÃ­do apÃ³s homologaÃ§Ã£o integrada, CPB final,
commit documental, push, Pull Request, Code Review, merge e validaÃ§Ã£o
pÃ³s-merge. A publicaÃ§Ã£o remota das regras permanece uma decisÃ£o separada.

### SituaÃ§Ã£o apÃ³s Code Review

- CPB final: 7/7 arquivos;
- CPB corretivo: 11/11 arquivos;
- Pull Request nÂº 3: integrado Ã  `main`;
- Code Review Arquitetural: aprovada apÃ³s a correÃ§Ã£o R1;
- status checks e workflows no GitHub: nÃ£o configurados;
- merge commit: `21f8ea2`;
- `flutter analyze` pÃ³s-merge: sem issues;
- Firestore pÃ³s-merge: 15/15 testes aprovados;
- `main` sincronizada e working tree limpa;
- regras remotas: nÃ£o publicadas.

------------------------------------------------------------------------

## 7.14 ADM-001C â€” IntegraÃ§Ã£o e validaÃ§Ã£o pÃ³s-merge

- **Data:** 01/08/2026
- **Pull Request:** nÂº 3
- **Merge commit:** `21f8ea2`
- **Branch integrada:** `feature/adm-001c-identidade-seguranca`

### Resultado

O Pull Request nÂº 3 foi integrado Ã  `main` por merge commit, preservando os
seis commits da ADM-001C. A cÃ³pia local avanÃ§ou por fast-forward e permaneceu
sincronizada com `origin/main`.

### ValidaÃ§Ã£o pÃ³s-merge

- `flutter analyze`: **No issues found!**;
- Firebase Emulator Suite: **15/15 testes aprovados**;
- falhas esperadas de autorizaÃ§Ã£o: `PERMISSION_DENIED` confirmado;
- working tree: limpa;
- publicaÃ§Ã£o das regras: nÃ£o realizada.

### Encerramento

A ADM-001C estÃ¡ formalmente concluÃ­da. A publicaÃ§Ã£o remota das regras do
Firestore permanece fora deste encerramento e exige autorizaÃ§Ã£o expressa,
backup da versÃ£o remota e teste de fumaÃ§a posterior.

------------------------------------------------------------------------

## 7.15 ADM-001C.4-R3 â€” SincronizaÃ§Ã£o Arquitetural PÃ³s-Merge

**Data:** 02/08/2026
**Branch:** `docs/adm-001c4-r3-sincronizacao-arquitetural`
**Tipo:** CorreÃ§Ã£o de consistÃªncia documental
**Status:** ConcluÃ­da apÃ³s o merge do Pull Request nÂº 5

### Causa-raiz

O encerramento pÃ³s-merge da ADM-001C atualizou o Engineering Log e o README
consolidado, mas nÃ£o atualizou integralmente a seÃ§Ã£o de baseline da Arquitetura
da Plataforma. O documento arquitetural ainda informava branch de feature e
integraÃ§Ã£o pendente, embora os Pull Requests nÂº 3 e nÂº 4 jÃ¡ estivessem
integrados Ã  `main`.

### CorreÃ§Ã£o preparada

- atualizaÃ§Ã£o da Arquitetura da Plataforma para a versÃ£o 2.4;
- registro do merge funcional `21f8ea2`;
- registro do encerramento documental `b0738ef`;
- substituiÃ§Ã£o da feature branch pela `main` como branch oficial;
- registro das branches encerradas;
- preservaÃ§Ã£o explÃ­cita do bloqueio de `firebase deploy`;
- manutenÃ§Ã£o dos dÃ©bitos controlados da ADM-001C.

### Impacto

A alteraÃ§Ã£o Ã© exclusivamente documental. NÃ£o modifica cÃ³digo Flutter,
dependÃªncias, rotas, providers, modelos, regras do Firestore ou dados remotos.

### ValidaÃ§Ãµes executadas

- `git diff --check`: sem erros; avisos LF para CRLF classificados como
  informativos no ambiente Windows;
- `flutter analyze`: `No issues found!` na execuÃ§Ã£o local;
- CPB final em modo `-Full`: `No issues found!`;
- CPB: quatro arquivos solicitados, quatro incluÃ­dos, zero ausentes e zero
  comandos com falha;
- branch confirmada: `docs/adm-001c4-r3-sincronizacao-arquitetural`;
- baseline confirmada: `b0738ef`;
- integridade dos quatro arquivos: confirmada por comparaÃ§Ã£o binÃ¡ria;
- HAT-2 final: aprovada sem ressalvas apÃ³s correÃ§Ã£o editorial e regeneraÃ§Ã£o do
  CPB.

### Tratamento da ressalva editorial

O README e este Engineering Log ainda registravam o pacote como â€œpreparado
para validaÃ§Ã£oâ€, embora as validaÃ§Ãµes jÃ¡ estivessem concluÃ­das. A redaÃ§Ã£o foi
atualizada, o CPB foi regenerado e os quatro arquivos foram novamente
comparados antes do versionamento.

### Controle de integraÃ§Ã£o

A correÃ§Ã£o foi versionada na branch
`docs/adm-001c4-r3-sincronizacao-arquitetural`, submetida ao Pull Request nÂº 5
e integrada Ã  `main` pelo merge commit `6a6794d`. A validaÃ§Ã£o pÃ³s-merge foi
concluÃ­da com `flutter analyze` sem issues e working tree limpa. A publicaÃ§Ã£o
remota permaneceu separada atÃ© a autorizaÃ§Ã£o expressa da SEC-001A.

------------------------------------------------------------------------

## 7.16 SEC-001A â€” PublicaÃ§Ã£o Controlada das Regras do Firestore

**Data:** 02/08/2026
**Branch:** `security/sec-001a-publicacao-controlada-firestore`
**Commit preparatÃ³rio:** `9da5c94`
**Commit documental:** `1ba5ba3`
**Pull Request / merge:** nÂº 6 / `c8d2d95`
**Tipo:** SeguranÃ§a, publicaÃ§Ã£o remota e homologaÃ§Ã£o
**Status:** PublicaÃ§Ã£o, homologaÃ§Ã£o e integraÃ§Ã£o concluÃ­das sem ressalvas tÃ©cnicas

### Objetivo

Substituir a regra remota genÃ©rica, que concedia leitura e escrita total a
qualquer conta autenticada, pela baseline versionada e testada da ADM-001C.3.

### Baseline anterior

- publicaÃ§Ã£o exibida: `29/07/2026 Ã s 22:31`;
- snapshot: `docs/SEC-001A_BASELINE_REMOTA_FIRESTORE.rules`;
- SHA-256:
  `9537678D49AD35DB5D8F85F7D976FEF36104D7C9C52546E1EF9F3195F65D6805`;
- severidade: crÃ­tica, por confundir autenticaÃ§Ã£o com autorizaÃ§Ã£o total.

### PreparaÃ§Ã£o e HATs

- Blueprint, plano, README, snapshot e manifesto versionados;
- CPB: 14/14 arquivos, zero ausentes e zero comandos falhos;
- Firebase CLI local: `15.25.1`;
- Firebase Emulator Suite: 15/15 testes aprovados;
- `flutter analyze`: `No issues found!`;
- hash candidato:
  `8838A3F097168C342289F51D2746B265AA540457C59AA226819EB730B2CA3BFD`;
- HAT-1 e HAT-2: aprovadas sem ressalvas tÃ©cnicas;
- conta ativa e contas inativas preparadas para smoke test;
- rollback condicionado revisado.

### AutorizaÃ§Ã£o

O responsÃ¡vel autorizou textual e expressamente a publicaÃ§Ã£o das regras da
SEC-001A no projeto `geduc-rae-mobile`. O comando remoto permaneceu bloqueado
atÃ© essa manifestaÃ§Ã£o.

### PublicaÃ§Ã£o

O deploy foi iniciado em `02/08/2026 Ã s 21:04:30`, UTC-03:00, com o executÃ¡vel
local e o projeto explicitamente informado:

```powershell
.\node_modules\.bin\firebase.cmd deploy `
  --only firestore:rules `
  --project geduc-rae-mobile
```

O Firebase CLI confirmou compilaÃ§Ã£o, upload, release para `cloud.firestore` e
`Deploy complete!`. Nenhum dado, Ã­ndice, funÃ§Ã£o, hosting ou cÃ³digo Flutter foi
publicado.

### VerificaÃ§Ã£o remota

- nova versÃ£o confirmada no Console Firebase Ã s 21:05;
- banco confirmado: `(default)`;
- versÃ£o anterior preservada no histÃ³rico;
- regra remota copiada integralmente apÃ³s o deploy;
- comparaÃ§Ã£o com `firestore.rules`: exit code `0`;
- working tree: limpa;
- nova publicaÃ§Ã£o: nÃ£o executada nem necessÃ¡ria.

### HomologaÃ§Ã£o pÃ³s-deploy

- administrador ativo: aprovado;
- mÃ³dulos administrativos: visÃ­veis;
- consultas aos dados existentes: aprovadas;
- lista de usuÃ¡rios: aprovada;
- gestor inativo: bloqueado;
- coordenador inativo: bloqueado;
- agente inativo: bloqueado;
- contas inativas acessaram dados: nÃ£o;
- tela branca ou exceÃ§Ã£o: nÃ£o;
- mensagem de conta inativa: correta e orientativa;
- rollback: nÃ£o indicado.

O smoke test remoto foi nÃ£o destrutivo. As escritas e negaÃ§Ãµes permanecem
cobertas pelos 15 testes do Emulador.

### Pesquisa de referÃªncia

A pesquisa foi concluÃ­da com fontes oficiais do Firebase, Google Cloud, OWASP
e NIST SP 800-207. A baseline publicada atende aos fundamentos de separaÃ§Ã£o
entre autenticaÃ§Ã£o e autorizaÃ§Ã£o, menor privilÃ©gio, decisÃ£o no backend,
negaÃ§Ã£o por padrÃ£o, validaÃ§Ã£o estrutural e testes automatizados.

Firebase App Check, Cloud Audit Logs, alertas, CI e revisÃ£o periÃ³dica de
privilÃ©gios foram registrados como evoluÃ§Ãµes de defesa em profundidade, sem
ressalva Ã  homologaÃ§Ã£o atual.

ReferÃªncia consolidada:
`docs/SEC-001A_PUBLICACAO_HOMOLOGACAO_REFERENCIAS.md`.

### Encerramento Git

- CPB de encerramento: gerado e revisado;
- registros documentais: versionados no commit `1ba5ba3`;
- Pull Request nÂº 6: aprovado e integrado;
- merge commit: `c8d2d95`;
- `main`: sincronizada com `origin/main`;
- working tree pÃ³s-merge: limpa;
- branch `security/sec-001a-publicacao-controlada-firestore`: removida local e
  remotamente.

------------------------------------------------------------------------

## 7.17 SEC-001A-R1 â€” SincronizaÃ§Ã£o Documental PÃ³s-Merge

**Data:** 03/08/2026
**Baseline de entrada:** `c8d2d95`
**Tipo:** CorreÃ§Ã£o de consistÃªncia documental

### Causa-raiz

O Pull Request nÂº 6 jÃ¡ havia sido integrado e sua branch removida, mas o README
e o Engineering Log ainda descreviam commit, push, Code Review e merge como
etapas futuras. A Arquitetura registrava corretamente `6a6794d` como baseline
histÃ³rica da ADM-001C e de entrada da SEC-001A, porÃ©m ainda nÃ£o declarava
`c8d2d95` como baseline final da Plataforma FÃªnix apÃ³s a SEC-001A.

### DecisÃ£o documental

- preservar `6a6794d` como baseline histÃ³rica de entrada;
- registrar `1ba5ba3` como commit documental;
- registrar o Pull Request nÂº 6 e o merge `c8d2d95`;
- registrar a remoÃ§Ã£o local e remota da branch da SEC-001A;
- substituir etapas futuras jÃ¡ executadas por resultados concluÃ­dos;
- elevar Arquitetura e Engineering Log para a versÃ£o 2.6.

### Limite de escopo

A correÃ§Ã£o nÃ£o altera providers, rotas, dependÃªncias, cÃ³digo Flutter,
`firestore.rules`, `firebase.json`, testes ou dados remotos. Nenhum comando de
deploy integra a SEC-001A-R1.

------------------------------------------------------------------------

## 7.18 SEC-001B â€” AutomaÃ§Ã£o de testes e proteÃ§Ã£o da main

**Data:** 03/08/2026

**Baseline de entrada:** `e5dd019`

**Branch da implementaÃ§Ã£o:** `security/sec-001b-quality-gates-ci`

**Commit da implementaÃ§Ã£o:** `f7db380`

**Pull Request / merge:** nÂº 8 / `1d279e9`

**Tipo:** SeguranÃ§a de integraÃ§Ã£o contÃ­nua e governanÃ§a Git

**Status:** HAT-1 a HAT-4 aprovadas; sincronizaÃ§Ã£o documental final preparada

### Problema

Os 15 testes das regras do Firestore e o analisador Flutter estavam disponÃ­veis
e aprovados localmente, mas nÃ£o existia workflow no repositÃ³rio nem gate remoto
obrigatÃ³rio. A integraÃ§Ã£o na `main` dependia de execuÃ§Ã£o e conferÃªncia manuais.

### DecisÃ£o

Foi criado o workflow `Quality Gates` com dois jobs independentes:

- `Quality Gate - Flutter Analyze`;
- `Quality Gate - Firestore Rules`.

O workflow Ã© iniciado em Pull Requests para a `main`, em pushes na `main` e por
`workflow_dispatch`. NÃ£o hÃ¡ filtros de caminho, deploy Firebase, secrets,
service accounts ou `pull_request_target`.

### Controles de supply chain

- `GITHUB_TOKEN` limitado a `contents: read`;
- checkout sem persistÃªncia de credenciais;
- actions fixadas por SHA completo;
- Node `24.18.0`;
- Java `21`;
- Flutter `3.44.4` stable;
- Firebase CLI `15.25.1`;
- testes executados no projeto isolado `geduc-rae-mobile-test`.

### HAT-2 â€” validaÃ§Ã£o local

- `npm ci`: aprovado;
- Firestore Emulator Suite: 15/15 testes aprovados;
- `flutter pub get`: aprovado;
- `flutter analyze`: `No issues found!`;
- diff: 6 arquivos e 498 inserÃ§Ãµes;
- commit: `f7db380`;
- working tree: limpa.

O npm registrou seis vulnerabilidades moderadas e avisos de scripts de
instalaÃ§Ã£o para trÃªs pacotes. Nenhuma correÃ§Ã£o automÃ¡tica foi aplicada. O tema
permanece como dÃ©bito controlado de supply chain.

### HAT-3 â€” Pull Request nÂº 8

Os dois jobs foram executados e aprovados no Pull Request. O merge foi concluÃ­do
em `1d279e9`, seguido por nova execuÃ§Ã£o automÃ¡tica na `main`. Uma execuÃ§Ã£o
manual adicional tambÃ©m foi aprovada em 46 segundos. O `flutter analyze` local
pÃ³s-merge permaneceu sem issues.

### Ruleset

Foi criado o ruleset `main-quality-gates`, identificador `20301322`, com estado
`Active`, alvo na default branch e bypass vazio.

Controles ativos:

- Pull Request obrigatÃ³rio;
- resoluÃ§Ãµes de conversas obrigatÃ³rias;
- branch atualizada com a base;
- dois checks obrigatÃ³rios com origem GitHub Actions;
- restriÃ§Ã£o de exclusÃ£o;
- bloqueio de force push.

### HAT-4 â€” prova controlada

**Branch:** `docs/sec-001b-hat4-prova-ruleset`

**Commit:** `7ce49d9`

**Pull Request / merge:** nÂº 9 / `a45c142`

O Pull Request documental exibiu ambos os checks como `Required`. Firestore
Rules foi aprovado em 34 segundos e Flutter Analyze em 48 segundos. O merge
foi concluÃ­do sem bypass somente apÃ³s os dois sucessos.

O push pÃ³s-merge da `main` iniciou automaticamente a execuÃ§Ã£o nÂº 5 do workflow,
concluÃ­da com sucesso em 59 segundos. A cÃ³pia local foi sincronizada em
`a45c142`; `flutter analyze` retornou `No issues found!` em 135,1 segundos e a
working tree permaneceu limpa.

### Parecer

``` text
HAT-1: APROVADA
HAT-2: APROVADA
HAT-3: APROVADA
HAT-4: APROVADA
Ressalvas tÃ©cnicas: nenhuma
Baseline tÃ©cnica final: a45c142
```

### Limite de escopo

A SEC-001B nÃ£o modifica cÃ³digo funcional, regras do Firestore, dados remotos ou
configuraÃ§Ã£o Firebase. O tratamento das vulnerabilidades moderadas do npm e a
remoÃ§Ã£o das branches de trabalho ocorrerÃ£o em fluxo separado e controlado.

## 7.19 SEC-001C â€” hardening da cadeia de dependÃªncias npm

**Data:** 03/08/2026

**Baseline de entrada:** `main` em `3400563`

**Branch:** `security/sec-001c-hardening-supply-chain`

**Commit:** `2c16d4d86c7a4d25f421cb0e36f79b6d58c1d5df`

**Pull Request / merge:** nÂº 11 / `6b53c8f`

### DiagnÃ³stico

O `npm audit` inicial encontrou seis ocorrÃªncias moderadas, zero alta e zero
crÃ­tica. O limiar `high` retornou sucesso. A inspeÃ§Ã£o de scripts identificou
`@firebase/util@1.12.1`, `protobufjs@7.6.5` e `re2@1.24.1` sem decisÃ£o
registrada. O `npm outdated` apontou apenas uma nova versÃ£o major de
`@firebase/rules-unit-testing`, mantida fora deste escopo.

### ImplementaÃ§Ã£o

- atualizaÃ§Ã£o segura do `re2` para `1.26.1`, sem `--force`;
- ativaÃ§Ã£o de `strict-allow-scripts=true`;
- aprovaÃ§Ã£o versionada dos trÃªs scripts revisados;
- negaÃ§Ã£o explÃ­cita de `fsevents`;
- scripts `audit:security` e `audit:scripts` no `package.json`;
- auditoria de severidade antes do `npm ci` no gate obrigatÃ³rio de Firestore.

O relatÃ³rio final contÃ©m cinco ocorrÃªncias moderadas. A correÃ§Ã£o forÃ§ada nÃ£o
foi aceita porque propÃµe downgrade para `firebase-tools@14.23.0`.

### HAT-2 â€” validaÃ§Ã£o local e CPB

`npm ci`, a polÃ­tica de scripts e o audit de severidade foram aprovados. Os 15
testes das regras do Firestore passaram e `flutter analyze` retornou
`No issues found!`.

O CPB
`SEC-001C-HARDENING-SUPPLY-CHAIN_2026-08-03_13-39-46.zip`, SHA-256
`3803BDCD0ECB8EA0354C8C8611F43ADC379203E63E06FAD536D6147420D1707A`,
foi aprovado com 9/9 arquivos exatos e analyze sem issues em 110,6 segundos.

### HAT-3 â€” Pull Request nÂº 11

O Pull Request nÃ£o apresentou conflitos. `Quality Gate - Firestore Rules` foi
aprovado em 32 segundos e `Quality Gate - Flutter Analyze` em 53 segundos;
ambos estavam marcados como `Required`. O merge ocorreu sem bypass.

### HAT-4 â€” pÃ³s-merge

O merge commit `6b53c8fe0964d91dc018799bcff8fcd429fa53af` tornou-se a
baseline oficial. O workflow automÃ¡tico da `main` concluiu em verde em 43
segundos. Localmente, nÃ£o havia scripts pendentes, o audit de severidade
retornou sucesso, os 15 testes passaram em 15,247 segundos e
`flutter analyze` terminou sem issues em 143,1 segundos. A working tree ficou
limpa e sincronizada com `origin/main`.

### Parecer

```text
HAT-1: APROVADA
HAT-2: APROVADA
HAT-3: APROVADA
HAT-4: APROVADA
Ressalvas impeditivas: nenhuma
Risco residual: cinco ocorrÃªncias moderadas transitivas monitoradas
Baseline tÃ©cnica final: 6b53c8f
```

â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

**Sistema de Conhecimento da Plataforma FÃªnix (SKPF)**

Documento Oficial

Engineering Log

VersÃ£o 2.8

------------------------------------------------------------------------

## AUD-L2-R4 â€” Encerramento ACL operacional

**Data:** 19/08/2026
**Status:** Homologado; preparado para commit Ãºnico

### Objetivo

Concluir o hardening da classificaÃ§Ã£o de acesso dos RAEs, vinculando identidade canÃ´nica e escopo operacional antes da persistÃªncia da classificaÃ§Ã£o ACL e impedindo o envio de novos RAEs com classificaÃ§Ã£o incompleta ou inconsistente.

### Resultado por etapa

- **R4.1 â€” ACL Core:** classificador central e chave canÃ´nica.
- **R4.2 â€” Identity Binding:** responsÃ¡vel e coordenador vinculados por identidade canÃ´nica.
- **R4.3 â€” Scope Resolver:** Regional, Equipe e Projeto resolvidos de forma determinÃ­stica e fail-closed.
- **R4.4-A â€” Final Classification:** classificaÃ§Ã£o final persistida e invalidada quando suas entradas mudam.
- **R4.4-B â€” Send Gate:** envio de RAE em rascunho condicionado Ã  integridade da ACL.

### ProteÃ§Ãµes consolidadas

- fallback nominal nÃ£o concede autorizaÃ§Ã£o;
- coordenador canÃ´nico deriva de `usuarioId`;
- escopo ambÃ­guo permanece nÃ£o resolvido;
- `aclScopeKey` Ã© validada contra os identificadores efetivamente persistidos;
- chave inconsistente bloqueia envio;
- alteraÃ§Ã£o posterior de identidade ou escopo invalida classificaÃ§Ã£o anterior;
- registro legado fora de rascunho nÃ£o sofre bloqueio ACL retroativo.

### HomologaÃ§Ã£o

```text
RaeAclClassifier:              8/8
AcaoController ACL:            9/9
R4.4-A Final Classification:   7/7
R4.4-B Send Gate:              5/5
Regressao completa:            755/755
flutter analyze:               No issues found
git diff --check:              sem erro de whitespace
```

O aviso de conversÃ£o LF para CRLF apresentado pelo Git em ambiente Windows foi classificado como informativo e nÃ£o representa falha de whitespace.

### Parecer

`AUD-L2-R4`: **HOMOLOGADO**.

O lote estÃ¡ autorizado para registro em commit Ãºnico. Push, Pull Request e merge permanecem etapas separadas e dependem de autorizaÃ§Ã£o prÃ³pria.
### CorreÃ§Ã£o R1 â€” Regional Scope Enforcement

A Code Review do PR #40 identificou que `AccessScope.regionalIds` nÃ£o participava da resoluÃ§Ã£o R4.3. A R1 tornou a dimensÃ£o Regional obrigatÃ³ria no `RaeScopeResolver`: escopo regional vazio ou Regional fora do conjunto permitido falha de forma fechada antes da resoluÃ§Ã£o de Equipe e Projeto.

Foram adicionadas regressÃµes explÃ­citas para Regional fora e dentro do `AccessScope`. A `RecursosOperacionaisPage` passou a encaminhar `escopo.regionalIds` ao resolver.
------------------------------------------------------------------------

## AUD-L2-R5.1 â€” FundaÃ§Ã£o de Evidence Storage

**Data:** 19/08/2026
**Branch:** `audit/aud-l2-r5-evidence-storage-architecture`
**Status:** R5.1 homologado; R5.1-R1 em validaÃ§Ã£o

### Contexto

A anÃ¡lise do armazenamento de evidÃªncias confirmou que as fotografias permanecem salvas localmente no dispositivo. A nÃ£o utilizaÃ§Ã£o de Firebase Storage Ã© uma decisÃ£o arquitetural consciente associada ao controle de custos.

Foi aprovada a criaÃ§Ã£o de uma camada abstrata para permitir futura sincronizaÃ§Ã£o remota sem retirar do armazenamento local o papel de fonte operacional.

### ImplementaÃ§Ã£o

Foram introduzidos:

- `lib/core/storage/remote_evidence_models.dart`;
- `lib/core/storage/remote_evidence_storage.dart`;
- `lib/core/storage/disabled_remote_evidence_storage.dart`;
- `lib/core/storage/evidence_storage_policy.dart`;
- `test/core/storage/remote_evidence_storage_test.dart`;
- `README_AUD-L2-R5.md`.

O `EvidenciaStorageService` existente nÃ£o foi alterado. O `SyncService`, os Providers e as rotas tambÃ©m permaneceram intactos.

### Resultado tÃ©cnico

```text
Testes focados R5.1:           8/8 aprovados
flutter analyze:               No issues found
git diff --check:              aprovado
RemoteEvidenceStorage:         contrato criado
Remote provider padrÃ£o:        desabilitado / fail-closed
Cloudflare R2:                 nÃ£o integrado
Credenciais:                   nenhuma
Upload remoto:                 nenhum
```

### Parecer

`AUD-L2-R5.1`: **HOMOLOGADO LOCALMENTE**.

A etapa estabelece somente a fundaÃ§Ã£o arquitetural. O commit inicial do R5.1 Ã© db43b2 e o trabalho estÃ¡ publicado no PR #41. A revisÃ£o prÃ©-merge identificou que localStorageRequired ainda era configurÃ¡vel; a R5.1-R1 remove essa possibilidade para tornar a invariante local-first estruturalmente obrigatÃ³ria. IntegraÃ§Ã£o real com armazenamento remoto permanece fora deste escopo.
### R5.1-R1 â€” ConsolidaÃ§Ã£o da invariante local-first

A revisÃ£o do PR #41 identificou que `EvidenceStoragePolicy` aceitava `localStorageRequired: false`, contrariando a invariante arquitetural de que toda evidÃªncia deve permanecer local-first.

A R1 remove `localStorageRequired` do construtor e o transforma em propriedade invariavelmente verdadeira. A habilitaÃ§Ã£o futura do armazenamento remoto passa a ser independente da persistÃªncia local obrigatÃ³ria.

```text
Commit inicial R5.1:            adb43b2
Pull Request:                   #41
Local storage required:         sempre true
Remote storage enabled:         configurÃ¡vel
```

------------------------------------------------------------------------

## AUD-L2-R5.2 / R5.2-C â€” Metadados, SHA-256 e autoria de evidÃªncias

**Data:** 20/08/2026
**Branch:** `audit/aud-l2-r5-2-c-evidence-author-identity`
**Tipo:** EvoluÃ§Ã£o de integridade e identidade operacional

### Resumo

O R5.2-A/B adicionou metadados de integridade Ã s evidÃªncias locais, incluindo
SHA-256, tamanho real, MIME type e campos reservados Ã  futura sincronizaÃ§Ã£o
remota. O R5.2-C vinculou novas evidÃªncias Ã  identidade operacional canÃ´nica
por meio de `AuthorizationService.usuarioAtual.id`.

### DecisÃ£o arquitetural

A interface obtÃ©m a identidade validada e repassa explicitamente
`autorUserId` ao `EvidenciaStorageService`. O serviÃ§o de arquivos permanece
desacoplado do Firebase Auth e do Firestore.

A ausÃªncia de identidade canÃ´nica provoca falha fechada. EvidÃªncias legadas
permanecem compatÃ­veis.

### Arquivos do R5.2-C

- `README_AUD-L2-R5.2-C.md`;
- `lib/core/services/evidencia_storage_service.dart`;
- `lib/modules/evidencias/evidencias_page.dart`;
- `test/core/services/evidencia_storage_service_test.dart`;
- `test/core/storage/evidence_metadata_calculator_test.dart`.

### ValidaÃ§Ã£o

```text
R5.2-A/B commit:               3647210
R5.2-A/B merge:                479c9dc
R5.2-A/B testes focados:       17/17
R5.2-A/B regressÃ£o:            775/775
R5.2-C regressÃ£o completa:     aprovada
flutter analyze:               0 issues
git diff --check:              aprovado
```

### Limites

NÃ£o foram introduzidos Cloudflare R2, upload remoto, URLs assinadas,
Firebase Storage, alteraÃ§Ãµes em `SyncService`, `AcaoModel`, Providers ou rotas.

### PrÃ³xima aÃ§Ã£o

Commit controlado do R5.2-C, publicaÃ§Ã£o da branch, Pull Request e validaÃ§Ã£o dos
Quality Gates antes do merge.
------------------------------------------------------------------------

## AUD-L2-R5.3 â€” AutorizaÃ§Ã£o remota e Access Broker

**Data:** 20/08/2026
**Branch:** `audit/aud-l2-r5-3-remote-access-authorization`
**Tipo:** SeguranÃ§a arquitetural / trust boundary

### Objetivo

Impedir que a futura integraÃ§Ã£o de armazenamento remoto transfira ao APK
credenciais, segredo de assinatura ou autoridade para conceder acesso ao
bucket.

### DecisÃ£o arquitetural

Foi introduzido um contrato `EvidenceAccessBroker` separado do transporte de
armazenamento. O broker representa a solicitaÃ§Ã£o de acesso, enquanto a futura
emissÃ£o do grant deverÃ¡ ocorrer exclusivamente em backend confiÃ¡vel.

A implementaÃ§Ã£o padrÃ£o `DisabledEvidenceAccessBroker` falha fechado para
leitura e upload.

### OperaÃ§Ãµes

- leitura: futura equivalÃªncia com `Permission.consultarRae`;
- upload: futura equivalÃªncia com `Permission.editarRae`;
- exclusÃ£o: fora do escopo e nÃ£o autorizada.

### Limites

Nenhum Worker, R2, credencial, URL assinada real, chamada HTTP, SyncService ou
deploy remoto Ã© introduzido no R5.3.
### ValidaÃ§Ã£o final

```text
Baseline de entrada:           53ac988
Testes focados R5.1 + R5.3:    aprovados
RegressÃ£o Flutter completa:    aprovada
flutter analyze:               0 issues
git diff --check:              aprovado
Escopo final:                  8 arquivos previstos
```

### Parecer

`AUD-L2-R5.3`: **HOMOLOGADO LOCALMENTE**.

O pacote estabelece exclusivamente a fronteira de confianÃ§a para autorizaÃ§Ã£o
remota de evidÃªncias. A implementaÃ§Ã£o produtiva do backend confiÃ¡vel, emissÃ£o
de grants temporÃ¡rios, Cloudflare Worker, R2 e transporte HTTP permanecem
reservados Ã s etapas posteriores.
------------------------------------------------------------------------

## AUD-L2-R5.4-A â€” RefatoraÃ§Ã£o do contrato remoto

**Data:** 20/08/2026
**Branch:** `audit/aud-l2-r5-4-a-remote-transport-contract`
**Baseline:** `8d4e0c2`
**Tipo:** RefatoraÃ§Ã£o arquitetural / storage remoto

### MotivaÃ§Ã£o

A HAT-1 do R5.4 identificou que o contrato legado `RemoteEvidenceStorage`
misturava transporte com concessÃ£o de acesso ao expor `createReadUri()` e
`delete()`.

Essa forma permitiria que uma futura implementaÃ§Ã£o cliente assumisse
responsabilidades que pertencem ao backend confiÃ¡vel.

### ImplementaÃ§Ã£o

O contrato legado Ã© substituÃ­do por `RemoteEvidenceTransport`, cuja operaÃ§Ã£o de
upload recebe obrigatoriamente:

- `EvidenceAccessGrant`;
- `RemoteEvidenceUploadRequest`.

A implementaÃ§Ã£o padrÃ£o continua fail-closed por meio de
`DisabledRemoteEvidenceTransport`.

### Fora do escopo

- HTTP real;
- Cloudflare R2;
- Worker;
- credenciais;
- signed URLs reais;
- exclusÃ£o remota;
- SyncService;
- Providers;
- rotas.
### ValidaÃ§Ã£o final

```text
Baseline de entrada:           8d4e0c2
Testes focados R5.3 + R5.4-A:  aprovados
RegressÃ£o Flutter completa:    aprovada
flutter analyze:               0 issues
git diff --check:              aprovado
Escopo final:                  9 caminhos Git previstos
```

### Parecer

`AUD-L2-R5.4-A`: **HOMOLOGADO LOCALMENTE**.

A refatoraÃ§Ã£o remove a ambiguidade do contrato legado e consolida a separaÃ§Ã£o:

```text
EvidenceAccessBroker      = plano de controle
RemoteEvidenceTransport   = plano de dados
```

O plano de dados nÃ£o possui `createReadUri()`, nÃ£o possui `delete()` e nÃ£o
recebe credenciais permanentes de provedor. A integraÃ§Ã£o HTTP real e o adapter
Cloudflare R2 continuam reservados Ã s prÃ³ximas subetapas.
------------------------------------------------------------------------

## AUD-L2-R5.4-B â€” Hardening de grants e object keys

**Data:** 20/08/2026
**Branch:** `audit/aud-l2-r5-4-b-grant-object-key-hardening`
**Baseline:** `ead4fe18b9e5ebb35a508baecbc6242b9d18fd2f`
**Tipo:** Hardening de seguranÃ§a / storage remoto

### Escopo

- exigir HTTPS em grants;
- exigir host em grants;
- rejeitar grants expirados;
- conferir compatibilidade de operaÃ§Ã£o por `validoPara(...)`;
- rejeitar `.` e `..` em identificadores usados por `buildObjectKey()`;
- preservar o bloqueio existente de separadores de caminho.

### Limites

A etapa nÃ£o introduz transporte HTTP, Cloudflare R2, Worker, credenciais,
signed URLs reais ou DELETE remoto.
### ValidaÃ§Ã£o final

```text
Baseline de entrada:           ead4fe18b9e5ebb35a508baecbc6242b9d18fd2f
Testes focados R5.4-B:          aprovados
RegressÃ£o Flutter completa:    aprovada
flutter analyze:               0 issues
git diff --check:              aprovado
Escopo final:                  7 caminhos Git previstos
```

### Parecer

`AUD-L2-R5.4-B`: **HOMOLOGADO LOCALMENTE**.

O grant remoto passa a exigir HTTPS, host vÃ¡lido, expiraÃ§Ã£o futura e
compatibilidade explÃ­cita de operaÃ§Ã£o. A geraÃ§Ã£o de object keys tambÃ©m
passa a rejeitar os identificadores reservados `.` e `..`, preservando
o bloqueio jÃ¡ existente de separadores de caminho.

Nenhum transporte HTTP real, Worker, Cloudflare R2 ou credencial foi
introduzido nesta etapa.
------------------------------------------------------------------------

## AUD-L2-R5.4-C â€” AbstraÃ§Ã£o de transporte HTTP

**Data:** 21/08/2026
**Branch:** `audit/aud-l2-r5-4-c-http-transport-abstraction`
**Baseline:** `8c04ba7e661942f212abfd15c840cb54f8ff7d0e`
**Tipo:** Arquitetura de transporte / storage remoto

### Escopo

- acrescentar `objectKey` ao `EvidenceAccessGrant`;
- garantir que a chave remota venha da fronteira confiÃ¡vel;
- introduzir `EvidenceHttpPutRequest`;
- introduzir `EvidenceHttpResponse`;
- introduzir `EvidenceHttpClient`;
- testar a porta HTTP com fake, sem trÃ¡fego real.

### Limites

Nenhuma biblioteca HTTP, chamada de rede, Cloudflare R2, Worker, credencial,
signed URL real ou upload remoto produtivo Ã© introduzido no R5.4-C.
### ValidaÃ§Ã£o final

```text
Baseline de entrada:           8c04ba7e661942f212abfd15c840cb54f8ff7d0e
Testes focados R5.4-C:          aprovados
RegressÃ£o Flutter completa:    aprovada
flutter analyze:               0 issues
git diff --check:              aprovado
Escopo final:                  9 caminhos Git previstos
```

### Parecer

`AUD-L2-R5.4-C`: **HOMOLOGADO LOCALMENTE**.

A etapa introduz a abstraÃ§Ã£o HTTP neutra de provedor e corrige a autoridade
da `objectKey`, que passa a ser fornecida pelo `EvidenceAccessGrant`.

Nenhuma implementaÃ§Ã£o HTTP concreta, Cloudflare R2, Worker/backend,
signed URL real ou credencial foi introduzida.
------------------------------------------------------------------------

## AUD-L2-R5.4-D â€” Signed URL Remote Transport

**Data:** 21/08/2026
**Branch:** `audit/aud-l2-r5-4-d-signed-url-remote-transport`
**Baseline:** `75176edfe61b273bb3b95de7d05e1b8cfe1513c6`
**Tipo:** ImplementaÃ§Ã£o do plano de dados / storage remoto

### Escopo

- introduzir `SignedUrlRemoteEvidenceTransport`;
- conectar grant autorizado Ã  porta `EvidenceHttpClient`;
- validar operaÃ§Ã£o, expiraÃ§Ã£o e Content-Type antes do HTTP;
- preservar URI e headers recebidos no grant;
- aceitar somente HTTP 2xx;
- usar a `objectKey` fornecida pelo grant;
- registrar `ETag` apenas como metadado opcional;
- testar todo o fluxo com cliente HTTP fake.

### Limites

Nenhum pacote HTTP concreto, trÃ¡fego de rede real, endpoint Cloudflare,
Worker produtivo, credencial, assinatura SigV4 ou persistÃªncia de signed URL Ã©
introduzido nesta etapa.
### ValidaÃ§Ã£o final

```text
Baseline de entrada:           75176edfe61b273bb3b95de7d05e1b8cfe1513c6
Testes focados R5.4-D:          aprovados
RegressÃ£o Flutter completa:    aprovada
flutter analyze:               0 issues
git diff --check:              aprovado
Escopo final:                  5 caminhos Git previstos
```

### Parecer

`AUD-L2-R5.4-D`: **HOMOLOGADO LOCALMENTE**.

A etapa implementa `SignedUrlRemoteEvidenceTransport`, conectando o grant
autorizado Ã  porta `EvidenceHttpClient` em modo fail-closed.

A implementaÃ§Ã£o nÃ£o conhece Cloudflare R2, nÃ£o assina URLs, nÃ£o possui
credenciais permanentes, nÃ£o interpreta `ETag` como SHA-256 e nÃ£o executa
trÃ¡fego HTTP real nesta subetapa.
------------------------------------------------------------------------

## AUD-L2-R5.4-E â€” Upload Failure Hardening

**Data:** 21/08/2026
**Branch:** `audit/aud-l2-r5-4-e-upload-failure-hardening`
**Baseline:** `7d17cfb5c3f67295ded46cdea4ce5004f99584aa`
**Tipo:** Contrato de erro / preparaÃ§Ã£o para sincronizaÃ§Ã£o

### Escopo

- substituir falhas genÃ©ricas do adapter por exceÃ§Ãµes tipadas;
- diferenciar falhas locais, grant, Content-Type, HTTP e transporte;
- preservar status HTTP quando disponÃ­vel;
- preservar causa de falha de transporte;
- classificar falhas potencialmente recuperÃ¡veis;
- garantir por teste que existe apenas uma tentativa HTTP por chamada;
- manter retry/backoff fora do transporte.

### Limites

Nenhum retry automÃ¡tico, pacote HTTP concreto, chamada de rede, Worker,
Cloudflare R2, renovaÃ§Ã£o de grant ou credencial Ã© introduzido nesta etapa.
### ValidaÃ§Ã£o final

```text
Baseline de entrada:           7d17cfb5c3f67295ded46cdea4ce5004f99584aa
Testes focados R5.4-E/R1:       aprovados
RegressÃ£o Flutter completa:    aprovada
flutter analyze:               0 issues
git diff --check:              aprovado
Escopo final:                  7 caminhos Git previstos
```

### Parecer

`AUD-L2-R5.4-E`: **HOMOLOGADO LOCALMENTE**.

A etapa substitui falhas genÃ©ricas por `RemoteEvidenceUploadException`,
preservando tipo, status HTTP e causa quando aplicÃ¡vel.

O transporte executa uma Ãºnica tentativa HTTP por chamada e nÃ£o executa retry
automÃ¡tico. A propriedade `retryCandidate` apenas informa Ã  futura camada de
sincronizaÃ§Ã£o quais falhas podem admitir nova tentativa.

Nenhum pacote HTTP concreto, trÃ¡fego de rede real, Worker/backend, Cloudflare
R2 produtivo, renovaÃ§Ã£o de grant ou credencial foi introduzido nesta etapa.

------------------------------------------------------------------------

## AUD-L2-R5.4-F â€” Integration Closure

**Data:** 21/08/2026
**Branch:** `audit/aud-l2-r5-4-f-integration-closure`
**Baseline:** `766a83a65de7c84e819dc2fd499f86c9d835d3ff`
**Tipo:** Gate de integracao / fechamento R5.4

### Objetivo

Consolidar A-E em um contrato transversal antes de iniciar R5.5.

### Escopo

- novo teste integrado dos invariantes do plano de dados remoto;
- fechamento documental R5.4;
- definicao explicita da fronteira de entrada do R5.5.

### Limites

Nenhum adapter HTTP real, dependencia de rede, Worker, provedor remoto,
credencial, fila, backoff ou retry automatico e introduzido.
### ValidaÃ§Ã£o final

```text
Baseline de entrada:           766a83a65de7c84e819dc2fd499f86c9d835d3ff
Teste transversal R5.4-F:      aprovado
RegressÃ£o test/core/storage:   aprovada
flutter analyze:               0 issues
git diff --check:              aprovado
Escopo final:                  4 caminhos Git previstos
CÃ³digo de produÃ§Ã£o novo:       nÃ£o
```

### Parecer

`AUD-L2-R5.4-F`: **HOMOLOGADO LOCALMENTE**.

O bloco R5.4 fica encerrado com os contratos A-E consolidados e validados de
forma transversal.

O transporte remoto continua provider-neutral, fail-closed, sem credenciais e
sem retry automÃ¡tico.

A prÃ³xima etapa, R5.5, deve assumir exclusivamente responsabilidades de
sincronizaÃ§Ã£o/orquestraÃ§Ã£o, preservando as fronteiras de confianÃ§a e de dados
definidas no R5.4.

------------------------------------------------------------------------

## AUD-L2-R5.5-A â€” Durable Evidence Sync Queue

**Data:** 21/08/2026
**Branch:** `audit/aud-l2-r5-5-a-durable-evidence-sync-queue`
**Baseline:** `b9bfe53640e9417f236e9c9b4ef913e1d79f1e93`
**Tipo:** Persistencia offline-first / fundacao de sincronizacao

### Diagnostico

O `SyncService` atual sincroniza RAEs persistidos pelo `OfflineService`.

O estado rico de evidencias, entretanto, e mantido em memoria pelo
`EvidenciaStorageService`.

Integrar upload remoto antes de criar persistencia especifica de evidencias
criaria risco de perda de fila e de estado apos reinicio do aplicativo.

### Escopo

- `EvidenceSyncJob`;
- `EvidenceSyncStore`;
- `SharedPreferencesEvidenceSyncStore`;
- serializacao de operacoes do store;
- validacao fail-closed;
- testes de persistencia, upsert, remocao, corrupcao e concorrencia.

### Limites

Nenhuma rede, retry, backoff, broker real, transporte real, Worker, R2/B2,
credencial ou integracao com o `SyncService` e introduzida.

### Validacao final

- teste focado R5.5-A: aprovado;
- regressao `test/core/sync`: aprovada;
- `flutter analyze`: 0 issues;
- `git diff --check`: aprovado;
- escopo: 7 caminhos;
- ajuste R5.5-A-R1 do contrato assincrono: aprovado.

### Parecer

AUD-L2-R5.5-A: **HOMOLOGADO LOCALMENTE**.

A fundacao duravel da fila de sincronizacao de evidencias esta pronta para o
R5.5-B, que podera iniciar a orquestracao sem introduzir rede real ou autoridade
de backend no cliente.

------------------------------------------------------------------------

## AUD-L2-R5.5-B â€” Evidence Sync Queue Orchestrator

**Data:** 21/08/2026
**Branch:** `audit/aud-l2-r5-5-b-evidence-sync-orchestrator`
**Baseline:** `bd55ba7f8df7d177a4e684c91c322e8ac6c063e0`
**Tipo:** Orquestracao de fila / selecao deterministica

### Escopo

- `EvidenceSyncOrchestrator`;
- leitura de `EvidenceSyncStore`;
- validacao fail-closed;
- elegibilidade de `pending`;
- elegibilidade temporal de `retryScheduled`;
- exclusao de `synced` e `blocked`;
- ordenacao deterministica;
- selecao do proximo candidato;
- testes sem side effects.

### Limites

Nenhuma persistencia e alterada pelo ato de selecionar candidatos.

Nao sao introduzidos broker produtivo, grant, transporte real, HTTP,
retry/backoff, conectividade, Worker, R2/B2 ou credenciais.

### Gate seguinte

R5.5-C podera consumir o candidato selecionado para solicitar um grant de
upload ao `EvidenceAccessBroker`, preservando o backend como autoridade.

### Validacao final

- teste focado R5.5-B: aprovado;
- regressao `test/core/sync`: aprovada;
- `flutter analyze`: 0 issues;
- `git diff --check`: aprovado;
- escopo: 5 caminhos;
- selecao sem persistencia, rede ou side effects.

### Parecer

AUD-L2-R5.5-B: **HOMOLOGADO LOCALMENTE**.

A fila duravel do R5.5-A agora possui uma camada deterministica e fail-closed
para selecionar candidatos de sincronizacao.

R5.5-C fica autorizado apenas como proxima etapa arquitetural, ainda sujeito a
implementacao, validacao e homologacao separadas.

------------------------------------------------------------------------

## AUD-L2-R5.5-C â€” Evidence Grant Acquisition

**Data:** 21/08/2026
**Branch:** `audit/aud-l2-r5-5-c-evidence-grant-acquisition`
**Baseline:** `d92200e9c8ac7f00330253a0fbd3a95d83448f5e`
**Tipo:** Orquestracao / fronteira de autorizacao

### Escopo

- `EvidenceSyncGrantCoordinator`;
- `EvidenceSyncGrantPreparation`;
- consumo do proximo candidato do R5.5-B;
- montagem de `EvidenceUploadAccessRequest`;
- uma chamada ao `requestUploadAccess`;
- validacao do grant para upload;
- preservacao do grant somente em memoria;
- testes de broker desabilitado, expiracao, operacao, HTTPS e objectKey.

### Limites

Nenhum upload e executado e nenhuma fila e alterada nesta etapa.

O cliente nao decide ACL, nao fabrica `objectKey` e nao persiste URL assinada.

### Gate seguinte

R5.5-D podera consumir `EvidenceSyncGrantPreparation` para executar exatamente
uma chamada ao `RemoteEvidenceTransport` e, somente apos sucesso confirmado,
persistir `objectKey` e `syncedAt`.

### Validacao final

- teste focado R5.5-C: aprovado;
- regressao `test/core/sync`: aprovada;
- `flutter analyze`: 0 issues;
- `git diff --check`: aprovado;
- escopo: 5 caminhos;
- grant mantido apenas em memoria;
- nenhum upload ou persistencia de sucesso executado.

### Parecer

AUD-L2-R5.5-C: **HOMOLOGADO LOCALMENTE**.

A Plataforma Fenix agora possui a ponte controlada entre a fila elegivel e a
autorizacao temporaria emitida pelo broker, sem transferir autoridade para o
cliente.

R5.5-D permanece como etapa separada para transporte e confirmacao persistida.

------------------------------------------------------------------------

## AUD-L2-R5.5-D â€” Evidence Upload + Persisted Confirmation

**Data:** 24/08/2026
**Branch:** `audit/aud-l2-r5-5-d-evidence-upload-confirmation`
**Baseline:** `6ea5aaae6cf46734ae559af91448a4b6f2e71936`
**Tipo:** Orquestracao / plano de dados / confirmacao persistida

### Escopo

- `EvidenceSyncUploadCoordinator`;
- consumo de `EvidenceSyncGrantPreparation`;
- uma unica chamada ao `RemoteEvidenceTransport`;
- validacao de `objectKey`;
- validacao opcional de `sizeBytes`;
- releitura fail-closed do job antes de confirmar;
- persistencia de estado `synced` somente apos sucesso;
- incremento de `attemptCount` em tentativa bem sucedida;
- registro de `lastAttemptAt`;
- limpeza de `nextAttemptAt`.

### Invariantes

- sem retry automatico;
- sem overwrite de job alterado durante upload;
- sem `objectKey` fabricado pelo cliente;
- sem `syncedAt` antes de sucesso remoto;
- sem alteracao do `SyncService`;
- sem credenciais permanentes.

### Risco conhecido

Sucesso remoto seguido de falha de persistencia local pode gerar nova tentativa
posterior. R5.5-E/F deve tratar esse caso com idempotencia/reconciliacao sobre a
mesma identidade de evidencia e o mesmo `objectKey`.

### Validacao final

- teste focado R5.5-D: aprovado;
- regressao `test/core/sync`: aprovada;
- `flutter analyze`: 0 issues;
- `git diff --check`: aprovado;
- escopo: 5 caminhos;
- uma tentativa de transporte por execucao;
- confirmacao `synced` apenas apos sucesso;
- protecao contra `objectKey` divergente;
- protecao contra alteracao concorrente do job;
- sem retry/backoff automatico.

### Parecer

AUD-L2-R5.5-D: **HOMOLOGADO LOCALMENTE**.

A Plataforma Fenix agora possui o caminho controlado:

fila elegivel -> grant temporario -> uma tentativa de upload -> validacao do
resultado -> confirmacao persistida.

R5.5-E permanece como etapa separada para politica de retry, backoff,
conectividade e reconciliacao de falhas apos efeito remoto.

------------------------------------------------------------------------

## AUD-L2-R5.5-E â€” Retry, Backoff, Connectivity e Reconciliacao

**Data:** 24/08/2026
**Branch:** `audit/aud-l2-r5-5-e-retry-reconciliation`
**Baseline:** `57767c55d16e9dd8a02945d60df3c320f83e3e78`
**Tipo:** Orquestracao / resiliencia / reconciliacao

### Escopo

- `EvidenceSyncConnectivityProbe`;
- adaptador `connectivity_plus`;
- `EvidenceSyncRetryPolicy`;
- `EvidenceSyncRetryCoordinator`;
- `EvidenceSyncConfirmationException`;
- `reconciliationObjectKey` no job duravel;
- backoff exponencial;
- limite de tentativas;
- bloqueio de falhas nao retryable;
- estabilidade obrigatoria do `objectKey` em reconciliacao;
- tipagem de falha de persistencia apos efeito remoto.

### Decisoes

1. transporte continua com uma unica tentativa;
2. sem rede nao incrementa `attemptCount`;
3. falha retryable incrementa tentativa e agenda `nextAttemptAt`;
4. falha nao retryable bloqueia;
5. retry apos possivel efeito remoto preserva chave confiavel;
6. grant posterior com outra chave bloqueia antes do PUT;
7. `objectKey` final permanece exclusivo de `synced`;
8. `SyncService` permanece sem logica de evidencia nesta etapa.

### Backoff padrao

- base: 30 segundos;
- teto: 30 minutos;
- maximo: 6 tentativas;
- sem jitter nesta versao.

### Ajustes durante a validacao

**R1 â€” const-evaluation**

`EvidenceSyncRetryPolicy` deixou de usar construtor `const`. As comparacoes de
`Duration` permanecem validadas por asserts em runtime.

**R2 â€” regressao R5.5-D**

Os testes anteriores do upload coordinator passaram a exigir
`EvidenceSyncConfirmationException` com os codigos:

- `objectKeyMismatch`;
- `sizeMismatch`;
- `jobChanged`.

### Validacao final

- teste legado R5.5-D: aprovado;
- teste focado R5.5-E: aprovado;
- regressao `test/core/sync`: aprovada;
- `flutter analyze`: 0 issues;
- `git diff --check`: aprovado;
- escopo: 11 caminhos.

### Parecer

AUD-L2-R5.5-E: **HOMOLOGADO LOCALMENTE**.

A etapa fecha a politica local de resiliencia de evidencias sem violar os
limites definidos no R5.4/R5.5:

- broker continua fornecendo a identidade remota confiavel;
- transporte continua sem retry automatico;
- fila duravel registra tentativa e proxima janela;
- falhas definitivas sao bloqueadas;
- efeito remoto incerto preserva a mesma identidade para reconciliacao;
- sucesso final continua exigindo confirmacao persistida.

## AUD-L2-R5.5-F â€” Fechamento de idempotencia e integracao

**Data:** 26/08/2026
**Baseline:** `07886ffc59823dbfc3b7cdd754d0a51dff45c979`
**Branch:** `audit/aud-l2-r5-5-f-idempotency-closure`

Implementado:

- `EvidenceUploadIdentity`;
- `idempotencyKey` canonica no request;
- binding de identidade no grant de upload;
- validacao fail-closed no Grant Coordinator;
- single-flight local no Retry Coordinator;
- testes de binding ausente/divergente;
- teste de concorrencia local.

Regra bloqueante: o backend remoto real deve garantir

`acaoId + evidenciaId + sha256 -> mesma objectKey`

antes de `remoteStorageEnabled` poder ser habilitado.

### Validacao final R5.5-F

- Grant Coordinator: aprovado;
- Retry Coordinator: aprovado;
- regressao `test/core/sync`: aprovada;
- regressao `test/core/storage`: aprovada;
- `flutter analyze`: 0 issues;
- `git diff --check`: aprovado;
- escopo final: 9 caminhos.

### Parecer

AUD-L2-R5.5-F: **HOMOLOGADO LOCALMENTE**.

Fica registrado como gate bloqueante que o backend remoto devera garantir:

`acaoId + evidenciaId + sha256 -> mesma objectKey autoritativa`

antes da habilitacao de `remoteStorageEnabled`.

O single-flight implementado nesta etapa e local ao processo e nao substitui
qualquer mecanismo futuro de coordenacao distribuida.

### AUD-L2-R5.6-A â€” Preparation Contract

Baseline: `4058bab930259ffaa4d862bf4367b236b1caabe4`.

Foi introduzida a fronteira provider-neutral de preparacao de evidencias,
preservando o original local e exigindo artefato derivado separado antes do
calculo de SHA-256/tamanho/MIME.

Escopo propositalmente sem compressao concreta, sem alteracao do fluxo
operacional, sem provider remoto e sem habilitacao de storage.

#### AUD-L2-R5.6-A - Homologacao local

Status: HOMOLOGADO LOCALMENTE - NAO COMMITADO / NAO PUBLICADO.

Gates aprovados:

- EvidencePreparation test;
- regressao core/storage;
- flutter analyze com 0 issues;
- git diff --check;
- exatamente 6 caminhos no escopo.

Decisao preservada:

`original -> prepare -> metadata -> identity -> queue`

SHA-256, tamanho e MIME destinados ao sync devem representar
exatamente o artefato preparado. O original local nao deve ser
sobrescrito ou comprimido in-place.

Proxima etapa autorizavel: AUD-L2-R5.6-B.
------------------------------------------------------------------------

## AUD-L2-R5.6-C - Pipeline Integration & Artifact Lifecycle

**Data:** 28/08/2026
**Branch:** `audit/aud-l2-r5-6-c-pipeline-integration-artifact-lifecycle`
**Baseline:** `66e51c788d7ca40b0fe7b306521c1df13fdbab84`
**Tipo:** integracao de pipeline / lifecycle local / fail-closed
**Status:** HOMOLOGADO LOCALMENTE - PRE-COMMIT

### Diagnostico

O fluxo local ja preservava o original e o R5.6-B ja produzia JPEG
deterministico separado. Faltava conectar esse artefato ao snapshot duravel da
fila sem misturar metadata do original com metadata do upload.

### Implementacao

Foram introduzidos:

- `ApplicationDocumentsEvidencePreparedPathResolver`;
- `EvidencePreparedArtifactLifecycle`;
- `EvidenceUploadEnrollmentCoordinator`;
- `EvidenceSyncPipelineCoordinator`;
- quatro suites de testes R5.6-C.

### Contrato consolidado

`original -> prepare -> metadata prepared -> EvidenceSyncJob -> store -> R5.5`

O job duravel passa a ser a fonte local do snapshot destinado ao transporte.

Re-enrollment identico nao reseta `retryScheduled`, `blocked` ou `synced`.

Snapshot divergente para a mesma identidade falha fechado e nao sobrescreve o
job existente.

Cleanup so ocorre depois de sync duravelmente confirmado. Falha ao remover o
derivado nao reabre upload.

### Protecao de lifecycle

A remocao e restrita a `.jpg` sob:

`GEDUC/evidence_upload_artifacts/`

Arquivos do original em `GEDUC/evidencias/` ficam fora dessa raiz e sao
recusados pelo lifecycle.

### Ajuste R1A

O primeiro gate encontrou falha em teste de snapshot divergente.

A implementacao de producao ja executava o cleanup antes do `StateError`.
O defeito era o teste nao aguardar explicitamente o Future antes de verificar a
existencia do arquivo.

R1A substituiu o assert assincrono pela forma `await expectLater(...)`.

Nenhum codigo de producao foi alterado no R1A.

### Validacao final pre-commit

```text
Teste exato R1A:               aprovado
Testes focais R5.6-C:          aprovados
Regressao test/core/storage:   aprovada
Regressao test/core/sync:      aprovada
flutter test completo:         aprovado
flutter analyze:               0 issues
git diff --check:              aprovado
Escopo final:                  11 caminhos Git
Commit:                        nao executado
Push:                          nao executado
PR:                            nao executado
remoteStorageEnabled:          inalterado / false
R5.7:                          nao iniciado
```

### Parecer

AUD-L2-R5.6-C: **HOMOLOGADO LOCALMENTE PARA PRE-COMMIT**.

A proxima fronteira permitida e o commit controlado, mediante autorizacao
separada.

<!-- AUD-L2-R5.7-BEGIN -->
## 2026-08-28 - AUD-L2-R5.7 - Integrated Evidence Tests & Final Homologation

Baseline: `c151d3934c47809f0a788192e365f5e5b3467a89`

Branch: `audit/aud-l2-r5-7-integrated-tests-final-homologation`

### Resultado

R5.7 homologado tecnicamente como pacote exclusivamente de testes, sem
alteracao de codigo de producao.

Arquivos de teste introduzidos:

- `test/support/evidence/evidence_r5_7_test_harness.dart`;
- `test/core/integration/evidence_r5_7_happy_path_test.dart`;
- `test/core/integration/evidence_r5_7_retry_reconciliation_test.dart`;
- `test/core/integration/evidence_r5_7_fail_closed_test.dart`.

O harness exercita componentes reais de preparacao, enrollment, store,
orchestrator, grant, upload, retry e pipeline. Somente conectividade, broker,
transporte e relogio sao doubles controlados.

### Cenarios homologados

- happy path completo ate `synced` + cleanup;
- preservacao byte a byte do original;
- metadata/SHA do preparado;
- persistencia duravel do job;
- retry com backoff;
- reconciliation com chave confiavel;
- idempotency key estavel entre tentativas;
- rede indisponivel sem efeitos remotos;
- grant com identity binding divergente;
- objectKey divergente durante reconciliation;
- retorno remoto incoerente;
- conflito concorrente de estado apos efeito remoto;
- lifecycle recusando remocao fora da raiz preparada.

### Correcoes de homologacao

R1: adicionados imports explicitos de
`evidence_sync_retry_coordinator.dart` nos tres testes que usam
`EvidenceSyncCycleStatus`.

R2: removido import nao utilizado de `evidence_sync_store.dart` no harness.

Ambas as correcoes ficaram restritas a teste.

### Gates finais

- Gate 1 - integrados R5.7: APROVADO;
- Gate 2 - `test/core/storage`: APROVADO;
- Gate 3 - `test/core/sync`: APROVADO;
- Gate 4 - `flutter test`: APROVADO;
- Gate 5 - `flutter analyze`: APROVADO / 0 issues;
- Gate 6 - `git diff --check`: APROVADO;
- Gate 7 - escopo final: APROVADO.

### Fronteiras preservadas

- `remoteStorageEnabled=false`;
- armazenamento local obrigatorio/local-first;
- zero alteracoes de producao;
- nenhuma credencial permanente no cliente;
- backend/R2/B2/Firebase Storage fora do escopo;
- commit, push, PR e merge nao executados nesta fronteira.

Parecer: AUD-L2-R5.7 HOMOLOGADO TECNICAMENTE E DOCUMENTADO PARA PRE-COMMIT.
<!-- AUD-L2-R5.7-END -->

---

## 2026-09-09 â€” AUD-L2-FC1.3 â€” Supply Chain Dependency Remediation

Durante o fechamento consolidado da Auditoria Lote 2 foi identificado novo
risco transitivo na toolchain Node: 14 vulnerabilidades, sendo 12 moderate e
2 high.

O audit de produÃ§Ã£o comprovou zero vulnerabilidades, restringindo o achado Ã s
devDependencies de engenharia.

RemediaÃ§Ã£o homologada:

- firebase-tools 15.25.1 -> 15.30.0;
- fast-uri -> 3.1.7 por override compatÃ­vel;
- js-yaml -> 4.3.2 por override compatÃ­vel;
- zero high;
- zero critical;
- 12 moderate residuais;
- audit de produÃ§Ã£o com zero vulnerabilidades;
- Firestore Rules 22/22;
- MIG-001E3 25/25;
- MIG-001E4 15/15;
- MIG-001E5 16/16;
- MIG-001E6 12/12;
- Flutter Test 919/919;
- Flutter Analyze 0 issues;
- git diff --check aprovado.

Nenhum cÃ³digo Flutter, regra Firestore, App Check, Storage, RBAC ou identidade
Android foi alterado.

Status: HOMOLOGADO LOCALMENTE â€” PRE-COMMIT.

---

## 2026-09-09 - AUD-L2-FC1.4 - Reconciliacao Documental

A auditoria documental de fechamento do Lote 2 identificou drift historico em registros PRE-COMMIT / NAO PUBLICADO.

Os documentos historicos foram deliberadamente preservados.

Foi adotada reconciliacao por camada consolidada, sem reescrita em massa dos READMEs de etapa.

Estado consolidado:

- R1: concluido e publicado;
- R2: concluido e publicado;
- R3: concluido e publicado;
- R4: concluido e publicado;
- R5: concluido e publicado na fronteira tecnica homologada;
- R6: concluido e publicado;
- R7: implementacoes tecnicas incorporadas a main, com requisitos produtivos transferidos;
- AUD-L2-FC1.3: publicado pelo PR #73.

Pendencias transferidas:

- applicationId Android definitivo;
- Firebase App Check Console/enforcement;
- Storage remoto, regras e testes;
- homologacao PDF Unicode;
- saneamento da fonte historica.

A carga historica permanece SUSPENSA.

Classificacao: DRIFT DOCUMENTAL HISTORICO - NAO BLOQUEANTE.

Documento consolidado oficial: README_AUD-L2-FC1.4.md.

Proxima etapa: AUD-L2-FC1.5 - Parecer Final e Encerramento Formal da Auditoria Lote 2.

---

## 2026-09-09 - AUD-L2-FC1.5 - Parecer Final e Encerramento Formal

A Auditoria Lote 2 da Plataforma Fenix atingiu sua fronteira formal de encerramento.

Parecer final:

- R1: CONCLUIDO;
- R2: CONCLUIDO;
- R3: CONCLUIDO;
- R4: CONCLUIDO;
- R5: CONCLUIDO NA FRONTEIRA TECNICA HOMOLOGADA;
- R6: CONCLUIDO;
- R7: CONCLUIDO NO ESCOPO DA AUDITORIA, com requisitos produtivos transferidos;
- FC1.3: CONCLUIDO E PUBLICADO;
- FC1.4: CONCLUIDO E PUBLICADO.

Nao permanecem bloqueadores para o encerramento formal da Auditoria Lote 2.

O encerramento da Auditoria Lote 2 NAO constitui autorizacao para publicacao produtiva.

Pendencias transferidas:

- REL-BLK-001: Android applicationId definitivo;
- SEC-NEXT-001: Storage remoto, regras e testes;
- SEC-NEXT-002: Firebase App Check Console, Play Integrity e enforcement;
- OBS-REL-001: homologacao visual PDF Unicode.

A migracao historica permanece SUSPENSA por qualidade da fonte.

remoteStorageEnabled permanece false.

Nao existe storage.rules produtivo versionado na fronteira de encerramento.

Quality Gates versionados:

- Flutter Analyze;
- Flutter Test;
- Firestore Rules;
- Dependency Review;
- Secret Scan;
- Migration Importer.

Baseline de encerramento:
7056f2798c2565f9bfa3ca79add075906e3711d0

Conclusao:

PARECER FAVORAVEL AO ENCERRAMENTO FORMAL DA AUDITORIA LOTE 2.

Proxima frente: SEGURANCA E RELEASE READINESS.

## 2026-09-12 15:14:52 -03:00 â€” SEC-R2-002A â€” Evidence Worker Backend R2

Data: 2026-09-12 15:14:52 -03:00
Sprint: SEC-R2-002A â€” A.1 a A.6A-R1
Branch: security/sec-r2-002a-backend-r2
Tipo: implementaÃ§Ã£o de seguranÃ§a backend
Resumo: criaÃ§Ã£o e homologaÃ§Ã£o do Evidence Worker R2.

DecisÃµes:

- contrato de evidÃªncias separado do cliente Flutter;
- ACL explÃ­cita;
- caller e autor tratados como identidades distintas;
- capability HMAC-SHA256 com expiraÃ§Ã£o;
- chave HMAC mÃ­nima de 256 bits;
- ArrayBuffer explÃ­cito nas chamadas WebCrypto;
- remoteStorageEnabled preservado como false.

ValidaÃ§Ã£o:

- capability: 7/7;
- suÃ­te consolidada: 47/47;
- typecheck: PASS;
- Flutter Analyze: PASS, 0 issues;
- git diff check: PASS;
- homologaÃ§Ã£o funcional: APROVADA.

Documentos relacionados:

- docs/SEC-R2-002A_BLUEPRINT.md;
- docs/01_PLATFORM_ARCHITECTURE.md;
- README_SEC-R2-002A.md;
- tools/manifestos/SEC-R2-002A-A6A-HOMOLOGADO.txt.

PrÃ³xima aÃ§Ã£o:

- publicar a branch;
- abrir PR contra main;
- aguardar quality gates remotos;
- nÃ£o ativar Storage produtivo nesta fronteira.

<!-- SEC-R2-002A-A6A-END -->

## 2026-09-13 - SEC-R2-002A.6B - Emissao do upload grant

Sprint: SEC-R2-002A.6B-R3
Branch: `security/sec-r2-002a-6b-grant-capability`
Baseline: `38682e679144d0b0c05439b698cce8ca049d7111`
Tipo: implementacao de seguranca backend
Status: HOMOLOGADO LOCALMENTE / PRE-COMMIT

Implementacao:

- novo contrato `evidence_grant.ts`;
- emissao integrada apos autenticacao, contrato e ACL;
- verificacao autoritativa obrigatoria de `autorUserId`;
- caller e autor preservados como identidades distintas;
- `objectKey` e idempotencia derivadas server-side;
- capability HMAC-SHA256 com TTL maximo de 300 segundos;
- response compativel com `EvidenceAccessGrant`;
- falhas do emissor tratadas sem vazamento de erro interno.

Validacao:

- testes focados A.6B: 23/23;
- suite Evidence Worker: 57/57;
- TypeScript typecheck: PASS;
- Flutter Test: 971/971;
- Flutter Analyze: PASS, 0 issues;
- hashes, registrants, diff check e escopo: PASS.

Fronteiras preservadas:

- PUT/R2 permanece fail-closed;
- `remoteStorageEnabled=false`;
- nenhum deploy, bucket, binding ou secret;
- merge depende de autorizacao especifica apos quality gates remotos.

Proxima fronteira tecnica: SEC-R2-002A.6C.
<!-- SEC-R2-002A-A6B-LOG-END -->

## 2026-09-13 - SEC-R2-002A.6C - Validacao do PUT e dos bytes

Sprint: SEC-R2-002A.6C
Branch: `security/sec-r2-002a-6c-put-validation`
Baseline: `4ed6dadd1dc0ba9362874b62d1a13de49dc61f28`
Tipo: implementacao de seguranca backend
Status: HOMOLOGADO LOCALMENTE / PRE-COMMIT

Implementacao:

- verificacao independente de TTL maximo, expiracao e emissao futura;
- limite operacional compartilhado de 10 MiB;
- validacao de Content-Type, idempotencia e Content-Length quando presente;
- bloqueio de Content-Range e codificacao transformadora;
- leitura do stream limitada ao tamanho autorizado;
- conferencia da assinatura JPEG;
- SHA-256 recalculado sobre os bytes reais;
- comparacao canonica da objectKey derivada server-side;
- respostas HTTP fail-closed sem vazamento de detalhes internos.

Validacao:

- testes focados A.6C: 53/53;
- suite Evidence Worker: 80/80;
- TypeScript typecheck: PASS;
- Flutter Test: PASS;
- Flutter Analyze: PASS, 0 issues;
- registrants EOL, hashes, diff check e escopo: PASS.

Fronteiras preservadas:

- PUT validado termina em `501` sem persistencia;
- R2 Binding ausente;
- `remoteStorageEnabled=false`;
- nenhum deploy, bucket, binding ou secret;
- merge depende de autorizacao especifica apos quality gates remotos.

Proxima fronteira tecnica: SEC-R2-002A.6D.
<!-- SEC-R2-002A-A6C-LOG-END -->

## 2026-09-13 - SEC-R2-002A.6D - Idempotencia e porta privada

Sprint: SEC-R2-002A.6D
Branch: `security/sec-r2-002a-6d-idempotency-port`
Baseline: `987ae5a534b9bff1b1299cd437822052a688713c`
Tipo: implementacao de seguranca backend
Status: HOMOLOGADO LOCALMENTE / PRE-COMMIT

Implementacao:

- contrato provider-neutral `EvidencePrivateStoragePort`;
- criacao atomica obrigatoria por `createIfAbsent`;
- ausencia deliberada de sequencia `HEAD` + `PUT`;
- `AtomicEvidenceUploadPersister` apos o validador A.6C;
- identidade imutavel derivada server-side;
- caller e autor preservados como identidades distintas;
- sucesso `201` para criacao e `200` para repeticao identica;
- conflito `409` para qualquer divergencia;
- porta ausente ou indisponivel em `503` fail-closed;
- respostas sem URL ou detalhe interno do storage.

Validacao:

- testes focados A.6D: 53/53;
- suite Evidence Worker: 99/99;
- TypeScript typecheck: PASS;
- Flutter Test: PASS;
- Flutter Analyze: PASS, 0 issues;
- registrants EOL, hashes, diff check e escopo: PASS.

Fronteiras preservadas:

- adapter e R2 Binding ausentes;
- `remoteStorageEnabled=false`;
- nenhum deploy, bucket, binding ou secret;
- merge depende de autorizacao especifica apos seis quality gates remotos.

Proxima fronteira tecnica: SEC-R2-002A.6E.
<!-- SEC-R2-002A-A6D-LOG-END -->

<!-- SEC-R2-002A-A6E-LOG-START -->
## 2026-09-15 12:22:43 -03:00 - SEC-R2-002A.6E

Fechamento da implementacao local do adapter Cloudflare R2.

Validacoes de homologacao:
- A.6E focado: 65/65 PASS;
- Evidence Worker: 111/111 PASS;
- TypeScript typecheck: PASS;
- Flutter Test: PASS;
- Flutter Analyze: PASS;
- registrants EOL: CLEAN;
- git diff --check: PASS;
- escopo e hashes: PASS;
- PUT condicional antes de HEAD: PASS;
- checksum SHA-256: PASS;
- metadados canonicos: PASS;
- idempotencia integral: PASS;
- sobrescrita silenciosa: PROIBIDA;
- binding R2 real: AUSENTE;
- remoteStorageEnabled=false.

Fronteira operacional: commit/push/PR e quality gates autorizados; merge, deploy, bucket, binding e secret permanecem fora deste script.
<!-- SEC-R2-002A-A6E-LOG-END -->

<!-- SEC-R2-002A-A6F-LOG-START -->
## 2026-09-15 14:02:27 -03:00 - SEC-R2-002A.6F

Preparacao versionada da infraestrutura Cloudflare R2 concluida em worktree
isolado.

Validacoes:

- baseline: PASS;
- hashes base: PASS;
- escopo pos-aplicacao: PASS;
- escopo pos-testes: PASS;
- MISSING=0;
- EXTRA=0;
- binding R2: PASS;
- `remoteStorageEnabled=false`;
- validator/auth/grant defaults: FAIL-CLOSED;
- `npm ci`: PASS;
- Vitest local: PASS;
- testes A.6F focados: PASS;
- Evidence Worker completo: PASS;
- TypeScript typecheck: PASS;
- Flutter Test: PASS;
- Flutter Analyze: PASS;
- git diff check: PASS;
- checkout principal: CLEAN / INTOCADO.

Fronteira: este fechamento publica codigo/PR. Bucket real, deploy Cloudflare,
secrets e habilitacao produtiva permanecem fora deste script.
<!-- SEC-R2-002A-A6F-LOG-END -->

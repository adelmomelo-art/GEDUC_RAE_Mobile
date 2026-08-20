# ARQUITETURA DA PLATAFORMA FÊNIX

> Documento Oficial de Arquitetura do Sistema de Conhecimento da
> Plataforma Fênix (SKPF)

------------------------------------------------------------------------

## Controle do Documento

  Item        Valor
  ----------- ----------------------------------------
  Documento   01_PLATFORM_ARCHITECTURE.md
  Versão      2.7
  Status      Oficial
  Sprint      SEC-001B-R1 — Quality Gates e Proteção da Main

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
imutabilidade de `createdAt` em `domains`.

A baseline foi publicada no projeto `geduc-rae-mobile` em 02/08/2026, após
autorização expressa, preservação da versão anterior e confirmação do hash
candidato. A fonte remota foi integralmente comparada com `firestore.rules` e
o smoke test pós-deploy foi aprovado sem regressão crítica.

## 18.4 Cadeia administrativa de usuários

A listagem de usuários segue:

``` text
Provider → UsuarioController → UsuarioRepository → UsuarioService → Firestore
```

Falhas de atualização preservam os dados já carregados e oferecem nova
tentativa.

------------------------------------------------------------------------

# 19. Baseline final da ADM-001C

``` text
ADM-001C.1: 072c5a5 — Identidade Confiável
ADM-001C.2: fc575a0 — Política Única de Autorização
ADM-001C.3: 42e3560 — Firestore Security Baseline
ADM-001C.3-R1: 2129355 — restauração das invariantes de domains
ADM-001C.4: 0d3d831 — homologação integrada e encerramento
Code Review: 7cd1104 — aprovação após correção R1
PR nº 3 / merge: 21f8ea2 — integração da ADM-001C
PR nº 4 / merge: b0738ef — encerramento documental pós-merge
PR nº 5 / merge: 6a6794d — sincronização arquitetural pós-merge
Branch oficial: main
Flutter analyze pós-merge: 0 issues
Firebase Emulator Suite: 15/15 testes
Working tree pós-merge: clean
Firestore remoto: baseline segura publicada em 02/08/2026
```

A baseline oficial da Plataforma Fênix após a conclusão da ADM-001C é o
commit `6a6794d` da branch `main`.

A feature branch `feature/adm-001c-identidade-seguranca` e a branch
documental `docs/enc-adm-001c-seguranca` foram removidas após os merges,
conforme o procedimento de encerramento.

## 19.1 Débitos controlados

- a matriz de permissões permanece estática no cliente;
- `acoes` ainda não possui autoria imutável por UID, impedindo política de
  propriedade individual sem evolução do modelo;
- o repositório ainda não possui status checks ou workflows automatizados;
- App Check, Cloud Audit Logs, alertas de segurança e status checks ainda
  exigem avaliação e pacotes próprios de defesa em profundidade.

## 19.2 Controle de publicação

As regras de segurança aprovadas no Firebase Emulator Suite foram publicadas
no Firebase remoto em 02/08/2026, exclusivamente no escopo `firestore:rules`.

O procedimento utilizou projeto explícito, CLI local versionada, preservação da
regra anterior, hash candidato, rollback condicionado, verificação integral da
fonte remota e smoke test não destrutivo. A homologação foi aprovada sem
ressalvas técnicas e não há indicação de rollback.

## 19.3 Sincronização arquitetural pós-merge

A ADM-001C.4-R3 corrige a divergência documental identificada após o
encerramento R2. O Engineering Log já registrava os merges e a validação
pós-merge, enquanto esta arquitetura ainda indicava integração pendente.

A arquitetura oficial passa a refletir o estado real do Git e do GitHub:

- Pull Request nº 3 integrado à `main`;
- Pull Request nº 4 integrado à `main`;
- baseline final da sincronização `6a6794d`;
- branches da ADM-001C encerradas;
- validações pós-merge aprovadas;
- regras remotas publicadas e homologadas pela SEC-001A.

------------------------------------------------------------------------

# 20. Baseline remota de segurança — SEC-001A

## 20.1 Estado publicado

``` text
Projeto Firebase: geduc-rae-mobile
Banco: Cloud Firestore (default)
Data: 02/08/2026
Regra: firestore.rules
SHA-256: 8838A3F097168C342289F51D2746B265AA540457C59AA226819EB730B2CA3BFD
Comparação remota/local: exit code 0
Smoke test pós-deploy: aprovado
Rollback: não indicado
```

## 20.2 Princípios de segurança

A autoridade persistente está no Firestore, e não na visibilidade de widgets
Flutter. Cada requisição exige autenticação, documento operacional existente,
conta ativa, perfil reconhecido e permissão compatível com a coleção.

A arquitetura aplica:

- separação entre autenticação e autorização;
- validação no backend em toda requisição;
- menor privilégio;
- negação por padrão;
- identidade imutável pelo cliente;
- validação estrutural de `domains`;
- testes automatizados positivos e negativos;
- publicação versionada, verificável e reversível somente por decisão humana.

## 20.3 Referências arquiteturais

A baseline foi confrontada com a documentação oficial do Firebase Security
Rules, o OWASP Authorization Cheat Sheet, o OWASP Top 10:2025 A01 e o NIST SP
800-207. O mapeamento completo está em
`docs/SEC-001A_PUBLICACAO_HOMOLOGACAO_REFERENCIAS.md`.

Firebase App Check, Cloud Audit Logs, alertas e automação de CI foram
classificados como defesas complementares a avaliar. Nenhum deles substitui a
matriz de autorização publicada.

## 20.4 Encerramento Git e baseline oficial

``` text
Baseline de entrada da SEC-001A: 6a6794d
Commit preparatório: 9da5c94
Commit documental: 1ba5ba3
Pull Request: nº 6
Merge na main: c8d2d95
Branch oficial: main
Working tree pós-merge: clean
Branch da SEC-001A: removida local e remotamente
```

O commit `6a6794d` permanece como baseline histórica de entrada da SEC-001A e
como encerramento da ADM-001C. Após a publicação, homologação, revisão e merge
do Pull Request nº 6, a baseline oficial da Plataforma Fênix passou a ser o
commit `c8d2d95` da branch `main`.

A sincronização SEC-001A-R1 é exclusivamente documental. Ela não modifica as
regras publicadas, o modelo de dados, o código Flutter ou a configuração do
Firebase e não autoriza nova publicação remota.

------------------------------------------------------------------------

# 21. Quality gates e proteção da main — SEC-001B

## 21.1 Pipeline oficial

O repositório possui o workflow `Quality Gates`, versionado em
`.github/workflows/quality-gates.yml`. Ele é executado em Pull Requests
destinados à `main`, em pushes na `main` e por acionamento manual.

``` text
Pull Request ou push na main
            │
       Quality Gates
        ┌───┴───┐
        │       │
Flutter Analyze Firestore Rules
        │       │
        └───┬───┘
            │
      Ruleset da main
```

Os jobs oficiais são:

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
Permissões do token: contents: read
Actions: fixadas por SHA completo
Deploy Firebase: ausente
```

O workflow não utiliza secrets, service accounts, login Firebase ou
`pull_request_target`. O checkout não persiste credenciais e as execuções
antigas do mesmo ref são canceladas por controle de concorrência.

## 21.3 Ruleset da branch oficial

O ruleset `main-quality-gates`, identificador `20301322`, está `Active` e tem
como alvo a default branch (`main`). A lista de bypass está vazia.

São exigidos:

- Pull Request antes do merge;
- resolução de conversas;
- branch atualizada com a base;
- `Quality Gate - Flutter Analyze` em sucesso;
- `Quality Gate - Firestore Rules` em sucesso;
- restrição de exclusão;
- bloqueio de force push.

O número de aprovações obrigatórias é `0`, compatível com a manutenção atual
por um único responsável. Essa configuração não reduz a obrigatoriedade dos
dois checks técnicos.

## 21.4 Homologação

``` text
Commit do workflow: f7db380
Pull Request do workflow: nº 8
Merge do workflow: 1d279e9
Commit da prova: 7ce49d9
Pull Request da prova: nº 9
Merge da prova: a45c142
HAT-1: aprovada
HAT-2: aprovada — 15/15 testes e analyze sem issues
HAT-3: aprovada — dois jobs remotos em sucesso
HAT-4: aprovada — dois checks Required e merge sem bypass
```

Após o Pull Request nº 9, o push da `main` executou automaticamente o workflow
e foi aprovado em 59 segundos. A validação local pós-merge confirmou
`flutter analyze` sem issues, working tree limpa e sincronização com
`origin/main`.

## 21.5 Baseline e limites

A baseline técnica oficial após a implantação e a prova dos quality gates é o
commit `a45c142` da branch `main`.

A SEC-001B não altera a matriz de autorização, as regras publicadas do
Firestore, o código Flutter ou os dados remotos. As seis vulnerabilidades npm
de severidade moderada identificadas durante `npm ci` permanecem registradas
como dívida de supply chain para tratamento independente.

# 22. Hardening da cadeia npm — SEC-001C

## 22.1 Objetivo e limite arquitetural

A SEC-001C endurece a instalação e a auditoria das dependências usadas nos
testes das regras do Firestore. O fluxo não modifica o código Flutter, as
regras publicadas, os dados remotos nem a matriz de autorização.

## 22.2 Política de scripts de instalação

O npm opera com `strict-allow-scripts=true`. Scripts de instalação somente
podem executar quando o pacote e a versão estiverem registrados em
`allowScripts`:

- `@firebase/util@1.12.1`;
- `protobufjs@7.6.5`;
- `re2@1.26.1`.

O pacote opcional `fsevents`, exclusivo de macOS, permanece explicitamente
negado. Mudanças de versão exigem nova revisão e aprovação.

## 22.3 Gate de vulnerabilidades

O job obrigatório `Quality Gate - Firestore Rules` executa
`npm run audit:security` antes do `npm ci`. O limiar `high` permite registrar
ocorrências moderadas, mas bloqueia automaticamente severidades alta e crítica
antes da instalação e dos testes.

A atualização segura do `re2`, de `1.24.1` para `1.26.1`, reduziu o relatório
de seis para cinco ocorrências moderadas. O uso de `npm audit fix --force`
permanece proibido porque a solução proposta pelo npm exige downgrade para
`firebase-tools@14.23.0`.

## 22.4 Homologação

```text
Baseline de entrada: 3400563
Commit da SEC-001C: 2c16d4d
Pull Request: nº 11
Merge / baseline final: 6b53c8f
HAT-1: aprovada
HAT-2: aprovada — 15/15 testes e analyze sem issues
HAT-3: aprovada — dois checks Required em sucesso
HAT-4: aprovada — workflow pós-merge verde em 43 s
```

Na validação pós-merge, a política de scripts não apresentou pendências, o
audit de severidade retornou sucesso, os 15 testes das regras foram aprovados e
o `flutter analyze` terminou sem issues. A working tree permaneceu limpa.

## 22.5 Risco residual

As cinco ocorrências moderadas remanescentes são transitivas da cadeia do
Firebase CLI, associadas a OpenTelemetry e UUID. Elas continuam visíveis nos
logs, não dispensam monitoramento e deverão ser corrigidas quando houver
atualização compatível sem regressão da toolchain.

------------------------------------------------------------------------


──────────────────────────────────────────────

**Sistema de Conhecimento da Plataforma Fênix (SKPF)**

Documento Oficial

Arquitetura da Plataforma Fênix

Versão 2.8

------------------------------------------------------------------------

## AUD-L2-R4 — ACL operacional e Send Gate

**Data:** 19/08/2026
**Status:** Homologado

A Plataforma Fênix passa a possuir uma cadeia ACL explícita para RAEs novos:

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

1. Nome de coordenador não autoriza avanço; somente identidade canônica.
2. Escopo ambíguo não é resolvido por escolha arbitrária.
3. ACL completa exige Regional, responsável, coordenador, Equipe e Projeto.
4. A chave canônica é `r:<regional>|e:<equipe>|p:<projeto>`.
5. Alteração em qualquer dimensão classificatória invalida a classificação anterior.
6. RAE novo em `rascunho` não pode ser enviado com ACL incompleta ou inconsistente.
7. ACL persistida inconsistente não pode ser silenciosamente normalizada durante o envio.
8. Registros históricos fora de `rascunho` preservam compatibilidade e não recebem bloqueio retroativo.

### Componentes introduzidos

- `RaeAclClassifier`
- `RaeIdentityResolver`
- `RaeScopeResolver`
- `RaeScopeCatalogService`

A integração permanece concentrada em `AcaoController` e `RecursosOperacionaisPage`, sem transferência de decisão de segurança para a interface.
### R4-R1 — Regional Scope Enforcement

A dimensão Regional do `AccessScope` passa a ser obrigatória na resolução do escopo ACL. Antes de avaliar Equipe e Projeto, o `regionalId` do RAE deve estar presente em `AccessScope.regionalIds`. Escopo regional vazio ou incompatível falha de forma fechada.
------------------------------------------------------------------------

## AUD-L2-R5.1 — Arquitetura híbrida de evidências

**Data:** 19/08/2026
**Status:** Homologado localmente

A Plataforma Fênix adota uma fronteira arquitetural para armazenamento remoto de evidências sem alterar a decisão operacional vigente de manter as fotografias no dispositivo.

### Princípio local-first

O `EvidenciaStorageService` permanece responsável pelo armazenamento local e continua sendo obrigatório. A indisponibilidade ou ausência de armazenamento remoto não pode impedir a captura, persistência ou continuidade de uma ação educativa.

```text
Captura da evidência
        |
        v
EvidenciaStorageService
        |
        +--> armazenamento local obrigatório
        |
        +--> EvidenciaModel(status: pendente)
        |
        `--> integração remota futura e opcional
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
- `RemoteEvidenceUploadRequest`: dados mínimos para futura transferência;
- `RemoteEvidenceUploadResult`: resultado neutro da sincronização remota;
- `DisabledRemoteEvidenceStorage`: implementação fail-closed quando não existe provedor configurado;
- `EvidenceStoragePolicy`: política explícita local-first com remoto desligado por padrão.

### Invariantes

1. O armazenamento local é obrigatório.
2. O armazenamento remoto é opcional.
3. Nenhuma credencial de provedor remoto pode ser embutida no APK.
4. A ausência de nuvem não pode impedir a operação de campo.
5. O contrato do aplicativo não deve depender diretamente de Cloudflare, Backblaze, Firebase ou outro fornecedor.
6. O R5.1 não altera `SyncService`, Providers, rotas ou o fluxo atual de evidências.
7. Cloudflare R2 e Backblaze B2 são candidatos futuros, não dependências atuais.
8. Firebase Storage permanece fora do fluxo de fotografias por decisão arquitetural e econômica vigente.

### Homologação

```text
Testes R5.1:                   8/8
flutter analyze:               0 issues
git diff --check:              aprovado
Integração remota ativa:       não
Mudança no fluxo de produção:  não
```

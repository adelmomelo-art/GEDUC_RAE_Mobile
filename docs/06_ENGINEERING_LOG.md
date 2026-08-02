# ENGINEERING LOG

> Diário Oficial de Engenharia da Plataforma Fênix> Sistema de Conhecimento da Plataforma Fênix (SKPF)

------------------------------------------------------------------------

## Controle do Documento

  Item        Valor
  ----------- ----------------------------------------
  Documento   06_ENGINEERING_LOG.md
  Versão      2.3
  Status      Oficial
  Sprint      ADM-001C — Identidade e Segurança

------------------------------------------------------------------------

# 1. Finalidade

O Engineering Log é o registro cronológico oficial da evolução técnica
da Plataforma Fênix.

Seu objetivo é preservar o histórico de decisões, implementações,
auditorias e homologações, permitindo compreender como e por que a
plataforma evoluiu.

------------------------------------------------------------------------

# 2. O que deve ser registrado

Cada entrada deverá registrar, sempre que aplicável:

-   Data;
-   Sprint;
-   Pacote ou Commit;
-   Tipo;
-   Objetivo;
-   Causa raiz;
-   Decisão arquitetural;
-   Arquivos impactados;
-   Resultado do `flutter analyze`;
-   Homologação funcional;
-   HAT-1 e HAT-2;
-   Commit e push;
-   Próximos passos;
-   Referências para ADRs, Blueprints e Auditorias.

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
Decisão arquitetural:

Arquivos alterados:

Validação:
- flutter analyze
- testes
- homologação funcional
- HAT-1
- HAT-2

Documentos relacionados:

Próxima ação:
```

------------------------------------------------------------------------

# 4. Marcos Arquiteturais

Os seguintes eventos devem receber destaque:

-   criação de novos módulos;
-   alterações de arquitetura;
-   integração de serviços;
-   mudanças de modelo de dados;
-   criação de componentes estratégicos;
-   mudanças de escopo de providers;
-   homologações de sprints;
-   validação ou evolução da metodologia de engenharia.

------------------------------------------------------------------------

# 5. Relação com o Git

O Engineering Log complementa o histórico do Git.

Enquanto o Git registra alterações de código, este documento registra o
contexto técnico e arquitetural dessas alterações.

------------------------------------------------------------------------

# 6. Relação com o SKPF

Sempre que uma decisão estrutural ocorrer, deverão ser atualizados:

-   Engineering Log;
-   Documento de Arquitetura;
-   ADR correspondente, quando existir;
-   Blueprint, quando aplicável;
-   Guia de Desenvolvimento, quando houver mudança metodológica.

------------------------------------------------------------------------

# 7. Registros Cronológicos

## 7.1 Sprint Arquitetural 1.0

### AE-001.1B

-   Homologação do Portal Oficial do SKPF.

### AE-001.1A

-   Homologação da Carta de Engenharia.

### AE-001.2

-   Homologação da Arquitetura Oficial da Plataforma.

------------------------------------------------------------------------

## 7.2 EST-005A — Auditoria da Infraestrutura de Providers

**Data:** 30/07/2026
**Branch:** `release/estabilizacao-pv006`
**Tipo:** Auditoria arquitetural e diagnóstico de causa raiz
**Pacotes:** `EST-005A-INFRA-PROVIDERS` e
`EST-005A-INFRA-PROVIDERS-R1`

### Resumo

A auditoria foi iniciada após a ocorrência de
`ProviderNotFoundException` na tela `AvaliacaoPage`.

Foram inspecionados:

1. árvore de providers;
2. árvore de rotas;
3. dependências do `DomainProvider`;
4. pontos de criação, consumo e descarte;
5. construtor e dependências internas do provider.

### Erro observado

`AvaliacaoPage` não localizava uma instância de `DomainProvider` em sua
árvore de contexto.

### Causa raiz

O `DomainProvider` era criado localmente em
`CaracterizacaoAcaoPage`, registrado por
`ChangeNotifierProvider.value` apenas sobre essa página e descartado no
ciclo de vida local.

Como `AvaliacaoPage` é aberta por rota independente, ela ficava fora do
escopo do provider.

### Por que a arquitetura permitiu o erro

O alcance real da dependência não havia sido refletido no escopo de
injeção. Um estado transversal foi tratado como estado local de página.

### Decisão da HAT-1

Promover o `DomainProvider` para o `MultiProvider` global em
`lib/app.dart` e remover sua criação e descarte locais da página de
Caracterização.

**HAT-1:** aprovada.

------------------------------------------------------------------------

## 7.3 EST-005B — Globalização do DomainProvider

**Data:** 30/07/2026
**Branch:** `release/estabilizacao-pv006`
**Pacote:** `EST-005B-GLOBAL-DOMAINPROVIDER-HOMOLOGADO`
**Commit:** `35d41f6`
**Tipo:** Correção arquitetural e estabilização funcional

### Objetivo

Eliminar definitivamente o `ProviderNotFoundException` em
`AvaliacaoPage`, garantindo que o `DomainProvider` esteja disponível
para todas as rotas consumidoras.

### Implementação

-   Registro de `DomainProvider` no `MultiProvider` global de
    `lib/app.dart`.
-   Remoção da criação local do provider em
    `CaracterizacaoAcaoPage`.
-   Remoção do descarte manual da instância local.
-   Consumo da instância global pelas páginas e widgets.
-   Preservação da cadeia:
    `DomainProvider → DomainRepository → DomainService`.

### Arquivos alterados

-   `lib/app.dart`;
-   `lib/modules/acoes/caracterizacao_acao_page.dart`;
-   `lib/modules/avaliacao/avaliacao_page.dart`;
-   `tools/manifestos/EST-005A-INFRA-PROVIDERS.txt`;
-   `tools/manifestos/EST-005A-INFRA-PROVIDERS-R1.txt`;
-   `tools/manifestos/EST-005B-GLOBAL-DOMAINPROVIDER-HOMOLOGADO.txt`.

### Validação técnica

-   Manifesto CPB localizado e processado.
-   10 arquivos incluídos.
-   0 arquivos ausentes.
-   `flutter analyze`: **No issues found!**
-   HAT-1: aprovada.
-   HAT-2: aprovada.

### Homologação funcional

Foram aprovados os seis cenários funcionais previstos:

-   HF-005B.1;
-   HF-005B.2;
-   HF-005B.3;
-   HF-005B.4;
-   HF-005B.5;
-   HF-005B.6.

O erro visual vermelho deixou de ocorrer e o fluxo de Avaliação passou a
acessar corretamente os domínios compartilhados.

### Git

``` text
Commit: 35d41f6
Mensagem:
refactor(domains): globaliza DomainProvider e estabiliza fluxo da Avaliação (EST-005B)

Push:
edbd57f..35d41f6
release/estabilizacao-pv006 -> origin/release/estabilizacao-pv006
```

### Resultado

A causa raiz foi eliminada. O provider agora possui escopo compatível
com seu uso transversal e permanece disponível acima das rotas
independentes.

A EST-005B foi a primeira sprint concluída integralmente com:

-   inspeção arquitetural prévia;
-   princípio Root Cause First;
-   HAT-1;
-   implementação;
-   homologação funcional estruturada;
-   CPB auditável;
-   HAT-2;
-   commit;
-   push.

### Próxima ação

Executar a EST-005D para sincronizar a arquitetura oficial, o Engineering
Log e o Blueprint da integração de domínios com a implementação
homologada.

------------------------------------------------------------------------

## 7.4 EST-005D — Consolidação Arquitetural e Documental

**Data:** 30/07/2026
**Branch:** `release/estabilizacao-pv006`
**Tipo:** Documentação técnica

### Objetivo

Atualizar os documentos oficiais após a globalização do
`DomainProvider`.

### Documentos da entrega

-   `docs/01_PLATFORM_ARCHITECTURE.md`;
-   `docs/06_ENGINEERING_LOG.md`;
-   `docs/SKPF/BP-ISSUE-002A.2_INTEGRACAO_DOMAIN_SERVICE.md`.

### Estado

Arquivos completos preparados para substituição direta.

### Critérios de encerramento

-   revisão dos arquivos pelo responsável do projeto;
-   inspeção do `git diff`;
-   geração do CPB documental;
-   HAT-2 documental;
-   commit e push;
-   working tree clean.

------------------------------------------------------------------------

# 8. Compromisso

Nenhuma alteração estrutural relevante deverá permanecer sem registro
neste documento.

------------------------------------------------------------------------


------------------------------------------------------------------------

## 7.5 ADM-001B.1 — Fundação Administrativa

**Data:** 31/07/2026
**Branch:** `feature/adm-001b1-fundacao-administrativa`
**Commit:** `6049e7d`
**Tipo:** Fundação arquitetural administrativa

### Objetivo

Substituir menus administrativos concorrentes por uma fundação modular,
centralizada e preparada para evolução.

### Implementação

- catálogo central de módulos;
- modelo `AdminModule`;
- estados de disponibilidade;
- permissão preliminar;
- cartão administrativo reutilizável;
- rotas administrativas centralizadas;
- página administrativa responsiva.

### Validação

- `flutter analyze`: **No issues found!**
- homologação funcional: **13/13 cenários aprovados**;
- Central de Domínios: aprovada;
- seis módulos: aprovados;
- responsividade: aprovada;
- navegação e botão Voltar: aprovados.

### Resultado

A Administração deixou de depender de listas literais mantidas
diretamente na página e passou a possuir catálogo próprio.

------------------------------------------------------------------------

## 7.6 ADM-001B.2 — Camada de Autorização Administrativa

**Data:** 31/07/2026
**Branch:** `feature/adm-001b2-autorizacao-administrativa`
**Commit:** `ff32e74`
**Tipo:** Segurança, autorização e proteção de rotas

### Objetivo

Centralizar decisões de autorização por perfil e proteger as rotas
administrativas independentemente da visibilidade dos botões.

### Implementação

- `Permission`;
- `AuthorizationPolicy`;
- `AuthorizationResult`;
- `AuthorizationService`;
- `RouteGuard`;
- `AccessDeniedPage`;
- filtragem dos módulos administrativos;
- integração com o roteador;
- correção da visibilidade da Administração para o perfil gestor.

### Matriz homologada

| Perfil | Resultado |
|---|---|
| Administrador | Acesso total |
| Gestor | Domínios, Usuários e Tipos de Ações |
| Coordenador | Administração oculta e rota bloqueada |
| Agente | Administração oculta e rota bloqueada |

### Validação técnica

- `flutter analyze`: **No issues found!**
- CPB homologado: 17 arquivos;
- arquivos ausentes: 0;
- `git diff --cached --check`: sem erros.

### Homologação funcional

- Android/tablet: aprovada para os quatro perfis;
- Central de Domínios: sem regressão;
- navegação: aprovada;
- tela vermelha: não identificada;
- travamentos: não identificados.

### Homologação Web

O perfil `agente` tentou acessar diretamente uma rota administrativa no
Flutter Web e foi redirecionado para `Acesso não autorizado`.

A tela apresentou corretamente:

- perfil identificado;
- mensagem de bloqueio;
- retorno ao Centro de Operações;
- ausência de exceções no Console.

### Resultado

A interface deixou de ser a única barreira de acesso. A Plataforma
Fênix passou a possuir proteção também na camada de navegação.

------------------------------------------------------------------------

## 7.7 Pull Request nº 1 — Primeira Code Review Arquitetural

**Data:** 31/07/2026
**Base:** `main`
**Head:** `feature/adm-001b2-autorizacao-administrativa`
**Merge:** `08f969d`

### Conteúdo

O Pull Request integrou:

- ADM-001B.1 — Fundação Administrativa;
- ADM-001B.2 — Camada de Autorização Administrativa.

### Revisão

Foram avaliados:

- arquitetura;
- segurança;
- navegação;
- regressões;
- qualidade;
- documentação;
- homologações;
- rastreabilidade Git.

### Parecer

``` text
Arquitetura: aprovada
Segurança: aprovada
Navegação: aprovada
Qualidade: aprovada
Homologação: aprovada
Resultado: aprovado para merge
```

### Pós-merge

- `main` sincronizada com `origin/main`;
- `flutter analyze`: **No issues found!**;
- `working tree clean`;
- nova baseline: `08f969d`.

------------------------------------------------------------------------

## 7.8 PF-ENG 003/2026 — Política Oficial de Engenharia

**Data de adoção:** 31/07/2026
**Status:** Oficial

### Decisão

Alterações estruturais passam a exigir:

1. inspeção;
2. Blueprint;
3. plano;
4. feature branch;
5. implementação;
6. `flutter analyze` com 0 issues;
7. homologação;
8. CPB;
9. commit;
10. push;
11. Pull Request;
12. Code Review Arquitetural;
13. merge;
14. validação pós-merge;
15. atualização documental.

### Finalidade

- impedir alterações estruturais diretamente na `main`;
- preservar rastreabilidade;
- reduzir regressões;
- formalizar revisão antes da integração;
- manter código e documentação sincronizados.

### Documento relacionado

`docs/PF-ENG-003-2026_POLITICA_DE_ENGENHARIA.md`

------------------------------------------------------------------------

## 7.9 ENC-ADM-001B.2 — Encerramento documental

**Data:** 31/07/2026
**Branch:** `docs/enc-adm-001b2-governanca`
**Tipo:** Consolidação documental

### Objetivo

Sincronizar a arquitetura oficial e o Engineering Log com a baseline
`08f969d`.

### Riscos registrados

- divergência entre `perfil` e `perfilAcesso`;
- verificação direta residual no atalho Administração;
- política de permissões ainda estática.

### Próxima ação

Executar auditoria específica da identidade, perfis e regras do
Firestore antes de ampliar permissões ou implementar novos módulos
administrativos.

------------------------------------------------------------------------

## 7.10 ADM-001C.1 — Identidade Confiável

**Data:** 01/08/2026  
**Commit:** `072c5a5`  
**Branch:** `feature/adm-001c-identidade-seguranca`

### Resultado

- identidade operacional centralizada no `AuthorizationService`;
- validação de documento, conta ativa e perfil reconhecido;
- estados explícitos para cadastro ausente, conta inativa e falha;
- remoção das consultas duplicadas no Login e na Home;
- limpeza da identidade no logout e proteção contra resposta de sessão anterior.

### Correção R1

Foi removida uma notificação prematura que provocava reentrada do GoRouter e
`Stack Overflow`. Após a correção, os testes no tablet confirmaram login,
Home, Administração, logout, retomada de sessão e ausência de tela branca.

### Validação

- `flutter analyze`: **No issues found!**;
- homologação funcional no tablet: aprovada;
- commit e push: concluídos.

------------------------------------------------------------------------

## 7.11 ADM-001C.2 — Política Única de Autorização

**Data:** 01/08/2026  
**Commit:** `fc575a0`  
**Branch:** `feature/adm-001c-identidade-seguranca`

### Resultado

- atalho Administração passou a consumir `Permission`;
- comparações textuais de perfil foram removidas da decisão da interface;
- `/admin-legado` passou a redirecionar ao painel oficial;
- listagem de usuários passou à cadeia Provider → Controller → Repository → Service;
- carregamento, atualização e falha passaram a possuir estados explícitos.

### Validação

- `flutter analyze`: **No issues found!**;
- CPB: 8/8 arquivos;
- homologação funcional no tablet: 10/10 itens;
- commit e push: concluídos.

------------------------------------------------------------------------

## 7.12 ADM-001C.3 — Firestore Security Baseline

**Data:** 01/08/2026  
**Commit:** `42e3560`  
**Branch:** `feature/adm-001c-identidade-seguranca`

### Auditoria

Foram inventariadas oito coleções: `usuarios`, `domains`, `tipos_acoes`,
`coordenadores`, `regionais`, `materiais`, `acoes` e `contadores`.

A regra anterior cobria somente `domains` e consultava o campo incorreto
`perfil`. A baseline passou a utilizar exclusivamente `perfilAcesso`, exigir
usuário ativo e perfil reconhecido e negar por padrão coleções não
inventariadas.

### Validação

- Firebase Emulator Suite com Java 21;
- 15/15 testes positivos e negativos aprovados após Code Review;
- `firebase-tools` 15.25.1;
- zero vulnerabilidades npm altas ou críticas;
- `flutter analyze`: **No issues found!**;
- commit e push: concluídos.

### Controle de publicação

As regras estão versionadas e testadas, porém não foram publicadas no
Firebase remoto. `firebase deploy` permanece condicionado a autorização
expressa e procedimento próprio.

### Correção pós-Code Review

A revisão do PR nº 3 identificou que a primeira baseline havia ampliado a
autorização de `domains` para gestor, conforme a matriz, mas removido
inadvertidamente duas invariantes anteriores: campos mínimos na criação e
imutabilidade de `createdAt`.

A R1 restaurou essas proteções, acrescentou validação de tipos essenciais e
incluiu testes negativos para documento incompleto e alteração de `createdAt`.

------------------------------------------------------------------------

## 7.13 ADM-001C.4 — Homologação integrada e encerramento

**Data:** 01/08/2026  
**Status:** Homologação integrada aprovada — 10/10

### Objetivo

Consolidar as evidências dos três pacotes, executar o checklist final,
sincronizar Arquitetura, Engineering Log e documentação de segurança e
preparar Pull Request para a `main`.

### Baseline de entrada

``` text
ADM-001C.1: 072c5a5
ADM-001C.2: fc575a0
ADM-001C.3: 42e3560
Branch sincronizada com origin
```

### Homologação funcional

O checklist integrado no tablet foi concluído com 10/10 itens aprovados:

- login e identificação;
- Home e indicadores;
- Administração e seis módulos;
- listagem e atualização de usuários;
- navegação de retorno;
- logout e novo login;
- retomada de sessão após reinício;
- ausência de tela branca, exceção ou travamento.

### Critério de encerramento

O status somente mudará para concluído após homologação integrada, CPB final,
commit documental, push, Pull Request, Code Review, merge e validação
pós-merge. A publicação remota das regras permanece uma decisão separada.

──────────────────────────────────────────────

**Sistema de Conhecimento da Plataforma Fênix (SKPF)**

Documento Oficial

Engineering Log

Versão 2.3

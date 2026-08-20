# ENGINEERING LOG

> Diário Oficial de Engenharia da Plataforma Fênix> Sistema de Conhecimento da Plataforma Fênix (SKPF)

------------------------------------------------------------------------

## Controle do Documento

  Item        Valor
  ----------- ----------------------------------------
  Documento   06_ENGINEERING_LOG.md
  Versão      2.7
  Status      Oficial
  Sprint      SEC-001B-R1 — Quality Gates e Proteção da Main

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
**Commit base:** `42e3560`
**Correção R1:** `2129355`
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

O pacote corretivo foi aprovado com 11/11 arquivos, 15/15 testes no emulador,
`flutter analyze` sem issues e working tree limpa. O commit `2129355` foi
publicado na branch do PR nº 3.

------------------------------------------------------------------------

## 7.13 ADM-001C.4 — Homologação integrada e encerramento

**Data:** 01/08/2026
**Status:** Concluída e validada após o merge

### Objetivo

Consolidar as evidências dos três pacotes, executar o checklist final,
sincronizar Arquitetura, Engineering Log e documentação de segurança e
preparar Pull Request para a `main`.

### Baseline de entrada

``` text
ADM-001C.1: 072c5a5
ADM-001C.2: fc575a0
ADM-001C.3: 42e3560
ADM-001C.3-R1: 2129355
Branch sincronizada com origin
Pull Request: nº 3 contra main
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

### Situação após Code Review

- CPB final: 7/7 arquivos;
- CPB corretivo: 11/11 arquivos;
- Pull Request nº 3: integrado à `main`;
- Code Review Arquitetural: aprovada após a correção R1;
- status checks e workflows no GitHub: não configurados;
- merge commit: `21f8ea2`;
- `flutter analyze` pós-merge: sem issues;
- Firestore pós-merge: 15/15 testes aprovados;
- `main` sincronizada e working tree limpa;
- regras remotas: não publicadas.

------------------------------------------------------------------------

## 7.14 ADM-001C — Integração e validação pós-merge

- **Data:** 01/08/2026
- **Pull Request:** nº 3
- **Merge commit:** `21f8ea2`
- **Branch integrada:** `feature/adm-001c-identidade-seguranca`

### Resultado

O Pull Request nº 3 foi integrado à `main` por merge commit, preservando os
seis commits da ADM-001C. A cópia local avançou por fast-forward e permaneceu
sincronizada com `origin/main`.

### Validação pós-merge

- `flutter analyze`: **No issues found!**;
- Firebase Emulator Suite: **15/15 testes aprovados**;
- falhas esperadas de autorização: `PERMISSION_DENIED` confirmado;
- working tree: limpa;
- publicação das regras: não realizada.

### Encerramento

A ADM-001C está formalmente concluída. A publicação remota das regras do
Firestore permanece fora deste encerramento e exige autorização expressa,
backup da versão remota e teste de fumaça posterior.

------------------------------------------------------------------------

## 7.15 ADM-001C.4-R3 — Sincronização Arquitetural Pós-Merge

**Data:** 02/08/2026
**Branch:** `docs/adm-001c4-r3-sincronizacao-arquitetural`
**Tipo:** Correção de consistência documental
**Status:** Concluída após o merge do Pull Request nº 5

### Causa-raiz

O encerramento pós-merge da ADM-001C atualizou o Engineering Log e o README
consolidado, mas não atualizou integralmente a seção de baseline da Arquitetura
da Plataforma. O documento arquitetural ainda informava branch de feature e
integração pendente, embora os Pull Requests nº 3 e nº 4 já estivessem
integrados à `main`.

### Correção preparada

- atualização da Arquitetura da Plataforma para a versão 2.4;
- registro do merge funcional `21f8ea2`;
- registro do encerramento documental `b0738ef`;
- substituição da feature branch pela `main` como branch oficial;
- registro das branches encerradas;
- preservação explícita do bloqueio de `firebase deploy`;
- manutenção dos débitos controlados da ADM-001C.

### Impacto

A alteração é exclusivamente documental. Não modifica código Flutter,
dependências, rotas, providers, modelos, regras do Firestore ou dados remotos.

### Validações executadas

- `git diff --check`: sem erros; avisos LF para CRLF classificados como
  informativos no ambiente Windows;
- `flutter analyze`: `No issues found!` na execução local;
- CPB final em modo `-Full`: `No issues found!`;
- CPB: quatro arquivos solicitados, quatro incluídos, zero ausentes e zero
  comandos com falha;
- branch confirmada: `docs/adm-001c4-r3-sincronizacao-arquitetural`;
- baseline confirmada: `b0738ef`;
- integridade dos quatro arquivos: confirmada por comparação binária;
- HAT-2 final: aprovada sem ressalvas após correção editorial e regeneração do
  CPB.

### Tratamento da ressalva editorial

O README e este Engineering Log ainda registravam o pacote como “preparado
para validação”, embora as validações já estivessem concluídas. A redação foi
atualizada, o CPB foi regenerado e os quatro arquivos foram novamente
comparados antes do versionamento.

### Controle de integração

A correção foi versionada na branch
`docs/adm-001c4-r3-sincronizacao-arquitetural`, submetida ao Pull Request nº 5
e integrada à `main` pelo merge commit `6a6794d`. A validação pós-merge foi
concluída com `flutter analyze` sem issues e working tree limpa. A publicação
remota permaneceu separada até a autorização expressa da SEC-001A.

------------------------------------------------------------------------

## 7.16 SEC-001A — Publicação Controlada das Regras do Firestore

**Data:** 02/08/2026
**Branch:** `security/sec-001a-publicacao-controlada-firestore`
**Commit preparatório:** `9da5c94`
**Commit documental:** `1ba5ba3`
**Pull Request / merge:** nº 6 / `c8d2d95`
**Tipo:** Segurança, publicação remota e homologação
**Status:** Publicação, homologação e integração concluídas sem ressalvas técnicas

### Objetivo

Substituir a regra remota genérica, que concedia leitura e escrita total a
qualquer conta autenticada, pela baseline versionada e testada da ADM-001C.3.

### Baseline anterior

- publicação exibida: `29/07/2026 às 22:31`;
- snapshot: `docs/SEC-001A_BASELINE_REMOTA_FIRESTORE.rules`;
- SHA-256:
  `9537678D49AD35DB5D8F85F7D976FEF36104D7C9C52546E1EF9F3195F65D6805`;
- severidade: crítica, por confundir autenticação com autorização total.

### Preparação e HATs

- Blueprint, plano, README, snapshot e manifesto versionados;
- CPB: 14/14 arquivos, zero ausentes e zero comandos falhos;
- Firebase CLI local: `15.25.1`;
- Firebase Emulator Suite: 15/15 testes aprovados;
- `flutter analyze`: `No issues found!`;
- hash candidato:
  `8838A3F097168C342289F51D2746B265AA540457C59AA226819EB730B2CA3BFD`;
- HAT-1 e HAT-2: aprovadas sem ressalvas técnicas;
- conta ativa e contas inativas preparadas para smoke test;
- rollback condicionado revisado.

### Autorização

O responsável autorizou textual e expressamente a publicação das regras da
SEC-001A no projeto `geduc-rae-mobile`. O comando remoto permaneceu bloqueado
até essa manifestação.

### Publicação

O deploy foi iniciado em `02/08/2026 às 21:04:30`, UTC-03:00, com o executável
local e o projeto explicitamente informado:

```powershell
.\node_modules\.bin\firebase.cmd deploy `
  --only firestore:rules `
  --project geduc-rae-mobile
```

O Firebase CLI confirmou compilação, upload, release para `cloud.firestore` e
`Deploy complete!`. Nenhum dado, índice, função, hosting ou código Flutter foi
publicado.

### Verificação remota

- nova versão confirmada no Console Firebase às 21:05;
- banco confirmado: `(default)`;
- versão anterior preservada no histórico;
- regra remota copiada integralmente após o deploy;
- comparação com `firestore.rules`: exit code `0`;
- working tree: limpa;
- nova publicação: não executada nem necessária.

### Homologação pós-deploy

- administrador ativo: aprovado;
- módulos administrativos: visíveis;
- consultas aos dados existentes: aprovadas;
- lista de usuários: aprovada;
- gestor inativo: bloqueado;
- coordenador inativo: bloqueado;
- agente inativo: bloqueado;
- contas inativas acessaram dados: não;
- tela branca ou exceção: não;
- mensagem de conta inativa: correta e orientativa;
- rollback: não indicado.

O smoke test remoto foi não destrutivo. As escritas e negações permanecem
cobertas pelos 15 testes do Emulador.

### Pesquisa de referência

A pesquisa foi concluída com fontes oficiais do Firebase, Google Cloud, OWASP
e NIST SP 800-207. A baseline publicada atende aos fundamentos de separação
entre autenticação e autorização, menor privilégio, decisão no backend,
negação por padrão, validação estrutural e testes automatizados.

Firebase App Check, Cloud Audit Logs, alertas, CI e revisão periódica de
privilégios foram registrados como evoluções de defesa em profundidade, sem
ressalva à homologação atual.

Referência consolidada:
`docs/SEC-001A_PUBLICACAO_HOMOLOGACAO_REFERENCIAS.md`.

### Encerramento Git

- CPB de encerramento: gerado e revisado;
- registros documentais: versionados no commit `1ba5ba3`;
- Pull Request nº 6: aprovado e integrado;
- merge commit: `c8d2d95`;
- `main`: sincronizada com `origin/main`;
- working tree pós-merge: limpa;
- branch `security/sec-001a-publicacao-controlada-firestore`: removida local e
  remotamente.

------------------------------------------------------------------------

## 7.17 SEC-001A-R1 — Sincronização Documental Pós-Merge

**Data:** 03/08/2026
**Baseline de entrada:** `c8d2d95`
**Tipo:** Correção de consistência documental

### Causa-raiz

O Pull Request nº 6 já havia sido integrado e sua branch removida, mas o README
e o Engineering Log ainda descreviam commit, push, Code Review e merge como
etapas futuras. A Arquitetura registrava corretamente `6a6794d` como baseline
histórica da ADM-001C e de entrada da SEC-001A, porém ainda não declarava
`c8d2d95` como baseline final da Plataforma Fênix após a SEC-001A.

### Decisão documental

- preservar `6a6794d` como baseline histórica de entrada;
- registrar `1ba5ba3` como commit documental;
- registrar o Pull Request nº 6 e o merge `c8d2d95`;
- registrar a remoção local e remota da branch da SEC-001A;
- substituir etapas futuras já executadas por resultados concluídos;
- elevar Arquitetura e Engineering Log para a versão 2.6.

### Limite de escopo

A correção não altera providers, rotas, dependências, código Flutter,
`firestore.rules`, `firebase.json`, testes ou dados remotos. Nenhum comando de
deploy integra a SEC-001A-R1.

------------------------------------------------------------------------

## 7.18 SEC-001B — Automação de testes e proteção da main

**Data:** 03/08/2026

**Baseline de entrada:** `e5dd019`

**Branch da implementação:** `security/sec-001b-quality-gates-ci`

**Commit da implementação:** `f7db380`

**Pull Request / merge:** nº 8 / `1d279e9`

**Tipo:** Segurança de integração contínua e governança Git

**Status:** HAT-1 a HAT-4 aprovadas; sincronização documental final preparada

### Problema

Os 15 testes das regras do Firestore e o analisador Flutter estavam disponíveis
e aprovados localmente, mas não existia workflow no repositório nem gate remoto
obrigatório. A integração na `main` dependia de execução e conferência manuais.

### Decisão

Foi criado o workflow `Quality Gates` com dois jobs independentes:

- `Quality Gate - Flutter Analyze`;
- `Quality Gate - Firestore Rules`.

O workflow é iniciado em Pull Requests para a `main`, em pushes na `main` e por
`workflow_dispatch`. Não há filtros de caminho, deploy Firebase, secrets,
service accounts ou `pull_request_target`.

### Controles de supply chain

- `GITHUB_TOKEN` limitado a `contents: read`;
- checkout sem persistência de credenciais;
- actions fixadas por SHA completo;
- Node `24.18.0`;
- Java `21`;
- Flutter `3.44.4` stable;
- Firebase CLI `15.25.1`;
- testes executados no projeto isolado `geduc-rae-mobile-test`.

### HAT-2 — validação local

- `npm ci`: aprovado;
- Firestore Emulator Suite: 15/15 testes aprovados;
- `flutter pub get`: aprovado;
- `flutter analyze`: `No issues found!`;
- diff: 6 arquivos e 498 inserções;
- commit: `f7db380`;
- working tree: limpa.

O npm registrou seis vulnerabilidades moderadas e avisos de scripts de
instalação para três pacotes. Nenhuma correção automática foi aplicada. O tema
permanece como débito controlado de supply chain.

### HAT-3 — Pull Request nº 8

Os dois jobs foram executados e aprovados no Pull Request. O merge foi concluído
em `1d279e9`, seguido por nova execução automática na `main`. Uma execução
manual adicional também foi aprovada em 46 segundos. O `flutter analyze` local
pós-merge permaneceu sem issues.

### Ruleset

Foi criado o ruleset `main-quality-gates`, identificador `20301322`, com estado
`Active`, alvo na default branch e bypass vazio.

Controles ativos:

- Pull Request obrigatório;
- resoluções de conversas obrigatórias;
- branch atualizada com a base;
- dois checks obrigatórios com origem GitHub Actions;
- restrição de exclusão;
- bloqueio de force push.

### HAT-4 — prova controlada

**Branch:** `docs/sec-001b-hat4-prova-ruleset`

**Commit:** `7ce49d9`

**Pull Request / merge:** nº 9 / `a45c142`

O Pull Request documental exibiu ambos os checks como `Required`. Firestore
Rules foi aprovado em 34 segundos e Flutter Analyze em 48 segundos. O merge
foi concluído sem bypass somente após os dois sucessos.

O push pós-merge da `main` iniciou automaticamente a execução nº 5 do workflow,
concluída com sucesso em 59 segundos. A cópia local foi sincronizada em
`a45c142`; `flutter analyze` retornou `No issues found!` em 135,1 segundos e a
working tree permaneceu limpa.

### Parecer

``` text
HAT-1: APROVADA
HAT-2: APROVADA
HAT-3: APROVADA
HAT-4: APROVADA
Ressalvas técnicas: nenhuma
Baseline técnica final: a45c142
```

### Limite de escopo

A SEC-001B não modifica código funcional, regras do Firestore, dados remotos ou
configuração Firebase. O tratamento das vulnerabilidades moderadas do npm e a
remoção das branches de trabalho ocorrerão em fluxo separado e controlado.

## 7.19 SEC-001C — hardening da cadeia de dependências npm

**Data:** 03/08/2026

**Baseline de entrada:** `main` em `3400563`

**Branch:** `security/sec-001c-hardening-supply-chain`

**Commit:** `2c16d4d86c7a4d25f421cb0e36f79b6d58c1d5df`

**Pull Request / merge:** nº 11 / `6b53c8f`

### Diagnóstico

O `npm audit` inicial encontrou seis ocorrências moderadas, zero alta e zero
crítica. O limiar `high` retornou sucesso. A inspeção de scripts identificou
`@firebase/util@1.12.1`, `protobufjs@7.6.5` e `re2@1.24.1` sem decisão
registrada. O `npm outdated` apontou apenas uma nova versão major de
`@firebase/rules-unit-testing`, mantida fora deste escopo.

### Implementação

- atualização segura do `re2` para `1.26.1`, sem `--force`;
- ativação de `strict-allow-scripts=true`;
- aprovação versionada dos três scripts revisados;
- negação explícita de `fsevents`;
- scripts `audit:security` e `audit:scripts` no `package.json`;
- auditoria de severidade antes do `npm ci` no gate obrigatório de Firestore.

O relatório final contém cinco ocorrências moderadas. A correção forçada não
foi aceita porque propõe downgrade para `firebase-tools@14.23.0`.

### HAT-2 — validação local e CPB

`npm ci`, a política de scripts e o audit de severidade foram aprovados. Os 15
testes das regras do Firestore passaram e `flutter analyze` retornou
`No issues found!`.

O CPB
`SEC-001C-HARDENING-SUPPLY-CHAIN_2026-08-03_13-39-46.zip`, SHA-256
`3803BDCD0ECB8EA0354C8C8611F43ADC379203E63E06FAD536D6147420D1707A`,
foi aprovado com 9/9 arquivos exatos e analyze sem issues em 110,6 segundos.

### HAT-3 — Pull Request nº 11

O Pull Request não apresentou conflitos. `Quality Gate - Firestore Rules` foi
aprovado em 32 segundos e `Quality Gate - Flutter Analyze` em 53 segundos;
ambos estavam marcados como `Required`. O merge ocorreu sem bypass.

### HAT-4 — pós-merge

O merge commit `6b53c8fe0964d91dc018799bcff8fcd429fa53af` tornou-se a
baseline oficial. O workflow automático da `main` concluiu em verde em 43
segundos. Localmente, não havia scripts pendentes, o audit de severidade
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
Risco residual: cinco ocorrências moderadas transitivas monitoradas
Baseline técnica final: 6b53c8f
```

──────────────────────────────────────────────

**Sistema de Conhecimento da Plataforma Fênix (SKPF)**

Documento Oficial

Engineering Log

Versão 2.8

------------------------------------------------------------------------

## AUD-L2-R4 — Encerramento ACL operacional

**Data:** 19/08/2026
**Status:** Homologado; preparado para commit único

### Objetivo

Concluir o hardening da classificação de acesso dos RAEs, vinculando identidade canônica e escopo operacional antes da persistência da classificação ACL e impedindo o envio de novos RAEs com classificação incompleta ou inconsistente.

### Resultado por etapa

- **R4.1 — ACL Core:** classificador central e chave canônica.
- **R4.2 — Identity Binding:** responsável e coordenador vinculados por identidade canônica.
- **R4.3 — Scope Resolver:** Regional, Equipe e Projeto resolvidos de forma determinística e fail-closed.
- **R4.4-A — Final Classification:** classificação final persistida e invalidada quando suas entradas mudam.
- **R4.4-B — Send Gate:** envio de RAE em rascunho condicionado à integridade da ACL.

### Proteções consolidadas

- fallback nominal não concede autorização;
- coordenador canônico deriva de `usuarioId`;
- escopo ambíguo permanece não resolvido;
- `aclScopeKey` é validada contra os identificadores efetivamente persistidos;
- chave inconsistente bloqueia envio;
- alteração posterior de identidade ou escopo invalida classificação anterior;
- registro legado fora de rascunho não sofre bloqueio ACL retroativo.

### Homologação

```text
RaeAclClassifier:              8/8
AcaoController ACL:            9/9
R4.4-A Final Classification:   7/7
R4.4-B Send Gate:              5/5
Regressao completa:            755/755
flutter analyze:               No issues found
git diff --check:              sem erro de whitespace
```

O aviso de conversão LF para CRLF apresentado pelo Git em ambiente Windows foi classificado como informativo e não representa falha de whitespace.

### Parecer

`AUD-L2-R4`: **HOMOLOGADO**.

O lote está autorizado para registro em commit único. Push, Pull Request e merge permanecem etapas separadas e dependem de autorização própria.
### Correção R1 — Regional Scope Enforcement

A Code Review do PR #40 identificou que `AccessScope.regionalIds` não participava da resolução R4.3. A R1 tornou a dimensão Regional obrigatória no `RaeScopeResolver`: escopo regional vazio ou Regional fora do conjunto permitido falha de forma fechada antes da resolução de Equipe e Projeto.

Foram adicionadas regressões explícitas para Regional fora e dentro do `AccessScope`. A `RecursosOperacionaisPage` passou a encaminhar `escopo.regionalIds` ao resolver.
------------------------------------------------------------------------

## AUD-L2-R5.1 — Fundação de Evidence Storage

**Data:** 19/08/2026
**Branch:** `audit/aud-l2-r5-evidence-storage-architecture`
**Status:** R5.1 homologado; R5.1-R1 em validação

### Contexto

A análise do armazenamento de evidências confirmou que as fotografias permanecem salvas localmente no dispositivo. A não utilização de Firebase Storage é uma decisão arquitetural consciente associada ao controle de custos.

Foi aprovada a criação de uma camada abstrata para permitir futura sincronização remota sem retirar do armazenamento local o papel de fonte operacional.

### Implementação

Foram introduzidos:

- `lib/core/storage/remote_evidence_models.dart`;
- `lib/core/storage/remote_evidence_storage.dart`;
- `lib/core/storage/disabled_remote_evidence_storage.dart`;
- `lib/core/storage/evidence_storage_policy.dart`;
- `test/core/storage/remote_evidence_storage_test.dart`;
- `README_AUD-L2-R5.md`.

O `EvidenciaStorageService` existente não foi alterado. O `SyncService`, os Providers e as rotas também permaneceram intactos.

### Resultado técnico

```text
Testes focados R5.1:           8/8 aprovados
flutter analyze:               No issues found
git diff --check:              aprovado
RemoteEvidenceStorage:         contrato criado
Remote provider padrão:        desabilitado / fail-closed
Cloudflare R2:                 não integrado
Credenciais:                   nenhuma
Upload remoto:                 nenhum
```

### Parecer

`AUD-L2-R5.1`: **HOMOLOGADO LOCALMENTE**.

A etapa estabelece somente a fundação arquitetural. O commit inicial do R5.1 é db43b2 e o trabalho está publicado no PR #41. A revisão pré-merge identificou que localStorageRequired ainda era configurável; a R5.1-R1 remove essa possibilidade para tornar a invariante local-first estruturalmente obrigatória. Integração real com armazenamento remoto permanece fora deste escopo.
### R5.1-R1 — Consolidação da invariante local-first

A revisão do PR #41 identificou que `EvidenceStoragePolicy` aceitava `localStorageRequired: false`, contrariando a invariante arquitetural de que toda evidência deve permanecer local-first.

A R1 remove `localStorageRequired` do construtor e o transforma em propriedade invariavelmente verdadeira. A habilitação futura do armazenamento remoto passa a ser independente da persistência local obrigatória.

```text
Commit inicial R5.1:            adb43b2
Pull Request:                   #41
Local storage required:         sempre true
Remote storage enabled:         configurável
```

------------------------------------------------------------------------

## AUD-L2-R5.2 / R5.2-C — Metadados, SHA-256 e autoria de evidências

**Data:** 20/08/2026
**Branch:** `audit/aud-l2-r5-2-c-evidence-author-identity`
**Tipo:** Evolução de integridade e identidade operacional

### Resumo

O R5.2-A/B adicionou metadados de integridade às evidências locais, incluindo
SHA-256, tamanho real, MIME type e campos reservados à futura sincronização
remota. O R5.2-C vinculou novas evidências à identidade operacional canônica
por meio de `AuthorizationService.usuarioAtual.id`.

### Decisão arquitetural

A interface obtém a identidade validada e repassa explicitamente
`autorUserId` ao `EvidenciaStorageService`. O serviço de arquivos permanece
desacoplado do Firebase Auth e do Firestore.

A ausência de identidade canônica provoca falha fechada. Evidências legadas
permanecem compatíveis.

### Arquivos do R5.2-C

- `README_AUD-L2-R5.2-C.md`;
- `lib/core/services/evidencia_storage_service.dart`;
- `lib/modules/evidencias/evidencias_page.dart`;
- `test/core/services/evidencia_storage_service_test.dart`;
- `test/core/storage/evidence_metadata_calculator_test.dart`.

### Validação

```text
R5.2-A/B commit:               3647210
R5.2-A/B merge:                479c9dc
R5.2-A/B testes focados:       17/17
R5.2-A/B regressão:            775/775
R5.2-C regressão completa:     aprovada
flutter analyze:               0 issues
git diff --check:              aprovado
```

### Limites

Não foram introduzidos Cloudflare R2, upload remoto, URLs assinadas,
Firebase Storage, alterações em `SyncService`, `AcaoModel`, Providers ou rotas.

### Próxima ação

Commit controlado do R5.2-C, publicação da branch, Pull Request e validação dos
Quality Gates antes do merge.
------------------------------------------------------------------------

## AUD-L2-R5.3 — Autorização remota e Access Broker

**Data:** 20/08/2026
**Branch:** `audit/aud-l2-r5-3-remote-access-authorization`
**Tipo:** Segurança arquitetural / trust boundary

### Objetivo

Impedir que a futura integração de armazenamento remoto transfira ao APK
credenciais, segredo de assinatura ou autoridade para conceder acesso ao
bucket.

### Decisão arquitetural

Foi introduzido um contrato `EvidenceAccessBroker` separado do transporte de
armazenamento. O broker representa a solicitação de acesso, enquanto a futura
emissão do grant deverá ocorrer exclusivamente em backend confiável.

A implementação padrão `DisabledEvidenceAccessBroker` falha fechado para
leitura e upload.

### Operações

- leitura: futura equivalência com `Permission.consultarRae`;
- upload: futura equivalência com `Permission.editarRae`;
- exclusão: fora do escopo e não autorizada.

### Limites

Nenhum Worker, R2, credencial, URL assinada real, chamada HTTP, SyncService ou
deploy remoto é introduzido no R5.3.
### Validação final

```text
Baseline de entrada:           53ac988
Testes focados R5.1 + R5.3:    aprovados
Regressão Flutter completa:    aprovada
flutter analyze:               0 issues
git diff --check:              aprovado
Escopo final:                  8 arquivos previstos
```

### Parecer

`AUD-L2-R5.3`: **HOMOLOGADO LOCALMENTE**.

O pacote estabelece exclusivamente a fronteira de confiança para autorização
remota de evidências. A implementação produtiva do backend confiável, emissão
de grants temporários, Cloudflare Worker, R2 e transporte HTTP permanecem
reservados às etapas posteriores.
------------------------------------------------------------------------

## AUD-L2-R5.4-A — Refatoração do contrato remoto

**Data:** 20/08/2026
**Branch:** `audit/aud-l2-r5-4-a-remote-transport-contract`
**Baseline:** `8d4e0c2`
**Tipo:** Refatoração arquitetural / storage remoto

### Motivação

A HAT-1 do R5.4 identificou que o contrato legado `RemoteEvidenceStorage`
misturava transporte com concessão de acesso ao expor `createReadUri()` e
`delete()`.

Essa forma permitiria que uma futura implementação cliente assumisse
responsabilidades que pertencem ao backend confiável.

### Implementação

O contrato legado é substituído por `RemoteEvidenceTransport`, cuja operação de
upload recebe obrigatoriamente:

- `EvidenceAccessGrant`;
- `RemoteEvidenceUploadRequest`.

A implementação padrão continua fail-closed por meio de
`DisabledRemoteEvidenceTransport`.

### Fora do escopo

- HTTP real;
- Cloudflare R2;
- Worker;
- credenciais;
- signed URLs reais;
- exclusão remota;
- SyncService;
- Providers;
- rotas.
### Validação final

```text
Baseline de entrada:           8d4e0c2
Testes focados R5.3 + R5.4-A:  aprovados
Regressão Flutter completa:    aprovada
flutter analyze:               0 issues
git diff --check:              aprovado
Escopo final:                  9 caminhos Git previstos
```

### Parecer

`AUD-L2-R5.4-A`: **HOMOLOGADO LOCALMENTE**.

A refatoração remove a ambiguidade do contrato legado e consolida a separação:

```text
EvidenceAccessBroker      = plano de controle
RemoteEvidenceTransport   = plano de dados
```

O plano de dados não possui `createReadUri()`, não possui `delete()` e não
recebe credenciais permanentes de provedor. A integração HTTP real e o adapter
Cloudflare R2 continuam reservados às próximas subetapas.
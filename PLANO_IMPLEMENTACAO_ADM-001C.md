# PLANO DE IMPLEMENTAÇÃO ADM-001C — IDENTIDADE E SEGURANÇA

**Plataforma Fênix — GEDUC RAE Mobile**  
**Versão:** 1.0  
**Data:** 01/08/2026  
**Status:** Proposto para homologação  
**Blueprint de referência:** `BLUEPRINT_ADM-001C.md` v1.0  
**Base técnica:** commit `383872db334299fda26bf80eb17afada3189cf59`  
**Metodologia:** PF-ENG 003/2026

---

## 1. Objetivo

Implementar, em pacotes incrementais e homologáveis, a arquitetura de identidade e segurança aprovada no Blueprint ADM-001C, preservando as entregas ADM-001B.1 e ADM-001B.2 e mantendo o aplicativo funcional ao final de cada pacote.

---

## 2. Regras de execução

1. Cada pacote será implementado isoladamente.
2. Todos os arquivos modificados serão entregues completos.
3. Nenhum pacote seguinte começará antes da homologação do anterior.
4. `flutter analyze` deverá retornar `No issues found!` em cada pacote.
5. O estado do Git será validado antes da geração do CPB.
6. O CPB será gerado com manifesto próprio e opção `-Full`.
7. Nenhuma regra será publicada no Firebase sem autorização expressa.
8. Alterações estruturais serão registradas no Engineering Log e na Arquitetura.
9. Saídas do CPB permanecerão ignoradas pelo Git.
10. Commits e pushes ocorrerão apenas após homologação.

---

## 3. Sequência dos pacotes

| Ordem | Pacote | Resultado principal |
|---:|---|---|
| 1 | ADM-001C.1 | Identidade operacional confiável e bloqueio seguro |
| 2 | ADM-001C.2 | Política única de autorização no cliente |
| 3 | ADM-001C.3 | Baseline completa das regras do Firestore |
| 4 | ADM-001C.4 | Homologação integrada, documentação e encerramento |

---

## 4. ADM-001C.1 — Identidade Confiável

### 4.1 Objetivo

Transformar o usuário corrente em identidade operacional validada, impedindo o acesso de contas sem cadastro, inativas, inválidas ou pertencentes a uma sessão anterior.

### 4.2 Entregas

- estado explícito de identidade;
- validação do documento `usuarios/{uid}`;
- exigência de `ativo == true`;
- perfil ausente ou desconhecido tratado como não identificado;
- proteção contra conclusão atrasada de consultas de sessão anterior;
- limpeza imediata da identidade no logout;
- centralização do usuário atual no `AuthorizationService`;
- remoção da consulta redundante de usuário no login;
- remoção da consulta redundante de usuário na Home;
- apresentação segura dos estados: sem cadastro, inativo e falha de validação.

### 4.3 Arquivos previstos

#### Novos

- `lib/core/security/identity_status.dart`
- `lib/modules/auth/account_access_page.dart`

#### Alterados

- `lib/data/models/usuario_model.dart`
- `lib/core/services/usuario_service.dart`
- `lib/core/security/authorization_service.dart`
- `lib/core/security/authorization_result.dart`
- `lib/core/routes/route_guard.dart`
- `lib/core/routes/app_routes.dart`
- `lib/modules/auth/login_page.dart`
- `lib/modules/home/home_page.dart`
- `lib/modules/home/services/home_loader_service.dart`
- arquivos de estado/controller da Home estritamente necessários à retirada da identidade duplicada.

### 4.4 Decisões técnicas

- `UsuarioModel.fromMap` receberá o identificador documental ou haverá fábrica equivalente que preserve o UID.
- `ativo` ausente não poderá resultar em conta ativa.
- o serviço de autorização manterá um contador ou token interno de geração da sessão.
- somente resultados da geração e do UID correntes poderão atualizar o estado.
- falha de rede durante validação não deverá liberar acesso com dados presumidos.
- dados operacionais em cache não concederão autorização administrativa.

### 4.5 Testes técnicos

1. sessão ausente;
2. usuário válido e ativo;
3. usuário autenticado sem documento;
4. usuário com `ativo == false`;
5. usuário sem campo `ativo`;
6. usuário sem perfil;
7. usuário com perfil desconhecido;
8. erro de leitura do Firestore;
9. logout durante carregamento;
10. troca rápida entre dois UIDs;
11. recarregamento após atualização do perfil;
12. retomada do aplicativo com sessão existente.

### 4.6 Homologação funcional

- usuário ativo entra normalmente;
- usuário sem cadastro visualiza orientação de acesso e pode sair;
- usuário inativo visualiza bloqueio e pode sair;
- falha de validação oferece nova tentativa sem liberar a Home;
- logout retorna ao login e não mantém nome, perfil ou permissões anteriores;
- a Home continua carregando indicadores e cache operacional normalmente para usuário válido.

### 4.7 Critério de parada

Qualquer regressão no login, na Home, na restauração de sessão ou no logout interrompe a evolução para ADM-001C.2.

---

## 5. ADM-001C.2 — Política Única de Autorização

### 5.1 Objetivo

Eliminar decisões de permissão duplicadas e garantir que interface, módulos e rotas consumam a mesma política do núcleo de segurança.

### 5.2 Entregas

- atalhos baseados em `Permission`, sem comparação textual de perfil;
- catálogo administrativo mantido como fonte de metadados dos módulos;
- rotas administrativas revisadas;
- tela de usuários integrada à cadeia Controller → Repository → Service;
- tratamento de erro e ciclo de vida assíncrono na listagem de usuários;
- planejamento da retirada da rota `/admin-legado`;
- remoção do adaptador obsoleto `admin_permission.dart`, caso não existam consumidores.

### 5.3 Arquivos previstos

- `lib/core/security/permission.dart`
- `lib/core/security/authorization_policy.dart`
- `lib/core/security/authorization_service.dart`
- `lib/core/routes/route_guard.dart`
- `lib/core/routes/app_routes.dart`
- `lib/modules/home/widgets/atalhos_widget.dart`
- `lib/modules/admin/admin_home_page.dart`
- `lib/modules/admin/admin_page.dart`
- `lib/modules/admin/domain/admin_module_catalog.dart`
- `lib/modules/admin/domain/admin_permission.dart`
- `lib/modules/admin/controllers/usuario_controller.dart`
- `lib/modules/usuarios/usuarios_page.dart`
- `lib/repositories/usuario_repository.dart`
- `lib/core/services/usuario_service.dart`

### 5.4 Testes por perfil

| Cenário | Administrador | Gestor | Coordenador | Agente |
|---|:---:|:---:|:---:|:---:|
| Atalho Administração | Exibe | Exibe | Oculta | Oculta |
| Entrada em `/admin` | Permite | Permite | Nega | Nega |
| Domínios | Permite | Permite | Nega | Nega |
| Usuários | Permite | Permite | Nega | Nega |
| Tipos de Ações | Permite | Permite | Nega | Nega |
| Coordenadores | Permite | Nega | Nega | Nega |
| Regionais | Permite | Nega | Nega | Nega |
| Materiais | Permite | Nega | Nega | Nega |

### 5.5 Homologação funcional

- acesso por cartão e URL direta produz a mesma decisão;
- módulos não autorizados não aparecem;
- tentativa direta apresenta a página de acesso negado;
- listagem de usuários utiliza o Provider/Controller global;
- falha na listagem apresenta mensagem e permite nova tentativa;
- nenhuma string de perfil permanece em widgets para decisão de autorização.

### 5.6 Critério de parada

Divergência entre visibilidade do módulo e proteção da rota impede o avanço para ADM-001C.3.

---

## 6. ADM-001C.3 — Firestore Security Baseline

### 6.1 Objetivo

Transformar `firestore.rules` em representação versionada e testável da política de acesso aos dados da Plataforma Fênix.

### 6.2 Pré-condição

Antes de escrever as regras definitivas, deverá ser gerado inventário das coleções e operações utilizadas pelo código atual.

### 6.3 Entregas

- inventário coleção × operação × perfil;
- campo oficial `perfilAcesso` nas regras;
- exigência de documento de usuário ativo;
- funções reutilizáveis de autenticação, identidade e perfil;
- regras explícitas para todas as coleções encontradas;
- testes positivos e negativos;
- documentação de implantação;
- nenhuma publicação automática.

### 6.4 Arquivos previstos

- `firestore.rules`
- `firebase.json`, se necessário para testes locais;
- arquivos de teste das regras;
- manifesto do inventário de coleções;
- documentação técnica da baseline.

### 6.5 Matriz mínima de testes

Para cada coleção e operação aplicável:

- não autenticado;
- autenticado sem documento;
- usuário inativo;
- administrador ativo;
- gestor ativo;
- coordenador ativo;
- agente ativo;
- perfil desconhecido;
- tentativa de alterar campos protegidos;
- tentativa de elevar o próprio perfil;
- tentativa de alterar a própria situação ativa.

### 6.6 Controle especial da coleção `usuarios`

As regras deverão impedir que um usuário comum:

- altere `perfilAcesso`;
- altere `ativo`;
- atribua permissões a si próprio;
- consulte a lista completa de usuários sem permissão;
- modifique UID ou identidade documental.

### 6.7 Publicação

A publicação seguirá etapa separada:

1. testes locais aprovados;
2. revisão do diff;
3. backup/registro da versão anterior;
4. autorização expressa do responsável;
5. publicação;
6. teste de fumaça no ambiente remoto;
7. registro do resultado.

### 6.8 Critério de parada

Qualquer regra sem teste negativo correspondente ou qualquer coleção sem decisão explícita impede publicação e avanço.

---

## 7. ADM-001C.4 — Homologação Integrada e Encerramento

### 7.1 Objetivo

Validar o comportamento conjunto de autenticação, identidade, autorização, interface e regras de dados; consolidar a documentação e encerrar a sprint.

### 7.2 Entregas

- checklist integrado por perfil;
- teste de login, retomada, logout e troca de sessão;
- teste de acesso por interface e URL direta;
- teste das regras do Firestore;
- `flutter analyze` com zero issues;
- CPB final de homologação;
- atualização da Arquitetura da Plataforma;
- atualização do Engineering Log;
- README de encerramento;
- orientação de commit, push e integração ao `main`.

### 7.3 Documentos previstos

- `README_ADM-001C.md`
- atualização de `docs/01_PLATFORM_ARCHITECTURE.md`
- atualização de `docs/06_ENGINEERING_LOG.md`
- atualização do Blueprint, apenas se a implementação homologada divergir da proposta;
- ADR, caso surja decisão estrutural não coberta pelo Blueprint.

---

## 8. Estratégia de Git

### 8.1 Branch

Manter:

```text
feature/adm-001c-identidade-seguranca
```

### 8.2 Commits previstos

```text
docs(security): aprova blueprint e plano da ADM-001C
feat(security): implementa identidade confiavel ADM-001C.1
refactor(security): centraliza politica de autorizacao ADM-001C.2
feat(security): estabelece baseline de regras Firestore ADM-001C.3
docs(security): homologa e encerra ADM-001C
```

Os textos poderão ser refinados conforme o conteúdo efetivamente homologado.

### 8.3 Proibição de commit antecipado

Arquivos de implementação não serão registrados antes do `flutter analyze`, CPB e homologação do pacote correspondente.

---

## 9. Manifestos CPB previstos

```text
tools/manifestos/ADM-001C.1-IDENTIDADE-CONFIAVEL.txt
tools/manifestos/ADM-001C.2-POLITICA-UNICA-AUTORIZACAO.txt
tools/manifestos/ADM-001C.3-FIRESTORE-SECURITY-BASELINE.txt
tools/manifestos/ADM-001C.4-HOMOLOGACAO-ENCERRAMENTO.txt
```

Comando padrão:

```powershell
.\tools\gerar_pacote_chatgpt.ps1 NOME-DO-PACOTE -Full
```

---

## 10. Riscos e controles

| Risco | Impacto | Controle |
|---|---|---|
| Bloquear usuários legítimos | Alto | migração e teste com perfis reais antes de publicar regras |
| Reutilizar identidade anterior | Crítico | geração de sessão e descarte de resposta atrasada |
| Divergência cliente/servidor | Crítico | matriz única e testes de paridade |
| Perder acesso administrativo | Crítico | validar administrador ativo antes da implantação remota |
| Regressão na Home offline | Alto | separar cache operacional de identidade/autorização |
| Regra excessivamente permissiva | Crítico | negar por padrão e criar testes negativos |
| Regra excessivamente restritiva | Alto | testes por operação e perfil no emulador |
| Escopo crescer para módulos não relacionados | Médio | respeitar os arquivos previstos e registrar exceções |

---

## 11. Critérios globais de conclusão

A ADM-001C somente será encerrada quando:

1. os quatro pacotes estiverem homologados;
2. nenhuma conta inativa ou sem cadastro alcançar área funcional;
3. não houver identidade duplicada entre Home, login e segurança;
4. todas as decisões administrativas utilizarem permissões centralizadas;
5. regras do Firestore estiverem testadas e alinhadas ao cliente;
6. `flutter analyze` apresentar zero issues;
7. documentação estiver atualizada;
8. Git estiver limpo após commit e push;
9. integração ao `main` estiver confirmada.

---

## 12. Decisão solicitada

Com a homologação deste Plano, fica autorizada a preparação do pacote **ADM-001C.1 — Identidade Confiável**, começando pelo manifesto de implementação e pela inspeção final dos arquivos diretamente dependentes da Home e da navegação.

Nenhuma alteração no Firebase remoto está autorizada por este documento.


# BLUEPRINT ADM-001C — IDENTIDADE E SEGURANÇA

**Plataforma Fênix — GEDUC RAE Mobile**  
**Versão:** 1.1  
**Data:** 01/08/2026  
**Status:** Implementado e homologado — encerramento documental em curso  
**Base técnica:** commit `383872db334299fda26bf80eb17afada3189cf59`  
**Baseline implementada:** commit `42e3560a26bf57e09f9ff3be4bb2f848cd2cf8a0`  
**Origem:** HAT-1 ADM-001C — Auditoria de Identidade e Segurança

---

## 1. Finalidade

Este Blueprint define a evolução da camada de identidade e segurança da Plataforma Fênix após a implementação e homologação da Fundação Administrativa (ADM-001B.1) e da Autorização Administrativa (ADM-001B.2).

A ADM-001C não substitui nem invalida as entregas anteriores. Seu objetivo é consolidar a identidade do usuário como fonte única de verdade, bloquear contas sem habilitação operacional, eliminar decisões de autorização duplicadas na interface e alinhar a política do aplicativo às regras do Cloud Firestore.

---

## 2. Princípios arquiteturais

1. **Negar por padrão:** ausência, inconsistência ou falha de leitura da identidade deve resultar em acesso negado.
2. **Fonte única de identidade:** apenas um componente deve manter o usuário operacional corrente.
3. **Autenticação não é autorização:** possuir sessão válida no Firebase Auth não garante acesso funcional.
4. **Servidor como autoridade final:** a interface melhora a experiência, mas as regras do Firestore protegem os dados.
5. **Política única:** perfis e permissões devem ser interpretados da mesma maneira em rotas, telas e regras.
6. **Menor privilégio:** cada perfil recebe somente as permissões necessárias.
7. **Transição incremental:** as correções serão implantadas em pacotes pequenos, analisáveis e homologáveis.
8. **Rastreabilidade:** toda alteração deve seguir a PF-ENG 003/2026 e possuir evidência no CPB, Git e documentação.

---

## 3. Diagnóstico consolidado da HAT-1

### 3.1 Conformidades preservadas

- Firebase inicializado antes da montagem do aplicativo.
- `AuthorizationService` disponibilizado globalmente.
- `RouteGuard` aplicado às rotas administrativas.
- permissões administrativas representadas por enumeração tipada.
- política inicial centralizada em `AuthorizationPolicy`.
- módulos administrativos filtrados por permissão.
- rota específica para acesso negado.
- atualização do roteador vinculada ao estado de autenticação e autorização.
- `flutter analyze` concluído com zero issues.

### 3.2 Não conformidades evolutivas

- o modelo utiliza `perfilAcesso`, enquanto as regras versionadas consultam `perfil`;
- o campo `ativo` não participa da decisão de acesso;
- usuário autenticado sem documento em `usuarios/{uid}` alcança a área operacional;
- identidade é consultada por `LoginPage`, `HomeLoaderService` e `AuthorizationService`;
- carregamento assíncrono pode concluir após uma troca de sessão;
- `AtalhosWidget` replica comparações textuais de perfil;
- `UsuariosPage` acessa `UsuarioService` diretamente;
- regras versionadas não representam todas as coleções utilizadas pela plataforma;
- permissões atribuídas ao perfil gestor no cliente não estão integralmente refletidas no Firestore.

---

## 4. Modelo de identidade confiável

### 4.1 Estados oficiais

A identidade operacional deverá possuir estados explícitos:

| Estado | Significado | Acesso permitido |
|---|---|---|
| `naoAutenticado` | Não existe sessão Firebase válida | Somente login e recuperação de senha |
| `carregando` | Sessão válida; identidade ainda em validação | Nenhuma rota funcional |
| `autenticadoSemCadastro` | Existe sessão, mas não existe `usuarios/{uid}` | Tela de acesso pendente/negado e saída |
| `inativo` | Documento localizado com `ativo != true` | Tela de conta inativa e saída |
| `ativo` | Documento válido, ativo e com perfil reconhecido | Recursos autorizados pela política |
| `erro` | Não foi possível validar a identidade | Negação segura, nova tentativa e saída |

### 4.2 Identificador canônico

- O UID do Firebase Auth será o identificador canônico.
- O documento deverá estar em `usuarios/{uid}`.
- O campo `id`, caso mantido no documento, não poderá divergir do UID.
- O modelo deverá receber o `documentId` explicitamente durante a conversão.

### 4.3 Campos mínimos

O documento de usuário deverá conter, no mínimo:

| Campo | Tipo | Regra |
|---|---|---|
| `nome` | string | obrigatório e não vazio |
| `email` | string | obrigatório |
| `perfilAcesso` | string | valor reconhecido pela política |
| `ativo` | bool | somente `true` libera acesso |
| `dataCriacao` | timestamp | obrigatório |

Campos ausentes ou inválidos não deverão receber valores permissivos. Para autorização, `ativo` ausente equivale a `false`, e perfil ausente equivale a perfil não identificado.

---

## 5. Fonte única de verdade

### 5.1 Componente responsável

O `AuthorizationService` evoluirá para manter o estado completo da identidade operacional. Ele será a única fonte de verdade para:

- UID autenticado;
- documento do usuário;
- situação ativa/inativa;
- perfil normalizado;
- permissões efetivas;
- estado de carregamento;
- falha de validação.

### 5.2 Consumidores

- `AppRoutes` consultará o estado consolidado.
- `RouteGuard` decidirá com base nesse estado.
- `HomePage` e seus widgets consumirão o usuário mantido pelo serviço.
- `AdminHomePage` continuará filtrando módulos pelas permissões efetivas.
- `LoginPage` realizará apenas autenticação; a validação operacional será centralizada.

### 5.3 Remoções de duplicidade

- `LoginPage` não consultará `UsuarioService` diretamente.
- `HomeLoaderService` não buscará novamente o usuário atual.
- `AtalhosWidget` não comparará strings de perfil.
- telas administrativas não criarão instâncias paralelas para decisões de autorização.

---

## 6. Segurança de concorrência e troca de sessão

Cada carregamento de identidade deverá ser associado ao UID que o originou. Antes de publicar o resultado, o serviço deverá confirmar que:

1. a sessão continua autenticada;
2. o UID atual ainda corresponde ao UID consultado;
3. a geração interna da sessão não foi substituída.

Resultados atrasados de uma sessão anterior deverão ser descartados. Ao sair, todos os dados de identidade e autorização deverão ser limpos imediatamente antes da notificação aos consumidores.

---

## 7. Política de perfis e permissões

### 7.1 Perfis reconhecidos

- `administrador`
- `gestor`
- `coordenador`
- `agente`

Qualquer outro valor será tratado como `nao-identificado` e não receberá permissão administrativa.

### 7.2 Matriz administrativa homologável

| Permissão | Administrador | Gestor | Coordenador | Agente |
|---|:---:|:---:|:---:|:---:|
| Acessar Administração | Sim | Sim | Não | Não |
| Gerenciar Domínios | Sim | Sim | Não | Não |
| Gerenciar Usuários | Sim | Sim* | Não | Não |
| Gerenciar Tipos de Ações | Sim | Sim | Não | Não |
| Gerenciar Coordenadores | Sim | Não | Não | Não |
| Gerenciar Regionais | Sim | Não | Não | Não |
| Gerenciar Materiais | Sim | Não | Não | Não |

\* Nesta fase, “gerenciar usuários” mantém o escopo funcional já existente. Operações futuras que alterem perfil, situação ou privilégios deverão possuir permissões específicas e mais restritivas.

### 7.3 Regra de interface

A visibilidade de atalhos não constitui controle de segurança. Todo acesso deverá permanecer protegido na rota e no Firestore.

---

## 8. Arquitetura de rotas

### 8.1 Redirecionamento global

O redirecionamento global deverá observar a seguinte ordem:

1. sessão ausente → `/login`;
2. identidade carregando → rota/tela de validação;
3. documento inexistente → acesso pendente/negado;
4. usuário inativo → conta inativa;
5. identidade válida na rota de login → `/home`;
6. identidade válida em rota funcional → prosseguir.

### 8.2 Proteção específica

As rotas administrativas continuarão usando permissões específicas. A rota `/acesso-negado` deverá permanecer acessível ao usuário autenticado mesmo sem permissão administrativa, evitando ciclos de redirecionamento.

### 8.3 Rota legada

`/admin-legado` deverá ser descontinuada após validação de que não existem consumidores necessários. Enquanto existir, permanecerá protegida pela permissão `acessarAdministracao` e não poderá representar um caminho alternativo de autorização.

---

## 9. Firestore Security Baseline

### 9.1 Convenção oficial

O nome oficial do campo será:

```text
perfilAcesso
```

As regras não utilizarão `perfil` como substituto silencioso. Qualquer migração de dados deverá ser explícita e auditável.

### 9.2 Funções de segurança

As regras deverão possuir funções equivalentes a:

- `autenticado()`;
- `usuarioExiste()`;
- `usuarioAtivo()`;
- `perfilAtual()`;
- `possuiPerfil(perfis)`;
- verificações específicas por coleção e operação.

As funções devem negar acesso quando o documento ou qualquer campo obrigatório estiver ausente.

### 9.3 Paridade obrigatória

Nenhuma permissão administrativa deverá ser liberada no cliente e bloqueada no Firestore sem decisão documental explícita. Da mesma forma, nenhuma operação deverá ser liberada no Firestore apenas porque a interface a oculta.

### 9.4 Escopo das regras

Antes da publicação, deverão ser inventariadas todas as coleções acessadas pela aplicação. Cada coleção deverá possuir decisão explícita para `get`, `list`, `create`, `update` e `delete`.

Ausência de regra continuará significando negação.

### 9.5 Publicação

As regras deverão ser validadas no Firebase Emulator Suite ou por testes equivalentes antes da publicação. A implantação em ambiente remoto exigirá autorização específica e evidência da versão publicada.

---

## 10. Camadas e responsabilidades

| Camada | Responsabilidade |
|---|---|
| Apresentação | Exibir estados e ações permitidas; não decidir privilégios por strings |
| Rotas | Bloquear navegação conforme identidade e permissão |
| Aplicação | Coordenar carregamento, renovação e limpeza da identidade |
| Domínio/Segurança | Normalizar perfis e avaliar permissões |
| Repositório | Fornecer contrato de leitura de usuário |
| Serviço/Dados | Ler `usuarios/{uid}` e preservar o identificador documental |
| Firestore Rules | Impor a autoridade final sobre leitura e escrita |

---

## 11. Plano incremental de implementação

### ADM-001C.1 — Identidade Confiável

- criar estado explícito de identidade;
- validar cadastro, perfil e `ativo == true`;
- impedir publicação de resultado pertencente a sessão anterior;
- centralizar usuário atual no serviço de autorização;
- retirar consulta de usuário do login e da Home;
- criar telas/estados para cadastro ausente, conta inativa e falha de validação.

### ADM-001C.2 — Política Única de Autorização

- substituir comparações textuais na interface;
- fazer atalhos consumirem permissões;
- revisar rotas administrativas e rota legada;
- conduzir `UsuariosPage` pela cadeia Controller → Repository → Service;
- manter matriz de permissões como fonte única no cliente.

### ADM-001C.3 — Firestore Security Baseline

- inventariar coleções e operações;
- alinhar `perfilAcesso`;
- exigir usuário ativo nas operações protegidas;
- implementar regras por coleção;
- criar matriz cliente × Firestore;
- validar regras antes de publicar.

### ADM-001C.4 — Homologação e Encerramento

- executar testes por perfil;
- executar testes de troca de sessão;
- executar testes de usuário inexistente e inativo;
- validar `flutter analyze` com zero issues;
- gerar CPB de homologação;
- atualizar Engineering Log, Arquitetura e documentação de segurança;
- commit, push e encerramento conforme PF-ENG 003/2026.

---

## 12. Critérios obrigatórios de homologação

1. Usuário sem sessão não acessa rotas funcionais.
2. Usuário autenticado sem documento não acessa a Home.
3. Usuário inativo não acessa a Home nem módulos administrativos.
4. Perfil desconhecido não recebe permissão administrativa.
5. Administrador acessa somente operações autorizadas pela matriz.
6. Gestor respeita exatamente a matriz homologada.
7. Coordenador e agente não acessam Administração.
8. URLs administrativas digitadas diretamente continuam protegidas.
9. Troca rápida de conta não reaproveita identidade anterior.
10. Logout elimina imediatamente a identidade em memória.
11. Atalhos e módulos usam a política central, sem comparação textual de perfil.
12. Regras do Firestore usam `perfilAcesso` e exigem usuário ativo.
13. Todas as coleções possuem decisão explícita de acesso.
14. Testes de regras aprovados antes de qualquer publicação.
15. `flutter analyze` retorna `No issues found!`.
16. Git e CPB registram integralmente os arquivos alterados.

---

## 13. Restrições desta etapa

- Não alterar o provedor global de domínios homologado.
- Não modificar fluxos funcionais do RAE fora do necessário para identidade.
- Não publicar regras no Firebase sem homologação e autorização.
- Não ampliar permissões por conveniência operacional.
- Não armazenar senha, token ou credencial no documento de usuário ou em cache local.
- Não iniciar a implementação antes da homologação deste Blueprint.

---

## 14. Arquivos inicialmente impactados

### Núcleo

- `lib/core/security/authorization_service.dart`
- `lib/core/security/authorization_policy.dart`
- `lib/core/security/authorization_result.dart`
- `lib/core/security/permission.dart`
- `lib/core/routes/route_guard.dart`
- `lib/core/routes/app_routes.dart`

### Identidade e dados

- `lib/data/models/usuario_model.dart`
- `lib/core/services/usuario_service.dart`
- `lib/repositories/usuario_repository.dart`

### Apresentação

- `lib/modules/auth/login_page.dart`
- `lib/modules/home/services/home_loader_service.dart`
- `lib/modules/home/widgets/atalhos_widget.dart`
- `lib/modules/usuarios/usuarios_page.dart`
- componentes adicionais de estado de acesso, caso aprovados no plano de implementação.

### Infraestrutura e documentação

- `firestore.rules`
- testes das regras de segurança;
- `docs/01_PLATFORM_ARCHITECTURE.md`
- `docs/06_ENGINEERING_LOG.md`
- documentação específica da ADM-001C.

---

## 15. Decisão arquitetural proposta

A Plataforma Fênix adotará identidade operacional validada como pré-condição para qualquer acesso funcional. O Firebase Auth continuará responsável pela autenticação, enquanto o documento `usuarios/{uid}` determinará habilitação, perfil e permissões. O `AuthorizationService` será a fonte única de identidade no cliente, e o Firestore será a autoridade final de acesso aos dados.

## 16. Registro de implementação

### 16.1 ADM-001C.1 — Identidade Confiável

- commit `072c5a5`;
- identidade centralizada no `AuthorizationService`;
- estados de identidade explícitos;
- correção R1 do ciclo de notificação/roteamento;
- homologação funcional no tablet aprovada.

### 16.2 ADM-001C.2 — Política Única de Autorização

- commit `fc575a0`;
- atalhos e rotas alinhados à matriz de `Permission`;
- rota administrativa legada consolidada;
- cadeia global de usuários aplicada;
- homologação funcional no tablet: 10/10.

### 16.3 ADM-001C.3 — Firestore Security Baseline

- commit `42e3560`;
- oito coleções inventariadas;
- campo oficial `perfilAcesso` aplicado;
- identidade ativa exigida nas operações protegidas;
- negação por padrão;
- 15/15 testes aprovados no Firebase Emulator Suite após Code Review;
- invariantes estruturais de `domains` preservadas;
- regras ainda não publicadas no Firebase remoto.

### 16.4 ADM-001C.4 — Encerramento

O pacote foi homologado integralmente no tablet, com 10/10 itens aprovados.
A conclusão documental não autoriza automaticamente a publicação das regras.
Integração à `main` exige Pull Request, Code Review Arquitetural, merge e
validação pós-merge conforme PF-ENG 003/2026.

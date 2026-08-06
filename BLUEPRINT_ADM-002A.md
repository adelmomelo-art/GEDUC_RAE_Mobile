# BLUEPRINT ADM-002A — Evolução do módulo Tipos de Ações

## 1. Objetivo

Transformar o módulo Tipos de Ações em um catálogo administrativo confiável, responsivo, testável e coerente com a arquitetura, a segurança e a identidade visual da Plataforma Fênix.

## 2. Estado atual

### 2.1 Cadeia já existente

```text
GeducRaeApp
  └─ ChangeNotifierProvider<TipoAcaoController>
       └─ TipoAcaoRepository
            └─ TipoAcaoService
                 └─ Firestore /tipos_acoes
```

Essa cadeia está registrada, mas não é consumida pela tela atual.

### 2.2 Cadeia efetivamente usada pela interface

```text
TiposAcoesPage
  ├─ FirebaseFirestore.instance
  ├─ StreamBuilder<QuerySnapshot>
  ├─ criação de UUID
  ├─ cadastro direto
  └─ atualização direta de ativo

NovaAcaoPage
  └─ FirebaseFirestore.instance
       └─ leitura direta de /tipos_acoes
```

Existem, portanto, dois caminhos de dados concorrentes.

## 3. Arquitetura-alvo

```text
UI
├─ TiposAcoesPage
├─ TipoAcaoFormPage
└─ NovaAcaoPage
       │
       ▼
TipoAcaoController
       │
       ▼
TipoAcaoRepository
       │
       ▼
TipoAcaoService
       │
       ▼
Firestore /tipos_acoes
```

### Regras obrigatórias

1. Nenhuma página do módulo poderá importar `cloud_firestore`.
2. A interface não poderá criar identificadores nem montar mapas Firestore.
3. O controller concentrará estado, loading, erro, salvamento, filtros e comandos.
4. O repository exporá operações de negócio.
5. O service será a única camada que conhece coleção, documentos e timestamps.
6. A tela Nova Ação deverá consumir somente tipos ativos.
7. Não haverá exclusão física.

## 4. Modelo de dados

A compatibilidade com os documentos existentes será preservada.

```text
id: String
nomeAcao: String
tipoAcao: String
publicoEstimadoPadrao: int
publicoMinimoPadrao: int
materiaisSugeridos: List<String>
ativo: bool
criadoEm: timestamp
atualizadoEm: timestamp
```

### Compatibilidade

- `id` deverá ser obtido prioritariamente de `document.id`.
- O campo `id` interno será mantido durante a transição.
- documentos legados sem `atualizadoEm` continuarão legíveis;
- materiais permanecerão como `List<String>` nesta intervenção;
- nenhuma migração para IDs do módulo Materiais será feita agora.

### Validações

- `nomeAcao` obrigatório;
- `tipoAcao` obrigatório;
- público estimado e mínimo inteiros não negativos;
- público mínimo não pode superar o estimado quando o estimado for maior que zero;
- materiais vazios são removidos e duplicados são consolidados;
- prevenção de duplicidade por comparação normalizada do par `nomeAcao + tipoAcao`;
- a regra final de unicidade somente será endurecida após conferência dos dados remotos existentes.

## 5. Estado do controller

O controller deverá expor, no mínimo:

```text
tipos
tiposFiltrados
carregando
salvando
erro
filtroTexto
filtroStatus

carregar()
criar()
atualizar()
alterarStatus()
buscarDuplicado()
limparErro()
```

Operações assíncronas deverão usar `try/catch/finally`, impedindo estado de carregamento permanente após falha.

## 6. Interface

### 6.1 Listagem

- cabeçalho administrativo;
- botão “Novo tipo de ação”;
- indicadores: total, ativos e inativos;
- pesquisa por nome, tipo e material;
- filtro por situação;
- cards responsivos no celular;
- apresentação mais densa no tablet;
- menu para editar;
- ativação/inativação com confirmação;
- mensagens de carregamento, vazio, erro e sucesso;
- atualização manual.

### 6.2 Formulário

- página própria, não `AlertDialog`;
- suporte a criar e editar;
- proteção contra descarte acidental;
- validação por `Form`;
- campos numéricos adequados;
- materiais apresentados como entradas normalizadas;
- botões com estado de salvamento;
- layout responsivo para Samsung A05 e Tab S6.

## 7. Identidade visual

A Home PV-007B-R3 é a referência cromática aprovada.

O repositório ainda possui dois sistemas visuais:

- `AppTheme/AppColors`, com paleta global anterior;
- `HomeVisualTokens`, restrito à Home.

A ADM-002A deverá introduzir tokens globais da Plataforma Fênix em `lib/core/theme/fenix_visual_tokens.dart`, preservando exatamente as cores homologadas da R3. A Home deverá permanecer visualmente idêntica. O novo módulo administrativo será o primeiro consumidor fora da Home.

Cores funcionais previstas:

- laranja para ação principal e destaque;
- verde-petróleo para estados ativos e confirmação;
- azul e azul-marinho para estrutura, navegação e informação;
- creme/off-white para superfícies de apoio;
- vermelho apenas para erro ou ação destrutiva;
- cinza neutro para conteúdo secundário.

## 8. Rotas e autorização

A rota atual `/tipos-acoes` será preservada nesta intervenção para evitar quebra de navegação.

Proteções mantidas:

```text
Permission.gerenciarTiposAcoes
administrador: permitido
gestor: permitido
coordenador: negado
agente: negado
```

Firestore:

```text
read: usuário ativo
create/update: administrador ou gestor
delete: negado
```

## 9. Segurança Firestore

As regras atuais controlam perfil, mas não validam estrutura dos documentos.

A etapa de hardening deverá acrescentar:

- conjunto de campos permitido;
- tipos de dados;
- `tipoAcaoId` coerente com o documento;
- `criadoEm` imutável;
- `atualizadoEm` obrigatório nas gravações novas;
- `ativo` booleano;
- números não negativos;
- lista de materiais composta por strings;
- exclusão permanentemente negada.

O endurecimento será aplicado somente após inventário dos documentos existentes para evitar bloquear registros legados.

## 10. Integração com Nova Ação

A Nova Ação deverá:

- carregar tipos por repository/controller;
- apresentar apenas registros ativos;
- preservar o valor de um rascunho legado mesmo que o tipo tenha sido posteriormente inativado;
- impedir nova seleção de item inativo;
- manter os padrões de público como sugestão, não como dado obrigatório;
- continuar gravando `acao.tipoAcao` de forma compatível.

## 11. Testes

### Unitários

- parsing tolerante do modelo;
- serialização;
- normalização;
- validações;
- controller em sucesso e erro;
- prevenção de duplicidade;
- ativação e inativação.

### Widgets

- listagem vazia;
- erro e recarregamento;
- filtros;
- formulário;
- A05 em largura lógica aproximada de 360;
- Tab S6 em largura lógica aproximada de 800;
- ausência de overflow;
- padrão cromático.

### Firestore Rules

- leitura por usuário ativo;
- escrita por administrador e gestor;
- bloqueio para coordenador, agente, inativo e anônimo;
- bloqueio de delete;
- rejeição de documento inválido;
- preservação de `criadoEm`.

## 12. Fora de escopo

- exclusão física;
- migração de materiais para referências;
- alteração massiva de todas as telas;
- mudança da fonte atual;
- deploy remoto sem pacote e homologação;
- alteração da semântica de `nomeAcao` e `tipoAcao` sem análise dos dados existentes.

## 13. Critérios de aceite

- nenhuma tela do módulo acessa Firestore diretamente;
- usuários não autorizados continuam bloqueados;
- inativos não aparecem para nova seleção;
- criação, edição e status funcionam;
- duplicidades são interceptadas;
- A05 e Tab S6 sem cortes ou overflow;
- cores alinhadas à R3;
- testes novos aprovados;
- suíte existente aprovada;
- `flutter analyze` com 0 issues;
- `git diff --check` aprovado;
- CPB validado;
- homologação visual antes do commit.

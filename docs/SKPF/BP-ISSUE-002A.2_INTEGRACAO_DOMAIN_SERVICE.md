# BP-ISSUE-002A.2 — Integração do DomainService com o Firestore

## Controle do Documento

| Item | Valor |
|---|---|
| Documento | `BP-ISSUE-002A.2_INTEGRACAO_DOMAIN_SERVICE.md` |
| Versão | 2.0 |
| Status | Implementado e homologado |
| Atualização | EST-005D |
| Commit de referência | `35d41f6` |
| Branch | `release/estabilizacao-pv006` |

## 1. Objetivo

Conectar o `DomainService` à infraestrutura persistente criada na
ISSUE-002A.1, preservar sua API pública e disponibilizar os domínios por
meio de uma cadeia arquitetural reutilizável:

```text
Apresentação
      ↓
DomainProvider
      ↓
DomainRepository
      ↓
DomainService
      ↓
DomainDataSource
      ↓
FirestoreDomainDataSource
      ↓
Cloud Firestore / domains
```

Este Blueprint também registra a consolidação realizada na EST-005B,
quando o `DomainProvider` foi promovido ao escopo global da aplicação.

## 2. Situação anterior à persistência

```text
DomainListPage
      ↓
DomainRepository
      ↓
DomainService
      ↓
List<DomainModel> em memória
```

Os registros existiam somente durante a execução da aplicação.

## 3. Arquitetura persistente implementada

```text
DomainListPage
      ↓
DomainRepository
      ↓
DomainService
      ↓
DomainDataSource
      ↓
FirestoreDomainDataSource
      ↓
Cloud Firestore / domains
```

A persistência foi incorporada sem exigir dependência direta das telas
com o Firestore.

## 4. Arquitetura de consumo consolidada

Com a evolução da Central de Domínios, múltiplas telas passaram a
consumir os mesmos dados por rotas diferentes.

A arquitetura consolidada é:

```text
main.dart
   ↓
App
   ↓
MultiProvider
   ↓
DomainProvider
   ↓
DomainRepository
   ↓
DomainService
   ↓
DomainDataSource
   ↓
FirestoreDomainDataSource
   ↓
Cloud Firestore / domains
```

Páginas consumidoras:

```text
DomainProvider global
   ├── CaracterizacaoAcaoPage
   ├── AvaliacaoPage
   ├── DomainDropdown
   ├── DomainRadioGroup
   └── DomainCheckboxGroup
```

## 5. Decisões arquiteturais

### 5.1 Injeção da fonte de dados

O `DomainService` recebe opcionalmente um `DomainDataSource`.

Quando nenhuma implementação é informada, utiliza:

```dart
FirestoreDomainDataSource()
```

Isso mantém o uso atual:

```dart
DomainService()
```

e permite futuramente injetar fontes alternativas ou doubles de teste.

### 5.2 API pública preservada

Foram mantidos os métodos:

- `listarTodos`;
- `listarPorGrupo`;
- `buscarPorId`;
- `buscarPorCodigo`;
- `salvar`;
- `salvarTodos`;
- `ativar`;
- `desativar`;
- `limparCache`.

O `DomainRepository` permaneceu como abstração entre provider e serviço.

### 5.3 Compatibilidade de `limparCache`

O método foi preservado como operação compatível com a API existente.

A estratégia concreta de cache deve permanecer encapsulada e não pode
forçar as páginas consumidoras a conhecer detalhes de persistência.

### 5.4 Escopo global do DomainProvider

O `DomainProvider` deve ser registrado no `MultiProvider` principal, em
`lib/app.dart`, acima do `MaterialApp` e das rotas.

Motivos:

-   Caracterização e Avaliação são alcançadas por rotas independentes;
-   widgets de domínio são reutilizados em diferentes módulos;
-   o provider representa estado transversal da aplicação;
-   o escopo local causava indisponibilidade fora da subárvore de
    Caracterização;
-   a instância global evita reinstanciação e descarte indevidos durante
    a navegação.

### 5.5 Ciclo de vida

O ciclo de vida do provider global é responsabilidade do
`ChangeNotifierProvider` raiz.

As páginas consumidoras não devem:

-   criar outra instância sem justificativa arquitetural;
-   registrar `ChangeNotifierProvider.value` para a instância global;
-   executar `dispose` manual do provider global;
-   depender da passagem por uma página anterior para obter o provider.

### 5.6 Dependência autocontida

O construtor do `DomainProvider` permanece capaz de compor suas
dependências padrão quando não houver injeção explícita:

```text
DomainProvider
      ↓
DomainRepository
      ↓
DomainService
```

Essa decisão permite o registro simples no `MultiProvider` e mantém a
possibilidade de injeção para testes ou evoluções futuras.

## 6. Causa raiz registrada na EST-005A

### Erro observado

`ProviderNotFoundException` em `AvaliacaoPage`.

### Origem

`DomainProvider` era instanciado em
`CaracterizacaoAcaoPage`, disponibilizado somente na
subárvore local e descartado pela própria página.

### Falha arquitetural

O provider possuía uso transversal, mas escopo local.

### Solução definitiva

Promover o provider para a raiz da aplicação, acima das rotas
consumidoras, e remover sua gestão de ciclo de vida da página de
Caracterização.

## 7. Impacto funcional

A integração permite que valores administrativos persistidos na coleção
`domains` sejam consumidos de forma padronizada pelos formulários.

Após a EST-005B:

-   Caracterização acessa os domínios globais;
-   Avaliação acessa os domínios sem depender da rota anterior;
-   a tela vermelha causada pela ausência do provider foi eliminada;
-   o mesmo estado arquitetural permanece disponível durante o fluxo;
-   widgets padronizados continuam desacoplados da persistência concreta.

## 8. Riscos controlados

- As regras do Firestore devem permitir leitura e escrita da coleção
  `domains` para o perfil autorizado.
- A aplicação necessita de tratamento adequado para indisponibilidade de
  rede.
- Operações de sementes devem permanecer idempotentes.
- Novos providers não devem ser promovidos ao escopo global sem análise
  do alcance real do estado.
- Um provider global não deve acumular regras de interface ou
  responsabilidades alheias ao domínio.

## 9. Critérios de homologação

### Persistência

- `flutter analyze` sem issues;
- aplicação inicia sem regressão;
- tela de domínios abre sem exceção;
- documentos são gravados na coleção `domains`;
- atualização do status ativo/inativo persiste após recarregar a tela.

### Escopo do provider

- acesso direto à rota de Avaliação sem
  `ProviderNotFoundException`;
- Caracterização continua carregando seus domínios;
- widgets consumidores recebem a mesma dependência global;
- retorno e reabertura das telas não causam loading infinito;
- nenhuma página executa descarte manual do provider global;
- homologação funcional HF-005B.1 a HF-005B.6 aprovada;
- `flutter analyze` com 0 issues;
- HAT-1 e HAT-2 aprovadas.

## 10. Evidências de implementação

```text
Pacote:
EST-005B-GLOBAL-DOMAINPROVIDER-HOMOLOGADO

Commit:
35d41f6

Mensagem:
refactor(domains): globaliza DomainProvider e estabiliza fluxo da Avaliação (EST-005B)

Push:
release/estabilizacao-pv006 -> origin/release/estabilizacao-pv006
```

## 11. Regra para evoluções futuras

Antes de alterar o escopo de um provider, a equipe deve inspecionar:

1. árvore de providers;
2. árvore de rotas;
3. consumidores diretos e indiretos;
4. duração necessária do estado;
5. dependências internas;
6. responsabilidade pelo ciclo de vida;
7. impacto em testes e navegação.

A decisão deve ser registrada no Blueprint e no Engineering Log quando
for estrutural.

## 12. Resultado

A integração de domínios está consolidada em duas dimensões:

1. persistência desacoplada por
   `DomainDataSource` e `FirestoreDomainDataSource`;
2. distribuição transversal por `DomainProvider` global.

A arquitetura elimina a dependência acidental entre rotas e preserva a
separação entre apresentação, estado, repositório, serviço e
persistência.

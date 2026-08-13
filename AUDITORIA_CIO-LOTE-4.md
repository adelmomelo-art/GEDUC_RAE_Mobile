# Auditoria técnica — CIO Lote 4

## Base auditada

- repositório: `GEDUC_RAE_Mobile`;
- branch de origem: `main`;
- baseline: `1a23910514c8d06c29f61bcf03a5e06d207e437f`;
- situação inicial: `main` sincronizada com `origin/main`;
- natureza desta entrega: auditoria e planejamento, sem alteração funcional.

## Conclusão executiva

O projeto já possui captura GPS, geocodificação, mapa interativo, catálogo de
regionais e o diagnóstico territorial criado no CIO Lote 3. Entretanto, ainda
não existe evidência suficiente para publicar um mapa territorial executivo.

O Lote 4 deve ser dedicado à qualidade e à governança territorial. O mapa deve
permanecer condicionado a dados reais, fonte cartográfica oficial e regras de
atribuição/licenciamento.

## Providers

- O `DashboardController` permanece local à tela do CIO.
- O `DashboardCIOBridge` continua sendo a fachada analítica única.
- `RegionalService` já isola a leitura da coleção `regionais` no fluxo de
  localização.
- Não há necessidade de Provider global novo.

**Decisão:** preservar a composição do Lote 3 e injetar o catálogo territorial
no bridge por serviço/repositório explícito, sem consulta Firestore em widgets.

## Rotas e permissões

- O CIO permanece em `/dashboard`, sem guarda de permissão específica.
- Qualquer identidade ativa pode ler `acoes` e `regionais` pelas regras atuais.
- Somente administradores podem criar ou atualizar regionais no Firestore.
- A permissão `gerenciarRegionais` existe na aplicação, mas somente o perfil
  `administrador` possui essa permissão; o perfil `gestor` não pode sanear o
  catálogo.

**Risco:** o público que identifica problemas no CIO pode não ter autoridade
para corrigi-los. Alterar essa política exige decisão institucional separada.

## Dependências

O projeto já utiliza:

- `flutter_map`;
- `latlong2`;
- `geolocator`;
- `geocoding`.

Não é necessária nova dependência para o núcleo de qualidade. A ativação de mapa
executivo poderá exigir provedor de blocos, geometria oficial ou armazenamento
próprio, mas essa decisão não deve ser antecipada neste lote.

## Catálogo de regionais

`RegionalModel` possui:

- `id`, nome, código e tipologia;
- bairros vinculados;
- estado ativo/inativo.

Não possui:

- geometria ou polígono;
- centroide ou caixa de abrangência;
- versão e vigência territorial;
- fonte oficial e data de referência;
- identificador externo oficial;
- histórico de alterações;
- estado de revisão/aprovação.

`RegionalService.listarAtivas()` consulta todas as regionais ativas e filtra a
tipologia no cliente. `resolverPorBairro()` detecta zero, uma ou múltiplas
correspondências, mas não produz auditoria global do catálogo.

A tela administrativa impede conflitos de bairro em operações normais da
interface, porém dados legados ou gravados por outros meios ainda podem conter
duplicidades. As regras Firestore não validam o formato territorial.

## Qualidade dos RAEs

O Lote 3 mede preenchimento, mas não validade institucional:

- qualquer `regionalId` não vazio conta como registro com ID;
- o ID não é confrontado com regional existente, ativa e da tipologia correta;
- coordenadas são aceitas se estiverem nos limites mundiais e não forem `(0,0)`;
- não há limite geográfico de Fortaleza;
- não há verificação de coerência entre coordenada, bairro e regional;
- `localizacaoValidada` não registra regra, versão ou responsável pela
  validação;
- fallback nominal legado não confirma equivalência com o catálogo.

## Dados reais

A auditoria do código não fornece acesso autenticado a uma exportação atual da
coleção de produção. Portanto, não é possível afirmar nesta etapa os percentuais
reais de cobertura, IDs órfãos, duplicidades ou coordenadas fora do município.

**Gate obrigatório:** executar relatório somente leitura sobre `acoes` e
`regionais` reais antes de aprovar mapa ou migração em massa.

## Cartografia

O mapa operacional usa `https://tile.openstreetmap.org/{z}/{x}/{y}.png` com um
identificador de aplicação, mas não foi encontrada atribuição visível no
componente.

A política oficial do OpenStreetMap exige atribuição visível, identificação do
aplicativo, respeito ao cache e proíbe download em massa/offline dos blocos
públicos. O serviço também não oferece SLA e recomenda que a URL do provedor não
fique rigidamente acoplada ao aplicativo.

Referências:

- https://operations.osmfoundation.org/policies/tiles/
- https://osmfoundation.org/wiki/Licence/Attribution_Guidelines

**Decisão:** o mapa executivo não pode reutilizar o componente atual sem
adequação de atribuição, política de cache e estratégia de provedor.

## Riscos e tratamentos

| Risco | Nível | Tratamento proposto |
|---|---:|---|
| `regionalId` órfão ou inativo ser considerado válido | Alto | Validar contra snapshot do catálogo ativo |
| Bairro associado a mais de uma regional | Alto | Auditoria global e fila de conflitos |
| Coordenada válida no mundo, mas fora de Fortaleza | Alto | Limite municipal oficial e classificação explícita |
| Mapa sugerir precisão inexistente | Alto | Manter mapa bloqueado até aprovação do gate |
| Ausência de geometria oficial | Alto | Definir fonte, versão, licença e vigência |
| Uso de blocos OSM sem atribuição visível | Alto | Adequar componente e estratégia de provedor |
| Gestor identificar problema sem poder corrigir | Médio | Definir fluxo institucional de saneamento |
| Leitura integral de ações no cliente | Médio | Medir volume e planejar agregação/paginação |
| Correção automática alterar histórico | Alto | Somente propostas; confirmação e trilha de auditoria |

## Portão de qualidade proposto

O mapa permanece bloqueado até que um relatório sobre dados reais demonstre:

1. 100% das regionais usadas pelo mapa com fonte, versão e identidade oficial;
2. zero bairros duplicados entre regionais ativas da mesma tipologia;
3. pelo menos 95% dos RAEs recentes com `regionalId` reconhecido e ativo;
4. pelo menos 90% dos RAEs recentes com coordenadas dentro do limite municipal;
5. zero coordenadas inválidas apresentadas como pontos confirmados;
6. divergências bairro–regional explicitadas e excluídas da camada oficial;
7. atribuição/licença e provedor cartográfico aprovados;
8. homologação específica no Samsung Galaxy A05.

Os percentuais devem ser confirmados pelo responsável institucional antes da
implementação. O período de “RAEs recentes” também precisa ser formalmente
definido, com proposta inicial de 12 meses.

## Escopo recomendado do Lote 4

- snapshot imutável do catálogo territorial;
- validador de `regionalId`, tipologia e estado ativo;
- auditor de duplicidade de bairros;
- classificador de registros válidos, legados, órfãos e divergentes;
- relatório de qualidade sobre dados reais;
- fila de saneamento somente consultiva;
- exportação técnica do diagnóstico, sem alterar RAEs automaticamente;
- definição documentada da fonte geográfica e do gate do mapa.

## Fora do escopo

- mapa executivo em produção;
- correção automática ou migração massiva de RAEs;
- mudança de permissões;
- novas coleções Firestore;
- previsão, IA generativa ou alocação automática;
- alterações no PDF ou no fluxo de fechamento do RAE.

## Parecer

O Lote 4 é viável sem novas dependências, rotas ou Providers globais. A primeira
entrega deve transformar preenchimento territorial em validade institucional
mensurável. O mapa somente deve ser planejado após evidência do gate.

# BUG-RAE-002E.2D.2E.1H — Blueprint IAM Least Privilege

Status: **BLUEPRINT LOCAL / NENHUMA MUTAÇÃO IAM**

## 1. Decisão

A auditoria BUG-RAE-002E.2D.2E.1G-R1 comprovou que o ADC local atual é do tipo
`authorized_user` e possui, entre outras, as permissões:

- `datastore.entities.get`;
- `datastore.entities.list`;
- `datastore.entities.create`;
- `datastore.entities.update`;
- `datastore.entities.delete`.

Logo:

- readiness funcional: PASS;
- readiness de segurança: BLOQUEADO;
- esse ADC não deve ser usado como identidade de escrita do seed real.

## 2. Identidade técnica proposta

Service account proposta:

`fenix-project-catalog-seed@geduc-rae-mobile.iam.gserviceaccount.com`

A conta **ainda não existe por efeito deste pacote**.

Características obrigatórias:

- finalidade exclusiva: seed institucional da coleção `projetos`;
- sem arquivo de chave persistente;
- token curto obtido por impersonação;
- nenhuma reutilização como identidade geral da Plataforma Fênix.

## 3. Custom role proposta

Role ID proposto:

`FenixProjectCatalogSeedCreateOnly`

Permissões de dados incluídas:

- `datastore.entities.get`;
- `datastore.entities.create`.

Permissões deliberadamente não incluídas:

- `datastore.entities.list`;
- `datastore.entities.update`;
- `datastore.entities.delete`;
- `datastore.entities.allocateIds`.

A ausência é intencional. IAM allow roles não são tratados aqui como uma política de
deny explícito; o objetivo é simplesmente não conceder essas capacidades à identidade
dedicada.

## 4. Por que `list` não é necessário

O fluxo produtivo desenhado já conhece exatamente os 53 IDs do manifesto.

O caminho final deverá:

1. fazer GET individual dos 53 destinos com a identidade dedicada;
2. validar ausência ou hash idêntico;
3. somente para ausentes executar CREATE_ONLY.

Portanto, a identidade de escrita não precisa enumerar a coleção.

## 5. Separação entre identidade de auditoria e escrita

O desenho passa a ter duas funções distintas.

### Identidade de auditoria

Pode verificar:

- projeto esperado;
- ruleset ativo;
- hashes de configuração;
- estado operacional do ambiente.

Essa identidade não deve ser usada pelo código para gravar documentos do catálogo.

### Identidade de seed

É exclusivamente a service account dedicada.

O token dessa identidade é o único que poderá alcançar as chamadas Firestore de:

- GET do documento conhecido;
- CREATE_ONLY do documento ausente.

O ADC `authorized_user` base **não deve ser reutilizado como bearer token nas chamadas
Firestore de documento do seed**.

## 6. Impersonação

Estratégia:

`service_account_impersonation_short_lived_token`

O principal operador precisa da capacidade de obter token curto da service account.
A permissão necessária é:

`iam.serviceAccounts.getAccessToken`

O papel padrão normalmente utilizado para isso é:

`roles/iam.serviceAccountTokenCreator`

Se usado, deverá ser vinculado de forma estreita ao recurso da service account alvo,
não como uma concessão ampla e genérica.

Nenhum arquivo de chave JSON da service account será criado como parte do desenho.

## 7. Invariantes para a futura ativação

A futura ativação remota só poderá prosseguir quando forem verdadeiros todos estes
itens:

1. service account dedicada existe;
2. custom role dedicada existe;
3. role contém `get + create`;
4. role não contém `list/update/delete/allocateIds`;
5. operador consegue impersonar a service account;
6. token efetivo da service account é testado por IAM;
7. perfil efetivo passa no avaliador least-privilege;
8. GET dos 53 ocorre usando a identidade dedicada;
9. dupla autorização continua obrigatória;
10. executor faz novo preflight dos 53 antes do primeiro create;
11. não existe UPDATE/PATCH/DELETE no código operacional;
12. pós-seed é READ-ONLY.

## 8. Rollback futuro

Como esta etapa não cria nada remotamente, não existe rollback agora.

Quando a mutação IAM for autorizada em etapa futura, o rollback deverá ser definido
antes da execução e deverá permitir remover:

- binding de impersonação;
- binding da custom role;
- custom role, se criada exclusivamente para esta operação;
- service account dedicada, se não houver dependência posterior aprovada.

A coleção `projetos` não será tratada como rollback via delete. CREATE_ONLY preserva
o princípio de não destruição; qualquer correção de conteúdo será tratada em intervenção
posterior e explícita.

## 9. Estado desta etapa

- IAM remoto alterado: NÃO;
- service account criada: NÃO;
- custom role criada: NÃO;
- binding IAM criado: NÃO;
- token impersonado obtido: NÃO;
- Firestore lido: NÃO;
- Firestore escrito: NÃO;
- seed executado: NÃO.

## 10. Próxima etapa

BUG-RAE-002E.2D.2E.1I deverá transformar este blueprint em um **plano de mutação IAM
dry-run**, com comandos ou operações declarativas geradas mas não executadas.

Somente depois de homologação desse plano será considerada uma etapa separada de
mutação IAM real.

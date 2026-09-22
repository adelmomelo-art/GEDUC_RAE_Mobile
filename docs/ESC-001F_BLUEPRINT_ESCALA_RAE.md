# ESC-001F — Blueprint Escala → RAE

**Baseline:** `4327de9e8f57959c1a572c41aba021ccc0c513ee`

## Regra de domínio

Somente atividade educativa de escala publicada, marcada com `geraRae=true`,
pode originar RAE. O operador deve ser agente participante ou coordenador da
atividade. Administrador, gestor, gerente e usuário externo não operam essa
integração.

## Identidade e idempotência

```text
chave = escalaId + "|" + escalaAtividadeId
raeId = "rae-" + SHA256(chave)
```

A mesma atividade sempre resolve para o mesmo documento. Repetir o envio não
cria outro RAE. Se a atividade já estiver ligada a ID diferente, a operação é
recusada.

## Persistência atômica

A confirmação remota ocorre em uma transação:

1. lê atividade e escala de origem;
2. confirma natureza educativa, `geraRae=true` e escala publicada;
3. grava `acoes/{raeId}` com `escalaId` e `escalaAtividadeId`;
4. grava o mesmo `raeId` em `escala_atividades/{atividadeId}`.

As Rules usam `getAfter()` para impedir vínculo unilateral ou forjado.

## Dados transportados

São pré-preenchidos apenas dados operacionais disponíveis: data, turno, tipo e
título da atividade, início planejado, QTH, regional, ponto de referência,
coordenação e equipe. Localização precisa ser validada no RAE e projeto
institucional precisa ser escolhido no catálogo canônico.

Horas realizadas da Escala não são convertidas em números de produtividade do
RAE. Nenhum dado financeiro existe nesta etapa.

## Ciclo de interface

```text
sem raeId  → Criar RAE desta atividade → fluxo normal do RAE
com raeId  → Abrir RAE vinculado        → detalhe somente leitura
```

Rascunho local da mesma atividade é retomado. Outro rascunho exige confirmação
antes de ser descartado.

## Critérios de homologação

- participante cria e conclui o RAE da própria atividade;
- coordenador cria o RAE da atividade coordenada;
- repetição não gera duplicidade;
- vínculo aparece nos dois documentos com o mesmo ID;
- botão muda de criar para abrir após recarregar a Escala;
- administrador e agente externo não recebem a ação;
- atividade administrativa e escala não publicada não geram RAE;
- projeto, localização e ACL continuam validados pelo fluxo normal;
- produção Firebase não é acessada durante HML isolada.

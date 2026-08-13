# Diagnóstico de saneamento territorial — Etapa 1

> **Diagnóstico histórico superado.** Os números refletem o catálogo anterior à
> reconstrução oficial. O reinício do saneamento usa a LC nº 307/2021.

## Resultado executivo

A leitura autenticada e somente leitura do Firestore de produção confirmou a
evidência observada no Samsung Galaxy A05 e permitiu separar a fila em dois
grupos de tratamento. Nenhum documento foi escrito, alterado ou excluído.

## Fonte e recorte

- projeto: `geduc-rae-mobile`;
- coleções lidas: `acoes` e `regionais`;
- data da leitura: 13/08/2026;
- janela: 13/08/2025 a 13/08/2026;
- RAEs encontrados na janela: 40;
- regionais encontradas: 12, todas ativas;
- dados pessoais: não incluídos neste relatório.

## Reconciliação dos indicadores

- RAEs com identidade regional válida: 5 (12,5%, exibidos como 16% no recorte
  corrente do dashboard);
- RAEs legados sem `regionalId`: 35;
- IDs órfãos: 0;
- regionais inativas referenciadas: 0;
- coordenadas mundiais utilizáveis: 40 de 40 (100%);
- RAEs sem número operacional: 8;
- fila consultiva: 35.

A diferença entre 12,5% na janela fixa e 16% na tela decorre de recortes
distintos: o painel superior estava avaliando 32 registros filtrados, enquanto a
fila consolidada avaliava os 40 registros dos últimos 12 meses.

## Matriz de prioridade dos 35 legados

### Grupo A — correspondência inequívoca: 22

O nome regional legado concorda com a única regional ativa que contém o bairro.
Esses registros são candidatos a um lote de preenchimento de `regionalId`, mas
somente após revisão humana da matriz individual e autorização específica de
escrita.

### Grupo B — decisão institucional: 13

- quatro RAEs usam bairros presentes em mais de uma regional ativa;
- nove RAEs usam bairros que não foram localizados no catálogo ativo;
- nenhum caso apresentou nome legado divergente de um único proprietário do
  bairro.

Esses 13 registros não devem receber `regionalId` por inferência automática.

### Grupo C — evidência totalmente insuficiente: 0

Todos os legados possuem ao menos nome regional ou bairro para encaminhamento,
mas os 13 casos do Grupo B continuam dependentes de decisão institucional.

## Oito conflitos do catálogo

| Bairro normalizado | Regionais ativas envolvidas |
|---|---|
| Boa Vista | SER 09 e SER 08 |
| Dendê | SER 09 e SER 08 |
| Dias Macedo | SER 09 e SER 08 |
| Parque Dois Irmãos | SER 09 e SER 08 |
| Passaré | SER 09 e SER 08 |
| Planalto Ayrton Senna e Prefeito José Walter. | SER 09 e SER 08 |
| Sabiaguaba | SER 07 e SER 06 |
| Serrinha | SER 09 e SER 08 |

O ponto final incorporado ao item “Planalto Ayrton Senna e Prefeito José
Walter.” também deve ser revisado como possível problema de modelagem: o campo
parece reunir mais de um bairro em uma única entrada textual.

## Riscos

1. Preencher os 35 IDs em bloco sem separar os grupos pode consolidar decisões
   territoriais incorretas.
2. Corrigir apenas os RAEs sem resolver o catálogo mantém a ambiguidade para
   novos registros.
3. Os oito RAEs sem número dificultam rastreabilidade e precisam de tratamento
   próprio, sem renumeração automática.
4. Coordenadas válidas mundialmente não comprovam que os pontos estejam dentro
   de Fortaleza; essa validação depende do limite municipal oficial.
5. O mapa deve permanecer bloqueado.

## Proposta de execução

1. Produzir matriz individual restrita dos 22 casos inequívocos, contendo apenas
   ID técnico, número do RAE, data, regional legada, bairro e `regionalId`
   proposto.
2. Submeter essa matriz à homologação humana antes de qualquer escrita.
3. Encaminhar os quatro casos ambíguos junto com os oito conflitos do catálogo
   para decisão institucional.
4. Investigar os nove bairros ausentes e os oito RAEs sem número em lotes
   separados.
5. Reexecutar o diagnóstico após cada lote aprovado e registrar antes/depois.

## Estado da etapa

Etapa 1 concluída em modo somente leitura. Não houve alteração no Firestore,
commit, publicação de branch, PR ou liberação do mapa.

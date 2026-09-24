# Blueprint ESC-001H.2 — Repository e controller históricos

**Baseline de entrada:** `846fefc28e62df7ec791c736f9144f6c6e9f2d74`

**Etapa anterior:** ESC-001H.1 — fechada

## Objetivo

Disponibilizar ao aplicativo uma consulta histórica de horas operacionais por intervalo de datas, reutilizando sem alteração semântica o núcleo puro da ESC-001H.1.

## Contrato do período

- início e fim são normalizados para a data local;
- os limites são inclusivos;
- o fim não pode anteceder o início;
- o intervalo máximo é de 366 dias;
- a resposta contém apenas dias com escala publicada;
- se houver mais de uma publicação na mesma data, prevalece a maior versão e, em empate, o menor ID;
- listas retornadas são imutáveis e ordenadas deterministicamente.

## Estratégia de persistência

O repository consulta em paralelo:

1. `escalas` pela faixa de `data`;
2. `escala_atividades` pela faixa de `data`;
3. `escala_alocacoes` pela faixa de `data`;
4. `escala_indisponibilidades` com `dataInicio` anterior ao fim exclusivo.

O filtro de `status == publicada`, a seleção de versão e o vínculo dos filhos são feitos em memória. Isso evita uma consulta por dia e não adiciona dependência de índice composto.

## Matriz de acesso

| Perfil | Histórico geral | Próprio histórico |
|---|---:|---:|
| administrador | sim | sim |
| gestor | sim | sim |
| gerente | sim | sim |
| coordenador | não | sim |
| agente | não | sim |

Perfis desconhecidos e UID vazio são rejeitados. Na visão própria, alocações, atividades e indisponibilidades de terceiros são removidas antes de o serviço histórico consolidar os dados.

## Estados do controller

- período selecionado;
- modo geral ou próprio;
- carregamento;
- resultado imutável;
- resumo histórico consolidado;
- erro capturado;
- geração de carregamento para descartar respostas obsoletas.

## Não objetivos

- nenhuma tela nesta etapa;
- nenhuma alteração nas regras do Firestore, pois as coleções já possuem leitura para usuário ativo;
- nenhuma produtividade, ranking ou Faixita;
- nenhum valor financeiro ou conversão monetária;
- nenhum deploy Firebase.

## Critérios de aceite

- repository retorna somente publicações válidas dentro do período;
- controller geral consolida todos os registros autorizados;
- controller próprio não expõe registros de terceiros;
- intervalo inválido é bloqueado antes de consultar o Firestore;
- identidade e pendências mantêm as regras da ESC-001H.1;
- testes completos e análise estática passam sem advertências.

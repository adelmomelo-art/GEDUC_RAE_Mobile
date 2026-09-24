# Blueprint ESC-001H.3 — UI histórica e indicadores de horas

**Baseline de entrada:** `39fd8f86692b0365f11d4f248e3021821314220b`

**Etapa anterior:** ESC-001H.2 — fechada

## Objetivo

Entregar a interface operacional de consulta histórica de horas, consumindo o núcleo consolidado da ESC-001H.1 e o repository/controller da ESC-001H.2 sem duplicar regras de domínio.

## Jornada

1. o usuário abre `Histórico de horas` na Escala GEDUC;
2. seleciona início e fim inclusivos, limitados a 366 dias;
3. perfis administrativos autorizados alternam entre visão geral e horas próprias;
4. coordenador e agente permanecem obrigatoriamente em `Minhas horas`;
5. a tela apresenta horas planejadas, realizadas, normais, extras, crédito, compensação e saldo do banco;
6. pendências são explícitas e nunca convertidas em horas inferidas;
7. dias e versões publicadas consultadas permanecem visíveis para conferência.

## Matriz visual de acesso

| Perfil | Visão geral | Minhas horas |
|---|---:|---:|
| administrador | sim | sim |
| gestor | sim | sim |
| gerente | sim | sim |
| coordenador | não | sim |
| agente | não | sim |

O bloqueio é aplicado pelo controller e não apenas pela ocultação do seletor.

## Estados obrigatórios

- carregando;
- resultado consolidado;
- período sem escala publicada;
- erro com nova tentativa;
- pendências de registro;
- saldo positivo, nulo ou negativo;
- layout responsivo para celular, tablet e web.

## Privacidade e integridade

- a visão própria filtra alocações e indisponibilidades antes da consolidação;
- a tela não grava dados;
- rascunhos e versões publicadas antigas não aparecem;
- o histórico não mostra valores financeiros;
- nenhuma consulta adicional por dia é criada;
- nenhuma regra Firestore é alterada.

## Não objetivos

- ranking ou avaliação individual;
- produtividade por RAE;
- recomendações da Faixita;
- conversão monetária ou folha de pagamento;
- exportação PDF histórica;
- deploy Firebase.

## Critérios de aceite

- rota protegida `/escala/historico` disponível pela Escala GEDUC;
- intervalo e modo de consulta controlados pelo `EscalaHistoricoController`;
- perfis gerais e próprios respeitam a matriz de acesso;
- indicadores e saldos utilizam exclusivamente o resumo da ESC-001H.1;
- vazio, erro, carregamento e pendências possuem tratamento visual;
- testes focados, suíte completa, análise e regressão das regras passam.

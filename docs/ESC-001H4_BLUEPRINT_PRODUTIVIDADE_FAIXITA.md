# Blueprint — ESC-001H.4 Produtividade e Faixita

**Baseline:** `29645e6186b48522510c9ed2393ee57413cbef57`

## Decisão de domínio

Neste escopo, “produtividade” significa acompanhamento da completude dos
registros e da aderência operacional ao planejamento. O sistema não atribui
nota, não ordena pessoas e não presume que trabalhar mais horas representa
melhor desempenho.

## Fontes de verdade

- horas planejadas: escala publicada;
- horas realizadas: registros coerentes feitos pelo próprio participante;
- banco de horas: crédito realizado menos compensação registrada;
- pendências: dados ausentes, inválidos ou sem identidade;
- período: inclusivo, limitado a 366 dias pela consulta histórica.

## Contrato de cálculo

| Indicador | Fórmula | Ausência de base |
|---|---|---|
| Cobertura | concluídas / alocações | `Sem base` quando não há alocações |
| Aderência | minutos realizados / planejados | `Sem base` quando planejado é zero |
| Pendências | sem horas + horas inválidas | exibidas antes da interpretação |

Faixas de aderência:

- abaixo: `< 90%`;
- compatível: `90% a 110%`;
- acima: `> 110%`.

## Faixita

A Faixita utiliza mensagens fixas e auditáveis:

1. sem alocações: informa ausência de base;
2. com pendências: orienta completar ou corrigir registros;
3. sem horas planejadas: informa impossibilidade de calcular aderência;
4. abaixo/compatível/acima: descreve a relação e recomenda conferência do
   contexto, horas extras ou banco quando aplicável.

## Segurança e privacidade

- respeita a visão geral de administrador, gestor e gerente;
- respeita a visão própria de coordenador e agente;
- não amplia consultas nem permissões;
- não persiste os indicadores;
- não acessa produção durante a homologação isolada.

## Fora do escopo

- cálculo financeiro;
- metas individuais;
- avaliação disciplinar;
- comparação ou ranking de pessoas;
- inteligência artificial generativa;
- alterações em Firestore Rules, índices ou deploy Firebase.

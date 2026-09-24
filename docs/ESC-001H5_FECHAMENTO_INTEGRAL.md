# ESC-001H.5 — Fechamento integral da trilha de indicadores de horas

**Baseline de entrada:** `2b6c245f43029209f7559c7c861f77e894b281ad`
**Natureza:** homologação técnica e funcional consolidada
**Regra:** nenhuma funcionalidade nova

## 1. Cadeia homologada

| Etapa | Merge oficial | Entrega |
|---|---|---|
| ESC-001H.1 | `846fefc28e62df7ec791c736f9144f6c6e9f2d74` | domínio histórico e banco de horas |
| ESC-001H.2 | `39fd8f86692b0365f11d4f248e3021821314220b` | consulta, repository e controller |
| ESC-001H.3 | `29645e6186b48522510c9ed2393ee57413cbef57` | interface histórica e indicadores |
| ESC-001H.4 | `2b6c245f43029209f7559c7c861f77e894b281ad` | cobertura, aderência e Faixita |

## 2. Matriz integral de aceite

1. considerar apenas escalas publicadas e a versão mais recente por data;
2. respeitar período inclusivo de no máximo 366 dias;
3. consolidar horas planejadas, normais, extras e créditos de banco;
4. debitar compensações e expor saldo negativo sem correção automática;
5. reconciliar identidade por `usuarioId` e `membroEquipeId`, nunca por nome;
6. manter registros ausentes ou inválidos como pendências explícitas;
7. restringir visão geral e visão própria pela política homologada;
8. calcular cobertura como registros coerentes sobre alocações;
9. calcular aderência como minutos realizados sobre planejados;
10. classificar aderência abaixo de 90%, entre 90% e 110%, ou acima de 110%;
11. emitir orientação determinística e auditável da Faixita;
12. não criar nota, ranking, comparação pessoal ou decisão automática opaca.

## 3. Quality gates

- ancestralidade das quatro entregas oficiais;
- formatação Dart sem alteração;
- testes focados da trilha histórica;
- suíte Flutter completa;
- `flutter analyze` sem issues;
- regressão integral das Firestore Rules em emulador;
- isolamento de `node_modules` da análise Flutter;
- escopo Git limitado aos três artefatos de fechamento;
- `git diff --check`;
- geração de CPB e SHA-256.

## 4. Segurança operacional

A homologação não acessa Firebase de produção, não lê nem altera documentos
reais, não publica Rules, índices, Functions, Storage ou Hosting e não modifica
App Check.

## 5. Fora do escopo permanente

- folha de pagamento e remuneração;
- valor de hora, adicional ou conversão monetária;
- orçamento ou financeiro;
- metas individuais, nota, ranking ou comparação entre pessoas;
- inteligência artificial generativa;
- nova interface ou persistência de indicadores.

## 6. Resultado esperado

Com todos os gates aprovados, a ESC-001H fica pronta para commit, PR, seis
Quality Gates, merge e sincronização da `main`. A definição de uma etapa
posterior exige atualização formal do roadmap; ESC-001I e ESC-002 não são
inferidas por este fechamento.

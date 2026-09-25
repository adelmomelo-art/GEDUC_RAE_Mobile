# UX-ESCALA-R1 - Blueprint de refinamentos pos-homologacao

**Baseline:** `21647c1cee46b3c25e344dfa46ae34fe0ab2a85d`
**Natureza:** manutencao visual sem mudanca de dominio

## Decisoes

1. A Escala GEDUC permanece como entrada unica de consulta na Home.
2. A alternancia Escala completa | Minha Escala permanece dentro da tela.
3. A rota legada de Minha Escala permanece valida.
4. O quadro geral de jornadas e removido por redundancia visual.
5. O carimbo da publicacao, versao, equipe, horas e classificacoes permanecem.

## Aceite

- "Jornadas de referencia" ausente nas duas visoes;
- `PUBLICADA - vN` presente;
- somente "Escala GEDUC" como atalho de consulta na Home;
- Gestao e Configuracao da Escala preservadas conforme perfil;
- testes focados, suite completa e analyze aprovados;
- Rules sem alteracao e regressao aprovada;
- producao nao acessada durante a homologacao deste pacote.

## Fora do escopo

- correcao de Salvar Escopo;
- alteracao de regras ou dados;
- execucao, RAE, evidencias e financeiro;
- nova etapa ESC ou mudanca do roadmap.
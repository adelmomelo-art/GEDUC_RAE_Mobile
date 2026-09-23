# ESC-001G — Blueprint do PDF oficial da Escala GEDUC

**Baseline de entrada:** `0e45c811fddd6fce155090e7f955ba667114c659`

**Etapa anterior:** ESC-001F — fechada e regras publicadas

## 1. Objetivo

Produzir um PDF institucional da versão publicada da Escala GEDUC, adequado
para consulta, impressão e salvamento pelo mecanismo nativo da plataforma.

## 2. Fonte oficial

O documento é construído exclusivamente com o `EscalaDiaConsulta` completo da
versão publicada. A seleção visual `Minha Escala` não reduz o conteúdo do PDF.

Escala ausente, rascunho e revisão ainda não publicada falham fechado.

## 3. Conteúdo

- cabeçalho institucional;
- data, dia da semana, versão e publicação;
- totais de atividades, integrantes e horas programadas;
- distribuição planejada entre jornada normal, hora extra e banco de horas;
- atividades por seção, com QTR e QTH;
- coordenação, tipo e orientação operacional;
- equipe completa com função, horário, jornada e duração prevista;
- compensações, férias e folgas;
- observação geral da versão publicada;
- numeração de páginas e aviso de versionamento.

## 4. Exclusões obrigatórias

- horas realizadas;
- observações de execução;
- resultados e evidências de missão;
- conteúdo do RAE;
- indicadores/Faixita;
- valores monetários ou qualquer cálculo financeiro.

## 5. Contratos técnicos

- `EscalaPdfService.gerarBytes` valida que a escala está publicada;
- nome de arquivo determinístico por data e versão;
- PDF A4 paisagem e fontes Noto Sans Unicode;
- ordenação determinística de seções, atividades e integrantes;
- integração somente pela consulta já autorizada, sem nova leitura Firestore;
- nenhuma alteração de schema, regras, índices, Functions, Storage ou App Check.

## 6. Interface

O botão `PDF oficial` aparece somente após o carregamento de uma escala
publicada. Durante a geração fica desabilitado e mostra progresso. Uma falha
gera mensagem local sem alterar dados.

## 7. Critérios de aceite

1. rascunho não expõe o comando nem gera documento oficial;
2. versão publicada gera bytes `%PDF` com fontes Unicode;
3. nome do arquivo contém data ISO e versão;
4. `Minha Escala` continua gerando o documento completo;
5. o documento contém somente planejamento e snapshots publicados;
6. testes focados, suíte completa e análise estática passam;
7. Firestore Rules permanecem sem regressão;
8. nenhum deploy é necessário.

## 8. Próxima etapa

ESC-001H permanece reservada a indicadores operacionais, Faixita e saldo de
horas. Cálculo financeiro não se aplica ao projeto.

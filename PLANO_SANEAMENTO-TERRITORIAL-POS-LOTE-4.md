# Ciclo de saneamento territorial pós-Lote 4

## Objetivo

Elevar a qualidade institucional dos vínculos territoriais dos RAEs e eliminar
conflitos do catálogo, sem alterar registros automaticamente e sem liberar o
mapa antes do atendimento integral dos portões aprovados.

## Baseline de abertura

- data: 13/08/2026;
- baseline técnico: `997d9e141ceac2bc6e1f4525fb66085ee1a99014`;
- dispositivo de evidência: Samsung Galaxy A05;
- cobertura institucional observada: 16%;
- coordenadas utilizáveis observadas: 100%;
- regionais ativas: 12;
- conflitos de bairro: 8;
- RAEs avaliados nos últimos 12 meses: 40;
- RAEs na fila consultiva: 35.

## Limites do ciclo

Permitido neste ciclo:

- leitura autenticada e diagnóstico;
- classificação e priorização das pendências;
- identificação dos conflitos de catálogo;
- produção de proposta de correção por lote;
- homologação humana de cada proposta antes de qualquer escrita.

Não permitido sem nova autorização específica:

- alterar automaticamente RAEs ou regionais;
- inferir uma regional apenas pela proximidade geográfica;
- excluir ou fundir documentos;
- alterar regras do Firestore, rotas ou dependências;
- publicar branch, abrir PR ou executar merge;
- habilitar o mapa.

## Frente 1 — Reconciliação da fila de 35 RAEs

1. Exportar somente os identificadores operacionais mínimos da fila.
2. Separar registros legados, órfãos, inativos, ambíguos e divergentes.
3. Para cada RAE, confrontar regional nominal, `regionalId`, tipologia, bairro e
   coordenadas com o catálogo oficial.
4. Classificar cada caso como correção inequívoca, decisão institucional ou
   insuficiência de evidência.
5. Produzir lotes pequenos e reversíveis para homologação humana.

## Frente 2 — Oito conflitos de bairro

1. Identificar bairro normalizado, tipologia e regionais envolvidas.
2. Confirmar se a duplicidade é erro, sobreposição institucional válida ou
   diferença histórica de vigência.
3. Definir regional responsável e data de vigência com fonte institucional.
4. Propor correção do catálogo sem apagar o histórico dos RAEs.

## Frente 3 — Governança e evidências

1. Registrar responsável e fonte de decisão de cada correção.
2. Manter trilha de antes/depois e mecanismo de reversão.
3. Não incluir nomes pessoais ou dados desnecessários nos relatórios.
4. Reexecutar o diagnóstico após cada lote homologado.

## Portões de encerramento

- 100% das regionais com identidade e fonte oficial registradas;
- zero bairros duplicados entre regionais ativas da mesma tipologia;
- pelo menos 95% dos RAEs recentes com `regionalId` reconhecido e ativo;
- pelo menos 90% dos RAEs recentes com coordenadas dentro do limite municipal
  oficialmente aprovado;
- zero coordenadas inválidas apresentadas como confirmadas;
- 100% das alterações com responsável, fonte e evidência de homologação.

## Etapa inicial autorizada

O ciclo está aberto para diagnóstico consultivo. O primeiro produto será uma
matriz agregada de prioridades e conflitos, sem escrita no Firestore e sem
exposição de dados pessoais.

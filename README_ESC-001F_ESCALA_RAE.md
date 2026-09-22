# ESC-001F — Escala → RAE

Integra a atividade educativa publicada da Escala GEDUC ao fluxo existente do
RAE, preservando a separação entre planejamento, execução e financeiro.

## Entrega

- botão `Criar RAE desta atividade` para agente participante ou coordenador;
- botão `Abrir RAE vinculado` quando o vínculo já existe;
- rascunho pré-preenchido com data, turno, atividade, QTH, regional,
  coordenação e equipe;
- ID `rae-<sha256>` determinístico por `escalaId|atividadeId`;
- vínculo bidirecional e transacional entre `acoes` e
  `escala_atividades.raeId`;
- retomada idempotente do mesmo rascunho;
- proteção contra troca da origem do RAE;
- nenhuma criação para missão administrativa, rascunho de escala,
  administrador ou usuário externo à atividade.

## Limites

- o projeto institucional e a validação da localização continuam sendo
  confirmados no fluxo normal do RAE;
- não há campo, cálculo ou integração financeira;
- não há mudança no upload físico de evidências;
- o RAE só é vinculado remotamente quando o relatório é enviado ou
  sincronizado.

## Validação

O pacote executa formatação, testes focados, suíte Flutter completa,
`flutter analyze`, regressão das Firestore Rules, isolamento de `node_modules`,
verificação de escopo e geração de CPB. Commit, push, PR, merge e deploy ficam
pendentes da homologação funcional.

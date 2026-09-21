# ESC-001E.3 — Tela Execução da Missão

**Baseline:** `57fc8722064337dfa459802c02d362a13f7b3fe2` (ESC-001E.2, PR #97).

## Fluxo

1. Na Escala publicada, a missão administrativa sem RAE oferece entrada ao agente participante ou coordenador autorizado.
2. A rota `/escala/execucao/:atividadeId` exige identidade ativa apta a consultar a Escala. A página carrega o contexto pela camada E.2, que valida publicação, natureza, executor canônico e execução individual. A rota direta não concede permissão de escrita.
3. A tela mostra título, data, equipe, executor, orientação e estado da própria execução.
4. Sem registro: **Iniciar missão**. Em andamento: **Salvar andamento**, **Concluir missão** e **Cancelar missão**. Conclusão exige resultado e confirmação; cancelamento exige confirmação. Estado terminal é somente leitura.
5. Erro de carregamento permite nova tentativa. Erro de gravação mantém os campos e mostra a falha.

## Limites

- A execução é individual por `atividadeId + auth.uid`; a tela não altera a atividade, equipe, QTR, QTH ou horas planejadas.
- O painel mostra a quantidade e os metadados de evidências já registrados. Entrada/remoção de evidências e UX de horas realizadas pertencem à E.4.
- Escala→RAE pertence à ESC-001F. Não há upload físico, alteração de Storage/R2/App Check, produtividade ou financeiro.
- O administrador não opera execução, ainda que conste na lista de participantes: alinhamento da política Flutter e das Rules à matriz da E.1.

## Verificação

- Widget: início, salvamento, conclusão com confirmação, resultado obrigatório, cancelamento com confirmação, acesso sem vínculo e nova tentativa após falha.
- Escala: botão só para missão administrativa publicada e executor autorizado.
- Política/Rules: administrador participante não escreve execução.
- `flutter test`, `flutter analyze` (0 issues) e regressão `npm run test:rules` antes de commit/PR.

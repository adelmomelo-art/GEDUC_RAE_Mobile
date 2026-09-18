# ESC-001D.5 — DELTA DE FIRESTORE RULES

Baseline: `cf0df4c0aa510e470db209e28cc762700190a878`

1. Escala inicial continua sendo criada somente pelo agente responsável.
2. Responsável ou Gerente podem criar **revisão** desde que:
   - origem exista e esteja publicada;
   - mesma data;
   - versão = origem + 1;
   - motivo não vazio;
   - `revisaoPreparada=false`.
3. Publicada não pode ser revisada in-place.
4. Publicada só pode transicionar para `arquivada`, preservando versão,
   origem e metadados de publicação.
5. Rascunho revisado só publica quando `revisaoPreparada=true`.
6. `origemAlocacaoId` permite copiar classificação complementar publicada
   somente quando os dados classificados são idênticos à origem.
7. Gerente continua proibido de criar/reclassificar HORA_EXTRA/BANCO_HORAS
   sem proveniência válida.
8. Atividades/alocações da versão publicada continuam imutáveis.
9. Storage/R2/App Check permanecem inalterados.

# ESC-001D.4 — Gestão da Escala GEDUC

Baseline: `97f7f331c82a845fbabac375610a5d0ecf110d57`

## Fluxo entregue

```text
/escala/gestao
→ selecionar data (calendário / anterior / próximo / hoje)
→ criar rascunho (responsável)
→ nova atividade
→ coordenador
→ equipe GEDUC
→ classificação de jornada
→ alertas
→ resumo de efetivo e horas
```

O Gerente pode editar rascunho existente, mas não cria nova escala.

A classificação de nova jornada adicional permanece atribuição do agente
responsável. Alertas de indisponibilidade e sobreposição são informativos e
não bloqueiam a decisão operacional.

A publicação/revisão permanece deliberadamente fora desta entrega e será
tratada na ESC-001D.5.

## Segurança D.4

A escala publicada permanece estruturalmente imutável nesta fase. Atividades e alocações só podem ser criadas/alteradas enquanto a escala-pai estiver em `rascunho`. O Gerente ganha somente leitura de `equipe_operacional` para montar a escala; o ACL global legado e as escritas da equipe permanecem inalterados.

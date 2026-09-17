# ESC-001D.3 — Consulta da Escala GEDUC

Baseline: `4b1902fa80708ac330b11d94c85aa3f37e4112a3`

Esta etapa cria a camada de consulta publicada da Escala GEDUC.

## Fluxo

```text
Home
→ Escala GEDUC
→ data
→ Escala completa | Minha Escala
→ seções
→ cards de atividade
```

## Princípios mantidos

- consultar é simples;
- rascunho não é exposto ao agente pela tela;
- QTR é horário;
- QTH é local;
- 180H/240H são referências informativas, não travas;
- hora extra e banco de horas continuam não financeiros;
- segunda jornada e sobreposição aparecem apenas como informação;
- nenhuma Firestore Rule é alterada nesta entrega.

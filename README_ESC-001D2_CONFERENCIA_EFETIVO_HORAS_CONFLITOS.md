# ESC-001D.2 — Equipe GEDUC, Conferência, Horas e Conflitos

Baseline: `c4af0b1dbb366b2352d6ac60b4bf20193ad9eda9`

A ESC-001D.2 implementa somente domínio puro. Não cria páginas, rotas,
controllers, repositórios Firestore, novas coleções ou regras financeiras.

## Fechamento funcional esperado

```text
35 agentes, 30 únicos alocados, 3 férias, 2 compensação
= cobertura 35/35

35 agentes, 29 únicos alocados, um deles alocado duas vezes,
3 férias, 2 compensação
= cobertura 34/35
= 30 alocações
= 29 pessoas em atividade
= 1 pessoa sem situação
```

A deduplicação usa UID canônico quando disponível. Membro legado sem UID pode
ser conferido por `membroEquipeId`, mas é obrigatoriamente sinalizado como
identidade não canônica.

Horas continuam sendo programadas. Horas realizadas permanecem para ESC-001E.

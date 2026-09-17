# ESC-001D.1 — Segurança e Contratos

Baseline: `603b891c6c3adfb37543122058c7e23a6dc93766`

## Objetivo

Abrir a implementação da ESC-001D pelo contrato e pela segurança, sem criar
telas nesta subetapa.

## Decisões implementadas

- somente o agente fixo responsável cria nova escala;
- Gerente não cria nova escala;
- Gerente e agente responsável editam, revisam e publicam escala existente;
- Administrador permanece em governança técnica/configuração;
- `gerente` continua isolado do ACL global legado;
- alocações passam a distinguir `normal`, `hora_extra` e `banco_horas`;
- nenhuma informação financeira é criada;
- `minutosPrevistos` representa horas programadas, não horas trabalhadas;
- campos de execução real ficam preparados, mas não são preenchidos nesta fase;
- jornada complementar exige motivo e autoria da classificação;
- exclusão client-side continua bloqueada.

## Fora do escopo

- telas;
- rotas;
- conferência dos 35 agentes;
- cálculo agregado de horas;
- detecção de sobreposição;
- execução real;
- RAE automático;
- PDF;
- indicadores históricos.

Esses itens seguem nas ESC-001D.2 a ESC-001H conforme plano homologado.

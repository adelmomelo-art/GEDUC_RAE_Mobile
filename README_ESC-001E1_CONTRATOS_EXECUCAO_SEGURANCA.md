# ESC-001E.1 — Contratos de Execução e Segurança

Baseline: `f1fe5fa513f42524fac64c74d824e623f9dcf2ff`

Entrega fundacional da ESC-001E:

- Blueprint v0.1;
- Plano v0.1;
- tipos de evidência administrativa;
- `registrarHorasRealizadas`;
- `EscalaExecucaoService`;
- resumo de horas realizadas;
- Rules: execução administrativa somente em escala publicada;
- Rules: agente registra apenas horas da própria alocação publicada;
- planejamento e classificação permanecem protegidos;
- execução terminal não reabre pelo cliente;
- regressão Dart + Firestore.

Não entram nesta subetapa:

- rota/tela de execução;
- repositório/controller de execução;
- upload físico de evidências;
- Escala → RAE;
- financeiro.

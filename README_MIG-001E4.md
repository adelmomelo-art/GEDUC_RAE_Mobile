# MIG-001E4 — Estado da intervenção

## Objetivo

Executar o primeiro piloto real de persistência histórica no Firestore com 10
registros determinísticos, sem tocar em `acoes` ou `contadores`.

## Estado atual

**E4-B1 — componentes implementados, testados somente com mocks.**

Implementado:

- `mig001e4_adc.mjs`
  - provider ADC com runner injetável;
  - token não é logado pelo provider;
  - comando gcloud fixo.

- `mig001e4_fingerprint.mjs`
  - somente GET;
  - read allowlist: `acoes`, `contadores`;
  - fingerprint determinístico por documentos ordenados;
  - sem superfície de escrita.

- `mig001e4_pilot.mjs`
  - projeto obrigatório `geduc-rae-mobile`;
  - piloto obrigatório de 10;
  - batch obrigatório `mig001e4_pilot_v1`;
  - `apply` genérico proibido;
  - 31 operações CREATE_ONLY;
  - distribuição 10 staging + 10 histórico + 10 journal + 1 batch;
  - batch marker reordenado e validado como última operação;
  - preflight de todos os 31 alvos antes da primeira escrita;
  - falha parcial interrompe execução;
  - nenhum update/delete automático.

## Estado de rede

Nesta etapa B1:

- `gcloud` real: não executado;
- ADC token real: não obtido;
- Firestore real: não acessado;
- reads reais: zero;
- writes reais: zero.

O primeiro acesso real permanece reservado para E4-P1, após a engenharia E4
passar por auditoria, commit, PR, Quality Gates e merge.
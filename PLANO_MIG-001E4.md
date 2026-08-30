# PLANO MIG-001E4 — Piloto real controlado

## E4-ENG — engenharia sem Firestore real

### E4-A1
Blueprint + plano + branch. Zero Firestore.

### E4-A2
Preflight local:
- Node;
- gcloud;
- ADC configurado;
- fonte SHA/count/schema;
- zero Firestore.

### E4-B1
Implementar:
- ADC token provider;
- read-only fingerprinter;
- pilot executor;
- guardas de `--pilot-apply 10`;
- preflight dos 31 alvos;
- batch marker por último.

Todos os testes com mocks.

### E4-B2
Auditoria local:
- 31 operações máximas;
- 10/10/10/1;
- zero deny roots;
- fingerprints mockados;
- token não vaza;
- erro parcial retomável;
- apply genérico continua proibido.

### E4-C
Testes, flutter analyze, commit, push, PR, 6/6 Quality Gates, merge e limpeza.

## E4-PILOT — primeiro contato real

### E4-P1 — read-only
- obter ADC token sem exibir;
- confirmar projeto;
- fingerprint PRE `/acoes`;
- fingerprint PRE `/contadores`;
- consultar os 31 targets;
- zero writes.

### E4-P2 — apply
Somente após P1 homologado:
- 10 staging;
- 10 histórico;
- 10 journal;
- batch marker por último.

### E4-P3 — reconciliação
- fingerprint POS `/acoes`;
- fingerprint POS `/contadores`;
- PRE == POS obrigatório;
- validar 10 históricos, 10 staging, 10 journal e batch.

## Stop conditions
Abortar antes de escrita se projeto, fonte, ADC, fingerprint, target, pilot size
ou batch ID divergirem. Nunca tentar update/delete automático.
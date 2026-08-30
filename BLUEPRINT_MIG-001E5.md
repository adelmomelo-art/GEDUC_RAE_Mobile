# BLUEPRINT MIG-001E5 — Rollback / Recovery da migração histórica

## Baseline

- Base oficial: `abbf90eadfcf4099541e67cd468e3717a8f620a6`
- MIG-001E4 piloto: homologado
- Pilot batch válido preservado: `mig001e4_pilot_v1`
- Pilot ID set SHA256: `8347d173f238cc4dc1514fe2ec134d68bf6d19e89ae7e784ba9ec0ba1bd60a9c`
- Registros válidos do piloto: `10`
- Targets válidos do piloto: `31`

## Princípio central

O MIG-001E5 **não utilizará os 31 documentos válidos do piloto como alvo de
teste de rollback**.

A prova de rollback/recovery será feita com um lote-probe descartável,
determinístico e isolado, usando as mesmas superfícies de persistência da
migração, mas IDs reservados e payload sem dados pessoais.

## Identidade reservada do probe

- batch: `mig001e5_rollback_probe_v1`
- document id base: `probe_mig001e5_v1`
- record type: `migration_rollback_probe`
- contém somente metadados técnicos
- zero raw responder email
- zero dados de ação reais
- zero número RAE
- zero contador

## Probe write set

Quatro documentos descartáveis:

1. `migration_google_forms_staging/probe_mig001e5_v1`
2. `acoes_historicas/probe_mig001e5_v1`
3. `migration_batches/mig001e5_rollback_probe_v1/changes/probe_mig001e5_v1_history`
4. `migration_batches/mig001e5_rollback_probe_v1`

Todos:
- CREATE_ONLY
- contentHash determinístico
- target exato fechado
- sem atualização

O batch marker é criado por último.

## Rollback seguro por hash

Não haverá DELETE genérico.

A única capacidade de remoção deve exigir simultaneamente:

- projeto explícito `geduc-rae-mobile`;
- batch exato `mig001e5_rollback_probe_v1`;
- target pertencente ao conjunto fixo de 4 documentos probe;
- GET prévio do `contentHash`;
- hash existente exatamente igual ao hash esperado;
- DELETE somente do target exato;
- qualquer divergência aborta antes do DELETE.

### Ordem do rollback

1. batch marker — remover o sinal de lote completo primeiro;
2. histórico probe;
3. staging probe;
4. journal probe — mantido até o final como guia de recuperação.

Firestore não apaga subcoleções ao apagar o documento pai; por isso o journal
permanece acessível até sua remoção explícita.

## Recovery

Depois de provar ausência dos quatro targets:

1. recriar staging probe;
2. recriar histórico probe;
3. recriar journal probe;
4. recriar batch marker por último;
5. verificar os quatro hashes.

A recuperação precisa reproduzir exatamente o mesmo conjunto e hashes.

## Limpeza final

Após recovery comprovado, executar novamente o rollback hash-guarded para
retornar os quatro targets à condição `missing`.

Estado final obrigatório:
- probe staging: missing;
- probe histórico: missing;
- probe journal: missing;
- probe batch: missing;
- 31 documentos válidos MIG-001E4: untouched/unchanged;
- `acoes`: fingerprint protegido estável;
- `contadores`: fingerprint protegido estável.

## Fingerprints protegidos

`acoes`
- count: `44`
- SHA256: `e377671d98863e9e949e0ba83beb254b04df279527ee5ef7ee2e5212256fb9e2`

`contadores`
- count: `1`
- SHA256: `8fc02c81a0ac2ecbbb47b53e2aaabea8b73112abc177c6fa7253a8263098da2f`

Esses fingerprints devem permanecer iguais antes, durante e depois do ciclo.

## Arquitetura

```text
MIG-001E4 pilot válido (31 docs)
        |
        |-- READ-ONLY proof --> untouched

MIG-001E5 probe (4 docs)
        |
        +--> preflight missing
        +--> create-only 4
        +--> verify hashes
        +--> rollback hash-guarded
        +--> verify missing
        +--> recovery create-only 4
        +--> verify hashes
        +--> final rollback hash-guarded
        +--> verify missing
```

## Invariantes

- zero DELETE nos 31 documentos válidos do piloto;
- zero write em `acoes`;
- zero write em `contadores`;
- zero update/PATCH/PUT;
- DELETE apenas dos 4 IDs probe;
- DELETE condicionado ao contentHash esperado;
- recovery somente CREATE_ONLY;
- batch marker create-last / delete-first;
- nenhuma limpeza automática fora do probe;
- token ADC nunca impresso ou persistido.
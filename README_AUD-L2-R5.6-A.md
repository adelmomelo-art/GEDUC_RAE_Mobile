# AUD-L2-R5.6-A â€” Preparation Contract

## Objetivo

Introduzir o contrato provider-neutral para preparacao local de evidencias antes
do calculo de metadata e antes da entrada no pipeline remoto.

Esta etapa nao implementa compressao concreta e nao altera o comportamento
operacional atual de captura/salvamento de fotos.

## Baseline

`4058bab930259ffaa4d862bf4367b236b1caabe4`

## Branch

`audit/aud-l2-r5-6-a-preparation-contract`

## Decisao arquitetural

O arquivo original local e a evidencia operacional/auditavel.

Qualquer arquivo destinado a transformacao/compressao deve ser produzido como
artefato derivado e separado. O original nao pode ser sobrescrito in-place.

Fluxo futuro obrigatorio:

1. capturar/salvar original local;
2. criar artefato preparado separado;
3. congelar os bytes do artefato preparado;
4. calcular SHA-256, tamanho e MIME sobre o artefato preparado;
5. criar identidade `acaoId + evidenciaId + sha256`;
6. criar job de sincronizacao;
7. obter grant;
8. executar upload.

## Contratos introduzidos

- `EvidencePreparationRequest`;
- `EvidencePreparedArtifact`;
- `EvidencePreparationFailure`;
- `EvidencePreparationException`;
- `EvidencePreparer`;
- `EvidencePreparationGuard`.

## Invariantes R5.6-A

1. original local deve ser preservado;
2. artefato preparado deve ter caminho diferente do original;
3. artefato deve declarar qual original o originou;
4. requisicao incompleta falha fechada;
5. artefato incompleto falha fechado;
6. artefato vinculado a outro original falha fechado;
7. `preparationProfile` identifica a receita de preparacao;
8. `preparationProfile` nao e SHA-256;
9. `preparationProfile` nao e objectKey;
10. `preparationProfile` nao e credencial;
11. SHA-256 e tamanho nao pertencem a esta etapa;
12. metadata deve ser calculada depois da preparacao;
13. nenhum provider remoto entra nesta camada;
14. nenhuma dependencia concreta de compressao entra em R5.6-A;
15. `remoteStorageEnabled=true` continua bloqueado.

## Fora do escopo

- compressao JPEG/WebP concreta;
- resize;
- normalizacao EXIF/orientacao;
- escolha de qualidade/dimensao;
- integracao com `EvidenciaStorageService`;
- integracao com `EvidenceSyncJob`;
- lifecycle/limpeza do derivado;
- HTTP/Dio;
- Worker;
- Cloudflare R2;
- Backblaze B2;
- secrets/credenciais;
- habilitacao de storage remoto.

## Proximas etapas

- R5.6-B: implementacao deterministica de preparacao/compressao;
- R5.6-C: integracao preparation -> metadata -> fila e lifecycle;
- R5.7: testes integrados/homologacao.

Status: HOMOLOGADO LOCALMENTE - NAO COMMITADO / NAO PUBLICADO.

## Homologacao final

O AUD-L2-R5.6-A foi homologado localmente sobre a baseline:

`4058bab930259ffaa4d862bf4367b236b1caabe4`

Validacoes obrigatorias:

- teste focado de EvidencePreparation: aprovado;
- regressao test/core/storage: aprovada;
- flutter analyze: 0 issues;
- git diff --check: aprovado;
- escopo Git: exatamente 6 caminhos;
- nenhuma dependencia concreta de compressao adicionada;
- nenhum fluxo operacional de captura alterado;
- nenhum provider remoto introduzido;
- remoteStorageEnabled permanece desabilitado.

### Invariantes homologados

1. o original local permanece preservado;
2. o artefato preparado deve possuir caminho separado;
3. o artefato preparado declara seu arquivo original;
4. request incompleto falha fechado;
5. artifact incompleto falha fechado;
6. source mismatch falha fechado;
7. original e prepared artifact nao podem compartilhar o mesmo caminho;
8. preparationProfile identifica somente a receita de preparacao;
9. preparationProfile nao representa SHA-256;
10. preparationProfile nao representa objectKey;
11. preparationProfile nao representa segredo ou credencial;
12. SHA-256 deve ser calculado somente depois da preparacao;
13. tamanho deve representar os bytes preparados;
14. MIME deve representar o artefato preparado;
15. R5.6-A nao implementa compressao concreta;
16. R5.6-A nao integra EvidenceSyncJob;
17. R5.6-A nao habilita storage remoto.

### Parecer

**AUD-L2-R5.6-A: HOMOLOGADO LOCALMENTE.**

A arquitetura esta aprovada para prosseguir ao R5.6-B -
Deterministic Image Compression, preservando a separacao entre
original auditavel e artefato derivado de transporte.
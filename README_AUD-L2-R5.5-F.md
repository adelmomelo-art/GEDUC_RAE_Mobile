# AUD-L2-R5.5-F — Fechamento de Idempotencia e Integracao

## Objetivo

Fechar os contratos obrigatorios antes de qualquer backend remoto real de
evidencias ser habilitado.

## Baseline

`07886ffc59823dbfc3b7cdd754d0a51dff45c979`

## Branch

`audit/aud-l2-r5-5-f-idempotency-closure`

## Identidade canonica

`EvidenceUploadIdentity` = `acaoId + evidenciaId + sha256`.

O request expoe a chave logica:

`evidence-upload-v1:{acaoId}:{evidenciaId}:{sha256}`

Ela nao e objectKey, segredo ou credencial.

## Binding de grant

O grant de upload usado pelo sync deve ecoar a identidade do snapshot.
O Grant Coordinator falha fechado se o binding estiver ausente ou divergente.

## Contrato bloqueante do backend futuro

Para a mesma identidade canonica, o backend deve garantir:

1. mesma identidade logica de idempotencia;
2. mesma objectKey autoritativa em renovacoes de grant;
3. PUT repetido na mesma chave e mesmo snapshot deve ser seguro;
4. ACL continua sendo decidida no backend;
5. mudanca de SHA representa outro snapshot.

`remoteStorageEnabled=true` permanece bloqueado ate esse contrato ser
implementado e testado no backend real.

## Single-flight local

O Retry Coordinator admite apenas um ciclo ativo por instancia.
Uma segunda chamada concorrente retorna `alreadyProcessing` sem pedir grant,
sem transportar e sem alterar tentativa.

Nao e lock distribuido.

## Fora do escopo

Worker/R2/B2 reais, HTTP/Dio, secrets, credenciais, DELETE, download, lock
distribuido e habilitacao do storage remoto.

Status: HOMOLOGADO LOCALMENTE — NAO COMMITADO / NAO PUBLICADO.

## Validacao final

- Grant Coordinator: aprovado;
- Retry Coordinator: aprovado;
- regressao `test/core/sync`: aprovada;
- regressao `test/core/storage`: aprovada;
- `flutter analyze`: 0 issues;
- `git diff --check`: aprovado;
- escopo Git: exatamente 9 caminhos.

## Invariantes homologados

1. `EvidenceUploadIdentity` e composta por `acaoId`, `evidenciaId` e `sha256`;
2. `idempotencyKey` e deterministica e logica, nao e `objectKey`;
3. grant de upload usado pelo sync deve ecoar `uploadIdentity`;
4. grant sem binding e recusado;
5. grant com `acaoId` divergente e recusado;
6. grant com `evidenciaId` divergente e recusado;
7. grant com SHA-256 divergente e recusado;
8. cliente continua proibido de fabricar `objectKey`;
9. broker/backend continua sendo a autoridade da identidade remota;
10. mesma identidade canonica deve produzir mesma `objectKey` no backend futuro;
11. PUT repetido na mesma chave e mesmo snapshot deve ser idempotente no backend;
12. mudanca de SHA representa outro snapshot;
13. Retry Coordinator admite apenas um ciclo ativo por instancia;
14. segunda chamada concorrente retorna `alreadyProcessing`;
15. chamada concorrente rejeitada nao pede grant;
16. chamada concorrente rejeitada nao chama transporte;
17. chamada concorrente rejeitada nao altera `attemptCount`;
18. single-flight local nao e lock distribuido.

## Gate bloqueante para storage remoto

`remoteStorageEnabled=true` permanece PROIBIDO nesta etapa.

Antes de qualquer habilitacao real, o backend devera provar por teste:

`acaoId + evidenciaId + sha256 -> mesma objectKey autoritativa`

inclusive em renovacoes de grant e repeticao segura de PUT.

Esse requisito cobre a janela residual em que:

1. o upload remoto pode ter ocorrido;
2. a persistencia local da confirmacao/reconciliacao pode falhar;
3. o processo pode reiniciar sem estado duravel suficiente.

Sem idempotencia server-side, essa janela pode produzir duplicacao remota.

## Limites conhecidos

- nao existe backend/Worker real;
- nao existe Cloudflare R2/Backblaze B2 real;
- nao existe HTTP/Dio real;
- nao existe lock distribuido;
- nao existe transacao atomica entre efeito remoto e persistencia local;
- o single-flight e apenas por instancia/processo;
- a idempotencia real ainda depende de implementacao futura no backend.

## Parecer

AUD-L2-R5.5-F: **HOMOLOGADO LOCALMENTE**.

O fechamento contratual da fila de sync esta aprovado para seguir adiante sem
habilitar storage remoto. A proxima fase pode evoluir para R5.6, mantendo o
backend remoto real bloqueado ate a implementacao e homologacao dos requisitos
de idempotencia server-side.

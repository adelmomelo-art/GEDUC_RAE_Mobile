# SEC-R2-002A.6E - Plano de Implementacao

## Baseline obrigatoria

- repositorio: `adelmomelo-art/GEDUC_RAE_Mobile`;
- branch base: `main`;
- commit: `34d71d540fd12ba2f04c24124e9c02910c25e069`;
- branch de trabalho: `security/sec-r2-002a-6e-r2-adapter`.

## Implementacao atomica

1. registrar a integracao da A.6D pelo PR #83;
2. criar o adapter `R2EvidencePrivateStorageAdapter`;
3. usar PUT condicional `etagDoesNotMatch: "*"` como primeira operacao;
4. enviar MIME, metadados canonicos e checksum SHA-256 ao R2;
5. consultar `head` somente depois de falha da precondicao;
6. validar chave, tamanho, MIME, checksum e identidade existentes;
7. converter objeto malformado em conflito sem sobrescrita;
8. adicionar o resultado explicito `conflict` a porta A.6D;
9. criar wiring opcional por `EVIDENCE_BUCKET` injetado;
10. preservar validador obrigatorio, health false e default fail-closed;
11. adicionar testes unitarios e de integracao do ponto de entrada;
12. atualizar blueprint consolidado e README.

## Gates locais

1. repositorio, origin, branch, baseline e working tree;
2. hashes exatos de todos os arquivos base;
3. confirmacao de ausencia de `r2_buckets` antes e depois;
4. teste focado A.6E:
   - `test/r2_evidence_storage.test.ts`;
   - `test/evidence_persistence.test.ts`;
   - `test/evidence_upload.test.ts`;
   - `test/index.test.ts`;
5. suite completa do Evidence Worker;
6. `npm run typecheck`;
7. `flutter test`;
8. `flutter analyze`;
9. neutralizacao segura apenas de EOL dos registrants gerados;
10. `git diff --check`;
11. verificacao do conjunto exato de arquivos;
12. confirmacao de `remoteStorageEnabled=false`;
13. interrupcao sem commit para homologacao humana.

## Resultado esperado

- PUT condicional atomico: PASS;
- `HEAD` antes de `PUT`: AUSENTE;
- checksum e metadados R2: PASS;
- idempotencia integral: PASS;
- sobrescrita silenciosa: PROIBIDA;
- binding ausente: `503` fail-closed;
- binding apenas simulado em testes;
- suite Evidence Worker e typecheck: PASS;
- Flutter Test e Flutter Analyze: PASS;
- registrants EOL, diff check e escopo: PASS;
- bucket, binding real, secret e deploy: nao executados;
- armazenamento remoto: FALSE;
- commit, push, PR e merge: nao executados.

## Rollback

Qualquer falha restaura somente os arquivos previstos e remove os novos
arquivos A.6E. A branch sera removida apenas se a baseline voltar a ficar
limpa. Alteracoes inesperadas nunca serao apagadas silenciosamente.

## Fechamento posterior

Depois da homologacao humana, um pacote separado podera atualizar a
documentacao final, criar manifesto e CPB, commitar, publicar a branch e abrir
o Pull Request. Merge e qualquer infraestrutura exigem autorizacoes proprias.

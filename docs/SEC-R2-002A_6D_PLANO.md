# SEC-R2-002A.6D - Plano de Implementacao

## Baseline obrigatoria

- repositorio: `adelmomelo-art/GEDUC_RAE_Mobile`;
- branch base: `main`;
- commit: `987ae5a534b9bff1b1299cd437822052a688713c`;
- branch de trabalho: `security/sec-r2-002a-6d-idempotency-port`.

## Implementacao atomica

1. corrigir a deriva documental da integracao A.6C;
2. criar o contrato `EvidencePrivateStoragePort`;
3. exigir criacao atomica por `createIfAbsent`;
4. criar `AtomicEvidenceUploadPersister`;
5. recalcular identidade e metadados antes da porta;
6. distinguir criacao, repeticao idempotente e conflito;
7. integrar o persister ao PUT depois do validador A.6C;
8. manter o default produtivo sem porta e em `503` fail-closed;
9. adicionar testes unitarios e de roteamento HTTP;
10. atualizar blueprint consolidado e README.

## Gates locais

1. repositorio, origin, branch, baseline e working tree;
2. hashes exatos dos arquivos base;
3. teste focado A.6D:
   - `test/evidence_persistence.test.ts`;
   - `test/evidence_upload.test.ts`;
   - `test/index.test.ts`;
4. suite completa do Evidence Worker;
5. `npm run typecheck`;
6. `flutter test`;
7. `flutter analyze`;
8. neutralizacao segura apenas de EOL dos registrants gerados;
9. `git diff --check`;
10. verificacao do conjunto exato de arquivos;
11. confirmacao de ausencia de binding R2;
12. confirmacao de `remoteStorageEnabled=false`;
13. interrupcao sem commit para homologacao humana.

## Resultado esperado

- teste focado A.6D: 53/53;
- suite Evidence Worker: 99/99;
- TypeScript typecheck: PASS;
- Flutter Test: PASS;
- Flutter Analyze: PASS;
- registrants EOL: CLEAN;
- diff check e escopo: PASS;
- criacao simulada: HTTP `201`;
- repeticao identica simulada: HTTP `200`;
- conflito simulado: HTTP `409` sem sobrescrita;
- porta produtiva ausente: HTTP `503`;
- R2 e armazenamento remoto: desabilitados;
- commit, push, PR, merge e deploy: nao executados.

## Rollback

Qualquer falha restaura somente os arquivos previstos e remove os novos
arquivos da A.6D. A branch sera removida apenas se a baseline voltar a ficar
limpa. Alteracoes inesperadas nunca serao apagadas silenciosamente.

## Resultado da execucao

Homologacao local concluida em 2026-09-13:

- arquivos completos e hashes: PASS;
- teste focado A.6D: 53/53;
- suite completa Evidence Worker: 99/99;
- TypeScript typecheck: PASS;
- Flutter Test: PASS;
- Flutter Analyze: PASS, 0 issues;
- registrants EOL e diff check: PASS;
- escopo final: CONTROLADO;
- criacao atomica sem `HEAD` + `PUT`: PASS;
- idempotencia integral: PASS;
- sobrescrita silenciosa: PROIBIDA;
- porta produtiva ausente: HTTP `503` fail-closed;
- R2 adapter/binding e armazenamento remoto: desabilitados;
- commit, push, PR e merge nao executados durante a aplicacao.

O fechamento autorizado pode documentar, criar manifesto e CPB, commitar,
publicar a branch e abrir o Pull Request. O merge depende de autorizacao
especifica apos os seis quality gates remotos.

## Integracao

- PR #83: integrado;
- merge SHA: `34d71d540fd12ba2f04c24124e9c02910c25e069`;
- branches local e remota: removidas;
- status final: HOMOLOGADO, INTEGRADO E ENCERRADO.

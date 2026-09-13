# SEC-R2-002A.6C - Plano de Implementacao

## Baseline

- repositorio: `adelmomelo-art/GEDUC_RAE_Mobile`;
- branch base: `main`;
- commit obrigatorio:
  `4ed6dadd1dc0ba9362874b62d1a13de49dc61f28`;
- branch de trabalho: `security/sec-r2-002a-6c-put-validation`.

## Implementacao atomica

1. endurecer a verificacao temporal da capability;
2. definir limite compartilhado de 10 MiB;
3. criar o validador HMAC do PUT;
4. validar headers e idempotencia derivados da capability;
5. ler o stream dentro do limite e conferir tamanho real;
6. validar assinatura JPEG e recalcular SHA-256;
7. conectar o validador ao roteamento HTTP;
8. manter o destino de storage desabilitado em `501`;
9. atualizar testes e documentacao consolidada.

## Gates locais

1. guard de repositorio, origin, branch, baseline e working tree;
2. hashes exatos dos arquivos completos;
3. teste focado A.6C:
   - `test/evidence_upload.test.ts`;
   - `test/evidence_capability.test.ts`;
   - `test/evidence_contract.test.ts`;
   - `test/index.test.ts`;
4. suite completa do Evidence Worker;
5. `npm run typecheck`;
6. `flutter test`;
7. `flutter analyze`;
8. neutralizacao segura apenas de EOL dos registrants gerados;
9. `git diff --check`;
10. verificacao do conjunto exato de arquivos;
11. confirmacao de `remoteStorageEnabled=false` e ausencia de binding R2;
12. interrupcao sem commit para homologacao humana.

## Resultado esperado

- teste focado: 53/53;
- suite Evidence Worker: 80/80;
- typecheck: PASS;
- Flutter Test: PASS;
- Flutter Analyze: PASS;
- registrants EOL: CLEAN;
- diff check: PASS;
- PUT valido: `501` apos validar bytes;
- R2/remote storage: desabilitado;
- commit, push e deploy: nao executados.

## Rollback

Qualquer falha restaura exclusivamente arquivos existentes da baseline, remove
os arquivos novos da A.6C e exclui a branch somente quando o working tree volta
a ficar limpo. Alteracoes inesperadas nunca sao apagadas silenciosamente.

## Resultado da execucao

Homologacao local concluida em 2026-09-13:

- arquivos completos e hashes: PASS;
- teste focado A.6C: 53/53;
- suite completa Evidence Worker: 80/80;
- TypeScript typecheck: PASS;
- Flutter Test: PASS;
- Flutter Analyze: PASS, 0 issues;
- registrants EOL e diff check: PASS;
- escopo final: CONTROLADO;
- PUT validado ate o contrato real dos bytes;
- persistencia: `501` fail-closed;
- `remoteStorageEnabled=false`;
- commit, push, PR e merge nao executados durante a aplicacao.

O fechamento autorizado pode documentar, criar manifesto, commitar, publicar a
branch e abrir o Pull Request. O merge depende de autorizacao especifica apos
os quality gates remotos.

## Integracao

- PR #82: merged;
- quality gates: 6/6 PASS;
- merge SHA: `987ae5a534b9bff1b1299cd437822052a688713c`;
- `main` local e remota: sincronizadas;
- branches local e remota: removidas;
- working tree: limpa;
- nenhum deploy, bucket, binding ou secret executado.

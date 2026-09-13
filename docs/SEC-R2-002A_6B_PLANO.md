# SEC-R2-002A.6B - Plano de Implementacao

## Baseline

- branch base: `main`;
- merge base: `38682e679144d0b0c05439b698cce8ca049d7111`;
- branch de trabalho: `security/sec-r2-002a-6b-grant-capability`;
- working tree obrigatoriamente limpa antes da intervencao.

## Entrega atomica

1. criar o contrato de emissao em `src/evidence_grant.ts`;
2. integrar o emissor apos autenticacao, contrato e ACL em `src/index.ts`;
3. manter defaults produtivos em fail-closed;
4. criar testes focados de emissao e capability;
5. atualizar os testes HTTP do Worker;
6. corrigir a deriva documental deixada apos o merge da A.6A;
7. executar todos os gates locais;
8. interromper sem commit para homologacao humana.

## Arquivos controlados

- `backend/evidence-worker/src/evidence_grant.ts`;
- `backend/evidence-worker/src/index.ts`;
- `backend/evidence-worker/test/evidence_grant.test.ts`;
- `backend/evidence-worker/test/index.test.ts`;
- `docs/SEC-R2-002A_6B_BLUEPRINT.md`;
- `docs/SEC-R2-002A_6B_PLANO.md`;
- `docs/SEC-R2-002A_BLUEPRINT.md`;
- `README_SEC-R2-002A.md`.

Qualquer arquivo divergente fora desse conjunto interrompe o pacote.

## Gates

- guard de repositorio, branch, baseline e origin;
- teste focado A.6B;
- suite completa Evidence Worker;
- TypeScript typecheck;
- Flutter Test;
- Flutter Analyze;
- neutralizacao somente de EOL em registrants gerados;
- `git diff --check`;
- manifesto exato de arquivos;
- confirmacao de `remoteStorageEnabled=false`;
- confirmacao de que o PUT permanece fail-closed.

## Rollback

Em caso de falha, o script restaura byte a byte os arquivos preexistentes,
remove somente os arquivos novos desta intervencao, volta para `main` e
remove somente a branch A.6B criada pelo proprio pacote.

Nenhum commit, push, PR, merge, deploy, bucket, binding ou secret faz parte
desta intervencao de implementacao.

## Resultado da execucao

Homologacao local concluida em 2026-09-13:

- arquivos completos e hashes: PASS;
- teste focado A.6B: 23/23;
- suite completa Evidence Worker: 57/57;
- TypeScript typecheck: PASS;
- Flutter Test: 971/971;
- Flutter Analyze: PASS, 0 issues;
- registrants e diff check: PASS;
- escopo final: CONTROLADO;
- PUT/R2: FAIL-CLOSED;
- `remoteStorageEnabled=false`.

O fechamento documental, commit, push e PR dependem de intervencao de
encerramento. O merge permanece sujeito a autorizacao especifica apos todos
os quality gates remotos.

# OBS-REL-001 - Plano

## Baseline

`11fd97de074bd16798fa6cf65e36222770793825`

## Branch

`release/obs-rel-001-pdf-unicode`

## Implementacao

1. reutilizar worktree isolado da R1;
2. validar hashes das fontes ja baixadas;
3. reconciliar asset Noto Sans no `pubspec.yaml`;
4. carregar Regular/Bold/Italic/BoldItalic por `rootBundle`;
5. criar `pw.ThemeData.withFont`;
6. aplicar tema global no `pw.Document`;
7. adicionar teste Unicode;
8. gerar amostra visual;
9. teste focado;
10. suite Flutter;
11. Flutter Analyze;
12. `git diff --check`;
13. escopo 12/12;
14. interromper antes de commit.

## Rollback

Enquanto nao houver commit, o worktree pode ser removido integralmente sem
afetar a `main`.

## Resultado da homologacao

- implementacao Unicode: PASS;
- assets Noto Sans: PASS;
- teste PDF focado: PASS;
- suite Flutter: PASS;
- Flutter Analyze: PASS;
- warnings Type1 Unicode: AUSENTES;
- homologacao visual R8: PASS;
- amostra final SHA-256:
  `807481D7D18A895BFF17BC941C9D5C77D304E258E2D9B17A5B41A1F51DAC12CE`.

A etapa esta liberada para commit, PR e Quality Gates.

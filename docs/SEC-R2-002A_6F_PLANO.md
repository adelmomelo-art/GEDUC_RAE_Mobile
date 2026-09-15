# SEC-R2-002A.6F - Plano de Preparacao da Infraestrutura R2

## Fase 1 - Preparacao versionada em worktree

1. validar baseline `ec217fa42244ef28a0b1fd275f7b10b85b0209db`;
2. manter checkout principal limpo e inalterado;
3. criar worktree isolado e branch `security/sec-r2-002a-6f-r2-infra`;
4. validar hashes dos arquivos-base;
5. adicionar `r2_buckets` ao Wrangler;
6. usar binding `EVIDENCE_BUCKET`;
7. apontar para bucket `fenix-evidence-private-prod`;
8. adicionar `remoteStorageBound` ao health;
9. manter `remoteStorageEnabled=false`;
10. comprovar que binding nao contorna o validador;
11. validar escopo por diff contra baseline;
12. exibir MISSING e EXTRA em qualquer divergencia;
13. executar `npm ci` no Evidence Worker dentro do worktree;
14. executar gates locais usando dependencias locais do worktree;
15. interromper antes de commit/push para homologacao.

## Fase 2 - Fechamento de codigo

Depois da homologacao:

1. documentacao final e manifesto;
2. CPB;
3. commit no worktree;
4. push;
5. PR;
6. seis Quality Gates;
7. merge controlado;
8. sincronizacao da main;
9. remocao do worktree e branches integradas.

## Fase 3 - Ativacao operacional R2

Somente sobre main integrada:

1. autenticar Wrangler na conta Cloudflare correta;
2. criar `fenix-evidence-private-prod`;
3. confirmar bucket privado;
4. confirmar `r2.dev` desabilitado;
5. confirmar ausencia de custom domain publico;
6. implantar `fenix-evidence-api` com binding `EVIDENCE_BUCKET`;
7. consultar `/health`;
8. exigir `remoteStorageBound=true`;
9. exigir `remoteStorageEnabled=false`;
10. confirmar PUT ainda fail-closed sem wiring produtivo;
11. registrar URL/version/deployment;
12. manter rollback pronto.

## Rollback operacional

Se o deploy remoto falhar:

- nao habilitar `remoteStorageEnabled`;
- restaurar a versao anterior do Worker;
- manter o bucket privado;
- nao apagar bucket automaticamente se houver qualquer objeto;
- excluir bucket somente quando comprovadamente vazio e criado pela etapa.

# ESC-001D.6 — DELTA DE FIRESTORE RULES

Baseline: `42a2fbef36bb27a8859e3c6b4d54b9ed528efb9c`

1. Mantém leitura da Escala para perfis reconhecidos ativos.
2. Mantém `Gerente` isolado do ACL legado global.
3. Mantém designação de responsável somente para Gerente/Administrador.
4. Mantém responsável como usuário ativo com perfil `agente` e vínculo
   canônico a membro ativo da Equipe Operacional.
5. Em update de `escala_perfis_operacionais`, passa a preservar:
   - `membroEquipeId`;
   - `usuarioId`;
   - `criadoPor`;
   - `criadoEm`.
6. Delete continua negado.
7. Storage/R2/App Check permanecem inalterados.

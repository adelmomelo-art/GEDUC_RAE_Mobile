# BUG-RAE-002 — Encerramento

**Data:** 11/09/2026  
**Branch:** `fix/bug-rae-002-acl-operacional-dinamica`

## Situação final

BUG-RAE-002 encerrado após correção e homologação do fluxo operacional de identificação, projeto institucional, coordenação e equipe dinâmica do RAE.

## Resultado funcional

- coordenador tratado por identidade canônica;
- equipe operacional vinculada dinamicamente ao RAE;
- catálogo institucional de projetos implantado;
- 53 projetos institucionais disponíveis no Firestore;
- `Projeto/Ação institucional` definido como fonte operacional única;
- campo visual legado `Nome da ação` removido;
- `nomeAcao` mantido apenas para compatibilidade de dados existentes;
- `tipoAcao` derivado automaticamente da categoria institucional do projeto;
- módulo administrativo `Tipos de Ações` mantido apenas como legado interno;
- acesso a `Tipos de Ações` desabilitado na tela Administração;
- coleção `tipos_acoes` preservada temporariamente para compatibilidade interna;
- nenhuma exclusão ou migração destrutiva executada.

## Homologação funcional

Homologação realizada em dispositivo Samsung com APK release assinado.

Aprovado:

1. remoção do campo visual `Nome da ação`;
2. seleção única por `Projeto/Ação institucional`;
3. persistência do projeto ao retornar à tela;
4. fluxo de avanço funcionando normalmente;
5. `Tipos de Ações` visível e desabilitado na Administração;
6. catálogo institucional operacional;
7. conclusão integral do RAE 0042/2026.

**RAE 0042/2026:** concluído com sucesso.

## Regressão

Resultado final:

- `flutter test`: PASS;
- Firestore Rules: PASS;
- `flutter analyze`: 0 issues;
- teste específico de projeto institucional: PASS;
- teste de coordenação canônica: PASS;
- teste de escopo operacional do RAE: PASS;
- teste de catálogo institucional: PASS.

Os avisos conhecidos de fontes Helvetica sem suporte Unicode no serviço PDF permanecem fora do escopo do BUG-RAE-002.

## Commits finais

- `c22a73e` — `fix(rae): unifica acao institucional e desativa tipo legado`
- `bbbf82d` — `test(rae): atualiza fluxo institucional da nova acao`

## Decisão de arquitetura

`Projeto/Ação institucional` passa a ser a identificação operacional oficial da ação.

`tipos_acoes` deixa de ser uma fonte de escolha do usuário e permanece temporariamente apenas como mecanismo de compatibilidade para parâmetros legados até futura retirada controlada.

## Status

**BUG-RAE-002: RESOLVIDO E HOMOLOGADO**

Próxima etapa: publicação da branch, Pull Request e validação pelos Quality Gates.
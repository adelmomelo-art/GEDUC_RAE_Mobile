# AUD-L2-R1 — Regression Protection

## Objetivo

Estabelecer a baseline automatizada pós-Auditoria do Lote 2 para Equipe e
Recursos Operacionais, persistência offline e sincronização, sem antecipar as
correções funcionais previstas para AUD-L2-R2 e AUD-L2-R3.

## Escopo coberto

- `AcaoModel`: round-trip da equipe nominal, órgãos, `anoRAE`, legado
  quantitativo, snapshot histórico e caracterização da paridade IDs/nomes.
- `MembroEquipeModel`: situação ativa/inativa, permissão para coordenar,
  vínculos agente/terceirizado, fallback legado e `MergePolicy`.
- `RecursosOperacionaisPage`: carregamento, legado, coordenador obrigatório e
  não removível, separação por vínculo, histórico inativo, materiais,
  persistência ao voltar, validação ao avançar e retry de erro.
- `OfflineService`: rascunho, exclusão, pendências, limpeza, round-trip dos
  campos do Lote 2 e duplicidade atual.
- `SyncService`: offline, fila vazia, sucesso, falha, sucesso parcial, falhas
  consecutivas, recuperação e retry.

Foi adicionada à página somente uma injeção opcional da função que lista
membros. Em produção, o comportamento permanece o mesmo e continua usando
`EquipeOperacionalService` por padrão. Nenhuma dependência foi adicionada.

## Baselines de defeitos conhecidos

Os testes verdes documentam o comportamento atual, sem promovê-lo a contrato
desejado:

- salvar duas vezes a mesma ação offline mantém duas entradas;
- o retry envia novamente a mesma ação ao serviço remoto;
- coordenador inativo encontrado é aceito pela tela;
- coordenador com `podeCoordenar=false` é aceito pela tela;
- o modelo aceita listas de IDs e nomes com comprimentos diferentes.

## Deliberadamente não corrigido

- deduplicação da fila e idempotência remota: AUD-L2-R2;
- validação de `ativo && podeCoordenar`, identidade por ID, fallback por nome,
  paridade estrutural e tratamento de `anoRAE`: AUD-L2-R3;
- Firebase Rules, ACL Stage 4A, CI, coverage, materiais/domínios e UI.

## Arquivos testados

- `lib/modules/recursos/recursos_operacionais_page.dart`
- `lib/data/models/acao_model.dart`
- `lib/data/models/membro_equipe_model.dart`
- `lib/core/services/equipe_operacional_service.dart`
- `lib/core/services/offline_service.dart`
- `lib/core/services/sync_service.dart`
- `lib/core/services/firebase_acao_service.dart`
- `lib/repositories/acao_repository.dart`
- `lib/modules/acoes/controllers/acao_controller.dart`

## Validação

```text
flutter test test/data/models/acao_equipe_operacional_test.dart test/data/models/membro_equipe_model_test.dart test/core/services/offline_service_test.dart test/core/services/sync_service_test.dart test/modules/recursos/recursos_operacionais_page_test.dart
flutter test
flutter analyze
```

Resultados finais:

- suíte específica: 35 testes aprovados;
- testes adicionados no AUD-L2-R1: 26;
- suíte completa: 690 testes aprovados;
- `flutter analyze`: `No issues found`.

import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/services/offline_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/acao_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late OfflineService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = OfflineService();
  });

  test('salva e recupera rascunho com equipe nominal e múltiplos órgãos',
      () async {
    final acao = criarAcaoTeste(
      agenteEquipeIds: const ['a1', 'a2'],
      agenteEquipeNomes: const ['Ana', 'Bruno'],
      terceirizadoEquipeIds: const ['t1'],
      terceirizadoEquipeNomes: const ['Carlos'],
      orgaoParticipanteId: 'orgao-1',
      orgaoParticipanteIds: const ['orgao-1', 'orgao-2'],
    );

    await service.salvarRascunhoAcao(acao);
    final recuperada = await service.recuperarRascunhoAcao();

    expect(recuperada, isNotNull);
    expect(recuperada!.id, acao.id);
    expect(recuperada.agenteEquipeIds, ['a1', 'a2']);
    expect(recuperada.agenteEquipeNomes, ['Ana', 'Bruno']);
    expect(recuperada.terceirizadoEquipeIds, ['t1']);
    expect(recuperada.terceirizadoEquipeNomes, ['Carlos']);
    expect(recuperada.orgaoParticipanteIds, ['orgao-1', 'orgao-2']);
  });

  test('recuperar rascunho vazio retorna null', () async {
    expect(await service.recuperarRascunhoAcao(), isNull);
  });

  test('exclui rascunho salvo', () async {
    await service.salvarRascunhoAcao(criarAcaoTeste());
    await service.excluirRascunhoAcao();

    expect(await service.recuperarRascunhoAcao(), isNull);
  });

  test('salva e lista ações pendentes preservando o round-trip', () async {
    await service.salvarAcaoPendente(criarAcaoTeste(id: 'pendente-1'));
    await service.salvarAcaoPendente(criarAcaoTeste(id: 'pendente-2'));

    final pendentes = await service.listarAcoesPendentes();

    expect(pendentes.map((acao) => acao.id), ['pendente-1', 'pendente-2']);
  });

  test('limpa todas as ações pendentes', () async {
    await service.salvarAcaoPendente(criarAcaoTeste());
    await service.limparAcoesPendentes();

    expect(await service.listarAcoesPendentes(), isEmpty);
  });

  test('mesmo ID substitui a pendência anterior sem alterar sua posição',
      () async {
    final acao = criarAcaoTeste(id: 'repetida');

    await service.salvarAcaoPendente(acao.copyWith(status: 'primeira-versao'));
    await service.salvarAcaoPendente(criarAcaoTeste(id: 'outra'));
    await service
        .salvarAcaoPendente(acao.copyWith(status: 'versao-atualizada'));

    final pendentes = await service.listarAcoesPendentes();
    expect(pendentes, hasLength(2));
    expect(pendentes.map((item) => item.id), ['repetida', 'outra']);
    expect(pendentes.first.status, 'versao-atualizada');
  });
}

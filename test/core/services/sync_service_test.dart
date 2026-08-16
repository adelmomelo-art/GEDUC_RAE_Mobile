import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/services/firebase_acao_service.dart';
import 'package:geduc_rae_mobile/core/services/offline_service.dart';
import 'package:geduc_rae_mobile/core/services/sync_service.dart';
import 'package:geduc_rae_mobile/data/models/acao_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/acao_fixture.dart';

class _FakeConnectivity extends Fake implements Connectivity {
  _FakeConnectivity(this.resultados);

  List<ConnectivityResult> resultados;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => resultados;
}

class _FakeFirebaseAcaoService extends Fake implements FirebaseAcaoService {
  _FakeFirebaseAcaoService([List<bool>? resultados])
      : resultados = resultados ?? <bool>[];

  final List<bool> resultados;
  final List<AcaoModel> recebidas = [];

  @override
  Future<String> salvarAcao(AcaoModel acao) async {
    recebidas.add(acao);
    final sucesso = resultados.isEmpty ? true : resultados.removeAt(0);
    if (!sucesso) throw Exception('falha remota controlada');
    return 'remota-${recebidas.length}';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late OfflineService offline;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    offline = OfflineService();
  });

  SyncService criarService({
    required _FakeConnectivity connectivity,
    required _FakeFirebaseAcaoService firebase,
  }) {
    return SyncService(
      offlineService: offline,
      firebaseService: firebase,
      connectivity: connectivity,
    );
  }

  test('sem conexão não sincroniza e registra falha', () async {
    await offline.salvarAcaoPendente(criarAcaoTeste());
    final firebase = _FakeFirebaseAcaoService();
    final service = criarService(
      connectivity: _FakeConnectivity([ConnectivityResult.none]),
      firebase: firebase,
    );

    await service.sincronizarAcoesPendentes();

    expect(firebase.recebidas, isEmpty);
    expect(service.erro, 'Sem conexão com a internet.');
    expect(service.falhasConsecutivasSincronizacao, 1);
    expect(await offline.listarAcoesPendentes(), hasLength(1));
  });

  test('sem pendências encerra com sucesso', () async {
    final service = criarService(
      connectivity: _FakeConnectivity([ConnectivityResult.wifi]),
      firebase: _FakeFirebaseAcaoService(),
    );

    await service.sincronizarAcoesPendentes();

    expect(service.totalPendentes, 0);
    expect(service.totalSincronizadas, 0);
    expect(service.erro, isNull);
    expect(service.falhasConsecutivasSincronizacao, 0);
  });

  test('sucesso sincroniza e remove a pendência', () async {
    await offline.salvarAcaoPendente(criarAcaoTeste());
    final firebase = _FakeFirebaseAcaoService();
    final service = criarService(
      connectivity: _FakeConnectivity([ConnectivityResult.wifi]),
      firebase: firebase,
    );

    await service.sincronizarAcoesPendentes();

    expect(service.totalSincronizadas, 1);
    expect(service.totalPendentes, 0);
    expect(firebase.recebidas.single.sincronizado, isTrue);
    expect(firebase.recebidas.single.status, 'enviado');
    expect(await offline.listarAcoesPendentes(), isEmpty);
  });

  test('falha remota mantém ação na fila', () async {
    await offline.salvarAcaoPendente(criarAcaoTeste());
    final service = criarService(
      connectivity: _FakeConnectivity([ConnectivityResult.mobile]),
      firebase: _FakeFirebaseAcaoService([false]),
    );

    await service.sincronizarAcoesPendentes();

    expect(service.totalSincronizadas, 0);
    expect(service.totalPendentes, 1);
    expect(service.erro, contains('1 ação(ões)'));
    expect(await offline.listarAcoesPendentes(), hasLength(1));
  });

  test('sucesso parcial mantém somente as falhas', () async {
    await offline.salvarAcaoPendente(criarAcaoTeste(id: 'ok'));
    await offline.salvarAcaoPendente(criarAcaoTeste(id: 'falha'));
    final service = criarService(
      connectivity: _FakeConnectivity([ConnectivityResult.wifi]),
      firebase: _FakeFirebaseAcaoService([true, false]),
    );

    await service.sincronizarAcoesPendentes();

    expect(service.totalSincronizadas, 1);
    expect(service.totalPendentes, 1);
    expect((await offline.listarAcoesPendentes()).single.id, 'falha');
  });

  test('falhas consecutivas acumulam e sucesso posterior zera contador',
      () async {
    await offline.salvarAcaoPendente(criarAcaoTeste(id: 'retry'));
    final firebase = _FakeFirebaseAcaoService([false, false, true]);
    final service = criarService(
      connectivity: _FakeConnectivity([ConnectivityResult.wifi]),
      firebase: firebase,
    );

    await service.sincronizarAcoesPendentes();
    await service.sincronizarAcoesPendentes();
    expect(service.falhasConsecutivasSincronizacao, 2);

    await service.sincronizarAcoesPendentes();

    expect(firebase.recebidas, hasLength(3));
    expect(firebase.recebidas.map((acao) => acao.id), everyElement('retry'));
    expect(service.falhasConsecutivasSincronizacao, 0);
    expect(service.erro, isNull);
    expect(await offline.listarAcoesPendentes(), isEmpty);
  });
}

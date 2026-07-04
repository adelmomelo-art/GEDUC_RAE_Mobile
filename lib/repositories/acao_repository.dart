import '../core/services/firebase_acao_service.dart';
import '../core/services/offline_service.dart';
import '../core/services/sync_service.dart';
import '../data/models/acao_model.dart';

class AcaoRepository {
  final OfflineService offlineService;
  final FirebaseAcaoService firebaseService;
  final SyncService syncService;

  AcaoRepository({
    required this.offlineService,
    required this.firebaseService,
    required this.syncService,
  });

  Future<void> salvarRascunho(AcaoModel acao) async {
    await offlineService.salvarRascunhoAcao(acao);
  }

  Future<AcaoModel?> recuperarRascunho() async {
    return offlineService.recuperarRascunhoAcao();
  }

  Future<void> excluirRascunho() async {
    await offlineService.excluirRascunhoAcao();
  }

  Future<void> salvarPendente(AcaoModel acao) async {
    await offlineService.salvarAcaoPendente(
      acao.copyWith(
        status: 'pendente',
        sincronizado: false,
      ),
    );
  }

  Future<List<AcaoModel>> listarPendentes() async {
    return offlineService.listarAcoesPendentes();
  }

  Future<void> limparPendentes() async {
    await offlineService.limparAcoesPendentes();
  }

  Future<bool> temInternet() async {
    return syncService.temInternet();
  }

  Future<String> gerarNumeroRaeAutomatico() async {
    return firebaseService.gerarNumeroRaeAutomatico();
  }

  Future<String> enviarAcao(AcaoModel acao) async {
    final conectado = await temInternet();

    if (conectado) {
      return firebaseService.salvarAcao(
        acao.copyWith(
          status: 'enviado',
          sincronizado: true,
        ),
      );
    }

    await salvarPendente(acao);

    return acao.id;
  }

  Future<void> sincronizarPendentes() async {
    await syncService.sincronizarAcoesPendentes();
  }

  Stream<List<AcaoModel>> listarAcoesOnline() {
    return firebaseService.listarAcoes();
  }

  Future<List<AcaoModel>> listarAcoesOnlineFuture() async {
    return firebaseService.listarAcoesFuture();
  }

  Future<AcaoModel?> buscarPorId(String id) async {
    return firebaseService.buscarAcaoPorId(id);
  }

  Future<void> atualizarAcao(String id, AcaoModel acao) async {
    await firebaseService.atualizarAcao(id, acao);
  }

  Future<void> excluirAcao(String id) async {
    await firebaseService.excluirAcao(id);
  }
}
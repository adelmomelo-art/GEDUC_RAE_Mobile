import '../core/services/tipo_acao_service.dart';
import '../data/models/tipo_acao_model.dart';

class TipoAcaoRepository {
  final TipoAcaoService tipoAcaoService;

  TipoAcaoRepository({
    required this.tipoAcaoService,
  });

  Future<List<TipoAcaoModel>> listarTiposAcoes() async {
    return tipoAcaoService.listarTiposAcoes();
  }

  Future<void> salvarTipoAcao(TipoAcaoModel tipoAcao) async {
    await tipoAcaoService.salvarTipoAcao(tipoAcao);
  }
}
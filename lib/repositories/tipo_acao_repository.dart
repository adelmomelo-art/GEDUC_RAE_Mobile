import '../core/services/tipo_acao_service.dart';
import '../data/models/tipo_acao_model.dart';

class TipoAcaoValidationException implements Exception {
  const TipoAcaoValidationException(this.erros);

  final List<String> erros;

  @override
  String toString() => erros.join(' ');
}

class TipoAcaoDuplicadoException implements Exception {
  const TipoAcaoDuplicadoException(this.tipoExistente);

  final TipoAcaoModel tipoExistente;

  @override
  String toString() =>
      'Já existe um tipo de ação com o mesmo nome e classificação.';
}

class TipoAcaoRepository {
  TipoAcaoRepository({
    TipoAcaoDataSource? dataSource,
    TipoAcaoService? tipoAcaoService,
  }) : assert(
         dataSource == null || tipoAcaoService == null,
         'Informe dataSource ou tipoAcaoService, não ambos.',
       ),
       _dataSource = dataSource ?? tipoAcaoService ?? TipoAcaoService();

  final TipoAcaoDataSource _dataSource;

  Future<List<TipoAcaoModel>> listarTiposAcoes({bool somenteAtivos = false}) {
    return _dataSource.listarTiposAcoes(somenteAtivos: somenteAtivos);
  }

  /// Compatibilidade com o fluxo anterior.
  Future<TipoAcaoModel> salvarTipoAcao(TipoAcaoModel tipoAcao) {
    return criarTipoAcao(tipoAcao);
  }

  Future<TipoAcaoModel> criarTipoAcao(TipoAcaoModel tipoAcao) async {
    final normalizado = tipoAcao.normalizado();
    _validar(normalizado);
    await _garantirNaoDuplicado(normalizado);
    return _dataSource.salvarTipoAcao(normalizado);
  }

  Future<void> atualizarTipoAcao(TipoAcaoModel tipoAcao) async {
    final normalizado = tipoAcao.normalizado();
    _validar(normalizado);

    if (normalizado.id.isEmpty) {
      throw const TipoAcaoValidationException(<String>[
        'O identificador é obrigatório para atualizar.',
      ]);
    }

    await _garantirNaoDuplicado(normalizado, ignorarId: normalizado.id);
    await _dataSource.atualizarTipoAcao(normalizado);
  }

  Future<void> alterarStatus(String id, bool ativo) {
    return _dataSource.alterarStatus(id, ativo);
  }

  Future<TipoAcaoModel?> buscarDuplicado(
    TipoAcaoModel candidato, {
    String? ignorarId,
  }) async {
    final chave = candidato.normalizado().chaveNormalizada;
    final tipos = await listarTiposAcoes();

    for (final tipo in tipos) {
      if (ignorarId != null && tipo.id == ignorarId) {
        continue;
      }
      if (tipo.chaveNormalizada == chave) {
        return tipo;
      }
    }
    return null;
  }

  void _validar(TipoAcaoModel tipoAcao) {
    final erros = tipoAcao.validar();
    if (erros.isNotEmpty) {
      throw TipoAcaoValidationException(erros);
    }
  }

  Future<void> _garantirNaoDuplicado(
    TipoAcaoModel tipoAcao, {
    String? ignorarId,
  }) async {
    final duplicado = await buscarDuplicado(tipoAcao, ignorarId: ignorarId);
    if (duplicado != null) {
      throw TipoAcaoDuplicadoException(duplicado);
    }
  }
}

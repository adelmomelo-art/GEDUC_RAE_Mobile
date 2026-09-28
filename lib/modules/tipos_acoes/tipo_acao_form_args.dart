import '../../data/models/tipo_acao_model.dart';

class TipoAcaoFormArgs {
  const TipoAcaoFormArgs({this.tipoAcao});

  final TipoAcaoModel? tipoAcao;

  bool get editando => tipoAcao != null;
}

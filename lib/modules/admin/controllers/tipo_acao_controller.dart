import 'package:flutter/material.dart';

import '../../../data/models/tipo_acao_model.dart';
import '../../../repositories/tipo_acao_repository.dart';

class TipoAcaoController extends ChangeNotifier {
  final TipoAcaoRepository tipoAcaoRepository;

  TipoAcaoController({
    required this.tipoAcaoRepository,
  });

  List<TipoAcaoModel> tipos = [];
  bool carregando = false;

  Future<void> carregarTipos() async {
    carregando = true;
    notifyListeners();

    tipos = await tipoAcaoRepository.listarTiposAcoes();

    carregando = false;
    notifyListeners();
  }
}
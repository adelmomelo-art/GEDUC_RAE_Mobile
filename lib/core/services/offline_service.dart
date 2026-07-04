import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/acao_model.dart';

class OfflineService {
  static const _keyAcoesPendentes = 'acoes_pendentes';
  static const _keyRascunhoAcao = 'acao_rascunho';

  Future<void> salvarAcaoPendente(AcaoModel acao) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_keyAcoesPendentes) ?? [];

    lista.add(jsonEncode(acao.toMap()));

    await prefs.setStringList(_keyAcoesPendentes, lista);
  }

  Future<List<AcaoModel>> listarAcoesPendentes() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_keyAcoesPendentes) ?? [];

    return lista
        .map(
          (item) => AcaoModel.fromMap(
            jsonDecode(item) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> limparAcoesPendentes() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyAcoesPendentes);
  }

  Future<void> salvarRascunhoAcao(AcaoModel acao) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _keyRascunhoAcao,
      jsonEncode(acao.toMap()),
    );
  }

  Future<AcaoModel?> recuperarRascunhoAcao() async {
    final prefs = await SharedPreferences.getInstance();
    final rascunho = prefs.getString(_keyRascunhoAcao);

    if (rascunho == null || rascunho.isEmpty) {
      return null;
    }

    return AcaoModel.fromMap(
      jsonDecode(rascunho) as Map<String, dynamic>,
    );
  }

  Future<void> excluirRascunhoAcao() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyRascunhoAcao);
  }
}
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/acao_model.dart';
import 'firebase_acao_service.dart';
import 'offline_service.dart';

class SyncService extends ChangeNotifier {
  static const _keyAcoesPendentes = 'acoes_pendentes';

  final OfflineService offlineService;
  final FirebaseAcaoService firebaseService;

  SyncService({
    required this.offlineService,
    required this.firebaseService,
  });

  bool sincronizando = false;
  int totalPendentes = 0;
  int totalSincronizadas = 0;
  String? erro;

  Future<bool> temInternet() async {
    try {
      final resultado = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));

      return resultado.isNotEmpty && resultado.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }

  Future<void> sincronizarAcoesPendentes() async {
    erro = null;

    final conectado = await temInternet();

    if (!conectado) {
      erro = 'Sem conexão com a internet.';
      notifyListeners();
      return;
    }

    final pendentes = await offlineService.listarAcoesPendentes();

    if (pendentes.isEmpty) {
      totalPendentes = 0;
      totalSincronizadas = 0;
      notifyListeners();
      return;
    }

    sincronizando = true;
    totalPendentes = pendentes.length;
    totalSincronizadas = 0;
    notifyListeners();

    final naoSincronizadas = <AcaoModel>[];

    for (final acao in pendentes) {
      try {
        await firebaseService.salvarAcao(
          acao.copyWith(
            sincronizado: true,
            status: 'enviado',
          ),
        );

        totalSincronizadas++;
        notifyListeners();
      } catch (_) {
        naoSincronizadas.add(acao);
      }
    }

    await _salvarPendenciasRestantes(naoSincronizadas);

    sincronizando = false;

    if (naoSincronizadas.isNotEmpty) {
      erro =
          '${naoSincronizadas.length} ação(ões) não puderam ser sincronizadas.';
    }

    notifyListeners();
  }

  Future<void> _salvarPendenciasRestantes(List<AcaoModel> acoes) async {
    final prefs = await SharedPreferences.getInstance();

    if (acoes.isEmpty) {
      await prefs.remove(_keyAcoesPendentes);
      return;
    }

    final lista = acoes.map((acao) => jsonEncode(acao.toMap())).toList();

    await prefs.setStringList(_keyAcoesPendentes, lista);
  }
}
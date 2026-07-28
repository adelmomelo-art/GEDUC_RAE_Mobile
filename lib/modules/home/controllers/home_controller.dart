import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../acoes/controllers/acao_controller.dart';
import '../models/home_state.dart';
import '../services/home_loader_service.dart';

class HomeController extends ChangeNotifier {
  HomeController({
    HomeLoaderService? loaderService,
  }) : _loaderService = loaderService ?? HomeLoaderService();

  final HomeLoaderService _loaderService;

  HomeState _state = const HomeState();
  HomeState get state => _state;

  bool _disposed = false;

  Future<void> carregarPortal({
    required AcaoController acaoController,
  }) async {
    _emitir(
      _state.copyWith(
        status: HomeStatus.carregando,
        removerMensagem: true,
      ),
    );

    try {
      await acaoController
          .carregarRascunhoSeExistir()
          .timeout(const Duration(seconds: 4));

      final resultado = await _loaderService.carregar();

      _emitir(
        HomeState(
          status: resultado.online ? HomeStatus.online : HomeStatus.offline,
          usuario: resultado.usuario,
          totalAcoes: resultado.totalAcoes,
          totalPessoas: resultado.totalPessoas,
          totalVeiculos: resultado.totalVeiculos,
          totalCredenciais: resultado.totalCredenciais,
          ultimosRaes: resultado.ultimosRaes,
          mensagem: resultado.mensagem,
        ),
      );
    } on TimeoutException {
      _emitir(
        _state.copyWith(
          status: HomeStatus.offline,
          mensagem:
              'O carregamento local demorou além do esperado. O Centro de Operação foi liberado em modo offline.',
        ),
      );
    } catch (_) {
      _emitir(
        _state.copyWith(
          status: HomeStatus.erro,
          mensagem:
              'Não foi possível atualizar os indicadores, mas os recursos locais continuam disponíveis.',
        ),
      );
    } finally {
      if (_state.status == HomeStatus.carregando) {
        _emitir(
          _state.copyWith(
            status: HomeStatus.erro,
            mensagem:
                'O carregamento foi encerrado com segurança. Tente atualizar novamente quando houver conexão.',
          ),
        );
      }
    }
  }

  Future<void> atualizar({
    required AcaoController acaoController,
  }) {
    return carregarPortal(acaoController: acaoController);
  }

  void _emitir(HomeState novoEstado) {
    if (_disposed) return;

    _state = novoEstado;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

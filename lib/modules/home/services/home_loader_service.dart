import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/services/firebase_acao_service.dart';
import '../../../core/services/usuario_service.dart';
import '../../../data/models/acao_model.dart';
import '../../../data/models/usuario_model.dart';

class HomeLoaderResult {
  const HomeLoaderResult({
    required this.online,
    required this.usuario,
    required this.totalAcoes,
    required this.totalPessoas,
    required this.totalVeiculos,
    required this.totalCredenciais,
    required this.ultimosRaes,
    this.mensagem,
  });

  final bool online;
  final UsuarioModel? usuario;
  final int totalAcoes;
  final int totalPessoas;
  final int totalVeiculos;
  final int totalCredenciais;
  final List<AcaoModel> ultimosRaes;
  final String? mensagem;

  factory HomeLoaderResult.offline({
    UsuarioModel? usuario,
    String? mensagem,
  }) {
    return HomeLoaderResult(
      online: false,
      usuario: usuario,
      totalAcoes: 0,
      totalPessoas: 0,
      totalVeiculos: 0,
      totalCredenciais: 0,
      ultimosRaes: const [],
      mensagem: mensagem ??
          'Sem conexão com o servidor. O Centro de Operação permanece disponível em modo offline.',
    );
  }
}

class HomeLoaderService {
  HomeLoaderService({
    FirebaseAcaoService? acaoService,
    UsuarioService? usuarioService,
    FirebaseAuth? firebaseAuth,
    this.timeout = const Duration(seconds: 6),
  })  : _acaoService = acaoService ?? FirebaseAcaoService(),
        _usuarioService = usuarioService ?? UsuarioService(),
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAcaoService _acaoService;
  final UsuarioService _usuarioService;
  final FirebaseAuth _firebaseAuth;
  final Duration timeout;

  Future<HomeLoaderResult> carregar() async {
    UsuarioModel? usuario;

    try {
      final uid = _firebaseAuth.currentUser?.uid;

      final usuarioFuture = uid == null
          ? Future<UsuarioModel?>.value(null)
          : _usuarioService.buscarUsuario(uid).timeout(timeout);

      final resultados = await Future.wait<dynamic>([
        usuarioFuture,
        _acaoService.totalAcoes().timeout(timeout),
        _acaoService.totalPessoasAlcancadas().timeout(timeout),
        _acaoService.totalVeiculosAbordados().timeout(timeout),
        _acaoService.totalCredenciaisEmitidas().timeout(timeout),
        _acaoService.listarAcoesFuture().timeout(timeout),
      ]);

      usuario = resultados[0] as UsuarioModel?;
      final lista = List<AcaoModel>.from(resultados[5] as List<AcaoModel>);

      lista.sort((a, b) => b.dataAcao.compareTo(a.dataAcao));

      return HomeLoaderResult(
        online: true,
        usuario: usuario,
        totalAcoes: resultados[1] as int,
        totalPessoas: resultados[2] as int,
        totalVeiculos: resultados[3] as int,
        totalCredenciais: resultados[4] as int,
        ultimosRaes: lista.take(3).toList(growable: false),
      );
    } on TimeoutException {
      return HomeLoaderResult.offline(
        usuario: usuario,
        mensagem:
            'O servidor não respondeu no tempo esperado. O Centro de Operação foi aberto em modo offline.',
      );
    } catch (_) {
      return HomeLoaderResult.offline(usuario: usuario);
    }
  }
}

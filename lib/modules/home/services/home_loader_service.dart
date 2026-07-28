import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/services/firebase_acao_service.dart';
import '../../../core/services/usuario_service.dart';
import '../../../data/models/acao_model.dart';
import '../../../data/models/usuario_model.dart';
import '../models/home_cache_data.dart';
import 'home_persistent_cache.dart';

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
    this.dadosEmCache = false,
    this.cacheDisponivel = false,
    this.atualizadoEm,
  });

  final bool online;
  final UsuarioModel? usuario;
  final int totalAcoes;
  final int totalPessoas;
  final int totalVeiculos;
  final int totalCredenciais;
  final List<AcaoModel> ultimosRaes;
  final String? mensagem;
  final bool dadosEmCache;
  final bool cacheDisponivel;
  final DateTime? atualizadoEm;

  factory HomeLoaderResult.offlineSemCache({
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
          'Sem conexão com o servidor e ainda não existem dados anteriores neste dispositivo.',
    );
  }

  factory HomeLoaderResult.offlineComCache({
    required HomeCacheData cache,
    UsuarioModel? usuario,
    String? mensagem,
  }) {
    return HomeLoaderResult(
      online: false,
      usuario: usuario,
      totalAcoes: cache.totalAcoes,
      totalPessoas: cache.totalPessoas,
      totalVeiculos: cache.totalVeiculos,
      totalCredenciais: cache.totalCredenciais,
      ultimosRaes: cache.ultimosRaes,
      mensagem: mensagem ??
          'Sem conexão com o servidor. Exibindo os últimos dados disponíveis neste dispositivo.',
      dadosEmCache: true,
      cacheDisponivel: true,
      atualizadoEm: cache.atualizadoEm,
    );
  }
}

class HomeLoaderService {
  HomeLoaderService({
    FirebaseAcaoService? acaoService,
    UsuarioService? usuarioService,
    FirebaseAuth? firebaseAuth,
    HomePersistentCache? persistentCache,
    this.timeout = const Duration(seconds: 6),
  })  : _acaoService = acaoService ?? FirebaseAcaoService(),
        _usuarioService = usuarioService ?? UsuarioService(),
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _persistentCache = persistentCache ?? HomePersistentCache();

  final FirebaseAcaoService _acaoService;
  final UsuarioService _usuarioService;
  final FirebaseAuth _firebaseAuth;
  final HomePersistentCache _persistentCache;
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

      final lista = List<AcaoModel>.from(
        resultados[5] as List<AcaoModel>,
      )..sort((a, b) => b.dataAcao.compareTo(a.dataAcao));

      final atualizadoEm = DateTime.now();
      final ultimosRaes = lista.take(3).toList(growable: false);

      final cacheData = HomeCacheData(
        totalAcoes: resultados[1] as int,
        totalPessoas: resultados[2] as int,
        totalVeiculos: resultados[3] as int,
        totalCredenciais: resultados[4] as int,
        ultimosRaes: ultimosRaes,
        atualizadoEm: atualizadoEm,
      );

      await _persistentCache.salvar(cacheData);

      return HomeLoaderResult(
        online: true,
        usuario: usuario,
        totalAcoes: cacheData.totalAcoes,
        totalPessoas: cacheData.totalPessoas,
        totalVeiculos: cacheData.totalVeiculos,
        totalCredenciais: cacheData.totalCredenciais,
        ultimosRaes: cacheData.ultimosRaes,
        cacheDisponivel: true,
        atualizadoEm: atualizadoEm,
      );
    } on TimeoutException {
      return _carregarFallback(
        usuario: usuario,
        mensagemSemCache:
            'O servidor não respondeu no tempo esperado e ainda não existem dados anteriores neste dispositivo.',
        mensagemComCache:
            'O servidor não respondeu no tempo esperado. Exibindo os últimos dados disponíveis neste dispositivo.',
      );
    } catch (_) {
      return _carregarFallback(usuario: usuario);
    }
  }

  Future<HomeLoaderResult> _carregarFallback({
    UsuarioModel? usuario,
    String? mensagemSemCache,
    String? mensagemComCache,
  }) async {
    final cache = await _persistentCache.recuperar();

    if (cache == null) {
      return HomeLoaderResult.offlineSemCache(
        usuario: usuario,
        mensagem: mensagemSemCache,
      );
    }

    return HomeLoaderResult.offlineComCache(
      cache: cache,
      usuario: usuario,
      mensagem: mensagemComCache,
    );
  }
}

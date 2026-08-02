import 'dart:async';

import '../../../core/services/firebase_acao_service.dart';
import '../../../data/models/acao_model.dart';
import '../models/home_cache_data.dart';
import 'home_persistent_cache.dart';

class HomeLoaderResult {
  const HomeLoaderResult({
    required this.online,
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
    String? mensagem,
  }) {
    return HomeLoaderResult(
      online: false,
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
    String? mensagem,
  }) {
    return HomeLoaderResult(
      online: false,
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
    HomePersistentCache? persistentCache,
    this.timeout = const Duration(seconds: 6),
  })  : _acaoService = acaoService ?? FirebaseAcaoService(),
        _persistentCache = persistentCache ?? HomePersistentCache();

  final FirebaseAcaoService _acaoService;
  final HomePersistentCache _persistentCache;
  final Duration timeout;

  Future<HomeLoaderResult> carregar() async {
    try {
      return await carregarRemoto();
    } on TimeoutException {
      return _carregarFallback(
        mensagemSemCache:
            'O servidor não respondeu no tempo esperado e ainda não existem dados anteriores neste dispositivo.',
        mensagemComCache:
            'O servidor não respondeu no tempo esperado. Exibindo os últimos dados disponíveis neste dispositivo.',
      );
    } catch (_) {
      return _carregarFallback();
    }
  }

  Future<HomeLoaderResult> carregarRemoto() async {
    final resultados = await Future.wait<dynamic>([
      _acaoService.totalAcoes().timeout(timeout),
      _acaoService.totalPessoasAlcancadas().timeout(timeout),
      _acaoService.totalVeiculosAbordados().timeout(timeout),
      _acaoService.totalCredenciaisEmitidas().timeout(timeout),
      _acaoService.listarAcoesFuture().timeout(timeout),
    ]);

    final lista = List<AcaoModel>.from(
      resultados[4] as List<AcaoModel>,
    )..sort((a, b) => b.dataAcao.compareTo(a.dataAcao));

    final atualizadoEm = DateTime.now();
    final ultimosRaes = lista.take(3).toList(growable: false);

    final cacheData = HomeCacheData(
      totalAcoes: resultados[0] as int,
      totalPessoas: resultados[1] as int,
      totalVeiculos: resultados[2] as int,
      totalCredenciais: resultados[3] as int,
      ultimosRaes: ultimosRaes,
      atualizadoEm: atualizadoEm,
    );

    await _persistentCache.salvar(cacheData);

    return HomeLoaderResult(
      online: true,
      totalAcoes: cacheData.totalAcoes,
      totalPessoas: cacheData.totalPessoas,
      totalVeiculos: cacheData.totalVeiculos,
      totalCredenciais: cacheData.totalCredenciais,
      ultimosRaes: cacheData.ultimosRaes,
      cacheDisponivel: true,
      atualizadoEm: atualizadoEm,
    );
  }

  Future<HomeLoaderResult> _carregarFallback({
    String? mensagemSemCache,
    String? mensagemComCache,
  }) async {
    final cache = await _persistentCache.recuperar();
    if (cache == null) {
      return HomeLoaderResult.offlineSemCache(
        mensagem: mensagemSemCache,
      );
    }

    return HomeLoaderResult.offlineComCache(
      cache: cache,
      mensagem: mensagemComCache,
    );
  }

}

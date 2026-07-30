import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/domain_model.dart';
import '../../repositories/domain_repository.dart';
import '../services/domain_service.dart';
import 'domain_cache.dart';
import 'domain_extensions.dart';
import 'domain_persistent_cache.dart';

class DomainProvider extends ChangeNotifier {
  final DomainRepository repository;
  final DomainCache cache;
  final DomainPersistentCache persistentCache;

  final Map<String, List<DomainModel>> _dominiosPorGrupo = {};
  final Map<String, Future<List<DomainModel>>> _carregamentosPorGrupo = {};
  final Set<String> _gruposCarregando = {};
  final Set<String> _gruposCarregados = {};
  final Set<String> _gruposComDadosDesatualizados = {};
  final Map<String, Object> _errosPorGrupo = {};
  final Map<String, int> _versoesPorGrupo = {};

  int _geracao = 0;

  DomainProvider({
    DomainRepository? repository,
    DomainCache? cache,
    DomainPersistentCache? persistentCache,
  })  : repository = repository ??
            DomainRepository(
              domainService: DomainService(),
            ),
        cache = cache ?? DomainCache(),
        persistentCache = persistentCache ?? DomainPersistentCache();

  List<DomainModel> dominiosDoGrupo(String grupo) {
    return List<DomainModel>.unmodifiable(
      _dominiosPorGrupo[grupo] ?? const <DomainModel>[],
    );
  }

  Map<String, String> opcoesDoGrupo(String grupo) {
    return dominiosDoGrupo(grupo).paraMapaDeOpcoes();
  }

  bool estaCarregando(String grupo) {
    return _gruposCarregando.contains(grupo);
  }

  bool foiCarregado(String grupo) {
    return _gruposCarregados.contains(grupo);
  }

  bool possuiErro(String grupo) {
    return _errosPorGrupo.containsKey(grupo);
  }

  bool possuiDadosDesatualizados(String grupo) {
    return _gruposComDadosDesatualizados.contains(grupo);
  }

  Object? erroDoGrupo(String grupo) {
    return _errosPorGrupo[grupo];
  }

  Duration? idadeDoCache(String grupo) {
    return cache.idade(grupo);
  }

  Future<Duration?> idadeDoCachePersistente(String grupo) {
    return persistentCache.idade(grupo);
  }

  Future<List<DomainModel>> carregarGrupo(
    String grupo, {
    bool forcarAtualizacao = false,
    bool notificar = true,
  }) {
    final grupoNormalizado = grupo.trim();

    if (grupoNormalizado.isEmpty) {
      return Future<List<DomainModel>>.error(
        ArgumentError.value(grupo, 'grupo', 'O grupo não pode ser vazio.'),
      );
    }

    final carregamentoExistente = _carregamentosPorGrupo[grupoNormalizado];

    if (carregamentoExistente != null) {
      return carregamentoExistente;
    }

    if (!forcarAtualizacao) {
      final itensEmCache = cache.obter(grupoNormalizado);

      // Cache vazio não pode encerrar o fluxo de carregamento. Isso ocorre,
      // por exemplo, quando um grupo foi consultado antes de receber seus
      // primeiros domínios. Nesse caso, a fonte oficial precisa ser acessada.
      if (itensEmCache != null && itensEmCache.isNotEmpty) {
        final tratados = _mesclarComLegados(
          grupoNormalizado,
          itensEmCache,
        );

        _aplicarDados(
          grupo: grupoNormalizado,
          itens: tratados,
          desatualizados: false,
        );

        if (notificar) {
          notifyListeners();
        }

        return Future<List<DomainModel>>.value(
          List<DomainModel>.unmodifiable(tratados),
        );
      }
    }

    final geracaoDoCarregamento = _geracao;
    final versaoDoGrupo = _versaoAtual(grupoNormalizado);

    _gruposCarregando.add(grupoNormalizado);
    _errosPorGrupo.remove(grupoNormalizado);

    if (notificar) {
      notifyListeners();
    }

    late final Future<List<DomainModel>> carregamento;

    carregamento = _carregarComCamadas(
      grupo: grupoNormalizado,
      forcarAtualizacao: forcarAtualizacao,
      geracaoDoCarregamento: geracaoDoCarregamento,
      versaoDoGrupo: versaoDoGrupo,
    ).whenComplete(() {
      if (identical(
        _carregamentosPorGrupo[grupoNormalizado],
        carregamento,
      )) {
        _carregamentosPorGrupo.remove(grupoNormalizado);
        _gruposCarregando.remove(grupoNormalizado);

        if (notificar) {
          notifyListeners();
        }
      }
    });

    _carregamentosPorGrupo[grupoNormalizado] = carregamento;

    return carregamento;
  }

  Future<List<DomainModel>> _carregarComCamadas({
    required String grupo,
    required bool forcarAtualizacao,
    required int geracaoDoCarregamento,
    required int versaoDoGrupo,
  }) async {
    if (!forcarAtualizacao) {
      final persistidos = await persistentCache.obter(grupo);

      // Um cache persistente vazio é tratado como cache miss. Caso contrário,
      // o grupo permaneceria indefinidamente sem opções, mesmo após ser
      // alimentado na Central de Domínios.
      if (persistidos != null &&
          persistidos.isNotEmpty &&
          _carregamentoAindaValido(
            grupo: grupo,
            geracaoDoCarregamento: geracaoDoCarregamento,
            versaoDoGrupo: versaoDoGrupo,
          )) {
        cache.armazenar(grupo, persistidos);

        final apresentados = _mesclarComLegados(
          grupo,
          persistidos,
        );

        _aplicarDados(
          grupo: grupo,
          itens: apresentados,
          desatualizados: false,
        );

        return List<DomainModel>.unmodifiable(apresentados);
      }
    }

    return _carregarDaFonte(
      grupo: grupo,
      geracaoDoCarregamento: geracaoDoCarregamento,
      versaoDoGrupo: versaoDoGrupo,
    );
  }

  Future<List<DomainModel>> _carregarDaFonte({
    required String grupo,
    required int geracaoDoCarregamento,
    required int versaoDoGrupo,
  }) async {
    try {
      final carregados = await repository.listarPorGrupo(grupo);
      final tratadosDaFonte = carregados.somenteVigentes().ordenados();

      if (!_carregamentoAindaValido(
        grupo: grupo,
        geracaoDoCarregamento: geracaoDoCarregamento,
        versaoDoGrupo: versaoDoGrupo,
      )) {
        return List<DomainModel>.unmodifiable(tratadosDaFonte);
      }

      cache.armazenar(grupo, tratadosDaFonte);
      await persistentCache.armazenar(grupo, tratadosDaFonte);

      final apresentados = _mesclarComLegados(
        grupo,
        tratadosDaFonte,
      );

      _aplicarDados(
        grupo: grupo,
        itens: apresentados,
        desatualizados: false,
      );

      return List<DomainModel>.unmodifiable(apresentados);
    } catch (erro) {
      if (!_carregamentoAindaValido(
        grupo: grupo,
        geracaoDoCarregamento: geracaoDoCarregamento,
        versaoDoGrupo: versaoDoGrupo,
      )) {
        rethrow;
      }

      final cacheExpirado = cache.obterMesmoExpirado(grupo);
      final persistidoExpirado =
          await persistentCache.obterMesmoExpirado(grupo);
      final contingencia = _primeiraListaNaoVazia(
        cacheExpirado,
        persistidoExpirado,
      );

      if (contingencia != null) {
        cache.armazenar(grupo, contingencia);

        final apresentados = _mesclarComLegados(
          grupo,
          contingencia,
        );

        _aplicarDados(
          grupo: grupo,
          itens: apresentados,
          desatualizados: true,
          erro: erro,
        );

        return List<DomainModel>.unmodifiable(apresentados);
      }

      _errosPorGrupo[grupo] = erro;
      rethrow;
    }
  }

  Future<void> carregarGrupos(
    Iterable<String> grupos, {
    bool forcarAtualizacao = false,
  }) async {
    final gruposUnicos = grupos
        .map((grupo) => grupo.trim())
        .where((grupo) => grupo.isNotEmpty)
        .toSet();

    await Future.wait(
      gruposUnicos.map(
        (grupo) => carregarGrupo(
          grupo,
          forcarAtualizacao: forcarAtualizacao,
          notificar: false,
        ),
      ),
    );

    notifyListeners();
  }

  Future<void> recarregarGrupo(String grupo) async {
    invalidarGrupo(
      grupo,
      notificar: false,
      invalidarPersistencia: false,
    );

    await carregarGrupo(
      grupo,
      forcarAtualizacao: true,
    );
  }

  Future<void> recarregarGrupos(Iterable<String> grupos) async {
    final gruposUnicos = grupos
        .map((grupo) => grupo.trim())
        .where((grupo) => grupo.isNotEmpty)
        .toSet();

    for (final grupo in gruposUnicos) {
      invalidarGrupo(
        grupo,
        notificar: false,
        invalidarPersistencia: false,
      );
    }

    await carregarGrupos(
      gruposUnicos,
      forcarAtualizacao: true,
    );
  }

  void preservarValorLegado({
    required String grupo,
    required String id,
    required String nome,
  }) {
    final grupoNormalizado = grupo.trim();
    final idNormalizado = id.trim();
    final nomeNormalizado = nome.trim();

    if (grupoNormalizado.isEmpty ||
        idNormalizado.isEmpty ||
        nomeNormalizado.isEmpty) {
      return;
    }

    final atuais = List<DomainModel>.from(
      _dominiosPorGrupo[grupoNormalizado] ?? const <DomainModel>[],
    );

    if (atuais.any((domain) => domain.id == idNormalizado)) {
      return;
    }

    atuais.add(
      DomainModel(
        id: idNormalizado,
        grupo: grupoNormalizado,
        codigo: idNormalizado,
        nome: nomeNormalizado,
        ordem: 999999,
        ativo: false,
        metadados: const {
          'origem': 'legado',
          'somenteLeitura': true,
        },
      ),
    );

    _dominiosPorGrupo[grupoNormalizado] = atuais.ordenados();
    notifyListeners();
  }

  void invalidarGrupo(
    String grupo, {
    bool notificar = true,
    bool invalidarPersistencia = true,
  }) {
    final grupoNormalizado = grupo.trim();

    if (grupoNormalizado.isEmpty) {
      return;
    }

    _incrementarVersao(grupoNormalizado);
    _dominiosPorGrupo.remove(grupoNormalizado);
    _gruposCarregados.remove(grupoNormalizado);
    _gruposComDadosDesatualizados.remove(grupoNormalizado);
    _errosPorGrupo.remove(grupoNormalizado);
    cache.invalidarGrupo(grupoNormalizado);

    if (invalidarPersistencia) {
      unawaited(persistentCache.invalidarGrupo(grupoNormalizado));
    }

    if (notificar) {
      notifyListeners();
    }
  }

  Future<void> limpar({
    bool limparCacheDoServico = false,
    bool limparCachePersistente = true,
  }) async {
    _geracao++;
    _dominiosPorGrupo.clear();
    _carregamentosPorGrupo.clear();
    _gruposCarregando.clear();
    _gruposCarregados.clear();
    _gruposComDadosDesatualizados.clear();
    _errosPorGrupo.clear();
    _versoesPorGrupo.clear();
    cache.limpar();

    if (limparCachePersistente) {
      await persistentCache.limpar();
    }

    if (limparCacheDoServico) {
      await repository.limparCache();
    }

    notifyListeners();
  }

  void _aplicarDados({
    required String grupo,
    required List<DomainModel> itens,
    required bool desatualizados,
    Object? erro,
  }) {
    _dominiosPorGrupo[grupo] = itens;
    _gruposCarregados.add(grupo);

    if (desatualizados) {
      _gruposComDadosDesatualizados.add(grupo);
    } else {
      _gruposComDadosDesatualizados.remove(grupo);
    }

    if (erro == null) {
      _errosPorGrupo.remove(grupo);
    } else {
      _errosPorGrupo[grupo] = erro;
    }
  }

  List<DomainModel> _mesclarComLegados(
    String grupo,
    Iterable<DomainModel> itensDaFonte,
  ) {
    final resultado = List<DomainModel>.from(itensDaFonte);
    final legados = (_dominiosPorGrupo[grupo] ?? const <DomainModel>[])
        .where(_ehValorLegado);

    for (final legado in legados) {
      if (resultado.every((domain) => domain.id != legado.id)) {
        resultado.add(legado);
      }
    }

    return resultado.ordenados();
  }

  List<DomainModel>? _primeiraListaNaoVazia(
    List<DomainModel>? primaria,
    List<DomainModel>? secundaria,
  ) {
    if (primaria != null && primaria.isNotEmpty) {
      return primaria;
    }

    if (secundaria != null && secundaria.isNotEmpty) {
      return secundaria;
    }

    return null;
  }

  bool _ehValorLegado(DomainModel domain) {
    return domain.metadados['origem'] == 'legado';
  }

  int _versaoAtual(String grupo) {
    return _versoesPorGrupo[grupo] ?? 0;
  }

  void _incrementarVersao(String grupo) {
    _versoesPorGrupo[grupo] = _versaoAtual(grupo) + 1;
  }

  bool _carregamentoAindaValido({
    required String grupo,
    required int geracaoDoCarregamento,
    required int versaoDoGrupo,
  }) {
    return _geracao == geracaoDoCarregamento &&
        _versaoAtual(grupo) == versaoDoGrupo;
  }
}

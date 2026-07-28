import 'package:flutter/foundation.dart';

import '../../data/models/domain_model.dart';
import '../../repositories/domain_repository.dart';
import '../services/domain_service.dart';
import 'domain_cache.dart';
import 'domain_extensions.dart';

class DomainProvider extends ChangeNotifier {
  final DomainRepository repository;
  final DomainCache cache;

  final Map<String, List<DomainModel>> _dominiosPorGrupo = {};
  final Set<String> _gruposCarregando = {};
  final Map<String, Object> _errosPorGrupo = {};

  DomainProvider({
    DomainRepository? repository,
    DomainCache? cache,
  })  : repository = repository ??
            DomainRepository(
              domainService: DomainService(),
            ),
        cache = cache ?? DomainCache();

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
    return _dominiosPorGrupo.containsKey(grupo);
  }

  bool possuiErro(String grupo) {
    return _errosPorGrupo.containsKey(grupo);
  }

  Object? erroDoGrupo(String grupo) {
    return _errosPorGrupo[grupo];
  }

  Future<List<DomainModel>> carregarGrupo(
    String grupo, {
    bool forcarAtualizacao = false,
    bool notificar = true,
  }) async {
    if (!forcarAtualizacao) {
      final itensEmMemoria = _dominiosPorGrupo[grupo];

      if (itensEmMemoria != null) {
        return List<DomainModel>.unmodifiable(itensEmMemoria);
      }

      final itensEmCache = cache.obter(grupo);

      if (itensEmCache != null) {
        _dominiosPorGrupo[grupo] = itensEmCache;
        _errosPorGrupo.remove(grupo);

        if (notificar) {
          notifyListeners();
        }

        return itensEmCache;
      }
    }

    if (_gruposCarregando.contains(grupo)) {
      return dominiosDoGrupo(grupo);
    }

    _gruposCarregando.add(grupo);
    _errosPorGrupo.remove(grupo);

    if (notificar) {
      notifyListeners();
    }

    try {
      final carregados = await repository.listarPorGrupo(grupo);
      final tratados = carregados.somenteVigentes().ordenados();

      _dominiosPorGrupo[grupo] = tratados;
      cache.armazenar(grupo, tratados);

      return List<DomainModel>.unmodifiable(tratados);
    } catch (erro) {
      _errosPorGrupo[grupo] = erro;
      rethrow;
    } finally {
      _gruposCarregando.remove(grupo);

      if (notificar) {
        notifyListeners();
      }
    }
  }

  Future<void> carregarGrupos(
    Iterable<String> grupos, {
    bool forcarAtualizacao = false,
  }) async {
    final gruposUnicos = grupos.toSet();

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
    invalidarGrupo(grupo, notificar: false);
    await carregarGrupo(grupo, forcarAtualizacao: true);
  }

  Future<void> recarregarGrupos(Iterable<String> grupos) async {
    for (final grupo in grupos.toSet()) {
      invalidarGrupo(grupo, notificar: false);
    }

    await carregarGrupos(
      grupos,
      forcarAtualizacao: true,
    );
  }

  void preservarValorLegado({
    required String grupo,
    required String id,
    required String nome,
  }) {
    if (id.trim().isEmpty || nome.trim().isEmpty) {
      return;
    }

    final atuais = List<DomainModel>.from(
      _dominiosPorGrupo[grupo] ?? const <DomainModel>[],
    );

    if (atuais.any((domain) => domain.id == id)) {
      return;
    }

    atuais.add(
      DomainModel(
        id: id,
        grupo: grupo,
        codigo: id,
        nome: nome,
        ordem: 999999,
        ativo: false,
        metadados: const {
          'origem': 'legado',
          'somenteLeitura': true,
        },
      ),
    );

    final ordenados = atuais.ordenados();
    _dominiosPorGrupo[grupo] = ordenados;
    notifyListeners();
  }

  void invalidarGrupo(
    String grupo, {
    bool notificar = true,
  }) {
    _dominiosPorGrupo.remove(grupo);
    _errosPorGrupo.remove(grupo);
    cache.invalidarGrupo(grupo);

    if (notificar) {
      notifyListeners();
    }
  }

  Future<void> limpar({
    bool limparCacheDoServico = false,
  }) async {
    _dominiosPorGrupo.clear();
    _gruposCarregando.clear();
    _errosPorGrupo.clear();
    cache.limpar();

    if (limparCacheDoServico) {
      await repository.limparCache();
    }

    notifyListeners();
  }
}

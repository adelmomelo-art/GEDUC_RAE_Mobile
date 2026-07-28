import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/domain_model.dart';

/// Cache persistente dos domínios.
///
/// Camada complementar ao [DomainCache] em memória. Sua finalidade é manter
/// os grupos disponíveis após o encerramento do aplicativo e permitir
/// operação contingencial quando a fonte remota estiver indisponível.
class DomainPersistentCache {
  static const String _prefixo = 'fenix.domain_cache.v1';
  static const String _chaveIndice = '$_prefixo.grupos';

  final Duration validade;
  final Duration retencaoMaxima;

  DomainPersistentCache({
    this.validade = const Duration(hours: 24),
    this.retencaoMaxima = const Duration(days: 30),
  });

  Future<DomainPersistentCacheEntry?> obterEntrada(String grupo) async {
    final grupoNormalizado = grupo.trim();

    if (grupoNormalizado.isEmpty) {
      return null;
    }

    final preferences = await SharedPreferences.getInstance();
    final conteudo = preferences.getString(_chaveDoGrupo(grupoNormalizado));

    if (conteudo == null || conteudo.trim().isEmpty) {
      return null;
    }

    try {
      final json = jsonDecode(conteudo);

      if (json is! Map) {
        await invalidarGrupo(grupoNormalizado);
        return null;
      }

      final entrada = DomainPersistentCacheEntry.fromJson(
        Map<String, dynamic>.from(json),
      );

      if (entrada.grupo != grupoNormalizado ||
          entrada.armazenadoEm.add(retencaoMaxima).isBefore(DateTime.now())) {
        await invalidarGrupo(grupoNormalizado);
        return null;
      }

      return entrada;
    } catch (_) {
      await invalidarGrupo(grupoNormalizado);
      return null;
    }
  }

  /// Retorna apenas dados dentro do TTL persistente.
  Future<List<DomainModel>?> obter(String grupo) async {
    final entrada = await obterEntrada(grupo);

    if (entrada == null || entrada.expirado(validade)) {
      return null;
    }

    return entrada.itens;
  }

  /// Retorna dados ainda retidos mesmo após o TTL.
  ///
  /// Usado somente como contingência quando a fonte remota falhar.
  Future<List<DomainModel>?> obterMesmoExpirado(String grupo) async {
    return (await obterEntrada(grupo))?.itens;
  }

  Future<void> armazenar(
    String grupo,
    Iterable<DomainModel> itens,
  ) async {
    final grupoNormalizado = grupo.trim();

    if (grupoNormalizado.isEmpty) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    final entrada = DomainPersistentCacheEntry(
      grupo: grupoNormalizado,
      armazenadoEm: DateTime.now(),
      itens: itens,
    );

    await preferences.setString(
      _chaveDoGrupo(grupoNormalizado),
      jsonEncode(entrada.toJson()),
    );

    final grupos =
        preferences.getStringList(_chaveIndice)?.toSet() ?? <String>{};

    if (grupos.add(grupoNormalizado)) {
      final ordenados = grupos.toList()..sort();
      await preferences.setStringList(_chaveIndice, ordenados);
    }
  }

  Future<Duration?> idade(String grupo) async {
    final entrada = await obterEntrada(grupo);

    if (entrada == null) {
      return null;
    }

    return DateTime.now().difference(entrada.armazenadoEm);
  }

  Future<void> invalidarGrupo(String grupo) async {
    final grupoNormalizado = grupo.trim();

    if (grupoNormalizado.isEmpty) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_chaveDoGrupo(grupoNormalizado));

    final grupos = preferences.getStringList(_chaveIndice)?.toSet();

    if (grupos == null || !grupos.remove(grupoNormalizado)) {
      return;
    }

    if (grupos.isEmpty) {
      await preferences.remove(_chaveIndice);
      return;
    }

    final ordenados = grupos.toList()..sort();
    await preferences.setStringList(_chaveIndice, ordenados);
  }

  Future<void> limparExpirados() async {
    final preferences = await SharedPreferences.getInstance();
    final grupos =
        preferences.getStringList(_chaveIndice)?.toList() ?? <String>[];

    for (final grupo in grupos) {
      final entrada = await obterEntrada(grupo);

      if (entrada == null) {
        continue;
      }

      if (entrada.armazenadoEm.add(retencaoMaxima).isBefore(DateTime.now())) {
        await invalidarGrupo(grupo);
      }
    }
  }

  Future<void> limpar() async {
    final preferences = await SharedPreferences.getInstance();
    final grupos =
        preferences.getStringList(_chaveIndice)?.toList() ?? <String>[];

    for (final grupo in grupos) {
      await preferences.remove(_chaveDoGrupo(grupo));
    }

    await preferences.remove(_chaveIndice);
  }

  String _chaveDoGrupo(String grupo) {
    return '$_prefixo.grupo.${Uri.encodeComponent(grupo)}';
  }
}

class DomainPersistentCacheEntry {
  final String grupo;
  final DateTime armazenadoEm;
  final List<DomainModel> itens;

  DomainPersistentCacheEntry({
    required this.grupo,
    required this.armazenadoEm,
    required Iterable<DomainModel> itens,
  }) : itens = List<DomainModel>.unmodifiable(itens);

  bool expirado(Duration validade) {
    return !DateTime.now().isBefore(armazenadoEm.add(validade));
  }

  Map<String, dynamic> toJson() {
    return {
      'versao': 1,
      'grupo': grupo,
      'armazenadoEm': armazenadoEm.toIso8601String(),
      'itens': itens.map((item) => _normalizarJson(item.toJson())).toList(),
    };
  }

  factory DomainPersistentCacheEntry.fromJson(
    Map<String, dynamic> json,
  ) {
    final itensJson = json['itens'];

    final itens = itensJson is List
        ? itensJson
            .whereType<Map>()
            .map(
              (item) => DomainModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false)
        : const <DomainModel>[];

    return DomainPersistentCacheEntry(
      grupo: json['grupo']?.toString() ?? '',
      armazenadoEm: DateTime.tryParse(json['armazenadoEm']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      itens: itens,
    );
  }

  static dynamic _normalizarJson(dynamic valor) {
    if (valor == null || valor is String || valor is num || valor is bool) {
      return valor;
    }

    if (valor is DateTime) {
      return valor.toIso8601String();
    }

    if (valor is Map) {
      return valor.map(
        (chave, conteudo) => MapEntry(
          chave.toString(),
          _normalizarJson(conteudo),
        ),
      );
    }

    if (valor is Iterable) {
      return valor.map(_normalizarJson).toList();
    }

    return valor.toString();
  }
}

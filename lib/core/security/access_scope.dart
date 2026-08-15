import 'dart:collection';

/// Vínculos territoriais e operacionais que limitam o acesso de um usuário.
///
/// Este contrato não concede permissões. Enquanto não houver um avaliador de
/// escopo integrado às regras e às consultas, os perfis restritos permanecem
/// bloqueados pela [AuthorizationPolicy].
class AccessScope {
  AccessScope({
    Iterable<String> regionalIds = const <String>[],
    Iterable<String> equipeIds = const <String>[],
    Iterable<String> projetoIds = const <String>[],
    this.version = 1,
  })  : regionalIds = _normalizarIds(regionalIds),
        equipeIds = _normalizarIds(equipeIds),
        projetoIds = _normalizarIds(projetoIds);

  final Set<String> regionalIds;
  final Set<String> equipeIds;
  final Set<String> projetoIds;
  final int version;

  bool get possuiRegionais => regionalIds.isNotEmpty;
  bool get possuiEquipes => equipeIds.isNotEmpty;
  bool get possuiProjetos => projetoIds.isNotEmpty;

  /// O Gerente somente pode ser ativado quando as três dimensões existirem.
  bool get completoParaGerente =>
      version > 0 && possuiRegionais && possuiEquipes && possuiProjetos;

  /// Interseção por dimensão: o registro deve atender simultaneamente a todas.
  bool abrangeGerente({
    required String regionalId,
    required String equipeId,
    required String projetoId,
  }) {
    if (!completoParaGerente) return false;
    return regionalIds.contains(regionalId.trim()) &&
        equipeIds.contains(equipeId.trim()) &&
        projetoIds.contains(projetoId.trim());
  }

  factory AccessScope.fromMap(Map<String, dynamic>? map) {
    if (map == null) return AccessScope();
    return AccessScope(
      regionalIds: _lerIds(map['regionalIds']),
      equipeIds: _lerIds(map['equipeIds']),
      projetoIds: _lerIds(map['projetoIds']),
      version: _lerVersao(map['scopeVersion']),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'regionalIds': regionalIds.toList(growable: false),
        'equipeIds': equipeIds.toList(growable: false),
        'projetoIds': projetoIds.toList(growable: false),
        'scopeVersion': version,
      };

  static Set<String> _normalizarIds(Iterable<String> valores) {
    final ids = SplayTreeSet<String>();
    for (final valor in valores) {
      final id = valor.trim();
      if (id.isNotEmpty) ids.add(id);
    }
    return UnmodifiableSetView<String>(ids);
  }

  static Iterable<String> _lerIds(Object? valor) {
    if (valor is! Iterable) return const <String>[];
    return valor.map((item) => item?.toString() ?? '');
  }

  static int _lerVersao(Object? valor) {
    if (valor is int) return valor;
    return int.tryParse(valor?.toString() ?? '') ?? 1;
  }
}

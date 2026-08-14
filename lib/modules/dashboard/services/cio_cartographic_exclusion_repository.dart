import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/cartography/cio_cartographic_models.dart';
import 'cio_geometry_repository.dart';

class CioCartographicExclusionRepository {
  CioCartographicExclusionRepository({
    AssetBundle? bundle,
    this.asset = 'assets/geo/exclusoes_cartograficas_lote5.json',
  }) : bundle = bundle ?? rootBundle;

  final AssetBundle bundle;
  final String asset;
  Future<List<CioCartographicExclusion>>? _cached;

  Future<List<CioCartographicExclusion>> load() => _cached ??= _load();

  Future<List<CioCartographicExclusion>> _load() async {
    final decoded = jsonDecode(await bundle.loadString(asset));
    if (decoded is! Map || decoded['items'] is! List) {
      throw const CioGeometryException('Manifesto de exclusões inválido.');
    }
    final items = (decoded['items'] as List).map((value) {
      if (value is! Map) {
        throw const CioGeometryException('Exclusão cartográfica inválida.');
      }
      final item = Map<String, dynamic>.from(value);
      final id = item['id']?.toString().trim() ?? '';
      final group = item['group']?.toString().trim() ?? '';
      final reason = item['reason']?.toString().trim() ?? '';
      if (id.isEmpty || !const {'G1', 'G2'}.contains(group) || reason.isEmpty) {
        throw const CioGeometryException('Exclusão cartográfica incompleta.');
      }
      return CioCartographicExclusion(
        actionId: id,
        group: group,
        reason: reason,
      );
    }).toList(growable: false);
    if (items.length != 8 ||
        items.map((item) => item.actionId).toSet().length != 8 ||
        items.where((item) => item.group == 'G1').length != 4 ||
        items.where((item) => item.group == 'G2').length != 4) {
      throw const CioGeometryException('Portão G1/G2 exige 4/4 exclusões.');
    }
    return List<CioCartographicExclusion>.unmodifiable(items);
  }
}

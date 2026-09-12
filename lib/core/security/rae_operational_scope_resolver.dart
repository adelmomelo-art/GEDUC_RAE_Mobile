import 'dart:convert';

import 'package:crypto/crypto.dart';

class RaeOperationalScopeResolution {
  const RaeOperationalScopeResolution({
    required this.regionalId,
    required this.coordenadorUserId,
    required this.equipeId,
    required this.projetoId,
    required this.membroUserIds,
    required this.completa,
  });

  final String regionalId;
  final String coordenadorUserId;
  final String equipeId;
  final String projetoId;
  final List<String> membroUserIds;
  final bool completa;
}

class RaeOperationalScopeResolver {
  const RaeOperationalScopeResolver._();

  static RaeOperationalScopeResolution resolve({
    required String acaoId,
    required String regionalId,
    required String coordenadorUserId,
    required String projetoId,
    required Iterable<String> membroUserIds,
  }) {
    final acao = acaoId.trim();
    final regional = regionalId.trim();
    final coordenador = coordenadorUserId.trim();
    final projeto = projetoId.trim();

    final membros = membroUserIds
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList(growable: false)
      ..sort();

    final possuiEquipeCanonica = acao.isNotEmpty &&
        coordenador.isNotEmpty &&
        membros.isNotEmpty &&
        membros.contains(coordenador);

    if (!possuiEquipeCanonica) {
      return RaeOperationalScopeResolution(
        regionalId: regional,
        coordenadorUserId: coordenador,
        equipeId: '',
        projetoId: projeto,
        membroUserIds: List<String>.unmodifiable(membros),
        completa: false,
      );
    }

    final payload = <String>[
      'v1',
      acao,
      coordenador,
      ...membros,
    ].join('|');

    final digest = sha256.convert(utf8.encode(payload)).toString();
    final equipeId = 'rae_team_${digest.substring(0, 24)}';

    final completa = regional.isNotEmpty && projeto.isNotEmpty;

    return RaeOperationalScopeResolution(
      regionalId: regional,
      coordenadorUserId: coordenador,
      equipeId: equipeId,
      projetoId: projeto,
      membroUserIds: List<String>.unmodifiable(membros),
      completa: completa,
    );
  }
}

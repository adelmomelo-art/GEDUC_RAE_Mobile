import 'access_scope.dart';
import 'authorization_policy.dart';

enum RaeQueryOperator { isEqualTo, whereIn }

class RaeQueryFilter {
  const RaeQueryFilter({
    required this.campo,
    required this.operador,
    required this.valor,
  });

  final String campo;
  final RaeQueryOperator operador;
  final Object valor;
}

class RaeQuerySpec {
  const RaeQuerySpec({this.filtros = const <RaeQueryFilter>[]});

  final List<RaeQueryFilter> filtros;
}

class RaeQueryPlan {
  const RaeQueryPlan._({required this.consultas, this.motivoBloqueio});

  final List<RaeQuerySpec> consultas;
  final String? motivoBloqueio;

  bool get bloqueado => motivoBloqueio != null;

  factory RaeQueryPlan.paraPerfil({
    required String perfilAcesso,
    required String usuarioId,
    AccessScope? escopo,
  }) {
    final perfil = AuthorizationPolicy.normalizarPerfil(perfilAcesso);
    final uid = usuarioId.trim();
    if (uid.isEmpty || !AuthorizationPolicy.perfilReconhecido(perfil)) {
      return const RaeQueryPlan._(
        consultas: [],
        motivoBloqueio: 'Identidade inválida ou perfil não reconhecido.',
      );
    }

    return switch (perfil) {
      'administrador' => const RaeQueryPlan._(
          consultas: [RaeQuerySpec()],
        ),
      'gestor' => RaeQueryPlan._(
          consultas: [_classificados()],
        ),
      'gerente' => _paraGerente(escopo),
      'coordenador' => RaeQueryPlan._(
          consultas: [
            RaeQuerySpec(filtros: [
              _classificado,
              RaeQueryFilter(
                campo: 'coordenadorUserId',
                operador: RaeQueryOperator.isEqualTo,
                valor: uid,
              ),
            ]),
          ],
        ),
      'agente' => RaeQueryPlan._(
          consultas: [
            RaeQuerySpec(filtros: [
              _classificado,
              RaeQueryFilter(
                campo: 'responsavelUserId',
                operador: RaeQueryOperator.isEqualTo,
                valor: uid,
              ),
            ]),
          ],
        ),
      _ => const RaeQueryPlan._(
          consultas: [],
          motivoBloqueio: 'Perfil sem plano de consulta.',
        ),
    };
  }

  static const RaeQueryFilter _classificado = RaeQueryFilter(
    campo: 'aclClassificacaoCompleta',
    operador: RaeQueryOperator.isEqualTo,
    valor: true,
  );

  static RaeQuerySpec _classificados() {
    return const RaeQuerySpec(filtros: [_classificado]);
  }

  static RaeQueryPlan _paraGerente(AccessScope? escopo) {
    if (escopo == null || !escopo.completoParaGerente) {
      return const RaeQueryPlan._(
        consultas: [],
        motivoBloqueio: 'Escopo do Gerente está incompleto.',
      );
    }

    final chaves = <String>[];
    for (final regionalId in escopo.regionalIds) {
      for (final equipeId in escopo.equipeIds) {
        for (final projetoId in escopo.projetoIds) {
          chaves.add(chaveEscopo(
            regionalId: regionalId,
            equipeId: equipeId,
            projetoId: projetoId,
          ));
          if (chaves.length > 300) {
            return const RaeQueryPlan._(
              consultas: [],
              motivoBloqueio:
                  'Escopo excede 300 combinações e exige revisão institucional.',
            );
          }
        }
      }
    }

    final consultas = <RaeQuerySpec>[];
    for (var inicio = 0; inicio < chaves.length; inicio += 30) {
      final fim = (inicio + 30).clamp(0, chaves.length);
      consultas.add(RaeQuerySpec(filtros: [
        _classificado,
        RaeQueryFilter(
          campo: 'aclScopeKey',
          operador: RaeQueryOperator.whereIn,
          valor: chaves.sublist(inicio, fim),
        ),
      ]));
    }
    return RaeQueryPlan._(consultas: consultas);
  }

  static String chaveEscopo({
    required String regionalId,
    required String equipeId,
    required String projetoId,
  }) {
    String parte(String prefixo, String valor) =>
        '$prefixo:${Uri.encodeComponent(valor.trim())}';
    return [
      parte('r', regionalId),
      parte('e', equipeId),
      parte('p', projetoId),
    ].join('|');
  }
}

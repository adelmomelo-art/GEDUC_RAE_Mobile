import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/security/access_scope.dart';
import 'package:geduc_rae_mobile/core/security/rae_query_plan.dart';

void main() {
  group('RaeQueryPlan', () {
    test('Administrador recebe consulta global', () {
      final plano = RaeQueryPlan.paraPerfil(
        perfilAcesso: 'administrador',
        usuarioId: 'admin-1',
      );

      expect(plano.bloqueado, isFalse);
      expect(plano.consultas, hasLength(1));
      expect(plano.consultas.single.filtros, isEmpty);
    });

    test('Gestor consulta somente classificação completa', () {
      final plano = RaeQueryPlan.paraPerfil(
        perfilAcesso: 'gestor',
        usuarioId: 'gestor-1',
      );

      expect(plano.consultas.single.filtros.single.campo,
          'aclClassificacaoCompleta');
    });

    test('Gerente incompleto permanece bloqueado', () {
      final plano = RaeQueryPlan.paraPerfil(
        perfilAcesso: 'gerente',
        usuarioId: 'gerente-1',
        escopo: AccessScope(regionalIds: const ['regional-1']),
      );

      expect(plano.bloqueado, isTrue);
      expect(plano.consultas, isEmpty);
    });

    test('Gerente gera chaves pela interseção e lotes de até 30', () {
      final plano = RaeQueryPlan.paraPerfil(
        perfilAcesso: 'gerente',
        usuarioId: 'gerente-1',
        escopo: AccessScope(
          regionalIds: List.generate(4, (i) => 'regional-$i'),
          equipeIds: List.generate(3, (i) => 'equipe-$i'),
          projetoIds: List.generate(3, (i) => 'projeto-$i'),
        ),
      );

      expect(plano.bloqueado, isFalse);
      expect(plano.consultas, hasLength(2));
      final tamanhos = plano.consultas.map((consulta) {
        return (consulta.filtros.last.valor as List<String>).length;
      });
      expect(tamanhos, [30, 6]);
    });

    test('Coordenador e Agente consultam pelo próprio UID', () {
      final coordenador = RaeQueryPlan.paraPerfil(
        perfilAcesso: 'coordenador',
        usuarioId: 'coordenador-1',
      );
      final agente = RaeQueryPlan.paraPerfil(
        perfilAcesso: 'agente',
        usuarioId: 'agente-1',
      );

      expect(
          coordenador.consultas.single.filtros.last.campo, 'coordenadorUserId');
      expect(agente.consultas.single.filtros.last.campo, 'responsavelUserId');
    });

    test('escopo excessivo falha fechado', () {
      final plano = RaeQueryPlan.paraPerfil(
        perfilAcesso: 'gerente',
        usuarioId: 'gerente-1',
        escopo: AccessScope(
          regionalIds: List.generate(7, (i) => 'regional-$i'),
          equipeIds: List.generate(7, (i) => 'equipe-$i'),
          projetoIds: List.generate(7, (i) => 'projeto-$i'),
        ),
      );

      expect(plano.bloqueado, isTrue);
      expect(plano.consultas, isEmpty);
    });
  });
}

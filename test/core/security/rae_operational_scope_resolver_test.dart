import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/security/rae_operational_scope_resolver.dart';

void main() {
  group('RaeOperationalScopeResolver', () {
    test('resolve ACL operacional sem depender de AccessScope', () {
      final resultado = RaeOperationalScopeResolver.resolve(
        acaoId: 'acao-0042',
        regionalId: 'regional-1',
        coordenadorUserId: 'uid-coordenador',
        projetoId: 'projeto-1',
        membroUserIds: const <String>[
          'uid-agente-1',
          'uid-coordenador',
          'uid-agente-2',
        ],
      );

      expect(resultado.completa, isTrue);
      expect(resultado.regionalId, 'regional-1');
      expect(resultado.projetoId, 'projeto-1');
      expect(
        resultado.equipeId,
        matches(RegExp(r'^rae_team_[a-f0-9]{24}$')),
      );
    });

    test('ordem dos membros nao altera identidade da equipe', () {
      final primeira = RaeOperationalScopeResolver.resolve(
        acaoId: 'acao-0042',
        regionalId: 'regional-1',
        coordenadorUserId: 'uid-coordenador',
        projetoId: 'projeto-1',
        membroUserIds: const <String>[
          'uid-coordenador',
          'uid-agente-1',
          'uid-agente-2',
        ],
      );

      final segunda = RaeOperationalScopeResolver.resolve(
        acaoId: 'acao-0042',
        regionalId: 'regional-1',
        coordenadorUserId: 'uid-coordenador',
        projetoId: 'projeto-1',
        membroUserIds: const <String>[
          'uid-agente-2',
          'uid-coordenador',
          'uid-agente-1',
        ],
      );

      expect(primeira.equipeId, segunda.equipeId);
    });

    test('membro duplicado nao altera identidade da equipe', () {
      final primeira = RaeOperationalScopeResolver.resolve(
        acaoId: 'acao-0042',
        regionalId: 'regional-1',
        coordenadorUserId: 'uid-coordenador',
        projetoId: 'projeto-1',
        membroUserIds: const <String>[
          'uid-coordenador',
          'uid-agente-1',
        ],
      );

      final segunda = RaeOperationalScopeResolver.resolve(
        acaoId: 'acao-0042',
        regionalId: 'regional-1',
        coordenadorUserId: 'uid-coordenador',
        projetoId: 'projeto-1',
        membroUserIds: const <String>[
          'uid-agente-1',
          'uid-coordenador',
          'uid-agente-1',
        ],
      );

      expect(primeira.equipeId, segunda.equipeId);
    });

    test('mudanca da composicao altera equipeId', () {
      final primeira = RaeOperationalScopeResolver.resolve(
        acaoId: 'acao-0042',
        regionalId: 'regional-1',
        coordenadorUserId: 'uid-coordenador',
        projetoId: 'projeto-1',
        membroUserIds: const <String>[
          'uid-coordenador',
          'uid-agente-1',
        ],
      );

      final segunda = RaeOperationalScopeResolver.resolve(
        acaoId: 'acao-0042',
        regionalId: 'regional-1',
        coordenadorUserId: 'uid-coordenador',
        projetoId: 'projeto-1',
        membroUserIds: const <String>[
          'uid-coordenador',
          'uid-agente-1',
          'uid-agente-2',
        ],
      );

      expect(primeira.equipeId, isNot(segunda.equipeId));
    });

    test('mudanca do coordenador altera equipeId', () {
      final primeira = RaeOperationalScopeResolver.resolve(
        acaoId: 'acao-0042',
        regionalId: 'regional-1',
        coordenadorUserId: 'uid-coordenador-1',
        projetoId: 'projeto-1',
        membroUserIds: const <String>[
          'uid-coordenador-1',
          'uid-agente',
        ],
      );

      final segunda = RaeOperationalScopeResolver.resolve(
        acaoId: 'acao-0042',
        regionalId: 'regional-1',
        coordenadorUserId: 'uid-coordenador-2',
        projetoId: 'projeto-1',
        membroUserIds: const <String>[
          'uid-coordenador-2',
          'uid-agente',
        ],
      );

      expect(primeira.equipeId, isNot(segunda.equipeId));
    });

    test('projeto diferente nao altera identidade da mesma equipe', () {
      final primeira = RaeOperationalScopeResolver.resolve(
        acaoId: 'acao-0042',
        regionalId: 'regional-1',
        coordenadorUserId: 'uid-coordenador',
        projetoId: 'projeto-1',
        membroUserIds: const <String>[
          'uid-coordenador',
          'uid-agente',
        ],
      );

      final segunda = RaeOperationalScopeResolver.resolve(
        acaoId: 'acao-0042',
        regionalId: 'regional-1',
        coordenadorUserId: 'uid-coordenador',
        projetoId: 'projeto-2',
        membroUserIds: const <String>[
          'uid-coordenador',
          'uid-agente',
        ],
      );

      expect(primeira.equipeId, segunda.equipeId);
    });

    test('projeto ausente preserva equipe mas mantem ACL incompleta', () {
      final resultado = RaeOperationalScopeResolver.resolve(
        acaoId: 'acao-0042',
        regionalId: 'regional-1',
        coordenadorUserId: 'uid-coordenador',
        projetoId: '',
        membroUserIds: const <String>[
          'uid-coordenador',
        ],
      );

      expect(resultado.completa, isFalse);
      expect(
        resultado.equipeId,
        matches(RegExp(r'^rae_team_[a-f0-9]{24}$')),
      );
      expect(resultado.projetoId, isEmpty);
    });

    test('regional ausente preserva equipe mas mantem ACL incompleta', () {
      final resultado = RaeOperationalScopeResolver.resolve(
        acaoId: 'acao-0042',
        regionalId: '',
        coordenadorUserId: 'uid-coordenador',
        projetoId: 'projeto-1',
        membroUserIds: const <String>[
          'uid-coordenador',
        ],
      );

      expect(resultado.completa, isFalse);
      expect(
        resultado.equipeId,
        matches(RegExp(r'^rae_team_[a-f0-9]{24}$')),
      );
    });

    test('falha fechada quando coordenador nao integra a equipe', () {
      final resultado = RaeOperationalScopeResolver.resolve(
        acaoId: 'acao-0042',
        regionalId: 'regional-1',
        coordenadorUserId: 'uid-coordenador',
        projetoId: 'projeto-1',
        membroUserIds: const <String>[
          'uid-agente-1',
          'uid-agente-2',
        ],
      );

      expect(resultado.completa, isFalse);
      expect(resultado.equipeId, isEmpty);
    });

    test('normaliza, deduplica e ordena identidades canonicas', () {
      final resultado = RaeOperationalScopeResolver.resolve(
        acaoId: 'acao-0042',
        regionalId: ' regional-1 ',
        coordenadorUserId: ' uid-coordenador ',
        projetoId: ' projeto-1 ',
        membroUserIds: const <String>[
          ' uid-agente-2 ',
          'uid-coordenador',
          '',
          'uid-agente-1',
          'uid-agente-2',
        ],
      );

      expect(resultado.completa, isTrue);
      expect(
        resultado.membroUserIds,
        const <String>[
          'uid-agente-1',
          'uid-agente-2',
          'uid-coordenador',
        ],
      );
    });
  });
}

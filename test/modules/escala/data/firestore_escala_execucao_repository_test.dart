import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/escala/data/firestore_escala_execucao_repository.dart';

void main() {
  group('FirestoreEscalaExecucaoRepository ID determinístico', () {
    test('mesma atividade e usuário produzem o mesmo ID', () {
      final a = FirestoreEscalaExecucaoRepository.gerarIdExecucao(
        atividadeId: 'atividade-1',
        usuarioId: 'uid-1',
      );
      final b = FirestoreEscalaExecucaoRepository.gerarIdExecucao(
        atividadeId: 'atividade-1',
        usuarioId: 'uid-1',
      );

      expect(a, b);
      expect(a, startsWith('exec-'));
      expect(a.length, 69);
    });

    test('atividade ou usuário diferentes produzem IDs diferentes', () {
      final base = FirestoreEscalaExecucaoRepository.gerarIdExecucao(
        atividadeId: 'atividade-1',
        usuarioId: 'uid-1',
      );
      final outraAtividade = FirestoreEscalaExecucaoRepository.gerarIdExecucao(
        atividadeId: 'atividade-2',
        usuarioId: 'uid-1',
      );
      final outroUsuario = FirestoreEscalaExecucaoRepository.gerarIdExecucao(
        atividadeId: 'atividade-1',
        usuarioId: 'uid-2',
      );

      expect(outraAtividade, isNot(base));
      expect(outroUsuario, isNot(base));
    });

    test('rejeita componentes vazios', () {
      expect(
        () => FirestoreEscalaExecucaoRepository.gerarIdExecucao(
          atividadeId: '',
          usuarioId: 'uid-1',
        ),
        throwsArgumentError,
      );
      expect(
        () => FirestoreEscalaExecucaoRepository.gerarIdExecucao(
          atividadeId: 'atividade-1',
          usuarioId: '   ',
        ),
        throwsArgumentError,
      );
    });
  });
}

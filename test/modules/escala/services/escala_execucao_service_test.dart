import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/escala/models/escala_models.dart';
import 'package:geduc_rae_mobile/modules/escala/services/escala_execucao_service.dart';

void main() {
  final agora = DateTime.utc(2026, 9, 18, 14);

  MissaoEvidenciaModel evidencia({
    String id = 'ev-1',
    String tipo = EscalaCodigos.evidenciaDocumento,
    String descricao = 'Relatório',
    String referencia = 'ref-1',
    String criadoPor = 'agente',
  }) {
    return MissaoEvidenciaModel(
      id: id,
      tipo: tipo,
      descricao: descricao,
      referencia: referencia,
      criadoPor: criadoPor,
      criadoEm: agora,
    );
  }

  ExecucaoMissaoModel execucao({
    String status = EscalaCodigos.execucaoEmExecucao,
    String resultado = '',
    DateTime? concluidoEm,
    List<MissaoEvidenciaModel> evidencias = const [],
  }) {
    return ExecucaoMissaoModel(
      id: 'atividade-admin__agente',
      escalaAtividadeId: 'atividade-admin',
      escalaId: 'escala-publicada',
      data: DateTime.utc(2026, 9, 18),
      status: status,
      resultadoResumo: resultado,
      observacao: '',
      evidencias: evidencias,
      executadoPorUsuarioId: 'agente',
      executadoPorMembroEquipeId: 'membro-agente',
      executadoPorNomeSnapshot: 'Agente',
      concluidoEm: concluidoEm,
      criadoEm: agora,
      atualizadoEm: agora,
    );
  }

  group('EscalaExecucaoService ESC-001E.1', () {
    test('aceita execução em andamento válida', () {
      expect(EscalaExecucaoService.validar(execucao()).valida, isTrue);
    });

    test('conclusão exige resultado e concluidoEm', () {
      final invalida = execucao(
        status: EscalaCodigos.execucaoConcluida,
      );

      expect(EscalaExecucaoService.validar(invalida).valida, isFalse);

      final valida = execucao(
        status: EscalaCodigos.execucaoConcluida,
        resultado: 'Dados consolidados e entregues.',
        concluidoEm: agora,
      );

      expect(EscalaExecucaoService.validar(valida).valida, isTrue);
    });

    test('tipa evidência e exige autoria do executor', () {
      expect(
        EscalaExecucaoService.validar(
          execucao(evidencias: [evidencia()]),
        ).valida,
        isTrue,
      );

      expect(
        EscalaExecucaoService.validar(
          execucao(
            evidencias: [
              evidencia(
                tipo: 'binario_desconhecido',
                criadoPor: 'outro',
              ),
            ],
          ),
        ).valida,
        isFalse,
      );
    });

    test('limita evidências a vinte itens', () {
      final itens = List<MissaoEvidenciaModel>.generate(
        21,
        (index) => evidencia(id: 'ev-$index'),
      );

      expect(
        EscalaExecucaoService.validar(
          execucao(evidencias: itens),
        ).valida,
        isFalse,
      );
    });

    test('terminal não reabre pelo lifecycle do domínio', () {
      expect(
        EscalaExecucaoService.transicaoStatusValida(
          statusAtual: EscalaCodigos.execucaoEmExecucao,
          proximoStatus: EscalaCodigos.execucaoConcluida,
        ),
        isTrue,
      );
      expect(
        EscalaExecucaoService.transicaoStatusValida(
          statusAtual: EscalaCodigos.execucaoConcluida,
          proximoStatus: EscalaCodigos.execucaoEmExecucao,
        ),
        isFalse,
      );
      expect(
        EscalaExecucaoService.transicaoStatusValida(
          statusAtual: EscalaCodigos.execucaoCancelada,
          proximoStatus: EscalaCodigos.execucaoEmExecucao,
        ),
        isFalse,
      );
    });
  });
}

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/escala/data/escala_repository.dart';
import 'package:geduc_rae_mobile/modules/escala/models/escala_models.dart';
import 'package:geduc_rae_mobile/modules/escala/services/escala_pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('gera PDF oficial da versão publicada com fontes Unicode', () async {
    final mensagens = <String>[];
    final dia = _diaPublicado();

    final bytes = await runZoned(
      () => EscalaPdfService().gerarBytes(dia),
      zoneSpecification: ZoneSpecification(
        print: (_, parent, zone, line) => mensagens.add(line),
      ),
    );

    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    expect(bytes.length, greaterThan(10000));
    expect(
      mensagens.where(
        (item) =>
            item.toLowerCase().contains('unicode support') ||
            item.toLowerCase().contains('helvetica'),
      ),
      isEmpty,
    );
  });

  test('nome do arquivo identifica data e versão publicada', () {
    expect(
      EscalaPdfService().nomeArquivo(_diaPublicado()),
      'Escala_GEDUC_2026-09-23_v4.pdf',
    );
  });

  test('bloqueia PDF oficial de escala não publicada', () async {
    final rascunho = _diaPublicado(
      status: EscalaCodigos.statusRascunho,
    );

    await expectLater(
      EscalaPdfService().gerarBytes(rascunho),
      throwsA(
        isA<StateError>().having(
          (erro) => erro.message,
          'message',
          contains('escala publicada'),
        ),
      ),
    );
  });
}

EscalaDiaConsulta _diaPublicado({
  String status = EscalaCodigos.statusPublicada,
}) {
  final data = DateTime(2026, 9, 23);
  final agora = DateTime(2026, 9, 22, 16, 30);
  return EscalaDiaConsulta(
    data: data,
    escala: EscalaModel(
      id: '2026-09-23',
      data: data,
      status: status,
      versao: 4,
      observacaoGeral: 'Atenção à sinalização e à segurança da equipe.',
      motivoRevisao: 'Ajuste de equipe',
      criadoPor: 'responsavel',
      criadoEm: agora,
      atualizadoPor: 'gerente',
      atualizadoEm: agora,
      publicadoPor: status == EscalaCodigos.statusPublicada ? 'gerente' : '',
      publicadoEm: status == EscalaCodigos.statusPublicada ? agora : null,
    ),
    atividades: [
      EscalaAtividadeModel(
        id: 'atividade-1',
        escalaId: '2026-09-23',
        data: data,
        secaoId: 'comandos',
        tipoAtividadeId: 'comando_educativo',
        naturezaAtividade: EscalaCodigos.naturezaEducativa,
        titulo: 'Educação e proteção no trânsito',
        descricao: 'Ação educativa com motociclistas.',
        turnoId: 'manha',
        qtrHorario: '08:00–12:00',
        horaInicio: '08:00',
        horaFim: '12:00',
        qthLocal: 'Praça José de Alencar',
        qthEndereco: 'Centro, Fortaleza',
        qthRegionalId: 'regional-centro',
        qthPontoReferencia: 'Próximo à estação',
        orientacaoOperacional: 'Usar colete e material educativo.',
        coordenadorMembroEquipeId: 'membro-coordenador',
        coordenadorUsuarioId: 'uid-coordenador',
        coordenadorNomeSnapshot: 'João Gonçalves',
        participanteUsuarioIds: const ['uid-agente'],
        geraRae: true,
        contabilizaProdutividade: true,
        raeId: '',
        execucaoMissaoId: '',
        status: EscalaCodigos.atividadePublicada,
        criadoPor: 'responsavel',
        criadoEm: agora,
        atualizadoPor: 'gerente',
        atualizadoEm: agora,
      ),
    ],
    alocacoes: [
      EscalaAlocacaoModel(
        id: 'alocacao-1',
        escalaId: '2026-09-23',
        atividadeId: 'atividade-1',
        data: data,
        membroEquipeId: 'membro-agente',
        usuarioId: 'uid-agente',
        nomeSnapshot: 'Maria da Conceição',
        vinculoSnapshot: 'agente',
        setorSnapshot: 'GEDUC',
        cargaHorariaSnapshot: '180H',
        funcaoNaAtividade: 'equipe',
        turnoId: 'manha',
        horaInicio: '08:00',
        horaFim: '12:00',
        tipoJornada: EscalaCodigos.jornadaBancoHoras,
        horaInicioReal: '08:15',
        horaFimReal: '11:45',
        minutosPrevistos: 240,
        minutosRealizados: 210,
        motivoJornadaComplementar: 'Convocação operacional',
        classificadoPor: 'gerente',
        classificadoEm: agora,
        observacao: 'Registro posterior que não integra o PDF oficial.',
        criadoPor: 'responsavel',
        criadoEm: agora,
        atualizadoPor: 'uid-agente',
        atualizadoEm: agora,
      ),
    ],
    indisponibilidades: [
      EscalaIndisponibilidadeModel(
        id: 'indisponibilidade-1',
        dataInicio: data,
        dataFim: data,
        membroEquipeId: 'membro-ferias',
        usuarioId: 'uid-ferias',
        nomeSnapshot: 'Agente em Férias',
        tipoId: 'ferias',
        turnoId: '',
        horaInicio: '',
        horaFim: '',
        observacao: 'Período previamente registrado.',
        criadoPor: 'responsavel',
        criadoEm: agora,
        atualizadoPor: 'responsavel',
        atualizadoEm: agora,
      ),
    ],
  );
}

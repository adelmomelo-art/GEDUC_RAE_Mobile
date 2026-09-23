import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/escala/data/escala_repository.dart';
import 'package:geduc_rae_mobile/modules/escala/models/escala_models.dart';
import 'package:geduc_rae_mobile/modules/escala/services/escala_indicadores_historicos_service.dart';

void main() {
  group('EscalaIndicadoresHistoricosService ESC-001H.1', () {
    test('consolida horas por natureza e saldo de banco por pessoa', () {
      final resumo = EscalaIndicadoresHistoricosService.consolidar(
        inicio: DateTime(2026, 9, 1, 18),
        fim: DateTime(2026, 9, 30, 6),
        dias: [
          _dia(
            DateTime(2026, 9, 10),
            alocacoes: [
              _alocacao(
                id: 'normal',
                usuarioId: 'uid-1',
                membroEquipeId: 'membro-1',
                nome: 'Ana',
                inicioReal: '08:00',
                fimReal: '09:00',
                minutosRealizados: 60,
              ),
              _alocacao(
                id: 'extra',
                usuarioId: 'uid-2',
                membroEquipeId: 'membro-2',
                nome: 'Bruno',
                tipo: EscalaCodigos.jornadaHoraExtra,
                inicioReal: '18:00',
                fimReal: '20:00',
                minutosRealizados: 120,
              ),
              _alocacao(
                id: 'banco',
                usuarioId: 'uid-1',
                membroEquipeId: 'membro-1',
                nome: 'Ana',
                tipo: EscalaCodigos.jornadaBancoHoras,
                inicioReal: '09:00',
                fimReal: '12:00',
                minutosRealizados: 180,
              ),
            ],
            indisponibilidades: [
              _indisponibilidade(
                id: 'compensacao',
                usuarioId: 'uid-1',
                membroEquipeId: 'membro-1',
                nome: 'Ana',
                tipo: 'compensacao',
                inicio: '13:00',
                fim: '14:00',
              ),
            ],
          ),
        ],
      );

      expect(resumo.inicio, DateTime(2026, 9, 1));
      expect(resumo.fim, DateTime(2026, 9, 30));
      expect(resumo.diasPublicados, 1);
      expect(resumo.totalAlocacoes, 3);
      expect(resumo.alocacoesComHorasRealizadas, 3);
      expect(resumo.alocacoesSemHorasRealizadas, 0);
      expect(resumo.alocacoesHorasInvalidas, 0);
      expect(resumo.minutosPlanejados, 360);
      expect(resumo.minutosRealizadosNormal, 60);
      expect(resumo.minutosRealizadosHoraExtra, 120);
      expect(resumo.minutosCreditoBanco, 180);
      expect(resumo.totalMinutosRealizados, 360);
      expect(resumo.minutosCompensadosBanco, 60);
      expect(resumo.saldoBancoMinutos, 120);
      expect(resumo.compensacoesComHoras, 1);
      expect(resumo.possuiPendencias, isFalse);

      expect(resumo.pessoas, hasLength(1));
      final pessoa = resumo.pessoas.single;
      expect(pessoa.chavePessoa, 'uid:uid-1');
      expect(pessoa.nome, 'Ana');
      expect(pessoa.minutosCredito, 180);
      expect(pessoa.minutosCompensados, 60);
      expect(pessoa.saldoMinutos, 120);
      expect(pessoa.saldoNegativo, isFalse);
      expect(pessoa.possuiPendencia, isFalse);
    });

    test('ignora rascunhos e dias fora do periodo', () {
      final resumo = EscalaIndicadoresHistoricosService.consolidar(
        inicio: DateTime(2026, 9, 1),
        fim: DateTime(2026, 9, 30),
        dias: [
          _dia(
            DateTime(2026, 9, 5),
            publicada: false,
            alocacoes: [_creditoBanco('rascunho')],
          ),
          _dia(
            DateTime(2026, 8, 31),
            alocacoes: [_creditoBanco('fora')],
          ),
          _dia(
            DateTime(2026, 9, 15),
            alocacoes: [_creditoBanco('valido')],
          ),
        ],
      );

      expect(resumo.diasPublicados, 1);
      expect(resumo.totalAlocacoes, 1);
      expect(resumo.minutosCreditoBanco, 120);
      expect(resumo.pessoas.single.usuarioId, 'uid-valido');
    });

    test('mantem registros incompletos ou invalidos como pendencias', () {
      final resumo = EscalaIndicadoresHistoricosService.consolidar(
        inicio: DateTime(2026, 9, 1),
        fim: DateTime(2026, 9, 30),
        dias: [
          _dia(
            DateTime(2026, 9, 12),
            alocacoes: [
              _alocacao(
                id: 'credito-sem-horas',
                usuarioId: 'uid-1',
                membroEquipeId: 'membro-1',
                nome: 'Ana',
                tipo: EscalaCodigos.jornadaBancoHoras,
              ),
              _alocacao(
                id: 'credito-invalido',
                usuarioId: 'uid-1',
                membroEquipeId: 'membro-1',
                nome: 'Ana',
                tipo: EscalaCodigos.jornadaBancoHoras,
                inicioReal: '08:00',
                fimReal: '',
                minutosRealizados: 60,
              ),
              _alocacao(
                id: 'credito-sem-identidade',
                usuarioId: '',
                membroEquipeId: '',
                nome: 'Sem cadastro',
                tipo: EscalaCodigos.jornadaBancoHoras,
                inicioReal: '08:00',
                fimReal: '09:00',
                minutosRealizados: 60,
              ),
            ],
            indisponibilidades: [
              _indisponibilidade(
                id: 'compensacao-sem-horas',
                usuarioId: 'uid-1',
                membroEquipeId: 'membro-1',
                nome: 'Ana',
                tipo: 'compensacao',
              ),
              _indisponibilidade(
                id: 'compensacao-invalida',
                usuarioId: 'uid-1',
                membroEquipeId: 'membro-1',
                nome: 'Ana',
                tipo: 'COMPENSACAO',
                inicio: 'xx',
                fim: '10:00',
              ),
              _indisponibilidade(
                id: 'compensacao-sem-identidade',
                usuarioId: '',
                membroEquipeId: '',
                nome: '',
                tipo: 'compensacao',
                inicio: '10:00',
                fim: '11:00',
              ),
              _indisponibilidade(
                id: 'ferias-ignorada',
                usuarioId: 'uid-2',
                membroEquipeId: 'membro-2',
                nome: 'Bruno',
                tipo: 'ferias',
                inicio: '08:00',
                fim: '18:00',
              ),
            ],
          ),
        ],
      );

      expect(resumo.alocacoesComHorasRealizadas, 1);
      expect(resumo.alocacoesSemHorasRealizadas, 1);
      expect(resumo.alocacoesHorasInvalidas, 1);
      expect(resumo.minutosCreditoBanco, 0);
      expect(resumo.compensacoesComHoras, 0);
      expect(resumo.compensacoesSemHoras, 1);
      expect(resumo.compensacoesInvalidas, 2);
      expect(resumo.registrosSemIdentidade, 2);
      expect(resumo.possuiPendencias, isTrue);

      final pessoa = resumo.pessoas.single;
      expect(pessoa.creditosPendentes, 2);
      expect(pessoa.compensacoesPendentes, 2);
      expect(pessoa.possuiPendencia, isTrue);
    });

    test('reconcilia usuario e membro sem duplicar o saldo', () {
      final resumo = EscalaIndicadoresHistoricosService.consolidar(
        inicio: DateTime(2026, 9, 1),
        fim: DateTime(2026, 9, 30),
        dias: [
          _dia(
            DateTime(2026, 9, 1),
            alocacoes: [
              _creditoBanco(
                'membro-primeiro',
                usuarioId: '',
                membroEquipeId: 'membro-1',
                minutos: 120,
              ),
            ],
          ),
          _dia(
            DateTime(2026, 9, 2),
            alocacoes: [
              _creditoBanco(
                'usuario-primeiro',
                usuarioId: 'uid-1',
                membroEquipeId: '',
                minutos: 60,
              ),
              _creditoBanco(
                'ponte-identidade',
                usuarioId: 'uid-1',
                membroEquipeId: 'membro-1',
                minutos: 30,
              ),
            ],
            indisponibilidades: [
              _indisponibilidade(
                id: 'debito',
                usuarioId: 'uid-1',
                membroEquipeId: '',
                nome: 'Ana',
                tipo: 'compensacao',
                inicio: '13:00',
                fim: '14:00',
              ),
            ],
          ),
        ],
      );

      expect(resumo.pessoas, hasLength(1));
      final pessoa = resumo.pessoas.single;
      expect(pessoa.chavePessoa, 'uid:uid-1');
      expect(pessoa.usuarioId, 'uid-1');
      expect(pessoa.membroEquipeId, 'membro-1');
      expect(pessoa.minutosCredito, 210);
      expect(pessoa.minutosCompensados, 60);
      expect(pessoa.saldoMinutos, 150);
    });

    test('mantem pessoas distintas mesmo quando possuem o mesmo nome', () {
      final resumo = EscalaIndicadoresHistoricosService.consolidar(
        inicio: DateTime(2026, 9, 1),
        fim: DateTime(2026, 9, 30),
        dias: [
          _dia(
            DateTime(2026, 9, 3),
            alocacoes: [
              _creditoBanco('a', usuarioId: 'uid-a', nome: 'Agente'),
              _creditoBanco('b', usuarioId: 'uid-b', nome: 'Agente'),
            ],
          ),
        ],
      );

      expect(resumo.pessoas, hasLength(2));
      expect(
        resumo.pessoas.map((item) => item.chavePessoa),
        ['uid:uid-a', 'uid:uid-b'],
      );
      expect(
        () => resumo.pessoas.add(resumo.pessoas.first),
        throwsUnsupportedError,
      );
    });

    test('rejeita periodo invertido e dia publicado duplicado', () {
      expect(
        () => EscalaIndicadoresHistoricosService.consolidar(
          inicio: DateTime(2026, 9, 30),
          fim: DateTime(2026, 9, 1),
          dias: const [],
        ),
        throwsArgumentError,
      );

      expect(
        () => EscalaIndicadoresHistoricosService.consolidar(
          inicio: DateTime(2026, 9, 1),
          fim: DateTime(2026, 9, 30),
          dias: [
            _dia(DateTime(2026, 9, 5)),
            _dia(DateTime(2026, 9, 5, 18)),
          ],
        ),
        throwsStateError,
      );
    });
  });
}

EscalaDiaConsulta _dia(
  DateTime data, {
  bool publicada = true,
  List<EscalaAlocacaoModel> alocacoes = const [],
  List<EscalaIndisponibilidadeModel> indisponibilidades = const [],
}) {
  final agora = DateTime(2026, 9, 1, 8);
  return EscalaDiaConsulta(
    data: data,
    escala: EscalaModel(
      id: _dataId(data),
      data: data,
      status: publicada
          ? EscalaCodigos.statusPublicada
          : EscalaCodigos.statusRascunho,
      versao: publicada ? 1 : 0,
      observacaoGeral: '',
      motivoRevisao: '',
      criadoPor: 'responsavel',
      criadoEm: agora,
      atualizadoPor: 'responsavel',
      atualizadoEm: agora,
      publicadoPor: publicada ? 'responsavel' : '',
      publicadoEm: publicada ? agora : null,
    ),
    atividades: const [],
    alocacoes: alocacoes,
    indisponibilidades: indisponibilidades,
  );
}

EscalaAlocacaoModel _creditoBanco(
  String id, {
  String? usuarioId,
  String? membroEquipeId,
  String nome = 'Agente',
  int minutos = 120,
}) {
  const inicioMinutos = 8 * 60;
  final fimMinutos = inicioMinutos + minutos;
  final inicio = _horario(inicioMinutos);
  final fim = _horario(fimMinutos);
  return _alocacao(
    id: id,
    usuarioId: usuarioId ?? 'uid-$id',
    membroEquipeId: membroEquipeId ?? 'membro-$id',
    nome: nome,
    tipo: EscalaCodigos.jornadaBancoHoras,
    inicioReal: inicio,
    fimReal: fim,
    minutosRealizados: minutos,
  );
}

EscalaAlocacaoModel _alocacao({
  required String id,
  required String usuarioId,
  required String membroEquipeId,
  required String nome,
  String tipo = EscalaCodigos.jornadaNormal,
  String inicioReal = '',
  String fimReal = '',
  int? minutosRealizados,
}) {
  final data = DateTime(2026, 9, 1);
  final agora = DateTime(2026, 9, 1, 8);
  return EscalaAlocacaoModel(
    id: id,
    escalaId: '2026-09-01',
    atividadeId: 'atividade-$id',
    data: data,
    membroEquipeId: membroEquipeId,
    usuarioId: usuarioId,
    nomeSnapshot: nome,
    vinculoSnapshot: 'agente',
    setorSnapshot: 'GEDUC',
    cargaHorariaSnapshot: '180H',
    funcaoNaAtividade: 'equipe',
    turnoId: 'manha',
    horaInicio: '08:00',
    horaFim: '10:00',
    tipoJornada: tipo,
    horaInicioReal: inicioReal,
    horaFimReal: fimReal,
    minutosPrevistos: 120,
    minutosRealizados: minutosRealizados,
    motivoJornadaComplementar:
        tipo == EscalaCodigos.jornadaNormal ? '' : 'Necessidade operacional',
    classificadoPor: tipo == EscalaCodigos.jornadaNormal ? '' : 'responsavel',
    classificadoEm: tipo == EscalaCodigos.jornadaNormal ? null : agora,
    observacao: '',
    criadoPor: 'responsavel',
    criadoEm: agora,
    atualizadoPor: usuarioId,
    atualizadoEm: agora,
  );
}

EscalaIndisponibilidadeModel _indisponibilidade({
  required String id,
  required String usuarioId,
  required String membroEquipeId,
  required String nome,
  required String tipo,
  String inicio = '',
  String fim = '',
}) {
  final data = DateTime(2026, 9, 1);
  final agora = DateTime(2026, 9, 1, 8);
  return EscalaIndisponibilidadeModel(
    id: id,
    dataInicio: data,
    dataFim: data,
    membroEquipeId: membroEquipeId,
    usuarioId: usuarioId,
    nomeSnapshot: nome,
    tipoId: tipo,
    turnoId: '',
    horaInicio: inicio,
    horaFim: fim,
    observacao: '',
    criadoPor: 'responsavel',
    criadoEm: agora,
    atualizadoPor: 'responsavel',
    atualizadoEm: agora,
  );
}

String _dataId(DateTime data) => '${data.year.toString().padLeft(4, '0')}-'
    '${data.month.toString().padLeft(2, '0')}-'
    '${data.day.toString().padLeft(2, '0')}';

String _horario(int minutos) => '${(minutos ~/ 60).toString().padLeft(2, '0')}:'
    '${(minutos % 60).toString().padLeft(2, '0')}';

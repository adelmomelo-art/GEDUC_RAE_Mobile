import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/data/models/projeto_model.dart';
import 'package:geduc_rae_mobile/data/models/regional_model.dart';
import 'package:geduc_rae_mobile/modules/agenda/controllers/agenda_controller.dart';
import 'package:geduc_rae_mobile/modules/agenda/data/agenda_repository.dart';
import 'package:geduc_rae_mobile/modules/agenda/models/agenda_compromisso.dart';
import 'package:geduc_rae_mobile/modules/escala/models/escala_models.dart';

class AgendaFake implements AgendaRepository {
  int leituras = 0, escritas = 0;
  int cancelamentos = 0;
  String? ultimoMotivo;
  Completer<void>? espera;
  final data = DateTime(2026, 10, 5);
  @override
  Future<EscalaConfiguracaoModel?> configuracao() async =>
      EscalaConfiguracaoModel(
          id: 'principal',
          responsavelEscalaUsuarioId: 'responsavel',
          responsavelEscalaMembroEquipeId: 'membro',
          ativo: true,
          designadoPor: 'admin',
          designadoEm: data);
  @override
  Future<AgendaMes> carregarMes(DateTime mes) async {
    leituras++;
    return AgendaMes(compromissos: [
      AgendaCompromisso(
          id: 'a', data: data, titulo: 'Palestra', turno: 'manha'),
      AgendaCompromisso(
          id: 'b', data: data, titulo: 'Travessia', turno: 'tarde')
    ], escalas: {}, atividades: {});
  }

  @override
  Future<List<ProjetoModel>> projetos() async => [];
  @override
  Future<List<RegionalModel>> regionais() async => [];
  @override
  String novoId() => 'novo';
  @override
  Future<void> salvar(AgendaCompromisso item,
      {required int revisaoEsperada, required String usuarioId}) async {
    escritas++;
    if (espera != null) await espera!.future;
  }

  @override
  Future<void> cancelar(AgendaCompromisso item,
      {required String motivo, required String usuarioId}) async {
    cancelamentos++;
    ultimoMotivo = motivo;
  }

  @override
  Future<void> montarEscala(AgendaCompromisso item,
      {required String usuarioId}) async {}
  @override
  Future<List<AgendaHistorico>> historico(String id) async => [];
}

void main() {
  test('nega acesso antes de ler compromissos privados', () async {
    final repo = AgendaFake();
    final controller = AgendaController(
        repository: repo, usuarioId: 'agente', perfilAcesso: 'agente');
    await controller.carregar();
    expect(controller.autorizado, isFalse);
    expect(repo.leituras, 0);
    expect(controller.dados, isNull);
    controller.dispose();
  });
  test('filtros e dia selecionado preservam a visão mensal', () async {
    final repo = AgendaFake();
    final c = AgendaController(
        repository: repo,
        usuarioId: 'responsavel',
        perfilAcesso: 'agente',
        dataInicial: repo.data);
    await c.carregar();
    expect(c.doDia, hasLength(2));
    c.filtrar(turno: 'tarde');
    expect(c.doDia.single.titulo, 'Travessia');
    c.filtrar(turno: '', texto: 'palestra');
    expect(c.doDia.single.id, 'a');
    await c.outroMes(1);
    expect(c.mes, DateTime(2026, 11));
    expect(c.doDia, isEmpty);
    c.dispose();
  });
  test('evita duplo envio e notificação após dispose durante gravação',
      () async {
    final repo = AgendaFake();
    final c = AgendaController(
        repository: repo,
        usuarioId: 'responsavel',
        perfilAcesso: 'agente',
        dataInicial: repo.data);
    await c.carregar();
    repo.espera = Completer<void>();
    final salvamento = c.salvar(c.doDia.first);
    await expectLater(c.salvar(c.doDia.first), throwsStateError);
    c.dispose();
    repo.espera!.complete();
    await salvamento;
    expect(repo.escritas, 1);
  });
}

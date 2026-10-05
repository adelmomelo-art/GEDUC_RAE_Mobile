import 'package:flutter/foundation.dart';

import '../../../data/models/projeto_model.dart';
import '../../../data/models/regional_model.dart';
import '../data/agenda_repository.dart';
import '../models/agenda_compromisso.dart';
import '../security/agenda_access_policy.dart';
import '../services/agenda_service.dart';

class AgendaController extends ChangeNotifier {
  AgendaController({
    required this.repository,
    required this.usuarioId,
    required this.perfilAcesso,
    DateTime? dataInicial,
  }) : diaSelecionado = dataInicial ?? DateTime.now();
  final AgendaRepository repository;
  final String usuarioId, perfilAcesso;
  DateTime diaSelecionado;
  String filtroTurno = '', filtroSituacao = '', pesquisa = '';
  bool carregando = false, salvando = false, autorizado = false;
  String? erro;
  AgendaMes? dados;
  List<ProjetoModel> projetos = [];
  List<RegionalModel> regionais = [];
  int _geracao = 0;
  bool _descartado = false;

  DateTime get mes => DateTime(diaSelecionado.year, diaSelecionado.month);
  List<AgendaCompromisso> get filtrados =>
      (dados?.compromissos ?? []).where((item) {
        final situacao = AgendaService.situacaoExibida(
          item,
          dados?.escalas[item.id],
        );
        return (filtroTurno.isEmpty || filtroTurno == item.turno) &&
            (filtroSituacao.isEmpty || filtroSituacao == situacao) &&
            (pesquisa.isEmpty ||
                '${item.titulo} ${item.instituicao} ${item.local}'
                    .toLowerCase()
                    .contains(pesquisa.toLowerCase()));
      }).toList();
  List<AgendaCompromisso> get doDia => filtrados
      .where(
        (item) =>
            AgendaService.dataId(item.data) ==
            AgendaService.dataId(diaSelecionado),
      )
      .toList();
  bool pendente(AgendaCompromisso item) =>
      item.vinculada &&
      !item.cancelada &&
      dados?.atividades[item.id]?.agendaRevisao != item.revisao;

  Future<void> carregar() async {
    if (_descartado) return;
    final geracao = ++_geracao;
    carregando = true;
    erro = null;
    autorizado = false;
    dados = null;
    _notificar();
    try {
      final config = await repository.configuracao();
      if (_descartado || geracao != _geracao) return;
      if (!AgendaAccessPolicy.autoriza(
        usuarioId: usuarioId,
        perfilAcesso: perfilAcesso,
        configuracao: config,
      )) {
        throw StateError('Agenda restrita ao responsável ativo pela escala.');
      }
      autorizado = true;
      final mesDados = await repository.carregarMes(mes);
      final catalogo = await repository.projetos();
      final listaRegionais = await repository.regionais();
      if (_descartado || geracao != _geracao) return;
      dados = mesDados;
      projetos = catalogo;
      regionais = listaRegionais;
    } catch (e) {
      if (!_descartado && geracao == _geracao) erro = _mensagem(e);
    } finally {
      if (!_descartado && geracao == _geracao) {
        carregando = false;
        _notificar();
      }
    }
  }

  Future<void> outroMes(int delta) async {
    if (salvando) return;
    diaSelecionado = DateTime(mes.year, mes.month + delta);
    await carregar();
  }

  void selecionarDia(DateTime dia) {
    diaSelecionado = dia;
    _notificar();
  }

  void filtrar({String? turno, String? situacao, String? texto}) {
    filtroTurno = turno ?? filtroTurno;
    filtroSituacao = situacao ?? filtroSituacao;
    pesquisa = texto ?? pesquisa;
    _notificar();
  }

  Future<void> salvar(AgendaCompromisso item) => _executar(
        () => repository.salvar(
          item,
          revisaoEsperada: item.revisao,
          usuarioId: usuarioId,
        ),
      );
  Future<void> cancelar(AgendaCompromisso item, String motivo) => _executar(
        () => repository.cancelar(item, motivo: motivo, usuarioId: usuarioId),
      );
  Future<void> montarEscala(AgendaCompromisso item) =>
      _executar(() => repository.montarEscala(item, usuarioId: usuarioId));
  Future<void> pronta(AgendaCompromisso item) async {
    final proxima = item.alterar({'situacao': 'pronta'});
    final erros = AgendaService.validar(proxima, paraEscala: true);
    if (erros.isNotEmpty) throw StateError(erros.join('\n'));
    await salvar(proxima);
  }

  Future<void> _executar(Future<void> Function() acao) async {
    if (!autorizado || salvando || carregando) {
      throw StateError('A agenda não está disponível para alteração.');
    }
    salvando = true;
    erro = null;
    _notificar();
    try {
      await acao();
      await carregar();
    } catch (e) {
      erro = _mensagem(e);
      rethrow;
    } finally {
      salvando = false;
      _notificar();
    }
  }

  String _mensagem(Object e) => e is StateError
      ? e.message.toString()
      : 'Não foi possível concluir a operação. Verifique a conexão e tente novamente.';
  void _notificar() {
    if (!_descartado) notifyListeners();
  }

  @override
  void dispose() {
    _descartado = true;
    ++_geracao;
    super.dispose();
  }
}

import 'package:flutter/foundation.dart';

import '../data/escala_repository.dart';
import '../models/escala_models.dart';
import '../security/escala_access_policy.dart';
import '../security/escala_permission.dart';
import '../services/escala_conflito_service.dart';
import '../services/escala_horas_service.dart';

class EscalaConsultaController extends ChangeNotifier {
  EscalaConsultaController({
    required EscalaRepository repository,
    required String usuarioId,
    String perfilAcesso = '',
    DateTime? dataInicial,
    bool iniciarMinhaEscala = false,
    DateTime Function()? agora,
  })  : _repository = repository,
        _usuarioId = usuarioId.trim(),
        _perfilAcesso = perfilAcesso.trim(),
        _dataSelecionada = _somenteData(dataInicial ?? DateTime.now()),
        _minhaEscala = iniciarMinhaEscala,
        _agora = agora ?? DateTime.now;

  final EscalaRepository _repository;
  final String _usuarioId;
  final String _perfilAcesso;
  final DateTime Function() _agora;

  DateTime _dataSelecionada;
  bool _minhaEscala;
  bool _carregando = false;
  bool _salvandoHoras = false;
  Object? _erro;
  EscalaDiaConsulta? _dia;
  int _geracaoCarregamento = 0;

  DateTime get dataSelecionada => _dataSelecionada;
  bool get minhaEscala => _minhaEscala;
  bool get carregando => _carregando;
  bool get salvandoHoras => _salvandoHoras;
  Object? get erro => _erro;
  EscalaDiaConsulta? get dia => _dia;
  String get usuarioId => _usuarioId;
  String get perfilAcesso => _perfilAcesso;

  bool get escalaEncontrada => _dia?.encontrada == true;
  bool get escalaPublicada => _dia?.publicada == true;
  EscalaModel? get escala => _dia?.escala;

  List<EscalaAtividadeModel> get atividadesVisiveis {
    final atual = _dia;
    if (atual == null || !atual.publicada) {
      return const <EscalaAtividadeModel>[];
    }

    if (!_minhaEscala) return atual.atividades;
    if (_usuarioId.isEmpty) return const <EscalaAtividadeModel>[];

    final idsAlocados = atual.alocacoes
        .where((item) => item.usuarioId.trim() == _usuarioId)
        .map((item) => item.atividadeId)
        .toSet();

    return List<EscalaAtividadeModel>.unmodifiable(
      atual.atividades.where((atividade) {
        if (atividade.coordenadorUsuarioId.trim() == _usuarioId) return true;
        if (atividade.participanteUsuarioIds.contains(_usuarioId)) return true;
        return idsAlocados.contains(atividade.id);
      }),
    );
  }

  List<EscalaAlocacaoModel> get alocacoesDoModoAtual {
    final atual = _dia;
    if (atual == null || !atual.publicada) {
      return const <EscalaAlocacaoModel>[];
    }

    if (!_minhaEscala) return atual.alocacoes;
    if (_usuarioId.isEmpty) return const <EscalaAlocacaoModel>[];

    return List<EscalaAlocacaoModel>.unmodifiable(
      atual.alocacoes.where((item) => item.usuarioId.trim() == _usuarioId),
    );
  }

  List<EscalaIndisponibilidadeModel> get indisponibilidadesVisiveis {
    final atual = _dia;
    if (atual == null || !atual.publicada) {
      return const <EscalaIndisponibilidadeModel>[];
    }

    if (!_minhaEscala) return atual.indisponibilidades;
    if (_usuarioId.isEmpty) {
      return const <EscalaIndisponibilidadeModel>[];
    }

    return List<EscalaIndisponibilidadeModel>.unmodifiable(
      atual.indisponibilidades.where(
        (item) => item.usuarioId.trim() == _usuarioId,
      ),
    );
  }

  EscalaHorasResumo get resumoHoras =>
      EscalaHorasService.resumir(alocacoesDoModoAtual);

  EscalaHorasRealizadasResumo get resumoHorasRealizadas =>
      EscalaHorasService.resumirRealizadas(alocacoesDoModoAtual);

  List<EscalaConflitoHorario> get conflitosSobreposicao =>
      EscalaConflitoService.detectarSobreposicoes(alocacoesDoModoAtual);

  List<EscalaMultiplaAlocacao> get multiplasAlocacoes =>
      EscalaConflitoService.detectarMultiplasAlocacoes(alocacoesDoModoAtual);

  List<EscalaAlocacaoModel> alocacoesDaAtividade(String atividadeId) {
    final atual = _dia;
    if (atual == null || !atual.publicada) {
      return const <EscalaAlocacaoModel>[];
    }

    return List<EscalaAlocacaoModel>.unmodifiable(
      atual.alocacoes.where((item) => item.atividadeId == atividadeId),
    );
  }

  EscalaAlocacaoModel? alocacaoPropriaDaAtividade(String atividadeId) {
    final id = atividadeId.trim();
    if (id.isEmpty || _usuarioId.isEmpty) return null;

    for (final item in alocacoesDaAtividade(id)) {
      if (item.usuarioId.trim() == _usuarioId) return item;
    }
    return null;
  }

  bool podeRegistrarHoras(EscalaAlocacaoModel alocacao) {
    return escalaPublicada &&
        alocacao.usuarioId.trim() == _usuarioId &&
        EscalaAccessPolicy.autoriza(
          perfilAcesso: _perfilAcesso,
          usuarioId: _usuarioId,
          responsavelEscalaUsuarioId: '',
          permissao: EscalaPermission.registrarHorasRealizadas,
          ehParticipanteAtividade: true,
        );
  }

  Future<void> registrarHorasRealizadas({
    required String alocacaoId,
    required String horaInicioReal,
    required String horaFimReal,
    required String observacao,
  }) async {
    if (_salvandoHoras) {
      throw StateError('Já existe um registro de horas em andamento.');
    }

    final dia = _dia;
    if (dia == null || !dia.publicada) {
      throw StateError('Horas realizadas exigem escala publicada.');
    }

    EscalaAlocacaoModel? alocacao;
    for (final item in dia.alocacoes) {
      if (item.id == alocacaoId.trim()) {
        alocacao = item;
        break;
      }
    }
    if (alocacao == null || !podeRegistrarHoras(alocacao)) {
      throw StateError('Somente o titular registra as próprias horas.');
    }

    final inicio = horaInicioReal.trim();
    final fim = horaFimReal.trim();
    final minutos = EscalaHorasService.calcularDuracaoMinutos(
      inicio: inicio,
      fim: fim,
    );
    if (minutos == null || minutos < 0 || minutos > 1440) {
      throw StateError('Informe início e fim reais no formato HH:mm.');
    }

    final instante = _agora();
    _salvandoHoras = true;
    notifyListeners();

    try {
      await _repository.salvarHorasRealizadas(
        alocacaoId: alocacao.id,
        usuarioId: _usuarioId,
        horaInicioReal: inicio,
        horaFimReal: fim,
        minutosRealizados: minutos,
        observacao: observacao,
        atualizadoEm: instante,
      );

      final atualizada = _copiarAlocacaoComHoras(
        alocacao,
        horaInicioReal: inicio,
        horaFimReal: fim,
        minutosRealizados: minutos,
        observacao: observacao,
        atualizadoEm: instante,
      );
      _dia = EscalaDiaConsulta(
        data: dia.data,
        escala: dia.escala,
        atividades: dia.atividades,
        alocacoes: List<EscalaAlocacaoModel>.unmodifiable(
          dia.alocacoes
              .map((item) => item.id == atualizada.id ? atualizada : item),
        ),
        indisponibilidades: dia.indisponibilidades,
      );
    } finally {
      _salvandoHoras = false;
      notifyListeners();
    }
  }

  Future<void> carregar() async {
    final geracao = ++_geracaoCarregamento;
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final resultado = await _repository.carregarDia(_dataSelecionada);
      if (geracao != _geracaoCarregamento) return;
      _dia = resultado;
    } catch (erro) {
      if (geracao != _geracaoCarregamento) return;
      _erro = erro;
      _dia = null;
    } finally {
      if (geracao == _geracaoCarregamento) {
        _carregando = false;
        notifyListeners();
      }
    }
  }

  Future<void> diaAnterior() async {
    await _definirData(_dataSelecionada.subtract(const Duration(days: 1)));
  }

  Future<void> proximoDia() async {
    await _definirData(_dataSelecionada.add(const Duration(days: 1)));
  }

  Future<void> hoje() async {
    await _definirData(DateTime.now());
  }

  Future<void> selecionarData(DateTime data) async {
    await _definirData(data);
  }

  void definirMinhaEscala(bool valor) {
    if (_minhaEscala == valor) return;
    _minhaEscala = valor;
    notifyListeners();
  }

  Future<void> _definirData(DateTime data) async {
    final normalizada = _somenteData(data);
    if (_dataSelecionada == normalizada && _dia != null) return;
    _dataSelecionada = normalizada;
    await carregar();
  }

  static DateTime _somenteData(DateTime data) =>
      DateTime(data.year, data.month, data.day);

  EscalaAlocacaoModel _copiarAlocacaoComHoras(
    EscalaAlocacaoModel origem, {
    required String horaInicioReal,
    required String horaFimReal,
    required int minutosRealizados,
    required String observacao,
    required DateTime atualizadoEm,
  }) {
    return EscalaAlocacaoModel(
      id: origem.id,
      escalaId: origem.escalaId,
      atividadeId: origem.atividadeId,
      data: origem.data,
      membroEquipeId: origem.membroEquipeId,
      usuarioId: origem.usuarioId,
      nomeSnapshot: origem.nomeSnapshot,
      vinculoSnapshot: origem.vinculoSnapshot,
      setorSnapshot: origem.setorSnapshot,
      cargaHorariaSnapshot: origem.cargaHorariaSnapshot,
      funcaoNaAtividade: origem.funcaoNaAtividade,
      turnoId: origem.turnoId,
      horaInicio: origem.horaInicio,
      horaFim: origem.horaFim,
      tipoJornada: origem.tipoJornada,
      horaInicioReal: horaInicioReal,
      horaFimReal: horaFimReal,
      minutosPrevistos: origem.minutosPrevistos,
      minutosRealizados: minutosRealizados,
      motivoJornadaComplementar: origem.motivoJornadaComplementar,
      classificadoPor: origem.classificadoPor,
      classificadoEm: origem.classificadoEm,
      origemAlocacaoId: origem.origemAlocacaoId,
      observacao: observacao.trim(),
      criadoPor: origem.criadoPor,
      criadoEm: origem.criadoEm,
      atualizadoPor: _usuarioId,
      atualizadoEm: atualizadoEm,
    );
  }
}

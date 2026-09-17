import 'package:flutter/foundation.dart';

import '../data/escala_repository.dart';
import '../models/escala_models.dart';
import '../services/escala_conflito_service.dart';
import '../services/escala_horas_service.dart';

class EscalaConsultaController extends ChangeNotifier {
  EscalaConsultaController({
    required EscalaRepository repository,
    required String usuarioId,
    DateTime? dataInicial,
    bool iniciarMinhaEscala = false,
  }) : _repository = repository,
       _usuarioId = usuarioId.trim(),
       _dataSelecionada = _somenteData(dataInicial ?? DateTime.now()),
       _minhaEscala = iniciarMinhaEscala;

  final EscalaRepository _repository;
  final String _usuarioId;

  DateTime _dataSelecionada;
  bool _minhaEscala;
  bool _carregando = false;
  Object? _erro;
  EscalaDiaConsulta? _dia;
  int _geracaoCarregamento = 0;

  DateTime get dataSelecionada => _dataSelecionada;
  bool get minhaEscala => _minhaEscala;
  bool get carregando => _carregando;
  Object? get erro => _erro;
  EscalaDiaConsulta? get dia => _dia;
  String get usuarioId => _usuarioId;

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
}

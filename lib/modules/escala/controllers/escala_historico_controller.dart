import 'package:flutter/foundation.dart';

import '../data/escala_repository.dart';
import '../models/escala_models.dart';
import '../security/escala_access_policy.dart';
import '../security/escala_permission.dart';
import '../services/escala_indicadores_historicos_service.dart';

class EscalaHistoricoController extends ChangeNotifier {
  EscalaHistoricoController({
    required EscalaRepository repository,
    required String usuarioId,
    required String perfilAcesso,
    String membroEquipeId = '',
    DateTime? inicioInicial,
    DateTime? fimInicial,
    bool iniciarSomenteMinhasHoras = false,
    DateTime Function()? agora,
  })  : _repository = repository,
        _usuarioId = usuarioId.trim(),
        _perfilAcesso = perfilAcesso.trim(),
        _membroEquipeId = membroEquipeId.trim(),
        _agora = agora ?? DateTime.now,
        _inicio = EscalaPeriodoConsulta.somenteData(
          inicioInicial ?? _primeiroDiaMes((agora ?? DateTime.now)()),
        ),
        _fim = EscalaPeriodoConsulta.somenteData(
          fimInicial ?? _ultimoDiaMes((agora ?? DateTime.now)()),
        ),
        _somenteMinhasHoras = iniciarSomenteMinhasHoras {
    EscalaPeriodoConsulta.validarPeriodo(inicio: _inicio, fim: _fim);
  }

  final EscalaRepository _repository;
  final String _usuarioId;
  final String _perfilAcesso;
  final String _membroEquipeId;
  final DateTime Function() _agora;

  DateTime _inicio;
  DateTime _fim;
  bool _somenteMinhasHoras;
  bool _carregando = false;
  Object? _erro;
  EscalaPeriodoConsulta? _periodo;
  EscalaIndicadoresHistoricosResumo? _resumo;
  int _geracaoCarregamento = 0;

  DateTime get inicio => _inicio;
  DateTime get fim => _fim;
  String get usuarioId => _usuarioId;
  String get perfilAcesso => _perfilAcesso;
  String get membroEquipeId => _membroEquipeId;
  bool get carregando => _carregando;
  Object? get erro => _erro;
  EscalaPeriodoConsulta? get periodo => _periodo;
  EscalaIndicadoresHistoricosResumo? get resumo => _resumo;

  bool get podeConsultarGeral => EscalaAccessPolicy.autoriza(
        perfilAcesso: _perfilAcesso,
        usuarioId: _usuarioId,
        responsavelEscalaUsuarioId: '',
        permissao: EscalaPermission.consultarHistoricoHorasGeral,
      );

  bool get podeConsultarProprio => EscalaAccessPolicy.autoriza(
        perfilAcesso: _perfilAcesso,
        usuarioId: _usuarioId,
        responsavelEscalaUsuarioId: '',
        permissao: EscalaPermission.consultarHistoricoHorasProprio,
      );

  bool get somenteMinhasHoras => _somenteMinhasHoras || !podeConsultarGeral;

  Future<void> carregar() async {
    final geracao = ++_geracaoCarregamento;
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final autorizado =
          somenteMinhasHoras ? podeConsultarProprio : podeConsultarGeral;
      if (!autorizado) {
        throw StateError('Usuário sem permissão para consultar o histórico.');
      }

      final resultado = await _repository.carregarPeriodo(
        inicio: _inicio,
        fim: _fim,
      );
      if (geracao != _geracaoCarregamento) return;

      final visivel =
          somenteMinhasHoras ? _filtrarPeriodoDoUsuario(resultado) : resultado;
      final consolidado = EscalaIndicadoresHistoricosService.consolidar(
        inicio: visivel.inicio,
        fim: visivel.fim,
        dias: visivel.dias,
      );
      if (geracao != _geracaoCarregamento) return;

      _periodo = visivel;
      _resumo = consolidado;
    } catch (erro) {
      if (geracao != _geracaoCarregamento) return;
      _erro = erro;
      _periodo = null;
      _resumo = null;
    } finally {
      if (geracao == _geracaoCarregamento) {
        _carregando = false;
        notifyListeners();
      }
    }
  }

  void selecionarPeriodo({required DateTime inicio, required DateTime fim}) {
    final novoInicio = EscalaPeriodoConsulta.somenteData(inicio);
    final novoFim = EscalaPeriodoConsulta.somenteData(fim);
    EscalaPeriodoConsulta.validarPeriodo(inicio: novoInicio, fim: novoFim);
    if (_inicio == novoInicio && _fim == novoFim) return;

    _inicio = novoInicio;
    _fim = novoFim;
    _invalidarResultado();
  }

  void selecionarMesAtual() {
    final referencia = _agora();
    selecionarPeriodo(
      inicio: _primeiroDiaMes(referencia),
      fim: _ultimoDiaMes(referencia),
    );
  }

  void definirSomenteMinhasHoras(bool valor) {
    if (!valor && !podeConsultarGeral) {
      throw StateError('Usuário sem permissão para o histórico geral.');
    }
    if (_somenteMinhasHoras == valor) return;
    _somenteMinhasHoras = valor;
    _invalidarResultado();
  }

  EscalaPeriodoConsulta _filtrarPeriodoDoUsuario(EscalaPeriodoConsulta origem) {
    final dias = origem.dias.map((dia) {
      final alocacoes = dia.alocacoes
          .where(
            (item) =>
                item.usuarioId.trim() == _usuarioId ||
                (_membroEquipeId.isNotEmpty &&
                    item.membroEquipeId.trim() == _membroEquipeId),
          )
          .toList(growable: false);
      final atividadesIds = alocacoes
          .map((item) => item.atividadeId.trim())
          .where((item) => item.isNotEmpty)
          .toSet();
      final atividades = dia.atividades.where((item) {
        return atividadesIds.contains(item.id) ||
            item.coordenadorUsuarioId.trim() == _usuarioId ||
            (_membroEquipeId.isNotEmpty &&
                item.coordenadorMembroEquipeId.trim() == _membroEquipeId) ||
            item.participanteUsuarioIds.contains(_usuarioId);
      }).toList(growable: false);
      final indisponibilidades = dia.indisponibilidades
          .where(
            (item) =>
                item.usuarioId.trim() == _usuarioId ||
                (_membroEquipeId.isNotEmpty &&
                    item.membroEquipeId.trim() == _membroEquipeId),
          )
          .toList(growable: false);

      return EscalaDiaConsulta(
        data: dia.data,
        escala: dia.escala,
        atividades: List<EscalaAtividadeModel>.unmodifiable(atividades),
        alocacoes: List<EscalaAlocacaoModel>.unmodifiable(alocacoes),
        indisponibilidades: List<EscalaIndisponibilidadeModel>.unmodifiable(
          indisponibilidades,
        ),
      );
    });

    return EscalaPeriodoConsulta(
      inicio: origem.inicio,
      fim: origem.fim,
      dias: dias,
    );
  }

  void _invalidarResultado() {
    _geracaoCarregamento++;
    _carregando = false;
    _erro = null;
    _periodo = null;
    _resumo = null;
    notifyListeners();
  }

  static DateTime _primeiroDiaMes(DateTime data) =>
      DateTime(data.year, data.month);

  static DateTime _ultimoDiaMes(DateTime data) =>
      DateTime(data.year, data.month + 1, 0);
}

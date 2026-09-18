import 'package:flutter/foundation.dart';

import '../data/escala_execucao_repository.dart';
import '../models/escala_models.dart';
import '../security/escala_access_policy.dart';
import '../security/escala_permission.dart';
import '../services/escala_execucao_service.dart';

class EscalaExecucaoController extends ChangeNotifier {
  EscalaExecucaoController({
    required EscalaExecucaoRepository repository,
    required String atividadeId,
    required String usuarioId,
    required String perfilAcesso,
    DateTime Function()? agora,
    String Function(DateTime instante, int sequencia)? novoIdEvidencia,
  })  : _repository = repository,
        _atividadeId = atividadeId.trim(),
        _usuarioId = usuarioId.trim(),
        _perfilAcesso = perfilAcesso.trim(),
        _agora = agora ?? DateTime.now,
        _novoIdEvidencia = novoIdEvidencia ?? _idEvidenciaPadrao;

  final EscalaExecucaoRepository _repository;
  final String _atividadeId;
  final String _usuarioId;
  final String _perfilAcesso;
  final DateTime Function() _agora;
  final String Function(DateTime instante, int sequencia) _novoIdEvidencia;

  EscalaExecucaoContexto? _contexto;
  bool _carregando = false;
  bool _salvando = false;
  Object? _erro;
  int _geracaoCarregamento = 0;

  String get atividadeId => _atividadeId;
  String get usuarioId => _usuarioId;
  String get perfilAcesso => _perfilAcesso;

  EscalaExecucaoContexto? get contexto => _contexto;
  EscalaAtividadeModel? get atividade => _contexto?.atividade;
  EscalaModel? get escala => _contexto?.escala;
  List<EscalaAlocacaoModel> get equipe =>
      _contexto?.equipe ?? const <EscalaAlocacaoModel>[];
  ExecucaoMissaoModel? get execucao => _contexto?.execucao;

  bool get carregando => _carregando;
  bool get salvando => _salvando;
  Object? get erro => _erro;

  bool get ehParticipante => _contexto?.participante(_usuarioId) == true;
  bool get ehCoordenador => _contexto?.coordenador(_usuarioId) == true;

  bool get podeExecutar {
    final atual = _contexto;
    if (atual == null || !atual.elegivelParaExecucao(_usuarioId)) return false;

    return EscalaAccessPolicy.autoriza(
      perfilAcesso: _perfilAcesso,
      usuarioId: _usuarioId,
      responsavelEscalaUsuarioId: '',
      permissao: EscalaPermission.registrarExecucaoMissao,
      ehParticipanteAtividade: ehParticipante,
      ehCoordenadorAtividade: ehCoordenador,
    );
  }

  bool get emExecucao => execucao?.status == EscalaCodigos.execucaoEmExecucao;

  bool get terminal =>
      execucao?.status == EscalaCodigos.execucaoConcluida ||
      execucao?.status == EscalaCodigos.execucaoCancelada;

  bool get podeEditar => podeExecutar && emExecucao;

  bool get podeAnexarEvidencia {
    if (!podeEditar) return false;

    return EscalaAccessPolicy.autoriza(
      perfilAcesso: _perfilAcesso,
      usuarioId: _usuarioId,
      responsavelEscalaUsuarioId: '',
      permissao: EscalaPermission.anexarEvidenciaMissao,
      ehParticipanteAtividade: ehParticipante,
      ehCoordenadorAtividade: ehCoordenador,
    );
  }

  Future<void> carregar() async {
    final geracao = ++_geracaoCarregamento;
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final resultado = await _repository.carregarContexto(
        atividadeId: _atividadeId,
        usuarioId: _usuarioId,
      );

      if (geracao != _geracaoCarregamento) return;
      _contexto = resultado;
    } catch (erro) {
      if (geracao != _geracaoCarregamento) return;
      _erro = erro;
      _contexto = null;
    } finally {
      if (geracao == _geracaoCarregamento) {
        _carregando = false;
        notifyListeners();
      }
    }
  }

  Future<void> iniciar() async {
    _exigirPodeExecutar();

    final existente = execucao;
    if (existente != null) {
      if (existente.status == EscalaCodigos.execucaoEmExecucao) return;
      throw StateError('Esta execução já está encerrada.');
    }

    final atual = _contexto!;
    final instante = _agora();

    final nova = ExecucaoMissaoModel(
      id: _repository.idExecucao(
        atividadeId: atual.atividade.id,
        usuarioId: _usuarioId,
      ),
      escalaAtividadeId: atual.atividade.id,
      escalaId: atual.escala.id,
      data: atual.atividade.data,
      status: EscalaCodigos.execucaoEmExecucao,
      resultadoResumo: '',
      observacao: '',
      evidencias: const <MissaoEvidenciaModel>[],
      executadoPorUsuarioId: _usuarioId,
      executadoPorMembroEquipeId: atual.executor.id,
      executadoPorNomeSnapshot: atual.executor.nome,
      concluidoEm: null,
      criadoEm: instante,
      atualizadoEm: instante,
    );

    _validarExecucao(nova);

    await _executarSalvamento(() async {
      final persistida = await _repository.iniciarExecucao(nova);
      _contexto = atual.comExecucao(persistida);
    });
  }

  Future<void> salvarResultadoObservacao({
    required String resultadoResumo,
    required String observacao,
  }) async {
    final atual = _exigirEditavel();

    final alterada = _copiarExecucao(
      atual,
      status: EscalaCodigos.execucaoEmExecucao,
      resultadoResumo: resultadoResumo,
      observacao: observacao,
      evidencias: atual.evidencias,
      concluidoEm: null,
      atualizadoEm: _agora(),
    );

    await _persistir(alterada);
  }

  Future<void> concluir({
    required String resultadoResumo,
    required String observacao,
  }) async {
    final atual = _exigirEditavel();
    final instante = _agora();

    final concluida = _copiarExecucao(
      atual,
      status: EscalaCodigos.execucaoConcluida,
      resultadoResumo: resultadoResumo,
      observacao: observacao,
      evidencias: atual.evidencias,
      concluidoEm: instante,
      atualizadoEm: instante,
    );

    await _persistir(concluida);
  }

  Future<void> cancelar({
    String observacao = '',
  }) async {
    final atual = _exigirEditavel();
    final instante = _agora();

    final cancelada = _copiarExecucao(
      atual,
      status: EscalaCodigos.execucaoCancelada,
      resultadoResumo: atual.resultadoResumo,
      observacao: observacao,
      evidencias: atual.evidencias,
      concluidoEm: null,
      atualizadoEm: instante,
    );

    await _persistir(cancelada);
  }

  Future<void> adicionarEvidencia({
    required String tipo,
    required String descricao,
    required String referencia,
  }) async {
    if (!podeAnexarEvidencia) {
      throw StateError('Execução não permite anexar evidência.');
    }

    final atual = _exigirEditavel();
    if (atual.evidencias.length >= 20) {
      throw StateError('A execução aceita no máximo 20 evidências.');
    }

    final instante = _agora();
    final id = _novoIdEvidencia(instante, atual.evidencias.length + 1).trim();

    if (id.isEmpty || atual.evidencias.any((item) => item.id == id)) {
      throw StateError('ID de evidência inválido ou duplicado.');
    }

    final evidencia = MissaoEvidenciaModel(
      id: id,
      tipo: tipo.trim(),
      descricao: descricao.trim(),
      referencia: referencia.trim(),
      criadoPor: _usuarioId,
      criadoEm: instante,
    );

    if (!EscalaExecucaoService.evidenciaValida(
      evidencia,
      executorUsuarioId: _usuarioId,
    )) {
      throw StateError('Evidência inválida.');
    }

    final evidencias = <MissaoEvidenciaModel>[
      ...atual.evidencias,
      evidencia,
    ];

    final alterada = _copiarExecucao(
      atual,
      status: atual.status,
      resultadoResumo: atual.resultadoResumo,
      observacao: atual.observacao,
      evidencias: evidencias,
      concluidoEm: atual.concluidoEm,
      atualizadoEm: instante,
    );

    await _persistir(alterada);
  }

  Future<void> removerEvidencia(String evidenciaId) async {
    if (!podeAnexarEvidencia) {
      throw StateError('Execução não permite remover evidência.');
    }

    final atual = _exigirEditavel();
    final id = evidenciaId.trim();

    final evidencias =
        atual.evidencias.where((item) => item.id != id).toList(growable: false);

    if (evidencias.length == atual.evidencias.length) {
      throw StateError('Evidência não encontrada.');
    }

    final alterada = _copiarExecucao(
      atual,
      status: atual.status,
      resultadoResumo: atual.resultadoResumo,
      observacao: atual.observacao,
      evidencias: evidencias,
      concluidoEm: atual.concluidoEm,
      atualizadoEm: _agora(),
    );

    await _persistir(alterada);
  }

  void _exigirPodeExecutar() {
    if (!podeExecutar) {
      throw StateError('Usuário sem permissão para executar esta missão.');
    }
  }

  ExecucaoMissaoModel _exigirEditavel() {
    _exigirPodeExecutar();

    final atual = execucao;
    if (atual == null) {
      throw StateError('Inicie a execução antes de editar.');
    }
    if (atual.status != EscalaCodigos.execucaoEmExecucao) {
      throw StateError('Execução terminal não pode ser alterada.');
    }

    return atual;
  }

  Future<void> _persistir(ExecucaoMissaoModel alterada) async {
    _validarExecucao(alterada);

    await _executarSalvamento(() async {
      await _repository.atualizarExecucao(alterada);
      _contexto = _contexto!.comExecucao(alterada);
    });
  }

  void _validarExecucao(ExecucaoMissaoModel valor) {
    final validacao = EscalaExecucaoService.validar(valor);
    if (!validacao.valida) {
      throw StateError(validacao.erros.join(' '));
    }
  }

  Future<void> _executarSalvamento(Future<void> Function() operacao) async {
    if (_salvando) {
      throw StateError('Já existe uma gravação em andamento.');
    }

    _salvando = true;
    _erro = null;
    notifyListeners();

    try {
      await operacao();
    } catch (erro) {
      _erro = erro;
      rethrow;
    } finally {
      _salvando = false;
      notifyListeners();
    }
  }

  static ExecucaoMissaoModel _copiarExecucao(
    ExecucaoMissaoModel origem, {
    required String status,
    required String resultadoResumo,
    required String observacao,
    required Iterable<MissaoEvidenciaModel> evidencias,
    required DateTime? concluidoEm,
    required DateTime atualizadoEm,
  }) {
    return ExecucaoMissaoModel(
      id: origem.id,
      escalaAtividadeId: origem.escalaAtividadeId,
      escalaId: origem.escalaId,
      data: origem.data,
      status: status,
      resultadoResumo: resultadoResumo.trim(),
      observacao: observacao.trim(),
      evidencias: evidencias,
      executadoPorUsuarioId: origem.executadoPorUsuarioId,
      executadoPorMembroEquipeId: origem.executadoPorMembroEquipeId,
      executadoPorNomeSnapshot: origem.executadoPorNomeSnapshot,
      concluidoEm: concluidoEm,
      criadoEm: origem.criadoEm,
      atualizadoEm: atualizadoEm,
    );
  }

  static String _idEvidenciaPadrao(DateTime instante, int sequencia) {
    return 'ev-${instante.microsecondsSinceEpoch}-$sequencia';
  }
}

import 'package:flutter/foundation.dart';

import '../../../data/models/membro_equipe_model.dart';
import '../data/escala_gestao_repository.dart';
import '../models/escala_models.dart';
import '../security/escala_access_policy.dart';
import '../security/escala_permission.dart';
import '../services/escala_conferencia_service.dart';
import '../services/escala_conflito_service.dart';
import '../services/escala_horas_service.dart';

class EscalaGestaoController extends ChangeNotifier {
  EscalaGestaoController({
    required EscalaGestaoRepository repository,
    required String usuarioId,
    required String perfilAcesso,
    DateTime? dataInicial,
    DateTime Function()? agora,
  })  : _repository = repository,
        _usuarioId = usuarioId.trim(),
        _perfilAcesso = perfilAcesso.trim(),
        _dataSelecionada = _somenteData(dataInicial ?? DateTime.now()),
        _agora = agora ?? DateTime.now;

  final EscalaGestaoRepository _repository;
  final String _usuarioId;
  final String _perfilAcesso;
  final DateTime Function() _agora;

  DateTime _dataSelecionada;
  bool _carregando = false;
  bool _salvando = false;
  Object? _erro;
  EscalaGestaoDados? _dados;
  int _geracaoCarregamento = 0;

  DateTime get dataSelecionada => _dataSelecionada;
  bool get carregando => _carregando;
  bool get salvando => _salvando;
  Object? get erro => _erro;
  EscalaGestaoDados? get dados => _dados;
  String get usuarioId => _usuarioId;
  String get perfilAcesso => _perfilAcesso;

  EscalaModel? get escala => _dados?.dia.escala;
  bool get possuiEscala => escala != null;
  bool get rascunho => escala?.status == EscalaCodigos.statusRascunho;
  bool get publicada => escala?.status == EscalaCodigos.statusPublicada;

  List<EscalaAtividadeModel> get atividades =>
      _dados?.dia.atividades ?? const <EscalaAtividadeModel>[];
  List<EscalaAlocacaoModel> get alocacoes =>
      _dados?.dia.alocacoes ?? const <EscalaAlocacaoModel>[];
  List<EscalaIndisponibilidadeModel> get indisponibilidades =>
      _dados?.dia.indisponibilidades ?? const <EscalaIndisponibilidadeModel>[];

  EscalaConfiguracaoModel? get configuracao => _dados?.configuracao;

  String get responsavelEscalaUsuarioId {
    final item = configuracao;
    if (item == null || !item.ativo) return '';
    return item.responsavelEscalaUsuarioId.trim();
  }

  bool get ehResponsavel =>
      _usuarioId.isNotEmpty &&
      _perfilAcesso.trim().toLowerCase() == 'agente' &&
      responsavelEscalaUsuarioId == _usuarioId;

  bool get ehGerente => _perfilAcesso.trim().toLowerCase() == 'gerente';
  bool get podeClassificarJornada => ehResponsavel;

  bool get podeCriarEscala =>
      !possuiEscala && _autoriza(EscalaPermission.criarEscala);

  bool get podeEditarEscala =>
      rascunho && _autoriza(EscalaPermission.editarEscala);

  EscalaHorasResumo get resumoHoras => EscalaHorasService.resumir(alocacoes);

  EscalaConferenciaResultado? get conferencia {
    final atual = _dados;
    if (atual == null) return null;
    return EscalaConferenciaService.conferir(
      data: _dataSelecionada,
      membrosEquipe: atual.membrosEquipe,
      perfisOperacionais: atual.perfisOperacionais,
      alocacoes: atual.dia.alocacoes,
      indisponibilidades: atual.dia.indisponibilidades,
      atividades: atual.dia.atividades,
    );
  }

  List<EscalaConflitoHorario> get conflitosSobreposicao =>
      EscalaConflitoService.detectarSobreposicoes(alocacoes);

  List<EscalaMultiplaAlocacao> get multiplasAlocacoes =>
      EscalaConflitoService.detectarMultiplasAlocacoes(alocacoes);

  List<String> get alertasGerais {
    final mensagens = <String>[];
    final resumo = conferencia;
    if (resumo != null && resumo.totalSemSituacao > 0) {
      mensagens.add(
        '${resumo.totalSemSituacao} agente(s) da GEDUC sem situação definida.',
      );
    }
    if (resumo != null && resumo.totalSituacaoDupla > 0) {
      mensagens.add(
        '${resumo.totalSituacaoDupla} agente(s) com alocação e indisponibilidade.',
      );
    }
    if (conflitosSobreposicao.isNotEmpty) {
      mensagens.add(
        '${conflitosSobreposicao.length} sobreposição(ões) de horário.',
      );
    }
    if (multiplasAlocacoes.isNotEmpty) {
      mensagens.add(
        '${multiplasAlocacoes.length} agente(s) com múltiplas alocações.',
      );
    }
    if (resumo != null && resumo.totalIdentidadeNaoCanonica > 0) {
      mensagens.add(
        '${resumo.totalIdentidadeNaoCanonica} integrante(s) sem UID canônico.',
      );
    }
    return List<String>.unmodifiable(mensagens);
  }

  List<EscalaAgenteGestao> get agentesDisponiveis {
    final atual = _dados;
    if (atual == null) return const <EscalaAgenteGestao>[];

    final perfisPorMembro = <String, EscalaPerfilOperacionalModel>{};
    for (final perfil in atual.perfisOperacionais) {
      if (!perfil.ativo) continue;
      if (perfil.setorCodigo.trim().toUpperCase() != 'GEDUC') continue;
      final membroId = perfil.membroEquipeId.trim();
      if (membroId.isEmpty) continue;
      perfisPorMembro.putIfAbsent(membroId, () => perfil);
    }

    final resultado = <EscalaAgenteGestao>[];
    final chaves = <String>{};
    for (final membro in atual.membrosEquipe) {
      if (!membro.ativo) continue;
      final perfil = perfisPorMembro[membro.id.trim()];
      if (perfil == null) continue;
      final uid = membro.usuarioId.trim();
      final chave = uid.isNotEmpty ? 'uid:$uid' : 'membro:${membro.id}';
      if (!chaves.add(chave)) continue;
      resultado.add(
        EscalaAgenteGestao(membro: membro, perfil: perfil, usuarioId: uid),
      );
    }
    resultado.sort((a, b) => a.nome.compareTo(b.nome));
    return List<EscalaAgenteGestao>.unmodifiable(resultado);
  }

  List<EscalaAgenteGestao> get coordenadoresDisponiveis =>
      List<EscalaAgenteGestao>.unmodifiable(
        agentesDisponiveis.where((item) => item.podeCoordenar),
      );

  List<EscalaAlocacaoModel> alocacoesDaAtividade(String atividadeId) =>
      List<EscalaAlocacaoModel>.unmodifiable(
        alocacoes.where((item) => item.atividadeId == atividadeId),
      );

  bool possuiOutraAlocacaoNoDia({
    required String membroEquipeId,
    String? ignorarAtividadeId,
  }) =>
      alocacoes.any(
        (item) =>
            item.membroEquipeId == membroEquipeId &&
            item.atividadeId != ignorarAtividadeId,
      );

  List<String> situacoesDoAgente(String membroEquipeId) {
    final agente = _agentePorMembro(membroEquipeId);
    if (agente == null) return const <String>[];
    final tipos = <String>{};
    for (final item in indisponibilidades) {
      final mesmoMembro = item.membroEquipeId.trim() == membroEquipeId.trim();
      final mesmoUid = agente.usuarioId.isNotEmpty &&
          item.usuarioId.trim() == agente.usuarioId;
      if (mesmoMembro || mesmoUid) {
        final tipo = item.tipoId.trim();
        if (tipo.isNotEmpty) tipos.add(tipo);
      }
    }
    final ordenados = tipos.toList()..sort();
    return List<String>.unmodifiable(ordenados);
  }

  Future<void> carregar() async {
    final geracao = ++_geracaoCarregamento;
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      final resultado = await _repository.carregarGestao(_dataSelecionada);
      if (geracao != _geracaoCarregamento) return;
      _dados = resultado;
    } catch (erro) {
      if (geracao != _geracaoCarregamento) return;
      _erro = erro;
      _dados = null;
    } finally {
      if (geracao == _geracaoCarregamento) {
        _carregando = false;
        notifyListeners();
      }
    }
  }

  Future<void> diaAnterior() async =>
      _definirData(_dataSelecionada.subtract(const Duration(days: 1)));
  Future<void> proximoDia() async =>
      _definirData(_dataSelecionada.add(const Duration(days: 1)));
  Future<void> hoje() async => _definirData(DateTime.now());
  Future<void> selecionarData(DateTime data) async => _definirData(data);

  Future<void> criarRascunho() async {
    if (!podeCriarEscala) {
      throw StateError(
        'Somente o agente responsável pode criar uma nova escala.',
      );
    }
    final agora = _agora();
    final dia = _somenteData(_dataSelecionada);
    final nova = EscalaModel(
      id: _idData(dia),
      data: dia,
      status: EscalaCodigos.statusRascunho,
      versao: 1,
      observacaoGeral: '',
      motivoRevisao: '',
      criadoPor: _usuarioId,
      criadoEm: agora,
      atualizadoPor: _usuarioId,
      atualizadoEm: agora,
      publicadoPor: '',
      publicadoEm: null,
    );
    await _executarSalvamento(() => _repository.criarRascunho(nova));
  }

  EscalaPreparacaoAtividade prepararAtividade(EscalaAtividadeEntrada entrada) {
    final bloqueios = <String>[];
    final alertas = <String>[];

    if (!podeEditarEscala) {
      bloqueios.add(
        'A escala precisa estar em rascunho e o usuário deve possuir gestão.',
      );
    }

    final natureza = entrada.naturezaAtividade.trim();
    if (natureza != EscalaCodigos.naturezaEducativa &&
        natureza != EscalaCodigos.naturezaAdministrativa) {
      bloqueios.add('Informe a natureza da atividade.');
    }
    if (entrada.secaoId.trim().isEmpty) {
      bloqueios.add('Informe a seção da escala.');
    }
    if (entrada.tipoAtividadeId.trim().isEmpty) {
      bloqueios.add('Informe o tipo da atividade.');
    }
    if (entrada.titulo.trim().isEmpty) {
      bloqueios.add('Informe o título da atividade.');
    }
    if (entrada.turnoId.trim().isEmpty) bloqueios.add('Informe o turno.');

    final inicio = entrada.horaInicio.trim();
    final fim = entrada.horaFim.trim();
    if (inicio.isEmpty != fim.isEmpty) {
      bloqueios.add('Informe início e fim do horário da atividade.');
    } else if (inicio.isNotEmpty &&
        EscalaHorasService.calcularDuracaoMinutos(inicio: inicio, fim: fim) ==
            null) {
      bloqueios.add('O horário da atividade é inválido.');
    }

    if (entrada.coordenadorMembroEquipeId.trim().isNotEmpty) {
      final coordenador = _agentePorMembro(entrada.coordenadorMembroEquipeId);
      if (coordenador == null || !coordenador.podeCoordenar) {
        bloqueios.add(
          'O coordenador precisa ser membro GEDUC ativo e apto a coordenar.',
        );
      }
    }

    final membrosSelecionados = <String>{};
    for (final selecao in entrada.equipe) {
      final membroId = selecao.membroEquipeId.trim();
      if (membroId.isEmpty || !membrosSelecionados.add(membroId)) {
        bloqueios.add('A equipe possui integrante inválido ou duplicado.');
        continue;
      }

      final agente = _agentePorMembro(membroId);
      if (agente == null) {
        bloqueios.add(
          'O integrante $membroId não pertence ao efetivo GEDUC ativo.',
        );
        continue;
      }

      final existenteNaAtividade = _alocacaoExistente(
        atividadeId: entrada.atividadeId,
        membroEquipeId: membroId,
      );
      final outras = alocacoes
          .where(
            (item) =>
                item.membroEquipeId == membroId &&
                item.atividadeId != entrada.atividadeId,
          )
          .toList(growable: false);
      final possuiOutra = outras.isNotEmpty;
      final tipo = _tipoJornadaEfetivo(
        selecao: selecao,
        possuiOutra: possuiOutra,
        existente: existenteNaAtividade,
      );

      if (tipo == null) {
        bloqueios.add('Classifique a nova jornada de ${agente.nome}.');
        continue;
      }
      if (!_tipoJornadaValido(tipo)) {
        bloqueios.add(
          'A classificação de jornada de ${agente.nome} é inválida.',
        );
        continue;
      }

      final mudouClassificacao = existenteNaAtividade != null &&
          (existenteNaAtividade.tipoJornada != tipo ||
              existenteNaAtividade.motivoJornadaComplementar.trim() !=
                  selecao.motivoJornadaComplementar.trim());
      final novaJornadaAdicional = possuiOutra && existenteNaAtividade == null;

      if (!podeClassificarJornada &&
          (novaJornadaAdicional ||
              mudouClassificacao ||
              (existenteNaAtividade == null && _jornadaComplementar(tipo)))) {
        bloqueios.add(
          'Somente o agente responsável pode classificar a jornada de ${agente.nome}.',
        );
      }

      if (_jornadaComplementar(tipo) &&
          selecao.motivoJornadaComplementar.trim().isEmpty) {
        bloqueios.add(
          'Informe o motivo da jornada complementar de ${agente.nome}.',
        );
      }

      if (possuiOutra) {
        alertas.add('${agente.nome} já possui outra alocação nesta data.');
      }
      final situacoes = situacoesDoAgente(membroId);
      if (situacoes.isNotEmpty) {
        alertas.add(
          '${agente.nome} possui ${situacoes.map(_rotuloSituacao).join(', ')}.',
        );
      }

      if (inicio.isNotEmpty && fim.isNotEmpty && outras.isNotEmpty) {
        final preview = _montarPreviewAlocacao(
          entrada: entrada,
          agente: agente,
          selecao: selecao,
          tipoJornada: tipo,
        );
        final conflitos = EscalaConflitoService.detectarSobreposicoes([
          ...outras,
          preview,
        ]);
        if (conflitos.any(
          (item) =>
              item.primeiraAlocacaoId == preview.id ||
              item.segundaAlocacaoId == preview.id,
        )) {
          alertas.add('${agente.nome} possui sobreposição de horário.');
        }
      }
    }

    return EscalaPreparacaoAtividade(
      bloqueios: bloqueios.toSet().toList(growable: false),
      alertas: alertas.toSet().toList(growable: false),
    );
  }

  Future<void> salvarAtividade(EscalaAtividadeEntrada entrada) async {
    final preparacao = prepararAtividade(entrada);
    if (!preparacao.valida) {
      throw EscalaGestaoValidationException(preparacao.bloqueios);
    }

    final escalaAtual = escala;
    if (escalaAtual == null) {
      throw StateError('Não existe escala para receber a atividade.');
    }

    final agora = _agora();
    EscalaAtividadeModel? existente;
    if (entrada.atividadeId != null) {
      for (final item in atividades) {
        if (item.id == entrada.atividadeId) {
          existente = item;
          break;
        }
      }
    }

    final atividadeId = existente?.id ?? _repository.novoIdAtividade();
    final coordenador = entrada.coordenadorMembroEquipeId.trim().isEmpty
        ? null
        : _agentePorMembro(entrada.coordenadorMembroEquipeId);

    final participantes = <String>{};
    final novasAlocacoes = <EscalaAlocacaoModel>[];
    final atuaisDaAtividade = <String, EscalaAlocacaoModel>{
      for (final item in alocacoesDaAtividade(atividadeId))
        item.membroEquipeId: item,
    };

    for (final selecao in entrada.equipe) {
      final agente = _agentePorMembro(selecao.membroEquipeId);
      if (agente == null) {
        throw StateError(
          'Integrante GEDUC deixou de estar disponível durante o salvamento.',
        );
      }
      final alocacaoExistente = atuaisDaAtividade[agente.membro.id];
      final possuiOutra = alocacoes.any(
        (item) =>
            item.membroEquipeId == agente.membro.id &&
            item.atividadeId != atividadeId,
      );
      final tipo = _tipoJornadaEfetivo(
        selecao: selecao,
        possuiOutra: possuiOutra,
        existente: alocacaoExistente,
      );
      if (tipo == null) {
        throw EscalaGestaoValidationException([
          'Classifique a nova jornada de ${agente.nome}.',
        ]);
      }
      if (agente.usuarioId.isNotEmpty) participantes.add(agente.usuarioId);
      novasAlocacoes.add(
        _montarAlocacao(
          atividadeId: atividadeId,
          escalaId: escalaAtual.id,
          entrada: entrada,
          agente: agente,
          selecao: selecao,
          tipoJornada: tipo,
          existente: alocacaoExistente,
          agora: agora,
        ),
      );
    }

    final selecionados =
        entrada.equipe.map((item) => item.membroEquipeId).toSet();
    final removerIds = atuaisDaAtividade.values
        .where((item) => !selecionados.contains(item.membroEquipeId))
        .map((item) => item.id)
        .toSet();

    final atividade = EscalaAtividadeModel(
      id: atividadeId,
      escalaId: escalaAtual.id,
      data: _somenteData(_dataSelecionada),
      secaoId: entrada.secaoId.trim(),
      tipoAtividadeId: entrada.tipoAtividadeId.trim(),
      naturezaAtividade: entrada.naturezaAtividade.trim(),
      titulo: entrada.titulo.trim(),
      descricao: entrada.descricao.trim(),
      turnoId: entrada.turnoId.trim(),
      qtrHorario: entrada.qtrHorario.trim(),
      horaInicio: entrada.horaInicio.trim(),
      horaFim: entrada.horaFim.trim(),
      qthLocal: entrada.qthLocal.trim(),
      qthEndereco: entrada.qthEndereco.trim(),
      qthRegionalId: entrada.qthRegionalId.trim(),
      qthPontoReferencia: entrada.qthPontoReferencia.trim(),
      orientacaoOperacional: entrada.orientacaoOperacional.trim(),
      coordenadorMembroEquipeId: coordenador?.membro.id ?? '',
      coordenadorUsuarioId: coordenador?.usuarioId ?? '',
      coordenadorNomeSnapshot: coordenador?.nome ?? '',
      participanteUsuarioIds: participantes,
      geraRae:
          entrada.naturezaAtividade.trim() == EscalaCodigos.naturezaEducativa,
      contabilizaProdutividade: true,
      raeId: existente?.raeId ?? '',
      execucaoMissaoId: existente?.execucaoMissaoId ?? '',
      status: existente?.status ?? EscalaCodigos.atividadePlanejada,
      criadoPor: existente?.criadoPor ?? _usuarioId,
      criadoEm: existente?.criadoEm ?? agora,
      atualizadoPor: _usuarioId,
      atualizadoEm: agora,
    );

    await _executarSalvamento(
      () => _repository.salvarAtividadeComEquipe(
        EscalaAtividadePersistencia(
          atividade: atividade,
          alocacoes: novasAlocacoes,
          removerAlocacaoIds: removerIds,
        ),
      ),
    );
  }

  Future<void> _executarSalvamento(Future<void> Function() operacao) async {
    if (_salvando) return;
    _salvando = true;
    _erro = null;
    notifyListeners();
    try {
      await operacao();
      await carregar();
    } catch (erro) {
      _erro = erro;
      rethrow;
    } finally {
      _salvando = false;
      notifyListeners();
    }
  }

  Future<void> _definirData(DateTime data) async {
    final normalizada = _somenteData(data);
    if (_dataSelecionada == normalizada && _dados != null) return;
    _dataSelecionada = normalizada;
    await carregar();
  }

  bool _autoriza(EscalaPermission permissao) => EscalaAccessPolicy.autoriza(
        perfilAcesso: _perfilAcesso,
        usuarioId: _usuarioId,
        responsavelEscalaUsuarioId: responsavelEscalaUsuarioId,
        permissao: permissao,
      );

  EscalaAgenteGestao? _agentePorMembro(String membroEquipeId) {
    final alvo = membroEquipeId.trim();
    for (final item in agentesDisponiveis) {
      if (item.membro.id == alvo) return item;
    }
    return null;
  }

  EscalaAlocacaoModel? _alocacaoExistente({
    required String? atividadeId,
    required String membroEquipeId,
  }) {
    if (atividadeId == null || atividadeId.trim().isEmpty) return null;
    for (final item in alocacoes) {
      if (item.atividadeId == atividadeId &&
          item.membroEquipeId == membroEquipeId) {
        return item;
      }
    }
    return null;
  }

  String? _tipoJornadaEfetivo({
    required EscalaEquipeSelecao selecao,
    required bool possuiOutra,
    required EscalaAlocacaoModel? existente,
  }) {
    final informado = selecao.tipoJornada?.trim() ?? '';
    if (informado.isNotEmpty) return informado;
    if (existente != null && existente.tipoJornada.trim().isNotEmpty) {
      return existente.tipoJornada.trim();
    }
    if (possuiOutra) return null;
    return EscalaCodigos.jornadaNormal;
  }

  EscalaAlocacaoModel _montarPreviewAlocacao({
    required EscalaAtividadeEntrada entrada,
    required EscalaAgenteGestao agente,
    required EscalaEquipeSelecao selecao,
    required String tipoJornada,
  }) {
    final agora = _agora();
    return EscalaAlocacaoModel(
      id: 'preview-${agente.membro.id}',
      escalaId: escala?.id ?? _idData(_dataSelecionada),
      atividadeId: entrada.atividadeId ?? 'preview-atividade',
      data: _somenteData(_dataSelecionada),
      membroEquipeId: agente.membro.id,
      usuarioId: agente.usuarioId,
      nomeSnapshot: agente.nome,
      vinculoSnapshot: agente.membro.vinculo.codigo,
      setorSnapshot: agente.perfil.setorCodigo,
      cargaHorariaSnapshot: agente.perfil.cargaHorariaCodigo,
      funcaoNaAtividade: 'equipe',
      turnoId: entrada.turnoId.trim(),
      horaInicio: entrada.horaInicio.trim(),
      horaFim: entrada.horaFim.trim(),
      tipoJornada: tipoJornada,
      horaInicioReal: '',
      horaFimReal: '',
      minutosPrevistos: EscalaHorasService.calcularDuracaoMinutos(
            inicio: entrada.horaInicio,
            fim: entrada.horaFim,
          ) ??
          0,
      minutosRealizados: null,
      motivoJornadaComplementar: selecao.motivoJornadaComplementar.trim(),
      classificadoPor: _jornadaComplementar(tipoJornada) ? _usuarioId : '',
      classificadoEm: _jornadaComplementar(tipoJornada) ? agora : null,
      observacao: '',
      criadoPor: _usuarioId,
      criadoEm: agora,
      atualizadoPor: _usuarioId,
      atualizadoEm: agora,
    );
  }

  EscalaAlocacaoModel _montarAlocacao({
    required String atividadeId,
    required String escalaId,
    required EscalaAtividadeEntrada entrada,
    required EscalaAgenteGestao agente,
    required EscalaEquipeSelecao selecao,
    required String tipoJornada,
    required EscalaAlocacaoModel? existente,
    required DateTime agora,
  }) {
    final motivo = _jornadaComplementar(tipoJornada)
        ? selecao.motivoJornadaComplementar.trim()
        : '';
    final mudouClassificacao = existente != null &&
        (existente.tipoJornada != tipoJornada ||
            existente.motivoJornadaComplementar.trim() != motivo);

    String classificadoPor;
    DateTime? classificadoEm;
    if (existente != null && !mudouClassificacao) {
      classificadoPor = existente.classificadoPor;
      classificadoEm = existente.classificadoEm;
    } else if (_jornadaComplementar(tipoJornada) ||
        (existente != null && mudouClassificacao)) {
      classificadoPor = _usuarioId;
      classificadoEm = agora;
    } else {
      classificadoPor = '';
      classificadoEm = null;
    }

    final minutos = EscalaHorasService.calcularDuracaoMinutos(
          inicio: entrada.horaInicio,
          fim: entrada.horaFim,
        ) ??
        0;

    return EscalaAlocacaoModel(
      id: existente?.id ?? _repository.novoIdAlocacao(),
      escalaId: escalaId,
      atividadeId: atividadeId,
      data: _somenteData(_dataSelecionada),
      membroEquipeId: agente.membro.id,
      usuarioId: agente.usuarioId,
      nomeSnapshot: agente.nome,
      vinculoSnapshot: agente.membro.vinculo.codigo,
      setorSnapshot: agente.perfil.setorCodigo.trim(),
      cargaHorariaSnapshot: agente.perfil.cargaHorariaCodigo.trim(),
      funcaoNaAtividade: existente?.funcaoNaAtividade ?? 'equipe',
      turnoId: entrada.turnoId.trim(),
      horaInicio: entrada.horaInicio.trim(),
      horaFim: entrada.horaFim.trim(),
      tipoJornada: tipoJornada,
      horaInicioReal: existente?.horaInicioReal ?? '',
      horaFimReal: existente?.horaFimReal ?? '',
      minutosPrevistos: minutos,
      minutosRealizados: existente?.minutosRealizados,
      motivoJornadaComplementar: motivo,
      classificadoPor: classificadoPor,
      classificadoEm: classificadoEm,
      observacao: existente?.observacao ?? '',
      criadoPor: existente?.criadoPor ?? _usuarioId,
      criadoEm: existente?.criadoEm ?? agora,
      atualizadoPor: _usuarioId,
      atualizadoEm: agora,
    );
  }

  static bool _tipoJornadaValido(String tipo) =>
      tipo == EscalaCodigos.jornadaNormal ||
      tipo == EscalaCodigos.jornadaHoraExtra ||
      tipo == EscalaCodigos.jornadaBancoHoras;

  static bool _jornadaComplementar(String tipo) =>
      tipo == EscalaCodigos.jornadaHoraExtra ||
      tipo == EscalaCodigos.jornadaBancoHoras;

  static String _rotuloSituacao(String tipo) {
    switch (tipo.trim().toLowerCase()) {
      case 'ferias':
        return 'férias';
      case 'compensacao':
        return 'compensação';
      case 'folga':
        return 'folga';
      default:
        return tipo.trim().replaceAll('_', ' ');
    }
  }

  static DateTime _somenteData(DateTime data) =>
      DateTime(data.year, data.month, data.day);

  static String _idData(DateTime data) =>
      '${data.year.toString().padLeft(4, '0')}-'
      '${data.month.toString().padLeft(2, '0')}-'
      '${data.day.toString().padLeft(2, '0')}';
}

class EscalaAgenteGestao {
  const EscalaAgenteGestao({
    required this.membro,
    required this.perfil,
    required this.usuarioId,
  });

  final MembroEquipeModel membro;
  final EscalaPerfilOperacionalModel perfil;
  final String usuarioId;

  String get nome => membro.nome.trim();
  bool get podeCoordenar => membro.podeCoordenar;
  String get cargaHoraria => perfil.cargaHorariaCodigo.trim();
  bool get identidadeCanonica => usuarioId.isNotEmpty;
}

class EscalaEquipeSelecao {
  const EscalaEquipeSelecao({
    required this.membroEquipeId,
    this.tipoJornada,
    this.motivoJornadaComplementar = '',
  });

  final String membroEquipeId;
  final String? tipoJornada;
  final String motivoJornadaComplementar;

  EscalaEquipeSelecao copyWith({
    String? tipoJornada,
    bool limparTipoJornada = false,
    String? motivoJornadaComplementar,
  }) =>
      EscalaEquipeSelecao(
        membroEquipeId: membroEquipeId,
        tipoJornada:
            limparTipoJornada ? null : (tipoJornada ?? this.tipoJornada),
        motivoJornadaComplementar:
            motivoJornadaComplementar ?? this.motivoJornadaComplementar,
      );
}

class EscalaAtividadeEntrada {
  const EscalaAtividadeEntrada({
    this.atividadeId,
    required this.naturezaAtividade,
    required this.secaoId,
    required this.tipoAtividadeId,
    required this.titulo,
    required this.descricao,
    required this.turnoId,
    required this.qtrHorario,
    required this.horaInicio,
    required this.horaFim,
    required this.qthLocal,
    required this.qthEndereco,
    required this.qthRegionalId,
    required this.qthPontoReferencia,
    required this.orientacaoOperacional,
    required this.coordenadorMembroEquipeId,
    required this.equipe,
  });

  final String? atividadeId;
  final String naturezaAtividade;
  final String secaoId;
  final String tipoAtividadeId;
  final String titulo;
  final String descricao;
  final String turnoId;
  final String qtrHorario;
  final String horaInicio;
  final String horaFim;
  final String qthLocal;
  final String qthEndereco;
  final String qthRegionalId;
  final String qthPontoReferencia;
  final String orientacaoOperacional;
  final String coordenadorMembroEquipeId;
  final List<EscalaEquipeSelecao> equipe;
}

class EscalaPreparacaoAtividade {
  const EscalaPreparacaoAtividade({
    required this.bloqueios,
    required this.alertas,
  });
  final List<String> bloqueios;
  final List<String> alertas;
  bool get valida => bloqueios.isEmpty;
}

class EscalaGestaoValidationException implements Exception {
  const EscalaGestaoValidationException(this.mensagens);
  final List<String> mensagens;
  @override
  String toString() => mensagens.join('\n');
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/models/membro_equipe_model.dart';
import '../models/escala_models.dart';
import '../services/escala_horas_service.dart';
import 'escala_configuracao_repository.dart';
import 'escala_gestao_repository.dart';
import 'escala_repository.dart';

class FirestoreEscalaRepository
    implements
        EscalaRepository,
        EscalaGestaoRepository,
        EscalaConfiguracaoRepository {
  FirestoreEscalaRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<EscalaDiaConsulta> carregarDia(DateTime data) async {
    final inicio = _somenteData(data);
    final escala = await _localizarEscala(inicio, preferirRascunho: false);

    if (escala == null) {
      return EscalaDiaConsulta.vazia(inicio);
    }

    if (escala.status != EscalaCodigos.statusPublicada) {
      return EscalaDiaConsulta(
        data: inicio,
        escala: escala,
        atividades: const <EscalaAtividadeModel>[],
        alocacoes: const <EscalaAlocacaoModel>[],
        indisponibilidades: const <EscalaIndisponibilidadeModel>[],
      );
    }

    return _carregarDiaComFilhos(data: inicio, escala: escala);
  }

  @override
  Future<void> salvarHorasRealizadas({
    required String alocacaoId,
    required String usuarioId,
    required String horaInicioReal,
    required String horaFimReal,
    required int minutosRealizados,
    required String observacao,
    required DateTime atualizadoEm,
  }) async {
    final id = alocacaoId.trim();
    final uid = usuarioId.trim();
    final inicio = horaInicioReal.trim();
    final fim = horaFimReal.trim();
    final minutos = EscalaHorasService.calcularDuracaoMinutos(
      inicio: inicio,
      fim: fim,
    );

    if (id.isEmpty || uid.isEmpty) {
      throw StateError('Alocação e usuário são obrigatórios.');
    }
    if (minutos == null ||
        minutos != minutosRealizados ||
        minutosRealizados < 0 ||
        minutosRealizados > 1440) {
      throw StateError('Intervalo de horas realizadas inválido.');
    }

    final alocacaoRef = _firestore.collection('escala_alocacoes').doc(id);

    await _firestore.runTransaction((transaction) async {
      final alocacaoSnapshot = await transaction.get(alocacaoRef);
      final alocacaoMap = alocacaoSnapshot.data();

      if (!alocacaoSnapshot.exists || alocacaoMap == null) {
        throw StateError('Alocação não encontrada.');
      }

      final alocacao = EscalaAlocacaoModel.fromMap(
        alocacaoMap,
        documentId: alocacaoSnapshot.id,
      );
      if (alocacao.usuarioId.trim() != uid) {
        throw StateError('Somente o titular registra as próprias horas.');
      }

      final escalaRef = _firestore.collection('escalas').doc(alocacao.escalaId);
      final escalaSnapshot = await transaction.get(escalaRef);
      final escalaMap = escalaSnapshot.data();
      if (!escalaSnapshot.exists || escalaMap == null) {
        throw StateError('Escala da alocação não encontrada.');
      }

      final escala = EscalaModel.fromMap(
        escalaMap,
        documentId: escalaSnapshot.id,
      );
      if (escala.status != EscalaCodigos.statusPublicada) {
        throw StateError('Horas realizadas exigem escala publicada.');
      }

      transaction.update(alocacaoRef, <String, dynamic>{
        'horaInicioReal': inicio,
        'horaFimReal': fim,
        'minutosRealizados': minutosRealizados,
        'observacao': observacao.trim(),
        'atualizadoPor': uid,
        'atualizadoEm': Timestamp.fromDate(atualizadoEm),
      });
    });
  }

  @override
  Future<EscalaConfiguracaoModel?> carregarConfiguracao() async {
    final snapshot = await _firestore
        .collection('escala_configuracoes')
        .doc('principal')
        .get();

    final map = snapshot.data();
    if (!snapshot.exists || map == null) return null;

    return EscalaConfiguracaoModel.fromMap(map, documentId: snapshot.id);
  }

  @override
  Future<EscalaConfiguracaoDados> carregarConfiguracaoOperacional() async {
    final resultados = await Future.wait<dynamic>([
      carregarConfiguracao(),
      _firestore.collection('escala_perfis_operacionais').get(),
      _firestore.collection('equipe_operacional').orderBy('nome').get(),
    ]);

    final configuracao = resultados[0] as EscalaConfiguracaoModel?;
    final perfisSnapshot = resultados[1] as QuerySnapshot<Map<String, dynamic>>;
    final membrosSnapshot =
        resultados[2] as QuerySnapshot<Map<String, dynamic>>;

    final perfis = perfisSnapshot.docs
        .map(
          (doc) => EscalaPerfilOperacionalModel.fromMap(
            doc.data(),
            documentId: doc.id,
          ),
        )
        .toList(growable: false);

    final membros = membrosSnapshot.docs
        .map((doc) => MembroEquipeModel.fromMap(doc.data(), documentId: doc.id))
        .toList(growable: false);

    return EscalaConfiguracaoDados(
      configuracao: configuracao,
      membrosEquipe: List<MembroEquipeModel>.unmodifiable(membros),
      perfisOperacionais: List<EscalaPerfilOperacionalModel>.unmodifiable(
        perfis,
      ),
    );
  }

  @override
  Future<void> salvarConfiguracaoEscala(
    EscalaConfiguracaoModel configuracao,
  ) async {
    await _firestore
        .collection('escala_configuracoes')
        .doc('principal')
        .set(configuracao.toMap());
  }

  @override
  Future<void> salvarPerfilOperacional(
    EscalaPerfilOperacionalModel perfil,
  ) async {
    await _firestore
        .collection('escala_perfis_operacionais')
        .doc(perfil.id)
        .set(perfil.toMap());
  }

  @override
  Future<EscalaGestaoDados> carregarGestao(DateTime data) async {
    final inicio = _somenteData(data);

    final resultados = await Future.wait<dynamic>([
      carregarConfiguracao(),
      _localizarEscala(inicio, preferirRascunho: true),
      _firestore.collection('escala_perfis_operacionais').get(),
      _firestore.collection('equipe_operacional').orderBy('nome').get(),
    ]);

    final configuracao = resultados[0] as EscalaConfiguracaoModel?;
    final escala = resultados[1] as EscalaModel?;
    final perfisSnapshot = resultados[2] as QuerySnapshot<Map<String, dynamic>>;
    final membrosSnapshot =
        resultados[3] as QuerySnapshot<Map<String, dynamic>>;

    final perfis = perfisSnapshot.docs
        .map(
          (doc) => EscalaPerfilOperacionalModel.fromMap(
            doc.data(),
            documentId: doc.id,
          ),
        )
        .toList(growable: false);

    final membros = membrosSnapshot.docs
        .map((doc) => MembroEquipeModel.fromMap(doc.data(), documentId: doc.id))
        .toList(growable: false);

    final dia = escala == null
        ? await _carregarDiaSemEscala(inicio)
        : await _carregarDiaComFilhos(data: inicio, escala: escala);

    return EscalaGestaoDados(
      dia: dia,
      configuracao: configuracao,
      membrosEquipe: List<MembroEquipeModel>.unmodifiable(membros),
      perfisOperacionais: List<EscalaPerfilOperacionalModel>.unmodifiable(
        perfis,
      ),
    );
  }

  @override
  Future<void> criarRascunho(EscalaModel escala) async {
    final inicio = _somenteData(escala.data);
    final fim = inicio.add(const Duration(days: 1));

    final existentes = await _firestore
        .collection('escalas')
        .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
        .where('data', isLessThan: Timestamp.fromDate(fim))
        .limit(1)
        .get();

    if (existentes.docs.isNotEmpty) {
      throw StateError('Já existe uma escala para a data selecionada.');
    }

    final ref = _firestore.collection('escalas').doc(_idData(inicio));

    await _firestore.runTransaction((transaction) async {
      final atual = await transaction.get(ref);
      if (atual.exists) {
        throw StateError('Já existe uma escala para a data selecionada.');
      }
      transaction.set(ref, escala.toMap());
    });
  }

  @override
  Future<void> salvarAtividadeComEquipe(
    EscalaAtividadePersistencia persistencia,
  ) async {
    final batch = _firestore.batch();

    batch.set(
      _firestore.collection('escala_atividades').doc(persistencia.atividade.id),
      persistencia.atividade.toMap(),
    );

    for (final alocacao in persistencia.alocacoes) {
      batch.set(
        _firestore.collection('escala_alocacoes').doc(alocacao.id),
        alocacao.toMap(),
      );
    }

    for (final id in persistencia.removerAlocacaoIds) {
      batch.delete(_firestore.collection('escala_alocacoes').doc(id));
    }

    await batch.commit();
  }

  @override
  Future<void> publicarEscala({
    required EscalaModel escalaAtual,
    required String usuarioId,
    required DateTime agora,
  }) async {
    final uid = usuarioId.trim();

    if (uid.isEmpty) {
      throw StateError('Usuário inválido para publicação.');
    }
    if (escalaAtual.status != EscalaCodigos.statusRascunho) {
      throw StateError('Somente rascunho pode ser publicado.');
    }
    if (escalaAtual.versao > 1 && !escalaAtual.revisaoPreparada) {
      throw StateError('A revisão ainda não terminou de ser preparada.');
    }

    final candidatas = await _buscarEscalasDaData(escalaAtual.data);
    final anterioresPublicadas = candidatas
        .where(
          (item) =>
              item.id != escalaAtual.id &&
              item.status == EscalaCodigos.statusPublicada,
        )
        .toList(growable: false);

    final batch = _firestore.batch();

    batch.update(
      _firestore.collection('escalas').doc(escalaAtual.id),
      <String, dynamic>{
        'status': EscalaCodigos.statusPublicada,
        'publicadoPor': uid,
        'publicadoEm': Timestamp.fromDate(agora),
        'atualizadoPor': uid,
        'atualizadoEm': Timestamp.fromDate(agora),
      },
    );

    for (final anterior in anterioresPublicadas) {
      batch.update(
        _firestore.collection('escalas').doc(anterior.id),
        <String, dynamic>{
          'status': EscalaCodigos.statusArquivada,
          'atualizadoPor': uid,
          'atualizadoEm': Timestamp.fromDate(agora),
        },
      );
    }

    await batch.commit();
  }

  @override
  Future<void> prepararRevisao({
    required EscalaModel escalaAtual,
    required String motivo,
    required String usuarioId,
    required DateTime agora,
  }) async {
    final uid = usuarioId.trim();
    final motivoNormalizado = motivo.trim();

    if (uid.isEmpty) {
      throw StateError('Usuário inválido para revisão.');
    }

    late final EscalaModel origem;
    EscalaModel? revisaoRecebida;

    if (escalaAtual.status == EscalaCodigos.statusPublicada) {
      origem = escalaAtual;
    } else if (escalaAtual.status == EscalaCodigos.statusRascunho &&
        escalaAtual.versao > 1 &&
        escalaAtual.revisaoDeEscalaId.trim().isNotEmpty &&
        !escalaAtual.revisaoPreparada) {
      final encontrada = await _carregarEscalaPorId(
        escalaAtual.revisaoDeEscalaId,
      );

      if (encontrada == null ||
          encontrada.status != EscalaCodigos.statusPublicada) {
        throw StateError(
          'A versão publicada de origem da revisão não está disponível.',
        );
      }

      origem = encontrada;
      revisaoRecebida = escalaAtual;
    } else {
      throw StateError(
        'A revisão deve iniciar a partir de uma versão publicada.',
      );
    }

    final motivoEfetivo =
        revisaoRecebida?.motivoRevisao.trim().isNotEmpty == true
            ? revisaoRecebida!.motivoRevisao.trim()
            : motivoNormalizado;

    if (motivoEfetivo.isEmpty) {
      throw StateError('Informe o motivo da revisão.');
    }

    final novaVersao = origem.versao + 1;
    final revisaoId = '${_idData(origem.data)}-v$novaVersao';
    final revisaoRef = _firestore.collection('escalas').doc(revisaoId);

    final revisao = revisaoRecebida ??
        await _firestore.runTransaction<EscalaModel>((transaction) async {
          final snapshot = await transaction.get(revisaoRef);
          final map = snapshot.data();

          if (snapshot.exists && map != null) {
            final existente = EscalaModel.fromMap(map, documentId: snapshot.id);

            _validarRevisaoExistente(
              existente: existente,
              origem: origem,
              novaVersao: novaVersao,
              motivo: motivoEfetivo,
            );

            return existente;
          }

          final nova = EscalaModel(
            id: revisaoId,
            data: _somenteData(origem.data),
            status: EscalaCodigos.statusRascunho,
            versao: novaVersao,
            observacaoGeral: origem.observacaoGeral,
            motivoRevisao: motivoEfetivo,
            revisaoDeEscalaId: origem.id,
            revisaoPreparada: false,
            criadoPor: uid,
            criadoEm: agora,
            atualizadoPor: uid,
            atualizadoEm: agora,
            publicadoPor: '',
            publicadoEm: null,
          );

          transaction.set(revisaoRef, nova.toMap());
          return nova;
        });

    _validarRevisaoExistente(
      existente: revisao,
      origem: origem,
      novaVersao: novaVersao,
      motivo: motivoEfetivo,
    );

    if (revisao.revisaoPreparada) {
      return;
    }

    final origemDia = await _carregarDiaComFilhos(
      data: origem.data,
      escala: origem,
    );

    await _clonarAtividadesPendentes(
      origem: origemDia.atividades,
      escalaDestinoId: revisao.id,
      versaoDestino: revisao.versao,
      usuarioId: uid,
      agora: agora,
    );

    await _clonarAlocacoesPendentes(
      origem: origemDia.alocacoes,
      escalaDestinoId: revisao.id,
      versaoDestino: revisao.versao,
      usuarioId: uid,
      agora: agora,
    );

    await revisaoRef.update(<String, dynamic>{
      'revisaoPreparada': true,
      'atualizadoPor': uid,
      'atualizadoEm': Timestamp.fromDate(agora),
    });
  }

  @override
  String novoIdAtividade() =>
      _firestore.collection('escala_atividades').doc().id;

  @override
  String novoIdAlocacao() => _firestore.collection('escala_alocacoes').doc().id;

  void _validarRevisaoExistente({
    required EscalaModel existente,
    required EscalaModel origem,
    required int novaVersao,
    required String motivo,
  }) {
    if (existente.status != EscalaCodigos.statusRascunho ||
        existente.versao != novaVersao ||
        existente.revisaoDeEscalaId != origem.id) {
      throw StateError('Já existe uma revisão incompatível para esta data.');
    }

    if (existente.motivoRevisao.trim() != motivo) {
      throw StateError('Já existe uma revisão em andamento com outro motivo.');
    }
  }

  Future<void> _clonarAtividadesPendentes({
    required List<EscalaAtividadeModel> origem,
    required String escalaDestinoId,
    required int versaoDestino,
    required String usuarioId,
    required DateTime agora,
  }) async {
    for (final item in origem) {
      final cloneId = _idCloneAtividade(item.id, versaoDestino);
      final cloneRef = _firestore.collection('escala_atividades').doc(cloneId);

      await _firestore.runTransaction((transaction) async {
        final existente = await transaction.get(cloneRef);
        if (existente.exists) return;

        final clone = EscalaAtividadeModel(
          id: cloneId,
          escalaId: escalaDestinoId,
          data: _somenteData(item.data),
          secaoId: item.secaoId,
          tipoAtividadeId: item.tipoAtividadeId,
          naturezaAtividade: item.naturezaAtividade,
          titulo: item.titulo,
          descricao: item.descricao,
          turnoId: item.turnoId,
          qtrHorario: item.qtrHorario,
          horaInicio: item.horaInicio,
          horaFim: item.horaFim,
          qthLocal: item.qthLocal,
          qthEndereco: item.qthEndereco,
          qthRegionalId: item.qthRegionalId,
          qthPontoReferencia: item.qthPontoReferencia,
          orientacaoOperacional: item.orientacaoOperacional,
          coordenadorMembroEquipeId: item.coordenadorMembroEquipeId,
          coordenadorUsuarioId: item.coordenadorUsuarioId,
          coordenadorNomeSnapshot: item.coordenadorNomeSnapshot,
          participanteUsuarioIds: item.participanteUsuarioIds,
          geraRae: item.geraRae,
          contabilizaProdutividade: item.contabilizaProdutividade,
          raeId: item.raeId,
          execucaoMissaoId: item.execucaoMissaoId,
          status: item.status,
          criadoPor: usuarioId,
          criadoEm: agora,
          atualizadoPor: usuarioId,
          atualizadoEm: agora,
        );

        transaction.set(cloneRef, clone.toMap());
      });
    }
  }

  Future<void> _clonarAlocacoesPendentes({
    required List<EscalaAlocacaoModel> origem,
    required String escalaDestinoId,
    required int versaoDestino,
    required String usuarioId,
    required DateTime agora,
  }) async {
    for (final item in origem) {
      final cloneId = _idCloneAlocacao(item.id, versaoDestino);
      final cloneRef = _firestore.collection('escala_alocacoes').doc(cloneId);

      await _firestore.runTransaction((transaction) async {
        final existente = await transaction.get(cloneRef);
        if (existente.exists) return;

        final clone = EscalaAlocacaoModel(
          id: cloneId,
          escalaId: escalaDestinoId,
          atividadeId: _idCloneAtividade(item.atividadeId, versaoDestino),
          data: _somenteData(item.data),
          membroEquipeId: item.membroEquipeId,
          usuarioId: item.usuarioId,
          nomeSnapshot: item.nomeSnapshot,
          vinculoSnapshot: item.vinculoSnapshot,
          setorSnapshot: item.setorSnapshot,
          cargaHorariaSnapshot: item.cargaHorariaSnapshot,
          funcaoNaAtividade: item.funcaoNaAtividade,
          turnoId: item.turnoId,
          horaInicio: item.horaInicio,
          horaFim: item.horaFim,
          tipoJornada: item.tipoJornada,
          horaInicioReal: item.horaInicioReal,
          horaFimReal: item.horaFimReal,
          minutosPrevistos: item.minutosPrevistos,
          minutosRealizados: item.minutosRealizados,
          motivoJornadaComplementar: item.motivoJornadaComplementar,
          classificadoPor: item.classificadoPor,
          classificadoEm: item.classificadoEm,
          origemAlocacaoId: item.id,
          observacao: item.observacao,
          criadoPor: usuarioId,
          criadoEm: agora,
          atualizadoPor: usuarioId,
          atualizadoEm: agora,
        );

        transaction.set(cloneRef, clone.toMap());
      });
    }
  }

  Future<EscalaModel?> _carregarEscalaPorId(String id) async {
    final snapshot =
        await _firestore.collection('escalas').doc(id.trim()).get();

    final map = snapshot.data();
    if (!snapshot.exists || map == null) return null;

    return EscalaModel.fromMap(map, documentId: snapshot.id);
  }

  Future<List<EscalaModel>> _buscarEscalasDaData(DateTime data) async {
    final inicio = _somenteData(data);
    final fim = inicio.add(const Duration(days: 1));
    final candidatos = <String, EscalaModel>{};

    final porId =
        await _firestore.collection('escalas').doc(_idData(inicio)).get();

    final porIdMap = porId.data();
    if (porId.exists && porIdMap != null) {
      candidatos[porId.id] = EscalaModel.fromMap(
        porIdMap,
        documentId: porId.id,
      );
    }

    final porData = await _firestore
        .collection('escalas')
        .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
        .where('data', isLessThan: Timestamp.fromDate(fim))
        .get();

    for (final doc in porData.docs) {
      candidatos[doc.id] = EscalaModel.fromMap(doc.data(), documentId: doc.id);
    }

    return candidatos.values.toList(growable: false);
  }

  Future<EscalaModel?> _localizarEscala(
    DateTime data, {
    required bool preferirRascunho,
  }) async {
    final candidatas = await _buscarEscalasDaData(data);
    if (candidatas.isEmpty) return null;

    final escalas = candidatas.toList()
      ..sort((a, b) {
        final prioridadeA = _prioridadeStatus(
          a.status,
          preferirRascunho: preferirRascunho,
        );
        final prioridadeB = _prioridadeStatus(
          b.status,
          preferirRascunho: preferirRascunho,
        );

        final porStatus = prioridadeB.compareTo(prioridadeA);
        if (porStatus != 0) return porStatus;

        final porVersao = b.versao.compareTo(a.versao);
        if (porVersao != 0) return porVersao;

        return a.id.compareTo(b.id);
      });

    return escalas.first;
  }

  Future<EscalaDiaConsulta> _carregarDiaSemEscala(DateTime data) async {
    return EscalaDiaConsulta(
      data: data,
      escala: null,
      atividades: const <EscalaAtividadeModel>[],
      alocacoes: const <EscalaAlocacaoModel>[],
      indisponibilidades: await _carregarIndisponibilidades(data),
    );
  }

  Future<EscalaDiaConsulta> _carregarDiaComFilhos({
    required DateTime data,
    required EscalaModel escala,
  }) async {
    final resultados = await Future.wait<dynamic>([
      _firestore
          .collection('escala_atividades')
          .where('escalaId', isEqualTo: escala.id)
          .get(),
      _firestore
          .collection('escala_alocacoes')
          .where('escalaId', isEqualTo: escala.id)
          .get(),
      _carregarIndisponibilidades(data),
    ]);

    final atividadesSnapshot =
        resultados[0] as QuerySnapshot<Map<String, dynamic>>;
    final alocacoesSnapshot =
        resultados[1] as QuerySnapshot<Map<String, dynamic>>;
    final indisponibilidades =
        resultados[2] as List<EscalaIndisponibilidadeModel>;

    final atividades = atividadesSnapshot.docs
        .map(
          (doc) => EscalaAtividadeModel.fromMap(doc.data(), documentId: doc.id),
        )
        .where((item) => _mesmoDia(item.data, data))
        .toList()
      ..sort(_compararAtividades);

    final alocacoes = alocacoesSnapshot.docs
        .map(
          (doc) => EscalaAlocacaoModel.fromMap(doc.data(), documentId: doc.id),
        )
        .where((item) => _mesmoDia(item.data, data))
        .toList()
      ..sort(_compararAlocacoes);

    return EscalaDiaConsulta(
      data: data,
      escala: escala,
      atividades: List<EscalaAtividadeModel>.unmodifiable(atividades),
      alocacoes: List<EscalaAlocacaoModel>.unmodifiable(alocacoes),
      indisponibilidades: indisponibilidades,
    );
  }

  Future<List<EscalaIndisponibilidadeModel>> _carregarIndisponibilidades(
    DateTime data,
  ) async {
    final inicio = _somenteData(data);
    final fim = inicio.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('escala_indisponibilidades')
        .where('dataInicio', isLessThan: Timestamp.fromDate(fim))
        .get();

    final itens = snapshot.docs
        .map(
          (doc) => EscalaIndisponibilidadeModel.fromMap(
            doc.data(),
            documentId: doc.id,
          ),
        )
        .where((item) => _abrangeDia(item, inicio))
        .toList()
      ..sort((a, b) => a.nomeSnapshot.compareTo(b.nomeSnapshot));

    return List<EscalaIndisponibilidadeModel>.unmodifiable(itens);
  }

  static int _prioridadeStatus(
    String status, {
    required bool preferirRascunho,
  }) {
    if (preferirRascunho) {
      if (status == EscalaCodigos.statusRascunho) return 3;
      if (status == EscalaCodigos.statusPublicada) return 2;
      if (status == EscalaCodigos.statusArquivada) return 1;
      return 0;
    }

    if (status == EscalaCodigos.statusPublicada) return 3;
    if (status == EscalaCodigos.statusRascunho) return 2;
    if (status == EscalaCodigos.statusArquivada) return 1;
    return 0;
  }

  static String _idCloneAtividade(String origemId, int versao) =>
      'atividade-v$versao-$origemId';

  static String _idCloneAlocacao(String origemId, int versao) =>
      'alocacao-v$versao-$origemId';

  static String _idData(DateTime data) {
    final dia = _somenteData(data);
    return '${dia.year.toString().padLeft(4, '0')}-'
        '${dia.month.toString().padLeft(2, '0')}-'
        '${dia.day.toString().padLeft(2, '0')}';
  }

  static DateTime _somenteData(DateTime data) =>
      DateTime(data.year, data.month, data.day);

  static bool _mesmoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool _abrangeDia(EscalaIndisponibilidadeModel item, DateTime data) {
    final dia = _somenteData(data);
    final inicio = _somenteData(item.dataInicio);
    final fim = _somenteData(item.dataFim);

    if (fim.isBefore(inicio)) return false;
    return !dia.isBefore(inicio) && !dia.isAfter(fim);
  }

  static int _compararAtividades(
    EscalaAtividadeModel a,
    EscalaAtividadeModel b,
  ) {
    final secao = a.secaoId.compareTo(b.secaoId);
    if (secao != 0) return secao;

    final horarioA = a.horaInicio.trim().isNotEmpty
        ? a.horaInicio.trim()
        : a.qtrHorario.trim();
    final horarioB = b.horaInicio.trim().isNotEmpty
        ? b.horaInicio.trim()
        : b.qtrHorario.trim();

    final horario = horarioA.compareTo(horarioB);
    if (horario != 0) return horario;

    return a.titulo.compareTo(b.titulo);
  }

  static int _compararAlocacoes(EscalaAlocacaoModel a, EscalaAlocacaoModel b) {
    final atividade = a.atividadeId.compareTo(b.atividadeId);
    if (atividade != 0) return atividade;

    final nome = a.nomeSnapshot.compareTo(b.nomeSnapshot);
    if (nome != 0) return nome;

    return a.id.compareTo(b.id);
  }
}

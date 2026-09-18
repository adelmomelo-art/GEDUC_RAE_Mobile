import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/models/membro_equipe_model.dart';
import '../models/escala_models.dart';
import 'escala_gestao_repository.dart';
import 'escala_repository.dart';

class FirestoreEscalaRepository
    implements EscalaRepository, EscalaGestaoRepository {
  FirestoreEscalaRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<EscalaDiaConsulta> carregarDia(DateTime data) async {
    final inicio = _somenteData(data);
    final escala = await _localizarEscala(inicio);
    if (escala == null) return EscalaDiaConsulta.vazia(inicio);

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
  Future<EscalaGestaoDados> carregarGestao(DateTime data) async {
    final inicio = _somenteData(data);
    final resultados = await Future.wait<dynamic>([
      carregarConfiguracao(),
      _localizarEscala(inicio),
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

    // Compatibilidade com documentos legados cujo ID ainda nao seja yyyy-MM-dd.
    final existentes = await _firestore
        .collection('escalas')
        .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
        .where('data', isLessThan: Timestamp.fromDate(fim))
        .limit(1)
        .get();
    if (existentes.docs.isNotEmpty) {
      throw StateError('Ja existe uma escala para a data selecionada.');
    }

    final ref = _firestore.collection('escalas').doc(_idData(inicio));
    await _firestore.runTransaction((transaction) async {
      final atual = await transaction.get(ref);
      if (atual.exists) {
        throw StateError('Ja existe uma escala para a data selecionada.');
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
  String novoIdAtividade() =>
      _firestore.collection('escala_atividades').doc().id;

  @override
  String novoIdAlocacao() => _firestore.collection('escala_alocacoes').doc().id;

  Future<EscalaModel?> _localizarEscala(DateTime data) async {
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
    if (candidatos.isEmpty) return null;

    final escalas = candidatos.values.toList()
      ..sort((a, b) {
        final publicadaA = a.status == EscalaCodigos.statusPublicada ? 1 : 0;
        final publicadaB = b.status == EscalaCodigos.statusPublicada ? 1 : 0;
        final porPublicacao = publicadaB.compareTo(publicadaA);
        if (porPublicacao != 0) return porPublicacao;
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

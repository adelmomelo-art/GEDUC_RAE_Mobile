import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/escala_models.dart';
import 'escala_repository.dart';

class FirestoreEscalaRepository implements EscalaRepository {
  FirestoreEscalaRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<EscalaDiaConsulta> carregarDia(DateTime data) async {
    final inicio = DateTime(data.year, data.month, data.day);
    final fim = inicio.add(const Duration(days: 1));
    final candidatos = <String, EscalaModel>{};

    final idDeterministico = _idData(inicio);
    final porId = await _firestore
        .collection('escalas')
        .doc(idDeterministico)
        .get();

    if (porId.exists) {
      final map = porId.data();
      if (map != null) {
        candidatos[porId.id] = EscalaModel.fromMap(map, documentId: porId.id);
      }
    }

    final porData = await _firestore
        .collection('escalas')
        .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
        .where('data', isLessThan: Timestamp.fromDate(fim))
        .get();

    for (final doc in porData.docs) {
      candidatos[doc.id] = EscalaModel.fromMap(doc.data(), documentId: doc.id);
    }

    if (candidatos.isEmpty) {
      return EscalaDiaConsulta.vazia(inicio);
    }

    final escalas = candidatos.values.toList()
      ..sort((a, b) {
        final porVersao = b.versao.compareTo(a.versao);
        if (porVersao != 0) return porVersao;
        return a.id.compareTo(b.id);
      });

    final publicadas = escalas
        .where((item) => item.status == EscalaCodigos.statusPublicada)
        .toList();

    final escala = publicadas.isNotEmpty ? publicadas.first : escalas.first;

    if (escala.status != EscalaCodigos.statusPublicada) {
      return EscalaDiaConsulta(
        data: inicio,
        escala: escala,
        atividades: const <EscalaAtividadeModel>[],
        alocacoes: const <EscalaAlocacaoModel>[],
        indisponibilidades: const <EscalaIndisponibilidadeModel>[],
      );
    }

    final atividadesSnapshot = await _firestore
        .collection('escala_atividades')
        .where('escalaId', isEqualTo: escala.id)
        .get();

    final alocacoesSnapshot = await _firestore
        .collection('escala_alocacoes')
        .where('escalaId', isEqualTo: escala.id)
        .get();

    // A indisponibilidade não pertence a uma escala específica. Para evitar
    // exigir índice composto nesta fase, restringimos por dataInicio e
    // filtramos dataFim localmente.
    final indisponibilidadesSnapshot = await _firestore
        .collection('escala_indisponibilidades')
        .where('dataInicio', isLessThan: Timestamp.fromDate(fim))
        .get();

    final atividades =
        atividadesSnapshot.docs
            .map(
              (doc) =>
                  EscalaAtividadeModel.fromMap(doc.data(), documentId: doc.id),
            )
            .toList()
          ..sort(_compararAtividades);

    final alocacoes =
        alocacoesSnapshot.docs
            .map(
              (doc) =>
                  EscalaAlocacaoModel.fromMap(doc.data(), documentId: doc.id),
            )
            .where((item) => _mesmoDia(item.data, inicio))
            .toList()
          ..sort(_compararAlocacoes);

    final indisponibilidades =
        indisponibilidadesSnapshot.docs
            .map(
              (doc) => EscalaIndisponibilidadeModel.fromMap(
                doc.data(),
                documentId: doc.id,
              ),
            )
            .where((item) => _abrangeDia(item, inicio))
            .toList()
          ..sort((a, b) => a.nomeSnapshot.compareTo(b.nomeSnapshot));

    return EscalaDiaConsulta(
      data: inicio,
      escala: escala,
      atividades: List<EscalaAtividadeModel>.unmodifiable(atividades),
      alocacoes: List<EscalaAlocacaoModel>.unmodifiable(alocacoes),
      indisponibilidades: List<EscalaIndisponibilidadeModel>.unmodifiable(
        indisponibilidades,
      ),
    );
  }

  static String _idData(DateTime data) {
    return '${data.year.toString().padLeft(4, '0')}-'
        '${data.month.toString().padLeft(2, '0')}-'
        '${data.day.toString().padLeft(2, '0')}';
  }

  static bool _mesmoDia(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool _abrangeDia(EscalaIndisponibilidadeModel item, DateTime data) {
    final dia = DateTime(data.year, data.month, data.day);
    final inicio = DateTime(
      item.dataInicio.year,
      item.dataInicio.month,
      item.dataInicio.day,
    );
    final fim = DateTime(
      item.dataFim.year,
      item.dataFim.month,
      item.dataFim.day,
    );

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

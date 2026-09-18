import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

import '../../../data/models/membro_equipe_model.dart';
import '../models/escala_models.dart';
import '../services/escala_execucao_service.dart';
import 'escala_execucao_repository.dart';

class FirestoreEscalaExecucaoRepository implements EscalaExecucaoRepository {
  FirestoreEscalaExecucaoRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static String gerarIdExecucao({
    required String atividadeId,
    required String usuarioId,
  }) {
    final atividade = atividadeId.trim();
    final uid = usuarioId.trim();

    if (atividade.isEmpty || uid.isEmpty) {
      throw ArgumentError(
        'Atividade e usuário são obrigatórios para o ID de execução.',
      );
    }

    final digest = sha256.convert(utf8.encode('$atividade::$uid')).toString();
    return 'exec-$digest';
  }

  @override
  String idExecucao({
    required String atividadeId,
    required String usuarioId,
  }) =>
      gerarIdExecucao(
        atividadeId: atividadeId,
        usuarioId: usuarioId,
      );

  @override
  Future<EscalaExecucaoContexto> carregarContexto({
    required String atividadeId,
    required String usuarioId,
  }) async {
    final atividadeChave = atividadeId.trim();
    final uid = usuarioId.trim();

    if (atividadeChave.isEmpty || uid.isEmpty) {
      throw StateError('Atividade e usuário são obrigatórios.');
    }

    final atividadeSnapshot = await _firestore
        .collection('escala_atividades')
        .doc(atividadeChave)
        .get();

    final atividadeMap = atividadeSnapshot.data();
    if (!atividadeSnapshot.exists || atividadeMap == null) {
      throw StateError('Atividade da Escala não encontrada.');
    }

    final atividade = EscalaAtividadeModel.fromMap(
      atividadeMap,
      documentId: atividadeSnapshot.id,
    );

    if (atividade.escalaId.trim().isEmpty) {
      throw StateError('Atividade sem vínculo com escala.');
    }

    final escalaSnapshot =
        await _firestore.collection('escalas').doc(atividade.escalaId).get();

    final escalaMap = escalaSnapshot.data();
    if (!escalaSnapshot.exists || escalaMap == null) {
      throw StateError('Escala da atividade não encontrada.');
    }

    final escala = EscalaModel.fromMap(
      escalaMap,
      documentId: escalaSnapshot.id,
    );

    if (escala.status != EscalaCodigos.statusPublicada) {
      throw StateError('A execução exige escala publicada.');
    }

    if (atividade.naturezaAtividade != EscalaCodigos.naturezaAdministrativa ||
        atividade.geraRae) {
      throw StateError(
        'Somente missão administrativa sem RAE usa este fluxo de execução.',
      );
    }

    final execucaoId = gerarIdExecucao(
      atividadeId: atividade.id,
      usuarioId: uid,
    );

    final resultados = await Future.wait<dynamic>([
      _firestore
          .collection('escala_alocacoes')
          .where('atividadeId', isEqualTo: atividade.id)
          .get(),
      _firestore
          .collection('equipe_operacional')
          .where('usuarioId', isEqualTo: uid)
          .get(),
      _firestore.collection('escala_execucoes_missao').doc(execucaoId).get(),
    ]);

    final alocacoesSnapshot =
        resultados[0] as QuerySnapshot<Map<String, dynamic>>;
    final membrosSnapshot =
        resultados[1] as QuerySnapshot<Map<String, dynamic>>;
    final execucaoSnapshot =
        resultados[2] as DocumentSnapshot<Map<String, dynamic>>;

    final equipe = alocacoesSnapshot.docs
        .map(
          (doc) => EscalaAlocacaoModel.fromMap(
            doc.data(),
            documentId: doc.id,
          ),
        )
        .where((item) => item.escalaId == escala.id)
        .toList()
      ..sort((a, b) {
        final porNome = a.nomeSnapshot.compareTo(b.nomeSnapshot);
        if (porNome != 0) return porNome;
        return a.id.compareTo(b.id);
      });

    final membrosAtivos = membrosSnapshot.docs
        .map(
          (doc) => MembroEquipeModel.fromMap(
            doc.data(),
            documentId: doc.id,
          ),
        )
        .where((item) => item.ativo && item.usuarioId.trim() == uid)
        .toList(growable: false);

    if (membrosAtivos.length != 1) {
      throw StateError(
        'Executor sem vínculo canônico único e ativo na Equipe Operacional.',
      );
    }

    ExecucaoMissaoModel? execucao;
    final execucaoMap = execucaoSnapshot.data();
    if (execucaoSnapshot.exists && execucaoMap != null) {
      execucao = ExecucaoMissaoModel.fromMap(
        execucaoMap,
        documentId: execucaoSnapshot.id,
      );

      if (execucao.escalaAtividadeId != atividade.id ||
          execucao.executadoPorUsuarioId.trim() != uid) {
        throw StateError(
            'Execução determinística incompatível com o contexto.');
      }
    }

    return EscalaExecucaoContexto(
      atividade: atividade,
      escala: escala,
      equipe: List<EscalaAlocacaoModel>.unmodifiable(equipe),
      executor: membrosAtivos.single,
      execucao: execucao,
    );
  }

  @override
  Future<ExecucaoMissaoModel> iniciarExecucao(
    ExecucaoMissaoModel execucao,
  ) async {
    final validacao = EscalaExecucaoService.validar(execucao);
    if (!validacao.valida) {
      throw StateError(validacao.erros.join(' '));
    }

    final esperado = gerarIdExecucao(
      atividadeId: execucao.escalaAtividadeId,
      usuarioId: execucao.executadoPorUsuarioId,
    );

    if (execucao.id != esperado) {
      throw StateError(
          'ID de execução não corresponde ao contrato determinístico.');
    }

    final ref =
        _firestore.collection('escala_execucoes_missao').doc(execucao.id);

    return _firestore.runTransaction((transaction) async {
      final existenteSnapshot = await transaction.get(ref);
      final existenteMap = existenteSnapshot.data();

      if (existenteSnapshot.exists && existenteMap != null) {
        final existente = ExecucaoMissaoModel.fromMap(
          existenteMap,
          documentId: existenteSnapshot.id,
        );

        if (existente.escalaAtividadeId != execucao.escalaAtividadeId ||
            existente.executadoPorUsuarioId != execucao.executadoPorUsuarioId) {
          throw StateError('Execução existente incompatível.');
        }

        return existente;
      }

      transaction.set(ref, execucao.toMap());
      return execucao;
    });
  }

  @override
  Future<void> atualizarExecucao(
    ExecucaoMissaoModel execucao,
  ) async {
    final validacao = EscalaExecucaoService.validar(execucao);
    if (!validacao.valida) {
      throw StateError(validacao.erros.join(' '));
    }

    final esperado = gerarIdExecucao(
      atividadeId: execucao.escalaAtividadeId,
      usuarioId: execucao.executadoPorUsuarioId,
    );

    if (execucao.id != esperado) {
      throw StateError(
          'ID de execução não corresponde ao contrato determinístico.');
    }

    final ref =
        _firestore.collection('escala_execucoes_missao').doc(execucao.id);

    await _firestore.runTransaction((transaction) async {
      final atualSnapshot = await transaction.get(ref);
      final atualMap = atualSnapshot.data();

      if (!atualSnapshot.exists || atualMap == null) {
        throw StateError('Execução ainda não foi iniciada.');
      }

      final atual = ExecucaoMissaoModel.fromMap(
        atualMap,
        documentId: atualSnapshot.id,
      );

      if (atual.escalaAtividadeId != execucao.escalaAtividadeId ||
          atual.escalaId != execucao.escalaId ||
          atual.executadoPorUsuarioId != execucao.executadoPorUsuarioId ||
          atual.executadoPorMembroEquipeId !=
              execucao.executadoPorMembroEquipeId ||
          atual.criadoEm != execucao.criadoEm) {
        throw StateError('Identidade imutável da execução foi alterada.');
      }

      if (!EscalaExecucaoService.transicaoStatusValida(
        statusAtual: atual.status,
        proximoStatus: execucao.status,
      )) {
        throw StateError('Transição de status de execução inválida.');
      }

      transaction.update(ref, <String, dynamic>{
        'status': execucao.status.trim(),
        'resultadoResumo': execucao.resultadoResumo.trim(),
        'observacao': execucao.observacao.trim(),
        'evidencias': execucao.evidencias
            .map((item) => item.toMap())
            .toList(growable: false),
        'concluidoEm': execucao.concluidoEm == null
            ? null
            : Timestamp.fromDate(execucao.concluidoEm!),
        'atualizadoEm': Timestamp.fromDate(execucao.atualizadoEm),
      });
    });
  }
}

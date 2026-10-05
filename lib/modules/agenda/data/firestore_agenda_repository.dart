import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/projeto_catalog_service.dart';
import '../../../core/services/localizacao/regional_service.dart';
import '../../../data/models/projeto_model.dart';
import '../../../data/models/regional_model.dart';
import '../../escala/data/firestore_escala_repository.dart';
import '../../escala/data/firestore_escala_execucao_repository.dart';
import '../../escala/models/escala_models.dart';
import '../models/agenda_compromisso.dart';
import '../services/agenda_service.dart';
import 'agenda_repository.dart';

class FirestoreAgendaRepository implements AgendaRepository {
  FirestoreAgendaRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> get _agenda =>
      _db.collection('agenda_operacional');
  FirestoreEscalaRepository get _escalas =>
      FirestoreEscalaRepository(firestore: _db);

  @override
  Future<EscalaConfiguracaoModel?> configuracao() =>
      _escalas.carregarConfiguracao();
  @override
  Future<List<ProjetoModel>> projetos() =>
      ProjetoCatalogService(firestore: _db).listarAtivos();
  @override
  Future<List<RegionalModel>> regionais() =>
      RegionalService(firestore: _db).listarAtivas();
  @override
  String novoId() => _agenda.doc().id;

  @override
  Future<AgendaMes> carregarMes(DateTime mes) async {
    final inicio = DateTime(mes.year, mes.month);
    final fim = DateTime(mes.year, mes.month + 1);
    final resultado = await _agenda
        .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
        .where('data', isLessThan: Timestamp.fromDate(fim))
        .get();
    final itens = resultado.docs
        .map((d) => AgendaCompromisso.fromMap(d.id, d.data()))
        .toList()
      ..sort(
        (a, b) => a.data.compareTo(b.data) != 0
            ? a.data.compareTo(b.data)
            : a.titulo.compareTo(b.titulo),
      );
    final escalas = <String, EscalaModel>{};
    final atividades = <String, EscalaAtividadeModel>{};
    // Os vínculos são lidos somente após a consulta privada ser autorizada.
    final dias = <String, DateTime>{
      for (final item in itens.where((i) => i.vinculada))
        AgendaService.dataId(item.dataVinculada ?? item.data):
            item.dataVinculada ?? item.data,
    };
    await Future.wait(
      dias.values.map((data) async {
        final dia = await _escalas.carregarGestao(data);
        for (final item in itens.where(
          (i) =>
              i.vinculada &&
              AgendaService.dataId(i.dataVinculada ?? i.data) ==
                  AgendaService.dataId(data),
        )) {
          final escala = dia.dia.escala;
          if (escala != null) escalas[item.id] = escala;
          for (final a in dia.dia.atividades) {
            if (a.agendaCompromissoId == item.id) atividades[item.id] = a;
          }
        }
      }),
    );
    return AgendaMes(
      compromissos: itens,
      escalas: escalas,
      atividades: atividades,
    );
  }

  void _validar(AgendaCompromisso item, {bool paraEscala = false}) {
    final erros = AgendaService.validar(item, paraEscala: paraEscala);
    if (erros.isNotEmpty) throw StateError(erros.join('\n'));
  }

  Future<void> _catalogoValido(AgendaCompromisso item) async {
    if (item.projetoId.isEmpty) return;
    final projeto = await ProjetoCatalogService(
      firestore: _db,
    ).buscarAtivoPorId(item.projetoId);
    if (projeto == null) {
      throw StateError(
        'O projeto selecionado não está ativo no Catálogo Institucional.',
      );
    }
  }

  @override
  Future<void> salvar(
    AgendaCompromisso item, {
    required int revisaoEsperada,
    required String usuarioId,
  }) async {
    _validar(item);
    await _catalogoValido(item);
    final ref = _agenda.doc(item.id);
    final anteriorSnapshot = await ref.get();
    final anterior = anteriorSnapshot.data() == null
        ? null
        : AgendaCompromisso.fromMap(item.id, anteriorSnapshot.data()!);
    final remarcando = anterior != null &&
        AgendaService.dataId(anterior.data) != AgendaService.dataId(item.data);
    if (remarcando && item.motivo.trim().isEmpty) {
      throw StateError('Informe o motivo da remarcação.');
    }
    final retirada = remarcando && anterior.vinculada
        ? await _prepararRetirada(anterior)
        : null;
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final atual = snap.data() == null
          ? null
          : AgendaCompromisso.fromMap(item.id, snap.data()!);
      _conferirRevisao(atual, revisaoEsperada);
      if (atual?.cancelada == true) {
        throw StateError('Compromisso cancelado não pode ser editado.');
      }
      if (retirada != null) await _conferirRetirada(tx, retirada);
      final proxima = item.alterar({
        'revisao': revisaoEsperada + 1,
        'criadoPor': atual?.criadoPor ?? usuarioId,
        'criadoEm': atual?.toMap()['criadoEm'] ?? FieldValue.serverTimestamp(),
        'atualizadoPor': usuarioId,
        'atualizadoEm': FieldValue.serverTimestamp(),
        'escalaId': remarcando ? '' : atual?.escalaId ?? '',
        'atividadeId': remarcando ? '' : atual?.atividadeId ?? '',
        'dataVinculada': remarcando ? null : atual?.toMap()['dataVinculada'],
      });
      // FieldValue não pode ser convertido pelo modelo; os tempos são escritos aqui.
      final map = proxima.toMap()
        ..['criadoEm'] =
            atual?.toMap()['criadoEm'] ?? FieldValue.serverTimestamp()
        ..['atualizadoEm'] = FieldValue.serverTimestamp();
      if (retirada != null) _retirar(tx, retirada, usuarioId);
      tx.set(ref, map);
      _evento(
        tx,
        ref,
        proxima.revisao,
        remarcando
            ? 'remarcacao'
            : atual == null
                ? 'cadastro'
                : 'edicao',
        usuarioId,
        item.motivo,
        atual?.data,
        item.data,
      );
    });
  }

  void _conferirRevisao(AgendaCompromisso? atual, int revisaoEsperada) {
    if ((atual?.revisao ?? 0) != revisaoEsperada) {
      throw StateError(
        'O compromisso mudou. Atualize a agenda antes de salvar.',
      );
    }
  }

  @override
  Future<void> cancelar(
    AgendaCompromisso item, {
    required String motivo,
    required String usuarioId,
  }) async {
    if (motivo.trim().isEmpty) {
      throw StateError('Informe o motivo do cancelamento.');
    }
    final retirada = item.vinculada ? await _prepararRetirada(item) : null;
    final ref = _agenda.doc(item.id);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final atual = AgendaCompromisso.fromMap(item.id, snap.data()!);
      _conferirRevisao(atual, item.revisao);
      if (atual.cancelada) throw StateError('O compromisso já está cancelado.');
      if (retirada != null) await _conferirRetirada(tx, retirada);
      if (retirada != null) _retirar(tx, retirada, usuarioId);
      tx.update(ref, {
        'situacao': 'cancelada',
        'motivo': motivo.trim(),
        'revisao': atual.revisao + 1,
        'atualizadoPor': usuarioId,
        'atualizadoEm': FieldValue.serverTimestamp(),
      });
      _evento(
        tx,
        ref,
        atual.revisao + 1,
        'cancelamento',
        usuarioId,
        motivo,
        atual.data,
        atual.data,
      );
    });
  }

  @override
  Future<void> montarEscala(
    AgendaCompromisso item, {
    required String usuarioId,
  }) async {
    _validar(item, paraEscala: true);
    await _catalogoValido(item);
    await _conferirOrigemPublicada(item);
    final gestao = await _escalas.carregarGestao(item.data);
    final existente = gestao.dia.escala;
    if (existente != null &&
        (existente.status != 'rascunho' || !existente.revisaoPreparada)) {
      throw StateError(
        'Abra a Gestão da Escala e prepare uma revisão antes de aplicar o planejamento.',
      );
    }
    final agora = DateTime.now();
    final escala = existente ??
        EscalaModel(
          id: AgendaService.dataId(item.data),
          data: item.data,
          status: 'rascunho',
          versao: 1,
          observacaoGeral: '',
          motivoRevisao: '',
          revisaoDeEscalaId: '',
          revisaoPreparada: true,
          criadoPor: usuarioId,
          criadoEm: agora,
          atualizadoPor: usuarioId,
          atualizadoEm: agora,
          publicadoPor: '',
          publicadoEm: null,
        );
    final candidatas = gestao.dia.atividades
        .where((a) => a.agendaCompromissoId == item.id)
        .toList();
    if (candidatas.length > 1) {
      throw StateError('Mais de uma atividade vinculada. Revise a escala.');
    }
    final anterior = candidatas.isEmpty ? null : candidatas.single;
    if (item.vinculada && anterior == null) {
      throw StateError(
        'O vínculo não foi encontrado na versão atual. Atualize e confira a escala.',
      );
    }
    final idAtividade =
        anterior?.id ?? AgendaService.novaAtividadeId(item.id, escala.id);
    final ref = _agenda.doc(item.id);
    final escalaRef = _db.collection('escalas').doc(escala.id);
    final atividadeRef = _db.collection('escala_atividades').doc(idAtividade);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final atual = AgendaCompromisso.fromMap(item.id, snap.data()!);
      _conferirRevisao(atual, item.revisao);
      _validar(atual, paraEscala: true);
      final escalaSnap = await tx.get(escalaRef);
      final atividadeSnap = await tx.get(atividadeRef);
      if (existente == null && escalaSnap.exists) {
        throw StateError(
          'A escala foi criada por outra sessão. Atualize a agenda.',
        );
      }
      if (existente != null &&
          (escalaSnap.data()?['status'] != 'rascunho' ||
              escalaSnap.data()?['revisaoPreparada'] == false)) {
        throw StateError('A escala mudou de situação. Atualize a agenda.');
      }
      if (anterior == null && atividadeSnap.exists) {
        throw StateError(
          'Esta ação já possui atividade na escala. Atualize a agenda.',
        );
      }
      final a = atividadeSnap.data();
      if (a != null &&
          (a['agendaCompromissoId'] != item.id ||
              a['raeId'] != '' ||
              a['execucaoMissaoId'] != '' ||
              a['status'] == 'cancelada')) {
        throw StateError(
          'Atividade com resultado ou cancelamento não pode receber novo planejamento.',
        );
      }
      final proxima = atual.alterar({'revisao': atual.revisao + 1});
      final base = a ??
          EscalaAtividadeModel(
            id: idAtividade,
            escalaId: escala.id,
            data: atual.data,
            secaoId: atual.secaoId,
            tipoAtividadeId: 'agenda',
            naturezaAtividade: atual.natureza,
            titulo: atual.titulo,
            descricao: '',
            turnoId: atual.turno,
            qtrHorario: '',
            horaInicio: '',
            horaFim: '',
            qthLocal: '',
            qthEndereco: '',
            qthRegionalId: '',
            qthPontoReferencia: '',
            orientacaoOperacional: '',
            coordenadorMembroEquipeId: '',
            coordenadorUsuarioId: '',
            coordenadorNomeSnapshot: '',
            participanteUsuarioIds: const [],
            geraRae: atual.natureza == 'educativa',
            contabilizaProdutividade: true,
            raeId: '',
            execucaoMissaoId: '',
            status: 'planejada',
            criadoPor: usuarioId,
            criadoEm: agora,
            atualizadoPor: usuarioId,
            atualizadoEm: agora,
          ).toMap();
      if (!escalaSnap.exists) tx.set(escalaRef, escala.toMap());
      tx.set(atividadeRef, {
        ...base,
        ...AgendaService.camposPublicos(proxima),
        'atualizadoPor': usuarioId,
        'atualizadoEm': FieldValue.serverTimestamp(),
      });
      tx.update(ref, {
        'escalaId': escala.id,
        'atividadeId': idAtividade,
        'dataVinculada': Timestamp.fromDate(atual.data),
        'revisao': proxima.revisao,
        'atualizadoPor': usuarioId,
        'atualizadoEm': FieldValue.serverTimestamp(),
      });
      _evento(
        tx,
        ref,
        proxima.revisao,
        anterior == null ? 'vinculacao' : 'aplicacao',
        usuarioId,
        '',
        atual.data,
        atual.data,
      );
    });
  }

  Future<void> _conferirOrigemPublicada(AgendaCompromisso item) async {
    final familia = await _db
        .collection('escala_atividades')
        .where('agendaCompromissoId', isEqualTo: item.id)
        .get();
    for (final a in familia.docs) {
      final map = a.data();
      final data = (map['data'] as Timestamp).toDate();
      if (AgendaService.dataId(data) == AgendaService.dataId(item.data)) {
        continue;
      }
      final escala =
          await _db.collection('escalas').doc(map['escalaId'] as String).get();
      if (escala.data()?['status'] == 'publicada' &&
          map['status'] != 'cancelada') {
        throw StateError(
          'Publique a retirada da ação na escala de ${AgendaService.dataId(data)} antes de montar a nova data.',
        );
      }
    }
  }

  Future<_Retirada> _prepararRetirada(AgendaCompromisso item) async {
    final gestao = await _escalas.carregarGestao(
      item.dataVinculada ?? item.data,
    );
    final escala = gestao.dia.escala;
    if (escala == null ||
        escala.status != 'rascunho' ||
        !escala.revisaoPreparada) {
      throw StateError(
        'Prepare uma revisão da escala de origem antes de cancelar ou remarcar a ação.',
      );
    }
    final atividades = gestao.dia.atividades
        .where((a) => a.agendaCompromissoId == item.id)
        .toList();
    if (atividades.length != 1) {
      throw StateError('Não foi possível identificar a atividade vinculada.');
    }
    final a = atividades.single;
    final alocacoes =
        gestao.dia.alocacoes.where((v) => v.atividadeId == a.id).toList();
    final familia = await _db
        .collection('escala_atividades')
        .where('agendaCompromissoId', isEqualTo: item.id)
        .get();
    final origens = familia.docs
        .map((d) => EscalaAtividadeModel.fromMap(
              d.data(),
              documentId: d.id,
            ))
        .toList();
    // A execução administrativa não altera o documento da atividade.
    // Conferimos também resultados registrados nas versões anteriores.
    final alocacoesHistoricas = <String, EscalaAlocacaoModel>{};
    for (final origem in origens) {
      final execucoes = await _db
          .collection('escala_execucoes_missao')
          .where('escalaAtividadeId', isEqualTo: origem.id)
          .limit(1)
          .get();
      if (execucoes.docs.isNotEmpty) {
        throw StateError(
            'Há execução registrada. Preserve o histórico e confira a escala.');
      }
      final equipe = await _db
          .collection('escala_alocacoes')
          .where('atividadeId', isEqualTo: origem.id)
          .get();
      for (final doc in equipe.docs) {
        alocacoesHistoricas[doc.id] = EscalaAlocacaoModel.fromMap(
          doc.data(),
          documentId: doc.id,
        );
      }
    }
    return _Retirada(
        escala, a, alocacoes, origens, alocacoesHistoricas.values.toList());
  }

  Future<void> _conferirRetirada(Transaction tx, _Retirada r) async {
    final escala = await tx.get(_db.collection('escalas').doc(r.escala.id));
    final a = await tx.get(
      _db.collection('escala_atividades').doc(r.atividade.id),
    );
    if (escala.data()?['status'] != 'rascunho' ||
        escala.data()?['revisaoPreparada'] == false) {
      throw StateError('A escala de origem precisa estar em rascunho.');
    }
    if (a.data()?['atualizadoEm'] !=
        Timestamp.fromDate(r.atividade.atualizadoEm)) {
      throw StateError('A equipe da atividade mudou. Atualize a agenda.');
    }
    if (a.data()?['raeId'] != '' ||
        a.data()?['execucaoMissaoId'] != '' ||
        ['em_execucao', 'concluida'].contains(a.data()?['status'])) {
      throw StateError(
        'Ação com execução ou RAE exige conferência operacional antes de alteração.',
      );
    }
    for (final origem in r.origens) {
      final snapshot =
          await tx.get(_db.collection('escala_atividades').doc(origem.id));
      final dados = snapshot.data();
      if (dados == null ||
          dados['atualizadoEm'] != Timestamp.fromDate(origem.atualizadoEm)) {
        throw StateError('Uma versão da ação mudou. Atualize a agenda.');
      }
      if ((dados['raeId'] ?? '') != '' ||
          (dados['execucaoMissaoId'] ?? '') != '' ||
          ['em_execucao', 'concluida'].contains(dados['status'])) {
        throw StateError(
            'Há resultado em uma versão da ação. Preserve o registro.');
      }
      final usuarios = {
        ...origem.participanteUsuarioIds,
        if (origem.coordenadorUsuarioId.isNotEmpty) origem.coordenadorUsuarioId
      };
      for (final uid in usuarios) {
        final id = FirestoreEscalaExecucaoRepository.gerarIdExecucao(
          atividadeId: origem.id,
          usuarioId: uid,
        );
        final execucao =
            await tx.get(_db.collection('escala_execucoes_missao').doc(id));
        if (execucao.exists) {
          throw StateError(
              'Há execução registrada. Preserve o histórico e confira a escala.');
        }
      }
    }
    for (final alocacao in r.alocacoesHistoricas) {
      final snap = await tx.get(
        _db.collection('escala_alocacoes').doc(alocacao.id),
      );
      if (snap.data()?['minutosRealizados'] != null ||
          (snap.data()?['horaInicioReal'] ?? '') != '') {
        throw StateError(
          'Há horas realizadas. Preserve o registro e confira a escala.',
        );
      }
    }
  }

  void _retirar(Transaction tx, _Retirada r, String uid) {
    tx.update(_db.collection('escala_atividades').doc(r.atividade.id), {
      'status': 'cancelada',
      'participanteUsuarioIds': <String>[],
      'coordenadorMembroEquipeId': '',
      'coordenadorUsuarioId': '',
      'coordenadorNomeSnapshot': '',
      'contabilizaProdutividade': false,
      'atualizadoPor': uid,
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
    for (final alocacao in r.alocacoes) {
      tx.delete(_db.collection('escala_alocacoes').doc(alocacao.id));
    }
  }

  void _evento(
    Transaction tx,
    DocumentReference<Map<String, dynamic>> ref,
    int revisao,
    String acao,
    String uid,
    String motivo,
    DateTime? anterior,
    DateTime nova,
  ) {
    tx.set(ref.collection('historico').doc('$revisao'), {
      'acao': acao,
      'usuarioId': uid,
      'motivo': motivo.trim(),
      'revisao': revisao,
      'em': FieldValue.serverTimestamp(),
      'dataAnterior': anterior == null ? null : Timestamp.fromDate(anterior),
      'dataNova': Timestamp.fromDate(nova),
    });
  }

  @override
  Future<List<AgendaHistorico>> historico(String id) async {
    final snap = await _agenda
        .doc(id)
        .collection('historico')
        .orderBy('revisao', descending: true)
        .get();
    return snap.docs.map((d) {
      final m = d.data();
      return AgendaHistorico(
        acao: m['acao'] as String,
        usuarioId: m['usuarioId'] as String,
        motivo: m['motivo'] as String,
        revisao: m['revisao'] as int,
        em: (m['em'] as Timestamp).toDate(),
        dataAnterior: (m['dataAnterior'] as Timestamp?)?.toDate(),
        dataNova: (m['dataNova'] as Timestamp).toDate(),
      );
    }).toList();
  }
}

class _Retirada {
  const _Retirada(this.escala, this.atividade, this.alocacoes, this.origens,
      this.alocacoesHistoricas);
  final EscalaModel escala;
  final EscalaAtividadeModel atividade;
  final List<EscalaAlocacaoModel> alocacoes;
  final List<EscalaAtividadeModel> origens;
  final List<EscalaAlocacaoModel> alocacoesHistoricas;
}

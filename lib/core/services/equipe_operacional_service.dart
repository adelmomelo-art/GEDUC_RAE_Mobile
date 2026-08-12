import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/membro_equipe_model.dart';

class EquipeOperacionalService {
  EquipeOperacionalService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _membros =>
      _firestore.collection('equipe_operacional');

  Stream<List<MembroEquipeModel>> observarMembros() {
    return _membros.orderBy('nome').snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => MembroEquipeModel.fromMap(
                  doc.data(),
                  documentId: doc.id,
                ),
              )
              .toList(growable: false),
        );
  }

  Future<List<MembroEquipeModel>> listarMembros() async {
    final snapshot = await _membros.orderBy('nome').get();
    return snapshot.docs
        .map(
          (doc) => MembroEquipeModel.fromMap(
            doc.data(),
            documentId: doc.id,
          ),
        )
        .toList(growable: false);
  }

  Future<void> atualizarClassificacao({
    required String id,
    required VinculoOperacional vinculo,
    required bool podeCoordenar,
    required bool ativo,
  }) {
    return _membros.doc(id).update({
      'vinculo': vinculo.codigo,
      'podeCoordenar': podeCoordenar,
      'ativo': ativo,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<ResultadoFundacaoEquipe> sincronizarFundacao() async {
    final usuarios = await _firestore.collection('usuarios').get();
    final coordenadores = await _firestore.collection('coordenadores').get();
    final membrosAtuais = await _membros.get();
    final atuais = {for (final doc in membrosAtuais.docs) doc.id: doc.data()};
    final usuariosPorEmail = <String, String>{};
    final operacoes = <String, Map<String, dynamic>>{};
    final agora = Timestamp.now();

    for (final usuario in usuarios.docs) {
      final dados = usuario.data();
      final email = _normalizarEmail(dados['email']);
      if (email.isNotEmpty) usuariosPorEmail[email] = usuario.id;

      final atual = atuais[usuario.id];
      operacoes[usuario.id] = {
        'usuarioId': usuario.id,
        'nome': dados['nome']?.toString().trim() ?? '',
        'vinculo': atual?['vinculo'] ?? 'agente',
        'podeCoordenar': EquipeOperacionalMergePolicy.preservarBooleano(
          atual: atual,
          campo: 'podeCoordenar',
          padrao: false,
        ),
        'ativo': EquipeOperacionalMergePolicy.preservarBooleano(
          atual: atual,
          campo: 'ativo',
          padrao: dados['ativo'] == true,
        ),
        'origem': 'usuario',
        'createdAt': atual?['createdAt'] ?? agora,
        'updatedAt': agora,
      };
    }

    var coordenadoresImportados = 0;
    for (final coordenador in coordenadores.docs) {
      final dados = coordenador.data();
      final usuarioId = usuariosPorEmail[_normalizarEmail(dados['email'])];
      final id = usuarioId ?? 'legado_${coordenador.id}';
      final atual = atuais[id] ?? operacoes[id];

      operacoes[id] = {
        'usuarioId': usuarioId ?? '',
        'nome': dados['nome']?.toString().trim() ?? '',
        'vinculo': atual?['vinculo'] ?? 'agente',
        'podeCoordenar': EquipeOperacionalMergePolicy.preservarBooleano(
          atual: atual,
          campo: 'podeCoordenar',
          padrao: true,
        ),
        'ativo': EquipeOperacionalMergePolicy.preservarBooleano(
          atual: atual,
          campo: 'ativo',
          padrao: dados['ativo'] != false,
        ),
        'origem': usuarioId == null ? 'coordenador_legado' : 'usuario',
        'createdAt': atual?['createdAt'] ?? agora,
        'updatedAt': agora,
      };
      coordenadoresImportados++;
    }

    await _executarEmLotes(operacoes);
    return ResultadoFundacaoEquipe(
      usuariosSincronizados: usuarios.docs.length,
      coordenadoresImportados: coordenadoresImportados,
    );
  }

  Future<void> _executarEmLotes(
    Map<String, Map<String, dynamic>> operacoes,
  ) async {
    final entradas = operacoes.entries.toList(growable: false);
    for (var inicio = 0; inicio < entradas.length; inicio += 400) {
      final fim =
          inicio + 400 < entradas.length ? inicio + 400 : entradas.length;
      final batch = _firestore.batch();
      for (final operacao in entradas.sublist(inicio, fim)) {
        batch.set(_membros.doc(operacao.key), operacao.value);
      }
      await batch.commit();
    }
  }

  String _normalizarEmail(Object? valor) =>
      valor?.toString().trim().toLowerCase() ?? '';
}

class EquipeOperacionalMergePolicy {
  const EquipeOperacionalMergePolicy._();

  static bool preservarBooleano({
    required Map<String, dynamic>? atual,
    required String campo,
    required bool padrao,
  }) {
    final valorAtual = atual?[campo];
    return valorAtual is bool ? valorAtual : padrao;
  }
}

class ResultadoFundacaoEquipe {
  const ResultadoFundacaoEquipe({
    required this.usuariosSincronizados,
    required this.coordenadoresImportados,
  });

  final int usuariosSincronizados;
  final int coordenadoresImportados;
}

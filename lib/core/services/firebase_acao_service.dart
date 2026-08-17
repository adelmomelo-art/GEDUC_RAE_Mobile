import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/acao_model.dart';

class FirebaseAcaoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _acoesRef =>
      _firestore.collection('acoes');

  Future<String> salvarAcao(AcaoModel acao) async {
    try {
      final acaoId = AcaoPersistenceIdentity.documentId(acao);

      final numeroRae = acao.numeroRAE.isNotEmpty
          ? acao.numeroRAE
          : await gerarNumeroRaeAutomatico();

      final anoRae = acao.anoRAE > 0 ? acao.anoRAE : acao.dataAcao.year;

      final dados = acao
          .copyWith(
            id: acaoId,
            numeroRAE: numeroRae,
            anoRAE: anoRae,
            sincronizado: true,
          )
          .toMap();

      dados['dataAtualizacao'] = FieldValue.serverTimestamp();

      await _acoesRef.doc(acaoId).set(dados);

      return acaoId;
    } catch (e) {
      throw Exception('Erro ao salvar ação: $e');
    }
  }

  Future<String> criarAcao(AcaoModel acao) async {
    return salvarAcao(acao);
  }

  Future<void> atualizarAcao(String id, AcaoModel acao) async {
    try {
      final dados = acao.toMap();

      dados['id'] = id;
      dados['dataAtualizacao'] = FieldValue.serverTimestamp();

      await _acoesRef.doc(id).update(dados);
    } catch (e) {
      throw Exception('Erro ao atualizar ação: $e');
    }
  }

  Future<void> excluirAcao(String id) async {
    try {
      await _acoesRef.doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao excluir ação: $e');
    }
  }

  Future<AcaoModel?> buscarAcaoPorId(String id) async {
    try {
      final doc = await _acoesRef.doc(id).get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      final data = doc.data()!;
      data['id'] = doc.id;

      return AcaoModel.fromMap(data);
    } catch (e) {
      throw Exception('Erro ao buscar ação: $e');
    }
  }

  Stream<List<AcaoModel>> listarAcoes() {
    return _acoesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        data['id'] = doc.id;

        return AcaoModel.fromMap(data);
      }).toList();
    });
  }

  Future<List<AcaoModel>> listarAcoesFuture() async {
    final snapshot = await _acoesRef.get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      data['id'] = doc.id;

      return AcaoModel.fromMap(data);
    }).toList();
  }

  Stream<List<AcaoModel>> listarAcoesPorProjeto(String projetoId) {
    return _acoesRef
        .where(
          'projetoId',
          isEqualTo: projetoId,
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        data['id'] = doc.id;

        return AcaoModel.fromMap(data);
      }).toList();
    });
  }

  Future<void> alterarStatus(String id, String status) async {
    try {
      await _acoesRef.doc(id).update({
        'status': status,
        'dataAtualizacao': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao alterar status da ação: $e');
    }
  }

  Future<void> atualizarNumeroRae(
    String id,
    String numeroRae,
  ) async {
    try {
      await _acoesRef.doc(id).update({
        'numeroRAE': numeroRae,
        'dataAtualizacao': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar número RAE: $e');
    }
  }

  Future<String> gerarNumeroRaeAutomatico() async {
    try {
      final ano = DateTime.now().year;

      final counterRef = _firestore.collection('contadores').doc(
            'rae_$ano',
          );

      return await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(counterRef);

        int ultimoNumero = 0;

        if (snapshot.exists) {
          final data = snapshot.data();

          ultimoNumero = data?['ultimoNumero'] ?? 0;
        }

        final novoNumero = ultimoNumero + 1;

        transaction.set(
          counterRef,
          {
            'ultimoNumero': novoNumero,
            'ano': ano,
            'dataAtualizacao': FieldValue.serverTimestamp(),
          },
          SetOptions(
            merge: true,
          ),
        );

        return '${novoNumero.toString().padLeft(4, '0')}/$ano';
      });
    } catch (e) {
      throw Exception('Erro ao gerar número RAE automático: $e');
    }
  }

  Future<void> vincularQrCode(
    String id,
    String qrCodeUrl,
  ) async {
    try {
      await _acoesRef.doc(id).update({
        'qrCodeUrl': qrCodeUrl,
        'dataAtualizacao': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao vincular QR Code: $e');
    }
  }

  Future<int> totalAcoes() async {
    final snapshot = await _acoesRef.get();

    return snapshot.docs.length;
  }

  Future<int> totalPessoasAlcancadas() async {
    return totalPorCampo(
      'pessoasAlcancadas',
    );
  }

  Future<int> totalVeiculosAbordados() async {
    return totalPorCampo(
      'veiculosAbordados',
    );
  }

  Future<int> totalCredenciaisEmitidas() async {
    return totalPorCampo(
      'credenciaisEmitidas',
    );
  }

  Future<int> totalPorCampo(String campo) async {
    final snapshot = await _acoesRef.get();

    int total = 0;

    for (final doc in snapshot.docs) {
      final valor = doc.data()[campo];

      if (valor is int) {
        total += valor;
      } else if (valor is num) {
        total += valor.toInt();
      } else if (valor is String) {
        total += int.tryParse(valor) ?? 0;
      }
    }

    return total;
  }

  Future<Map<String, int>> acoesPorRegional() async {
    final acoes = await listarAcoesFuture();
    final mapa = <String, int>{};

    for (final acao in acoes) {
      final chave = acao.regional.isEmpty ? 'Não informada' : acao.regional;

      mapa[chave] = (mapa[chave] ?? 0) + 1;
    }

    return mapa;
  }

  Future<Map<String, int>> acoesPorTipo() async {
    final acoes = await listarAcoesFuture();
    final mapa = <String, int>{};

    for (final acao in acoes) {
      final chave = acao.tipoAcao.isEmpty ? 'Não informado' : acao.tipoAcao;

      mapa[chave] = (mapa[chave] ?? 0) + 1;
    }

    return mapa;
  }

  Future<Map<String, int>> metasAtingidas() async {
    final acoes = await listarAcoesFuture();

    int atingidas = 0;
    int naoAtingidas = 0;

    for (final acao in acoes) {
      if (acao.metaAtingida) {
        atingidas++;
      } else {
        naoAtingidas++;
      }
    }

    return {
      'Atingidas': atingidas,
      'Não atingidas': naoAtingidas,
    };
  }
}

class AcaoPersistenceIdentity {
  const AcaoPersistenceIdentity._();

  static String documentId(AcaoModel acao) {
    final id = acao.id.trim();

    if (id.isEmpty) {
      throw ArgumentError.value(
        acao.id,
        'acao.id',
        'A ação precisa de um ID local para persistência idempotente.',
      );
    }

    return id;
  }
}

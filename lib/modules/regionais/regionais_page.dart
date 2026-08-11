import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/regional_model.dart';

class RegionaisPage extends StatefulWidget {
  const RegionaisPage({super.key});

  @override
  State<RegionaisPage> createState() => _RegionaisPageState();
}

class _RegionaisPageState extends State<RegionaisPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> abrirFormulario([RegionalModel? existente]) async {
    final nomeController = TextEditingController(text: existente?.nome ?? '');
    final codigoController =
        TextEditingController(text: existente?.codigo ?? '');
    final bairrosController =
        TextEditingController(text: existente?.bairros.join(', ') ?? '');
    var tipo = existente?.tipo ?? TipoRegional.administrativa;
    var ativo = existente?.ativo ?? true;
    String? erro;
    var salvando = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existente == null ? 'Nova Regional' : 'Editar Regional'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 520,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                DropdownButtonFormField<TipoRegional>(
                  initialValue: tipo,
                  decoration: const InputDecoration(
                      labelText: 'Tipo de Regional *',
                      border: OutlineInputBorder()),
                  items: TipoRegional.values
                      .map((item) => DropdownMenuItem(
                          value: item, child: Text(item.rotulo)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => tipo = value);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                    controller: codigoController,
                    decoration: const InputDecoration(
                        labelText: 'Código',
                        hintText: 'Ex.: Regional 3',
                        border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(
                    controller: nomeController,
                    decoration: const InputDecoration(
                        labelText: 'Nome oficial *',
                        hintText: 'Ex.: Regional Administrativa 3',
                        border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(
                    controller: bairrosController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                        labelText: 'Bairros vinculados',
                        hintText: 'Separe os bairros por vírgula',
                        border: OutlineInputBorder())),
                SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Regional ativa'),
                    value: ativo,
                    onChanged: (value) => setDialogState(() => ativo = value)),
                if (erro != null)
                  Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(erro!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error))),
              ]),
            ),
          ),
          actions: [
            TextButton(
                onPressed: salvando ? null : () => Navigator.pop(dialogContext),
                child: const Text('CANCELAR')),
            FilledButton(
              onPressed: salvando
                  ? null
                  : () async {
                      final nome = nomeController.text.trim();
                      final bairros = bairrosController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toSet()
                          .toList();
                      if (nome.isEmpty) {
                        setDialogState(
                            () => erro = 'Informe o nome oficial da Regional.');
                        return;
                      }
                      setDialogState(() {
                        salvando = true;
                        erro = null;
                      });
                      final conflito = ativo
                          ? await _buscarConflito(
                              tipo: tipo,
                              bairros: bairros,
                              ignorarId: existente?.id)
                          : null;
                      if (conflito != null) {
                        setDialogState(() {
                          salvando = false;
                          erro = conflito;
                        });
                        return;
                      }
                      final id = existente?.id ?? const Uuid().v4();
                      final model = RegionalModel(
                          id: id,
                          nome: nome,
                          codigo: codigoController.text.trim(),
                          tipo: tipo,
                          bairros: bairros,
                          ativo: ativo);
                      await firestore.collection('regionais').doc(id).set(
                          model.toMap(incluirCriacao: existente == null),
                          SetOptions(merge: true));
                      if (dialogContext.mounted) Navigator.pop(dialogContext);
                    },
              child: Text(salvando ? 'SALVANDO...' : 'SALVAR'),
            ),
          ],
        ),
      ),
    );
    nomeController.dispose();
    codigoController.dispose();
    bairrosController.dispose();
  }

  Future<String?> _buscarConflito(
      {required TipoRegional tipo,
      required List<String> bairros,
      String? ignorarId}) async {
    final desejados = bairros.map(_normalizar).toSet();
    if (desejados.isEmpty) return null;
    final snapshot = await firestore
        .collection('regionais')
        .where('ativo', isEqualTo: true)
        .get();
    for (final doc in snapshot.docs) {
      if (doc.id == ignorarId) continue;
      final outra = RegionalModel.fromMap(doc.id, doc.data());
      if (outra.tipo != tipo) continue;
      final repetidos = outra.bairros
          .where((bairro) => desejados.contains(_normalizar(bairro)))
          .toList();
      if (repetidos.isNotEmpty) {
        return 'Conflito: ${repetidos.join(', ')} já pertence a ${outra.nome} nesta mesma tipologia.';
      }
    }
    return null;
  }

  String _normalizar(String valor) {
    var texto = valor.trim().toLowerCase();
    const origem = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const destino = 'aaaaaeeeeiiiiooooouuuuc';
    for (var i = 0; i < origem.length; i++) {
      texto = texto.replaceAll(origem[i], destino[i]);
    }
    return texto.replaceAll(RegExp(r'\s+'), ' ');
  }

  Future<void> alterarStatus(RegionalModel regional, bool ativo) async {
    if (ativo) {
      final conflito = await _buscarConflito(
          tipo: regional.tipo,
          bairros: regional.bairros,
          ignorarId: regional.id);
      if (conflito != null) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(conflito)));
        }
        return;
      }
    }
    await firestore
        .collection('regionais')
        .doc(regional.id)
        .update({'ativo': ativo, 'atualizadoEm': FieldValue.serverTimestamp()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Regionais')),
      floatingActionButton: FloatingActionButton(
          onPressed: () => abrirFormulario(), child: const Icon(Icons.add)),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: firestore.collection('regionais').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final regionais = (snapshot.data?.docs ?? [])
              .map((doc) => RegionalModel.fromMap(doc.id, doc.data()))
              .toList()
            ..sort((a, b) => a.nome.compareTo(b.nome));
          if (regionais.isEmpty) {
            return const Center(child: Text('Nenhuma regional cadastrada.'));
          }
          return ListView(
              padding: const EdgeInsets.all(16),
              children: regionais
                  .map((regional) => Card(
                          child: ListTile(
                        onTap: () => abrirFormulario(regional),
                        leading: Icon(
                            regional.ativo ? Icons.map : Icons.map_outlined,
                            color: regional.ativo ? Colors.green : Colors.red),
                        title: Text(regional.codigo.isEmpty
                            ? regional.nome
                            : '${regional.codigo} - ${regional.nome}'),
                        subtitle: Text(
                            '${regional.tipo.rotulo}\n${regional.bairros.isEmpty ? 'Sem bairros vinculados' : regional.bairros.join(', ')}'),
                        isThreeLine: true,
                        trailing: Switch(
                            value: regional.ativo,
                            onChanged: (value) =>
                                alterarStatus(regional, value)),
                      )))
                  .toList());
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class RegionaisPage extends StatefulWidget {
  const RegionaisPage({super.key});

  @override
  State<RegionaisPage> createState() => _RegionaisPageState();
}

class _RegionaisPageState extends State<RegionaisPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> abrirFormulario() async {
    final nomeController = TextEditingController();
    final bairrosController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova Regional'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da regional',
                    hintText: 'Ex: SER 03',
                  ),
                ),
                TextField(
                  controller: bairrosController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Bairros vinculados',
                    hintText: 'Ex: São Gerardo, Parquelândia, Monte Castelo',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () async {
                final id = const Uuid().v4();

                await firestore.collection('regionais').doc(id).set({
                  'id': id,
                  'nomeRegional': nomeController.text.trim(),
                  'bairrosVinculados': bairrosController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList(),
                  'ativo': true,
                  'criadoEm': Timestamp.now(),
                });

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('SALVAR'),
            ),
          ],
        );
      },
    );
  }

  Future<void> alterarStatus(String id, bool ativo) async {
    await firestore.collection('regionais').doc(id).update({
      'ativo': ativo,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regionais'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: abrirFormulario,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('regionais')
            .orderBy('nomeRegional')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Nenhuma regional cadastrada.'),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              final nome = data['nomeRegional'] ?? '';
              final bairros =
                  List<String>.from(data['bairrosVinculados'] ?? []);
              final ativo = data['ativo'] ?? true;

              return Card(
                child: ListTile(
                  leading: Icon(
                    ativo ? Icons.map : Icons.map_outlined,
                    color: ativo ? Colors.green : Colors.red,
                  ),
                  title: Text(nome),
                  subtitle: Text(
                    bairros.isEmpty
                        ? 'Sem bairros vinculados'
                        : bairros.join(', '),
                  ),
                  trailing: Switch(
                    value: ativo,
                    onChanged: (value) => alterarStatus(doc.id, value),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
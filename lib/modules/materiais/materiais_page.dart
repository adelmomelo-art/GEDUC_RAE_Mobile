import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class MateriaisPage extends StatefulWidget {
  const MateriaisPage({super.key});

  @override
  State<MateriaisPage> createState() => _MateriaisPageState();
}

class _MateriaisPageState extends State<MateriaisPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> abrirFormulario() async {
    final nomeController = TextEditingController();
    final categoriaController = TextEditingController();
    final quantidadeController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Novo Material'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do material',
                    hintText: 'Ex: Cones, panfletos, coletes',
                  ),
                ),
                TextField(
                  controller: categoriaController,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    hintText: 'Ex: Educativo, apoio, sinalização',
                  ),
                ),
                TextField(
                  controller: quantidadeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade disponível',
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

                await firestore.collection('materiais').doc(id).set({
                  'id': id,
                  'nomeMaterial': nomeController.text.trim(),
                  'categoria': categoriaController.text.trim(),
                  'quantidadeDisponivel':
                      int.tryParse(quantidadeController.text.trim()) ?? 0,
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
    await firestore.collection('materiais').doc(id).update({
      'ativo': ativo,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materiais'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: abrirFormulario,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('materiais')
            .orderBy('nomeMaterial')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Nenhum material cadastrado.'),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              final nome = data['nomeMaterial'] ?? '';
              final categoria = data['categoria'] ?? '';
              final quantidade = data['quantidadeDisponivel'] ?? 0;
              final ativo = data['ativo'] ?? true;

              return Card(
                child: ListTile(
                  leading: Icon(
                    ativo ? Icons.inventory : Icons.inventory_2_outlined,
                    color: ativo ? Colors.green : Colors.red,
                  ),
                  title: Text(nome),
                  subtitle: Text(
                    'Categoria: $categoria\nQuantidade: $quantidade',
                  ),
                  isThreeLine: true,
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
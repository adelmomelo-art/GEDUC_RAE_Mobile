import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TiposAcoesPage extends StatefulWidget {
  const TiposAcoesPage({super.key});

  @override
  State<TiposAcoesPage> createState() => _TiposAcoesPageState();
}

class _TiposAcoesPageState extends State<TiposAcoesPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> abrirFormulario() async {
    final nomeController = TextEditingController();
    final tipoController = TextEditingController();
    final estimadoController = TextEditingController();
    final minimoController = TextEditingController();
    final materiaisController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Novo Tipo de Ação'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da ação',
                  ),
                ),
                TextField(
                  controller: tipoController,
                  decoration: const InputDecoration(
                    labelText: 'Tipo da ação',
                  ),
                ),
                TextField(
                  controller: estimadoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Público estimado',
                  ),
                ),
                TextField(
                  controller: minimoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Público mínimo',
                  ),
                ),
                TextField(
                  controller: materiaisController,
                  decoration: const InputDecoration(
                    labelText: 'Materiais sugeridos',
                    hintText: 'Ex: cones, panfletos, coletes',
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

                await firestore.collection('tipos_acoes').doc(id).set({
                  'id': id,
                  'nomeAcao': nomeController.text.trim(),
                  'tipoAcao': tipoController.text.trim(),
                  'publicoEstimadoPadrao':
                      int.tryParse(estimadoController.text.trim()) ?? 0,
                  'publicoMinimoPadrao':
                      int.tryParse(minimoController.text.trim()) ?? 0,
                  'materiaisSugeridos': materiaisController.text
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
    await firestore.collection('tipos_acoes').doc(id).update({
      'ativo': ativo,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tipos de Ações'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: abrirFormulario,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('tipos_acoes')
            .orderBy('nomeAcao')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Nenhum tipo de ação cadastrado.'),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              final nome = data['nomeAcao'] ?? '';
              final tipo = data['tipoAcao'] ?? '';
              final estimado = data['publicoEstimadoPadrao'] ?? 0;
              final minimo = data['publicoMinimoPadrao'] ?? 0;
              final ativo = data['ativo'] ?? true;

              return Card(
                child: ListTile(
                  leading: Icon(
                    ativo ? Icons.check_circle : Icons.cancel,
                    color: ativo ? Colors.green : Colors.red,
                  ),
                  title: Text(nome),
                  subtitle: Text(
                    '$tipo\nEstimado: $estimado | Mínimo: $minimo',
                  ),
                  isThreeLine: true,
                  trailing: Switch(
                    value: ativo,
                    onChanged: (value) {
                      alterarStatus(doc.id, value);
                    },
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
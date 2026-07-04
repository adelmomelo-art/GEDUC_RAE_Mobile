import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CoordenadoresPage extends StatefulWidget {
  const CoordenadoresPage({super.key});

  @override
  State<CoordenadoresPage> createState() => _CoordenadoresPageState();
}

class _CoordenadoresPageState extends State<CoordenadoresPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> abrirFormulario() async {
    final nomeController = TextEditingController();
    final matriculaController = TextEditingController();
    final cargoController = TextEditingController();
    final telefoneController = TextEditingController();
    final emailController = TextEditingController();
    final setorController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Novo Coordenador'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome')),
                TextField(controller: matriculaController, decoration: const InputDecoration(labelText: 'Matrícula')),
                TextField(controller: cargoController, decoration: const InputDecoration(labelText: 'Cargo')),
                TextField(controller: telefoneController, decoration: const InputDecoration(labelText: 'Telefone')),
                TextField(controller: emailController, decoration: const InputDecoration(labelText: 'E-mail')),
                TextField(controller: setorController, decoration: const InputDecoration(labelText: 'Setor')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
            ElevatedButton(
              onPressed: () async {
                final id = const Uuid().v4();

                await firestore.collection('coordenadores').doc(id).set({
                  'id': id,
                  'nome': nomeController.text.trim(),
                  'matricula': matriculaController.text.trim(),
                  'cargo': cargoController.text.trim(),
                  'telefone': telefoneController.text.trim(),
                  'email': emailController.text.trim(),
                  'setor': setorController.text.trim(),
                  'ativo': true,
                  'criadoEm': Timestamp.now(),
                });

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('SALVAR'),
            ),
          ],
        );
      },
    );
  }

  Future<void> alterarStatus(String id, bool ativo) async {
    await firestore.collection('coordenadores').doc(id).update({'ativo': ativo});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coordenadores'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: abrirFormulario,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('coordenadores').orderBy('nome').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum coordenador cadastrado.'));
          }

          final docs = snapshot.data!.docs;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              final nome = data['nome'] ?? '';
              final cargo = data['cargo'] ?? '';
              final setor = data['setor'] ?? '';
              final ativo = data['ativo'] ?? true;

              return Card(
                child: ListTile(
                  leading: Icon(
                    ativo ? Icons.person : Icons.person_off,
                    color: ativo ? Colors.green : Colors.red,
                  ),
                  title: Text(nome),
                  subtitle: Text('$cargo\nSetor: $setor'),
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
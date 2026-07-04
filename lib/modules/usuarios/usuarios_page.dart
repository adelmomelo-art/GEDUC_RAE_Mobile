import 'package:flutter/material.dart';

import '../../core/services/usuario_service.dart';
import '../../data/models/usuario_model.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  final UsuarioService service = UsuarioService();

  List<UsuarioModel> usuarios = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarUsuarios();
  }

  Future<void> carregarUsuarios() async {
    final lista = await service.listarUsuarios();

    setState(() {
      usuarios = lista;
      carregando = false;
    });
  }

  Color corPerfil(String perfil) {
    if (perfil == 'administrador') return Colors.blue;
    if (perfil == 'gestor') return Colors.green;
    if (perfil == 'coordenador') return Colors.orange;
    if (perfil == 'agente') return Colors.purple;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuários'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: carregarUsuarios,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.blue.shade50,
            child: ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Usuários cadastrados'),
              subtitle: Text('${usuarios.length} usuário(s) encontrado(s)'),
            ),
          ),
          const SizedBox(height: 16),
          ...usuarios.map((usuario) {
            final cor = corPerfil(usuario.perfilAcesso);

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: cor.withValues(alpha: 0.15),
                  child: Icon(
                    Icons.person,
                    color: cor,
                  ),
                ),
                title: Text(usuario.nome),
                subtitle: Text(
                  '${usuario.email}\n'
                  'Perfil: ${usuario.perfilAcesso}\n'
                  'Ativo: ${usuario.ativo ? "Sim" : "Não"}',
                ),
                isThreeLine: true,
              ),
            );
          }),
        ],
      ),
    );
  }
}
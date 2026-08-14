import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/usuario_model.dart';
import '../admin/controllers/usuario_controller.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UsuarioController>().carregarUsuarios();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UsuarioController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuários'),
        actions: [
          IconButton(
            tooltip: 'Atualizar usuários',
            icon: const Icon(Icons.refresh),
            onPressed: controller.carregando ? null : controller.recarregar,
          ),
        ],
      ),
      body: _UsuariosBody(controller: controller),
    );
  }
}

class _UsuariosBody extends StatelessWidget {
  const _UsuariosBody({required this.controller});

  final UsuarioController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.carregando && controller.usuarios.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.possuiErro && controller.usuarios.isEmpty) {
      return _ErroUsuarios(onTentarNovamente: controller.recarregar);
    }

    return RefreshIndicator(
      onRefresh: controller.recarregar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          if (controller.possuiErro) ...[
            _AvisoErro(onTentarNovamente: controller.recarregar),
            const SizedBox(height: 12),
          ],
          Card(
            color: Colors.blue.shade50,
            child: ListTile(
              leading: controller.carregando
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.people),
              title: const Text('Usuários cadastrados'),
              subtitle: Text(
                '${controller.usuarios.length} usuário(s) encontrado(s)',
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (controller.usuarios.isEmpty)
            const _SemUsuarios()
          else
            ...controller.usuarios.map(_UsuarioCard.new),
        ],
      ),
    );
  }
}

class _UsuarioCard extends StatelessWidget {
  const _UsuarioCard(this.usuario);

  final UsuarioModel usuario;

  @override
  Widget build(BuildContext context) {
    final cor = _corPerfil(usuario.perfilAcesso);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cor.withValues(alpha: 0.15),
          child: Icon(Icons.person, color: cor),
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
  }

  Color _corPerfil(String perfil) {
    return switch (perfil.trim().toLowerCase()) {
      'administrador' => Colors.blue,
      'gestor' => Colors.green,
      'gerente' => Colors.teal,
      'coordenador' => Colors.orange,
      'agente' => Colors.purple,
      _ => Colors.grey,
    };
  }
}

class _ErroUsuarios extends StatelessWidget {
  const _ErroUsuarios({required this.onTentarNovamente});

  final Future<void> Function() onTentarNovamente;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 56),
            const SizedBox(height: 16),
            const Text(
              'Não foi possível carregar os usuários.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onTentarNovamente,
              icon: const Icon(Icons.refresh),
              label: const Text('TENTAR NOVAMENTE'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvisoErro extends StatelessWidget {
  const _AvisoErro({required this.onTentarNovamente});

  final Future<void> Function() onTentarNovamente;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: ListTile(
        leading: const Icon(Icons.warning_amber_rounded),
        title: const Text('Não foi possível atualizar a lista.'),
        trailing: TextButton(
          onPressed: onTentarNovamente,
          child: const Text('TENTAR'),
        ),
      ),
    );
  }
}

class _SemUsuarios extends StatelessWidget {
  const _SemUsuarios();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.person_search_outlined, size: 52),
          SizedBox(height: 12),
          Text('Nenhum usuário foi encontrado.'),
        ],
      ),
    );
  }
}

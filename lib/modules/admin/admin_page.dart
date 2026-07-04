import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  Widget menu(
    BuildContext context,
    IconData icone,
    String titulo,
    String subtitulo,
    String rota,
    Color cor,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cor.withValues(alpha: 0.15),
          child: Icon(
            icone,
            color: cor,
          ),
        ),
        title: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          context.go(rota);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administração'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.blue.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Painel Administrativo',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gerencie usuários, ações, materiais e parâmetros do sistema.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          menu(
            context,
            Icons.people,
            'Usuários',
            'Gerenciar acessos e perfis',
            '/usuarios',
            Colors.blue,
          ),
          menu(
            context,
            Icons.assignment,
            'Tipos de ações',
            'Configurar metas padrão',
            '/tipos-acoes',
            Colors.green,
          ),
          menu(
            context,
            Icons.inventory,
            'Materiais',
            'Cadastrar materiais',
            '/materiais',
            Colors.orange,
          ),
          menu(
            context,
            Icons.map,
            'Regionais',
            'SERs e bairros',
            '/regionais',
            Colors.red,
          ),
          menu(
            context,
            Icons.person_pin,
            'Coordenadores',
            'Responsáveis pelas ações',
            '/coordenadores',
            Colors.purple,
          ),
          menu(
            context,
            Icons.settings,
            'Configurações',
            'Parâmetros do sistema',
            '/configuracoes',
            Colors.teal,
          ),
        ],
      ),
    );
  }
}
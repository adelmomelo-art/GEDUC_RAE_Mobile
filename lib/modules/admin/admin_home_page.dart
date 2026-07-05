import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const itens = [
      _AdminItem(
        titulo: 'Central de Domínios',
        descricao: 'Gerencie listas, grupos e opções utilizadas no app.',
        icone: Icons.category,
        rota: '/admin/dominios',
      ),
      _AdminItem(
        titulo: 'Usuários',
        descricao: 'Cadastro e consulta de usuários da plataforma.',
        icone: Icons.people,
        rota: '/usuarios',
      ),
      _AdminItem(
        titulo: 'Tipos de Ações',
        descricao: 'Cadastro atual de tipos de ações educativas.',
        icone: Icons.assignment,
        rota: '/tipos-acoes',
      ),
      _AdminItem(
        titulo: 'Coordenadores',
        descricao: 'Cadastro de coordenadores e responsáveis.',
        icone: Icons.badge,
        rota: '/coordenadores',
      ),
      _AdminItem(
        titulo: 'Regionais',
        descricao: 'Cadastro de regionais e bairros vinculados.',
        icone: Icons.map,
        rota: '/regionais',
      ),
      _AdminItem(
        titulo: 'Materiais',
        descricao: 'Cadastro de materiais utilizados nas ações.',
        icone: Icons.inventory_2,
        rota: '/materiais',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administração'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: itens.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = itens[index];

          return Card(
            child: ListTile(
              leading: Icon(item.icone),
              title: Text(item.titulo),
              subtitle: Text(item.descricao),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(item.rota),
            ),
          );
        },
      ),
    );
  }
}

class _AdminItem {
  final String titulo;
  final String descricao;
  final IconData icone;
  final String rota;

  const _AdminItem({
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.rota,
  });
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/usuario_model.dart';

class AtalhosWidget extends StatelessWidget {
  final UsuarioModel? usuario;

  const AtalhosWidget({
    super.key,
    required this.usuario,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.apps,
                  color: Colors.blue,
                ),
                SizedBox(width: 8),
                Text(
                  'Acessos Rápidos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            _botaoPrincipal(
              context,
              icon: Icons.add,
              titulo: 'Nova Ação',
              rota: '/nova-acao',
            ),

            const SizedBox(height: 10),

            _botaoPrincipal(
              context,
              icon: Icons.search,
              titulo: 'Consulta de RAE',
              rota: '/consulta-rae',
            ),

            const SizedBox(height: 10),

            _botaoSecundario(
              context,
              icon: Icons.dashboard,
              titulo: 'Dashboard Executivo',
              rota: '/dashboard',
            ),

            const SizedBox(height: 10),

            _botaoSecundario(
              context,
              icon: Icons.analytics,
              titulo: 'Painel BI GEDUC',
              rota: '/bi-geduc',
            ),

            if (usuario?.perfilAcesso == 'administrador') ...[
              const SizedBox(height: 10),

              _botaoSecundario(
                context,
                icon: Icons.admin_panel_settings,
                titulo: 'Administração',
                rota: '/admin',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _botaoPrincipal(
    BuildContext context, {
    required IconData icon,
    required String titulo,
    required String rota,
  }) {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(titulo),
        onPressed: () => context.go(rota),
      ),
    );
  }

  Widget _botaoSecundario(
    BuildContext context, {
    required IconData icon,
    required String titulo,
    required String rota,
  }) {
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        icon: Icon(icon),
        label: Text(titulo),
        onPressed: () => context.go(rota),
      ),
    );
  }
}
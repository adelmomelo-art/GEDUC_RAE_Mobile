import 'package:flutter/material.dart';

class StatusWidget extends StatelessWidget {
  const StatusWidget({super.key});

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
          children: [
            const Row(
              children: [
                Icon(
                  Icons.monitor_heart,
                  color: Colors.blue,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Status Operacional',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _statusItem(
              icon: Icons.cloud_done,
              titulo: 'Firebase',
              descricao: 'Banco de dados em nuvem ativo',
              cor: Colors.teal,
            ),

            _divisor(),

            _statusItem(
              icon: Icons.sync,
              titulo: 'Sincronização',
              descricao: 'Serviços preparados para envio e consulta',
              cor: Colors.green,
            ),

            _divisor(),

            _statusItem(
              icon: Icons.qr_code,
              titulo: 'RAE Digital',
              descricao: 'QR Code, PDF e compartilhamento disponíveis',
              cor: Colors.blue,
            ),

            _divisor(),

            _statusItem(
              icon: Icons.analytics,
              titulo: 'BI GEDUC',
              descricao: 'Indicadores executivos disponíveis',
              cor: Colors.purple,
            ),

            _divisor(),

            _statusItem(
              icon: Icons.verified,
              titulo: 'Plataforma',
              descricao: 'Sistema operacional em evolução contínua',
              cor: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusItem({
    required IconData icon,
    required String titulo,
    required String descricao,
    required Color cor,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: cor,
        size: 30,
      ),
      title: Text(
        titulo,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(descricao),
    );
  }

  Widget _divisor() {
    return const Divider(height: 1);
  }
}
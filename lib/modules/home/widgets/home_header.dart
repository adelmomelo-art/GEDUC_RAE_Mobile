import 'package:flutter/material.dart';

import '../../../data/models/usuario_model.dart';

class HomeHeader extends StatelessWidget {
  final UsuarioModel? usuario;

  const HomeHeader({
    super.key,
    required this.usuario,
  });

  String _saudacao() {
    final hora = DateTime.now().hour;

    if (hora < 12) {
      return 'Bom dia';
    }

    if (hora < 18) {
      return 'Boa tarde';
    }

    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.account_balance,
                  size: 36,
                  color: Colors.blue,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'GEDUC RAE Mobile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Gerência de Educação para o Trânsito',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            const Divider(height: 28),
            Text(
              '${_saudacao()}, ${usuario?.nome ?? "Usuário"}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.badge,
                  size: 18,
                  color: Colors.blueGrey,
                ),
                const SizedBox(width: 6),
                Text(
                  usuario?.perfilAcesso ?? '',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.email,
                  size: 18,
                  color: Colors.blueGrey,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    usuario?.email ?? '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.insights,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Como a digitalização das ações educativas permitiu transformar dados operacionais em inteligência para tomada de decisão.',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

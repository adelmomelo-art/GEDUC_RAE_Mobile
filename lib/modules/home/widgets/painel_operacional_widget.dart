import 'package:flutter/material.dart';

class PainelOperacionalWidget extends StatelessWidget {
  final int totalAcoes;
  final int totalPessoas;
  final int totalVeiculos;
  final int totalCredenciais;
  final int totalUltimosRaes;

  const PainelOperacionalWidget({
    super.key,
    required this.totalAcoes,
    required this.totalPessoas,
    required this.totalVeiculos,
    required this.totalCredenciais,
    required this.totalUltimosRaes,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.speed,
                  color: Colors.blue,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Painel Operacional',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _linhaOperacional(
              icon: Icons.assignment_turned_in,
              titulo: 'RAEs registrados',
              valor: totalAcoes.toString(),
              cor: Colors.blue,
            ),
            _linhaOperacional(
              icon: Icons.history,
              titulo: 'Últimos RAEs exibidos',
              valor: totalUltimosRaes.toString(),
              cor: Colors.indigo,
            ),
            _linhaOperacional(
              icon: Icons.groups,
              titulo: 'Pessoas alcançadas',
              valor: totalPessoas.toString(),
              cor: Colors.green,
            ),
            _linhaOperacional(
              icon: Icons.directions_car,
              titulo: 'Veículos abordados',
              valor: totalVeiculos.toString(),
              cor: Colors.orange,
            ),
            _linhaOperacional(
              icon: Icons.badge,
              titulo: 'Credenciais emitidas',
              valor: totalCredenciais.toString(),
              cor: Colors.purple,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Operação GEDUC ativa e dados disponíveis para acompanhamento executivo.',
                      style: TextStyle(
                        fontSize: 13,
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

  Widget _linhaOperacional({
    required IconData icon,
    required String titulo,
    required String valor,
    required Color cor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: cor.withValues(alpha: 0.10),
            child: Icon(
              icon,
              color: cor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }
}

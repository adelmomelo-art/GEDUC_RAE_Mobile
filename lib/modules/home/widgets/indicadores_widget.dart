import 'package:flutter/material.dart';

class IndicadoresWidget extends StatelessWidget {
  final int totalAcoes;
  final int totalPessoas;
  final int totalVeiculos;
  final int totalCredenciais;

  const IndicadoresWidget({
    super.key,
    required this.totalAcoes,
    required this.totalPessoas,
    required this.totalVeiculos,
    required this.totalCredenciais,
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
            _titulo(),
            const SizedBox(height: 12),
            _indicador(
              titulo: 'Ações registradas',
              valor: totalAcoes.toString(),
              icone: Icons.assignment,
              cor: Colors.blue,
            ),
            _indicador(
              titulo: 'Pessoas alcançadas',
              valor: totalPessoas.toString(),
              icone: Icons.groups,
              cor: Colors.green,
            ),
            _indicador(
              titulo: 'Veículos abordados',
              valor: totalVeiculos.toString(),
              icone: Icons.directions_car,
              cor: Colors.orange,
            ),
            _indicador(
              titulo: 'Credenciais emitidas',
              valor: totalCredenciais.toString(),
              icone: Icons.badge,
              cor: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _titulo() {
    return const Row(
      children: [
        Icon(
          Icons.analytics,
          color: Colors.blue,
        ),
        SizedBox(width: 8),
        Text(
          'Indicadores Executivos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _indicador({
    required String titulo,
    required String valor,
    required IconData icone,
    required Color cor,
  }) {
    return Card(
      elevation: 0,
      color: cor.withValues(alpha: 0.08),
      child: ListTile(
        leading: Icon(
          icone,
          size: 34,
          color: cor,
        ),
        title: Text(titulo),
        subtitle: Text(
          valor,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: cor,
          ),
        ),
      ),
    );
  }
}
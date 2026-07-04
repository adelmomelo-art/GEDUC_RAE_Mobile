import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AvaliacaoPage extends StatefulWidget {
  const AvaliacaoPage({super.key});

  @override
  State<AvaliacaoPage> createState() => _AvaliacaoPageState();
}

class _AvaliacaoPageState extends State<AvaliacaoPage> {
  int nota = 5;
  bool houveMudanca = true;

  final riscoController = TextEditingController();
  final positivosController = TextEditingController();
  final dificuldadesController = TextEditingController();
  final recomendacoesController = TextEditingController();

  @override
  void dispose() {
    riscoController.dispose();
    positivosController.dispose();
    dificuldadesController.dispose();
    recomendacoesController.dispose();
    super.dispose();
  }

  Color corNota() {
    if (nota >= 4) return Colors.green;
    if (nota >= 3) return Colors.orange;
    return Colors.red;
  }

  String textoNota() {
    if (nota == 5) return 'Excelente';
    if (nota == 4) return 'Boa';
    if (nota == 3) return 'Regular';
    if (nota == 2) return 'Ruim';
    return 'Crítica';
  }

  void avancar() {
    context.go('/revisao');
  }

  @override
  Widget build(BuildContext context) {
    final corAtual = corNota();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avaliação'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: corAtual.withValues(alpha: 0.1),
            child: ListTile(
              leading: Icon(
                Icons.assessment,
                color: corAtual,
              ),
              title: Text(
                textoNota(),
                style: TextStyle(
                  color: corAtual,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text('Nota da ação: $nota'),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Avaliação geral',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [1, 2, 3, 4, 5].map((v) {
              return IconButton(
                onPressed: () {
                  setState(() {
                    nota = v;
                  });
                },
                icon: Icon(
                  v <= nota ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 36,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text(
              'Houve mudança de comportamento observável?',
            ),
            value: houveMudanca,
            onChanged: (valor) {
              setState(() {
                houveMudanca = valor;
              });
            },
          ),
          const SizedBox(height: 20),
          TextField(
            controller: riscoController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Fatores de risco observados',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: positivosController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Pontos positivos',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: dificuldadesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Dificuldades encontradas',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: recomendacoesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Recomendações',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: const Text('PRÓXIMO'),
              onPressed: avancar,
            ),
          ),
        ],
      ),
    );
  }
}
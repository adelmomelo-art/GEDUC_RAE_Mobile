import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'controllers/acao_controller.dart';

class ResultadosPage extends StatefulWidget {
  const ResultadosPage({super.key});

  @override
  State<ResultadosPage> createState() => _ResultadosPageState();
}

class _ResultadosPageState extends State<ResultadosPage> {
  final pessoasController = TextEditingController();
  final veiculosController = TextEditingController();
  final credenciaisController = TextEditingController(text: '0');
  final motivoController = TextEditingController();

  bool metaAtingida = true;
  int publicoMinimo = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final acao = context.read<AcaoController>().acaoAtual;

      if (acao == null) return;

      setState(() {
        publicoMinimo = acao.publicoMinimo;
        metaAtingida = acao.pessoasAlcancadas >= acao.publicoMinimo;

        if (acao.pessoasAlcancadas > 0) {
          pessoasController.text = acao.pessoasAlcancadas.toString();
        }

        if (acao.veiculosAbordados > 0) {
          veiculosController.text = acao.veiculosAbordados.toString();
        }

        credenciaisController.text = acao.credenciaisEmitidas.toString();

        if ((acao.motivoMetaNaoAtingida ?? '').isNotEmpty) {
          motivoController.text = acao.motivoMetaNaoAtingida!;
        }
      });
    });
  }

  void verificarMeta() {
    final pessoas = int.tryParse(pessoasController.text) ?? 0;

    setState(() {
      metaAtingida = pessoas >= publicoMinimo;
    });
  }

  @override
  void dispose() {
    pessoasController.dispose();
    veiculosController.dispose();
    credenciaisController.dispose();
    motivoController.dispose();
    super.dispose();
  }

  void salvarResultados() {
    final pessoas = int.tryParse(pessoasController.text) ?? 0;
    final veiculos = int.tryParse(veiculosController.text) ?? 0;
    final credenciais = int.tryParse(credenciaisController.text) ?? 0;

    if (pessoas <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe as pessoas alcançadas.'),
        ),
      );
      return;
    }

    if (!metaAtingida && motivoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o motivo da meta não atingida.'),
        ),
      );
      return;
    }

    context.read<AcaoController>().preencherResultados(
          pessoasAlcancadas: pessoas,
          veiculosAbordados: veiculos,
          credenciaisEmitidas: credenciais,
          motivoMetaNaoAtingida: motivoController.text.trim(),
        );

    context.go('/evidencias');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: metaAtingida ? Colors.green.shade50 : Colors.red.shade50,
            child: ListTile(
              leading: Icon(
                metaAtingida ? Icons.check_circle : Icons.warning,
                color: metaAtingida ? Colors.green : Colors.red,
              ),
              title: Text(
                metaAtingida ? 'Meta atingida' : 'Meta não atingida',
              ),
              subtitle: Text(
                'Público mínimo da ação: $publicoMinimo',
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: pessoasController,
            keyboardType: TextInputType.number,
            onChanged: (_) => verificarMeta(),
            decoration: const InputDecoration(
              labelText: 'Pessoas alcançadas',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: veiculosController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Veículos abordados',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: credenciaisController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Credenciais emitidas',
              border: OutlineInputBorder(),
            ),
          ),
          if (!metaAtingida) ...[
            const SizedBox(height: 16),
            TextField(
              controller: motivoController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Motivo da meta não atingida',
                border: OutlineInputBorder(),
              ),
            ),
          ],
          const SizedBox(height: 30),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: const Text('PRÓXIMO'),
              onPressed: salvarResultados,
            ),
          ),
        ],
      ),
    );
  }
}
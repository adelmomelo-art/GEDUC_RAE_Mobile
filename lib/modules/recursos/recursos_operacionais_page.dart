import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../acoes/controllers/acao_controller.dart';

class RecursosOperacionaisPage extends StatefulWidget {
  const RecursosOperacionaisPage({super.key});

  @override
  State<RecursosOperacionaisPage> createState() =>
      _RecursosOperacionaisPageState();
}

class _RecursosOperacionaisPageState extends State<RecursosOperacionaisPage> {
  final agentesController = TextEditingController(text: '0');
  final terceirizadosController = TextEditingController(text: '0');

  bool coberturaMidia = false;

  final materialUtilizadoIds = <String>{};

  final materiais = const {
    'material_caixa_som': 'Caixa de som',
    'material_tenda': 'Tenda',
    'material_banner': 'Banner',
    'material_faixa': 'Faixa',
    'material_cone': 'Cone',
    'material_cavalete': 'Cavalete',
    'material_minicircuito': 'Minicircuito',
    'material_bicicletas': 'Bicicletas',
    'material_kit_educativo': 'Kit educativo',
    'material_folders': 'Folders',
    'material_outros': 'Outros',
  };

  @override
  void initState() {
    super.initState();

    final acao = context.read<AcaoController>().acaoAtual;

    if (acao == null) return;

    agentesController.text = acao.agentesTransito.toString();
    terceirizadosController.text = acao.equipeTerceirizada.toString();
    coberturaMidia = acao.coberturaMidia;
    materialUtilizadoIds.addAll(acao.materialUtilizadoIds);
  }

  @override
  void dispose() {
    agentesController.dispose();
    terceirizadosController.dispose();
    super.dispose();
  }

  void salvar() {
    final agentes = int.tryParse(agentesController.text) ?? 0;
    final terceirizados = int.tryParse(terceirizadosController.text) ?? 0;

    if (agentes < 0 || terceirizados < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As quantidades não podem ser negativas.'),
        ),
      );
      return;
    }

    if (materialUtilizadoIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione ao menos um material utilizado.'),
        ),
      );
      return;
    }

    context.read<AcaoController>().preencherRecursosOperacionais(
          agentesTransito: agentes,
          equipeTerceirizada: terceirizados,
          materialUtilizadoIds: materialUtilizadoIds.toList(),
          coberturaMidia: coberturaMidia,
        );

    context.go('/integracao-observacoes');
  }

  Widget _secao(String titulo, List<Widget> filhos) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...filhos,
          ],
        ),
      ),
    );
  }

  Widget _campoNumero({
    required String label,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _materiaisCheckbox() {
    return Column(
      children: materiais.entries.map((entry) {
        return CheckboxListTile(
          value: materialUtilizadoIds.contains(entry.key),
          title: Text(entry.value),
          onChanged: (value) {
            setState(() {
              if (value == true) {
                materialUtilizadoIds.add(entry.key);
              } else {
                materialUtilizadoIds.remove(entry.key);
              }
            });
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recursos Operacionais'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _secao(
            'Equipe envolvida',
            [
              _campoNumero(
                label: 'Quantidade de agentes de trânsito',
                controller: agentesController,
              ),
              const SizedBox(height: 16),
              _campoNumero(
                label: 'Quantidade de equipe terceirizada',
                controller: terceirizadosController,
              ),
            ],
          ),
          _secao(
            'Materiais utilizados',
            [
              const Text(
                'Selecione os materiais utilizados na ação.',
              ),
              const SizedBox(height: 8),
              _materiaisCheckbox(),
            ],
          ),
          _secao(
            'Cobertura de mídia',
            [
              SwitchListTile(
                value: coberturaMidia,
                title: const Text('Houve cobertura de mídia?'),
                subtitle: const Text(
                  'Exemplo: imprensa, redes sociais, TV, rádio ou cobertura institucional.',
                ),
                onChanged: (value) {
                  setState(() {
                    coberturaMidia = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: const Text('SALVAR E AVANÇAR'),
              onPressed: salvar,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../acoes/controllers/acao_controller.dart';

class IntegracaoObservacoesPage extends StatefulWidget {
  const IntegracaoObservacoesPage({super.key});

  @override
  State<IntegracaoObservacoesPage> createState() =>
      _IntegracaoObservacoesPageState();
}

class _IntegracaoObservacoesPageState extends State<IntegracaoObservacoesPage> {
  bool houveParticipacaoOutroOrgao = false;
  String? orgaoParticipanteId;

  final pontosPositivosController = TextEditingController();
  final dificuldadesController = TextEditingController();
  final recomendacoesController = TextEditingController();

  final orgaos = const {
    'orgao_amc': 'AMC',
    'orgao_detran': 'DETRAN',
    'orgao_sefin': 'SEFIN',
    'orgao_agefis': 'AGEFIS',
    'orgao_sesec': 'SESEC',
    'orgao_gmf': 'Guarda Municipal',
    'orgao_outro': 'Outro órgão',
  };

  @override
  void initState() {
    super.initState();

    final acao = context.read<AcaoController>().acaoAtual;

    if (acao == null) return;

    houveParticipacaoOutroOrgao = acao.houveParticipacaoOutroOrgao;
    orgaoParticipanteId =
        acao.orgaoParticipanteId.isEmpty ? null : acao.orgaoParticipanteId;
    pontosPositivosController.text = acao.pontosPositivos;
    dificuldadesController.text = acao.dificuldadesEncontradas;
    recomendacoesController.text = acao.recomendacoes;
  }

  @override
  void dispose() {
    pontosPositivosController.dispose();
    dificuldadesController.dispose();
    recomendacoesController.dispose();
    super.dispose();
  }

  void salvar() {
    if (houveParticipacaoOutroOrgao && orgaoParticipanteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe qual órgão participou da ação.'),
        ),
      );
      return;
    }

    context.read<AcaoController>().preencherIntegracaoObservacoes(
          houveParticipacaoOutroOrgao: houveParticipacaoOutroOrgao,
          orgaoParticipanteId:
              houveParticipacaoOutroOrgao ? orgaoParticipanteId ?? '' : '',
          pontosPositivos: pontosPositivosController.text.trim(),
          dificuldadesEncontradas: dificuldadesController.text.trim(),
          recomendacoes: recomendacoesController.text.trim(),
        );

    context.go('/resultados');
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

  Widget _campoTextoLongo({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      minLines: 3,
      maxLines: 6,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Integração e Observações'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _secao(
            'Integração institucional',
            [
              SwitchListTile(
                value: houveParticipacaoOutroOrgao,
                title: const Text('Houve participação de outro órgão?'),
                onChanged: (value) {
                  setState(() {
                    houveParticipacaoOutroOrgao = value;

                    if (!value) {
                      orgaoParticipanteId = null;
                    }
                  });
                },
              ),
              if (houveParticipacaoOutroOrgao) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: orgaoParticipanteId,
                  decoration: const InputDecoration(
                    labelText: 'Qual órgão participou?',
                    border: OutlineInputBorder(),
                  ),
                  items: orgaos.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      orgaoParticipanteId = value;
                    });
                  },
                ),
              ],
            ],
          ),
          _secao(
            'Observações operacionais',
            [
              _campoTextoLongo(
                label: 'Observações positivas',
                controller: pontosPositivosController,
                hint: 'Registre aspectos positivos observados na ação.',
              ),
              const SizedBox(height: 16),
              _campoTextoLongo(
                label: 'Dificuldades encontradas',
                controller: dificuldadesController,
                hint: 'Registre dificuldades, limitações ou problemas.',
              ),
              const SizedBox(height: 16),
              _campoTextoLongo(
                label: 'Recomendações para próximas ações',
                controller: recomendacoesController,
                hint: 'Sugira melhorias para futuras ações.',
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

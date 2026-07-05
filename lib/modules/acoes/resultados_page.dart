import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/services/kpi_service.dart';
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
  int publicoEstimado = 0;

  int agentesTransito = 0;
  int equipeTerceirizada = 0;
  bool acaoPlanejada = false;
  bool coberturaMidia = false;
  bool houveParticipacaoOutroOrgao = false;
  bool possuiEvidencias = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final acao = context.read<AcaoController>().acaoAtual;

      if (acao == null) return;

      setState(() {
        publicoMinimo = acao.publicoMinimo;
        publicoEstimado = acao.publicoEstimado;
        metaAtingida = acao.pessoasAlcancadas >= acao.publicoMinimo;

        agentesTransito = acao.agentesTransito;
        equipeTerceirizada = acao.equipeTerceirizada;
        acaoPlanejada = acao.acaoPlanejada;
        coberturaMidia = acao.coberturaMidia;
        houveParticipacaoOutroOrgao = acao.houveParticipacaoOutroOrgao;
        possuiEvidencias = acao.fotosUrls.isNotEmpty;

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

  int get pessoasAlcancadas => int.tryParse(pessoasController.text) ?? 0;

  int get veiculosAbordados => int.tryParse(veiculosController.text) ?? 0;

  int get credenciaisEmitidas => int.tryParse(credenciaisController.text) ?? 0;

  double get percentualMetaMinima {
    return KpiService.calcularPercentual(
      realizado: pessoasAlcancadas,
      referencia: publicoMinimo,
    );
  }

  double get percentualPlanejamento {
    return KpiService.calcularPercentual(
      realizado: pessoasAlcancadas,
      referencia: publicoEstimado,
    );
  }

  double get pessoasPorEquipe {
    return KpiService.calcularPessoasPorEquipe(
      pessoasAlcancadas: pessoasAlcancadas,
      agentesTransito: agentesTransito,
      equipeTerceirizada: equipeTerceirizada,
    );
  }

  double get pessoasPorVeiculo {
    return KpiService.calcularPessoasPorVeiculo(
      pessoasAlcancadas: pessoasAlcancadas,
      veiculosAbordados: veiculosAbordados,
    );
  }

  int get indiceOperacional {
    return KpiService.calcularIndiceOperacional(
      metaAtingida: metaAtingida,
      possuiEvidencias: possuiEvidencias,
      acaoPlanejada: acaoPlanejada,
      houveParticipacaoOutroOrgao: houveParticipacaoOutroOrgao,
      coberturaMidia: coberturaMidia,
    );
  }

  double progressoLimitado(double valor) {
    if (valor < 0) return 0;
    if (valor > 1) return 1;
    return valor;
  }

  void verificarMeta() {
    final pessoas = pessoasAlcancadas;

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
    final pessoas = pessoasAlcancadas;
    final veiculos = veiculosAbordados;
    final credenciais = credenciaisEmitidas;

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

  Widget _cardExecutivo() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resultado da ação',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _linhaResumo('Público estimado', publicoEstimado.toString()),
            _linhaResumo('Meta mínima', publicoMinimo.toString()),
            _linhaResumo('Pessoas alcançadas', pessoasAlcancadas.toString()),
            _linhaResumo('Veículos abordados', veiculosAbordados.toString()),
            _linhaResumo(
              'Credenciais emitidas',
              credenciaisEmitidas.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linhaResumo(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            valor,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _cardMeta() {
    return Card(
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
    );
  }

  Widget _indicador({
    required String titulo,
    required String subtitulo,
    required double percentual,
    required String classificacao,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitulo),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progressoLimitado(percentual),
              minHeight: 10,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(classificacao),
                Text(
                  KpiService.formatarPercentual(percentual),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpiOperacional() {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inteligência Operacional',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _linhaResumo(
              'Pessoas por integrante da equipe',
              KpiService.formatarDecimal(pessoasPorEquipe),
            ),
            _linhaResumo(
              'Pessoas por veículo abordado',
              KpiService.formatarDecimal(pessoasPorVeiculo),
            ),
            _linhaResumo(
              'Índice operacional',
              '$indiceOperacional pontos',
            ),
            const SizedBox(height: 8),
            Text(
              KpiService.classificarIndiceOperacional(indiceOperacional),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardFaxita() {
    final analise = KpiService.gerarAnaliseFaxita(
      metaAtingida: metaAtingida,
      percentualMeta: percentualMetaMinima,
      percentualPlanejamento: percentualPlanejamento,
      pessoasPorEquipe: pessoasPorEquipe,
      indiceOperacional: indiceOperacional,
    );

    return Card(
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.psychology),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                analise,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoNumero({
    required TextEditingController controller,
    required String label,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final percentualMinimo = percentualMetaMinima;
    final percentualPlanejado = percentualPlanejamento;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _cardExecutivo(),
          const SizedBox(height: 12),
          _cardMeta(),
          const SizedBox(height: 12),
          _indicador(
            titulo: 'Cumprimento da meta mínima',
            subtitulo: '$pessoasAlcancadas de $publicoMinimo pessoas',
            percentual: percentualMinimo,
            classificacao: KpiService.classificarMeta(percentualMinimo),
          ),
          _indicador(
            titulo: 'Alcance do planejamento',
            subtitulo: '$pessoasAlcancadas de $publicoEstimado pessoas estimadas',
            percentual: percentualPlanejado,
            classificacao: KpiService.classificarPlanejamento(
              percentualPlanejado,
            ),
          ),
          _kpiOperacional(),
          _cardFaxita(),
          const SizedBox(height: 16),
          _campoNumero(
            controller: pessoasController,
            label: 'Pessoas alcançadas',
            onChanged: (_) => verificarMeta(),
          ),
          const SizedBox(height: 16),
          _campoNumero(
            controller: veiculosController,
            label: 'Veículos abordados',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          _campoNumero(
            controller: credenciaisController,
            label: 'Credenciais emitidas',
            onChanged: (_) => setState(() {}),
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

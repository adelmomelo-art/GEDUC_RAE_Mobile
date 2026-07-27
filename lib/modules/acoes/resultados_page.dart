import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  int publicoMinimo = 0;
  int publicoEstimado = 0;

  int agentesTransito = 0;
  int equipeTerceirizada = 0;
  bool acaoPlanejada = false;
  bool coberturaMidia = false;
  bool houveParticipacaoOutroOrgao = false;
  bool possuiEvidencias = false;

  bool _dadosCarregados = false;
  bool _navegando = false;

  @override
  void initState() {
    super.initState();
    _restaurarDados();

    pessoasController.addListener(_atualizarInterface);
    veiculosController.addListener(_atualizarInterface);
    credenciaisController.addListener(_atualizarInterface);
    motivoController.addListener(_atualizarInterface);
  }

  void _restaurarDados() {
    final acao = context.read<AcaoController>().acaoAtual;

    if (acao != null) {
      publicoMinimo = acao.publicoMinimo;
      publicoEstimado = acao.publicoEstimado;

      agentesTransito = acao.agentesTransito;
      equipeTerceirizada = acao.equipeTerceirizada;
      acaoPlanejada = acao.acaoPlanejada;
      coberturaMidia = acao.coberturaMidia;
      houveParticipacaoOutroOrgao = acao.houveParticipacaoOutroOrgao;
      possuiEvidencias = acao.fotosUrls.isNotEmpty;

      pessoasController.text = acao.pessoasAlcancadas > 0
          ? acao.pessoasAlcancadas.toString()
          : '';

      veiculosController.text = acao.veiculosAbordados > 0
          ? acao.veiculosAbordados.toString()
          : '';

      credenciaisController.text = acao.credenciaisEmitidas.toString();
      motivoController.text = acao.motivoMetaNaoAtingida ?? '';
    }

    _dadosCarregados = true;
  }

  @override
  void dispose() {
    pessoasController
      ..removeListener(_atualizarInterface)
      ..dispose();

    veiculosController
      ..removeListener(_atualizarInterface)
      ..dispose();

    credenciaisController
      ..removeListener(_atualizarInterface)
      ..dispose();

    motivoController
      ..removeListener(_atualizarInterface)
      ..dispose();

    super.dispose();
  }

  void _atualizarInterface() {
    if (!mounted || !_dadosCarregados) return;
    setState(() {});
  }

  int _valorInteiro(TextEditingController controller) {
    return int.tryParse(controller.text.trim()) ?? 0;
  }

  int get pessoasAlcancadas => _valorInteiro(pessoasController);

  int get veiculosAbordados => _valorInteiro(veiculosController);

  int get credenciaisEmitidas => _valorInteiro(credenciaisController);

  bool get metaDefinida => publicoMinimo > 0;

  bool get metaAtingida =>
      metaDefinida && pessoasAlcancadas >= publicoMinimo;

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

  bool get _resultadosValidos {
    if (pessoasAlcancadas <= 0) return false;

    if (metaDefinida &&
        !metaAtingida &&
        motivoController.text.trim().isEmpty) {
      return false;
    }

    return true;
  }

  double _progressoLimitado(double valor) {
    if (valor < 0) return 0;
    if (valor > 1) return 1;
    return valor;
  }

  void _persistirNoController() {
    context.read<AcaoController>().preencherResultados(
          pessoasAlcancadas: pessoasAlcancadas,
          veiculosAbordados: veiculosAbordados,
          credenciaisEmitidas: credenciaisEmitidas,
          motivoMetaNaoAtingida:
              metaDefinida && !metaAtingida
                  ? motivoController.text.trim()
                  : '',
        );
  }

  void _voltar() {
    if (_navegando) return;

    _persistirNoController();
    _navegando = true;
    context.go('/integracao-observacoes');
  }

  void _salvarEAvancar() {
    if (pessoasAlcancadas <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe as pessoas alcançadas.'),
        ),
      );
      return;
    }

    if (metaDefinida &&
        !metaAtingida &&
        motivoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o motivo da meta não atingida.'),
        ),
      );
      return;
    }

    if (_navegando) return;

    _persistirNoController();
    _navegando = true;
    context.go('/evidencias');
  }

  void _selecionarZero(TextEditingController controller) {
    if (controller.text.trim() == '0') {
      controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.text.length,
      );
    }
  }

  String get _mensagemFaxita {
    if (pessoasAlcancadas <= 0) {
      return 'Informe os resultados alcançados para que eu possa analisar '
          'o desempenho da ação.';
    }

    final analise = KpiService.gerarAnaliseFaxita(
      metaAtingida: metaAtingida,
      percentualMeta: percentualMetaMinima,
      percentualPlanejamento: percentualPlanejamento,
      pessoasPorEquipe: pessoasPorEquipe,
      indiceOperacional: indiceOperacional,
    );

    if (!metaDefinida) {
      return '$analise A ação não possui meta mínima definida; por isso, '
          'o cumprimento da meta não será classificado nesta etapa.';
    }

    if (!possuiEvidencias) {
      return '$analise O índice operacional ainda é provisório e poderá '
          'aumentar após o registro das evidências.';
    }

    return analise;
  }

  String get _statusGeral {
    if (pessoasAlcancadas <= 0) {
      return 'Resultados ainda não informados';
    }

    if (!metaDefinida) {
      return 'Resultados registrados, sem meta mínima definida';
    }

    if (metaAtingida) {
      return 'Meta mínima atingida';
    }

    return 'Meta mínima não atingida';
  }

  Color _corStatusMeta(BuildContext context) {
    if (!metaDefinida) {
      return Theme.of(context).colorScheme.secondaryContainer;
    }

    return metaAtingida
        ? Colors.green.shade50
        : Colors.orange.shade50;
  }

  IconData get _iconeStatusMeta {
    if (!metaDefinida) return Icons.info_outline;
    return metaAtingida ? Icons.check_circle_outline : Icons.warning_amber;
  }

  Color _corIconeMeta(BuildContext context) {
    if (!metaDefinida) {
      return Theme.of(context).colorScheme.onSecondaryContainer;
    }

    return metaAtingida ? Colors.green.shade700 : Colors.orange.shade800;
  }

  Widget _cabecalhoEtapa() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.analytics_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Resultados da ação',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '6 de 9',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Registre os resultados e acompanhe os indicadores operacionais.',
        ),
        const SizedBox(height: 12),
        const LinearProgressIndicator(
          value: 6 / 9,
          minHeight: 8,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ],
    );
  }

  Widget _cardFaxita() {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.psychology_alt_outlined,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Análise da Faxita',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _mensagemFaxita,
                    style: TextStyle(
                      color:
                          Theme.of(context).colorScheme.onPrimaryContainer,
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

  Widget _secao({
    required String titulo,
    required IconData icone,
    required List<Widget> filhos,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icone,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...filhos,
          ],
        ),
      ),
    );
  }

  Widget _campoNumero({
    required TextEditingController controller,
    required String label,
    required IconData icone,
    String? helperText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      onTap: () => _selecionarZero(controller),
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixIcon: Icon(icone),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _cardRegistroResultados() {
    return _secao(
      titulo: 'Registro dos resultados',
      icone: Icons.edit_note_outlined,
      filhos: [
        _campoNumero(
          controller: pessoasController,
          label: 'Pessoas alcançadas',
          icone: Icons.groups_outlined,
          helperText: 'Campo obrigatório.',
        ),
        const SizedBox(height: 16),
        _campoNumero(
          controller: veiculosController,
          label: 'Veículos abordados',
          icone: Icons.directions_car_outlined,
        ),
        const SizedBox(height: 16),
        _campoNumero(
          controller: credenciaisController,
          label: 'Credenciais emitidas',
          icone: Icons.badge_outlined,
        ),
        if (metaDefinida && !metaAtingida) ...[
          const SizedBox(height: 16),
          TextField(
            controller: motivoController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Motivo da meta não atingida',
              hintText:
                  'Registre o principal fator que comprometeu o resultado.',
              prefixIcon: Icon(Icons.comment_outlined),
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _cardMeta() {
    final titulo = !metaDefinida
        ? 'Meta mínima não definida'
        : metaAtingida
            ? 'Meta mínima atingida'
            : 'Meta mínima não atingida';

    final subtitulo = !metaDefinida
        ? 'A ação não possui referência mínima cadastrada.'
        : '$pessoasAlcancadas de $publicoMinimo pessoas';

    return Card(
      color: _corStatusMeta(context),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(
          _iconeStatusMeta,
          color: _corIconeMeta(context),
          size: 30,
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitulo),
        ),
      ),
    );
  }

  Widget _painelExecutivo() {
    return _secao(
      titulo: 'Painel executivo',
      icone: Icons.dashboard_outlined,
      filhos: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _metrica(
              titulo: 'Público estimado',
              valor: publicoEstimado.toString(),
              icone: Icons.people_alt_outlined,
            ),
            _metrica(
              titulo: 'Meta mínima',
              valor: metaDefinida ? publicoMinimo.toString() : 'Não definida',
              icone: Icons.flag_outlined,
            ),
            _metrica(
              titulo: 'Pessoas alcançadas',
              valor: pessoasAlcancadas.toString(),
              icone: Icons.groups_outlined,
            ),
            _metrica(
              titulo: 'Veículos abordados',
              valor: veiculosAbordados.toString(),
              icone: Icons.directions_car_outlined,
            ),
            _metrica(
              titulo: 'Credenciais emitidas',
              valor: credenciaisEmitidas.toString(),
              icone: Icons.badge_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _metrica({
    required String titulo,
    required String valor,
    required IconData icone,
  }) {
    return SizedBox(
      width: 210,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(
                icone,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      valor,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _indicador({
    required String titulo,
    required String subtitulo,
    required double percentual,
    required String classificacao,
    bool disponivel = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(subtitulo),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: disponivel ? _progressoLimitado(percentual) : 0,
            minHeight: 10,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  disponivel ? classificacao : 'Indicador indisponível',
                ),
              ),
              Text(
                disponivel
                    ? KpiService.formatarPercentual(percentual)
                    : '—',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardIndicadores() {
    return _secao(
      titulo: 'Indicadores de desempenho',
      icone: Icons.insights_outlined,
      filhos: [
        _indicador(
          titulo: 'Cumprimento da meta mínima',
          subtitulo: metaDefinida
              ? '$pessoasAlcancadas de $publicoMinimo pessoas'
              : 'Meta mínima não cadastrada',
          percentual: percentualMetaMinima,
          classificacao:
              KpiService.classificarMeta(percentualMetaMinima),
          disponivel: metaDefinida,
        ),
        const SizedBox(height: 14),
        _indicador(
          titulo: 'Alcance do planejamento',
          subtitulo: publicoEstimado > 0
              ? '$pessoasAlcancadas de $publicoEstimado pessoas estimadas'
              : 'Público estimado não cadastrado',
          percentual: percentualPlanejamento,
          classificacao: KpiService.classificarPlanejamento(
            percentualPlanejamento,
          ),
          disponivel: publicoEstimado > 0,
        ),
      ],
    );
  }

  Widget _linhaResumo(
    String label,
    String valor, {
    IconData? icone,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icone != null) ...[
            Icon(
              icone,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
          ],
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Text(
            valor,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _cardInteligenciaOperacional() {
    return _secao(
      titulo: 'Inteligência operacional',
      icone: Icons.analytics_outlined,
      filhos: [
        _linhaResumo(
          'Pessoas por integrante da equipe',
          KpiService.formatarDecimal(pessoasPorEquipe),
          icone: Icons.engineering_outlined,
        ),
        _linhaResumo(
          'Pessoas por veículo abordado',
          KpiService.formatarDecimal(pessoasPorVeiculo),
          icone: Icons.directions_car_outlined,
        ),
        _linhaResumo(
          'Índice operacional',
          '$indiceOperacional pontos',
          icone: Icons.speed_outlined,
        ),
        const Divider(height: 24),
        Text(
          KpiService.classificarIndiceOperacional(indiceOperacional),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        if (!possuiEvidencias) ...[
          const SizedBox(height: 10),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pontuação provisória: as evidências ainda serão '
                  'registradas na próxima etapa.',
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _fatorOperacional({
    required String titulo,
    required bool concluido,
    required String descricao,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(
        concluido
            ? Icons.check_circle_outline
            : Icons.radio_button_unchecked,
        color: concluido
            ? Colors.green.shade700
            : Theme.of(context).colorScheme.outline,
      ),
      title: Text(titulo),
      subtitle: Text(descricao),
    );
  }

  Widget _cardComposicaoIndice() {
    return _secao(
      titulo: 'Composição do índice',
      icone: Icons.fact_check_outlined,
      filhos: [
        _fatorOperacional(
          titulo: 'Planejamento da ação',
          concluido: acaoPlanejada,
          descricao: acaoPlanejada
              ? 'A ação foi registrada como planejada.'
              : 'A ação não foi registrada como planejada.',
        ),
        _fatorOperacional(
          titulo: 'Cumprimento da meta',
          concluido: metaAtingida,
          descricao: !metaDefinida
              ? 'Meta mínima não definida.'
              : metaAtingida
                  ? 'A meta mínima foi atingida.'
                  : 'A meta mínima ainda não foi atingida.',
        ),
        _fatorOperacional(
          titulo: 'Integração institucional',
          concluido: houveParticipacaoOutroOrgao,
          descricao: houveParticipacaoOutroOrgao
              ? 'Houve participação de outro órgão.'
              : 'Não houve participação de outro órgão.',
        ),
        _fatorOperacional(
          titulo: 'Cobertura de mídia',
          concluido: coberturaMidia,
          descricao: coberturaMidia
              ? 'A ação contou com cobertura de mídia.'
              : 'Não foi registrada cobertura de mídia.',
        ),
        _fatorOperacional(
          titulo: 'Evidências',
          concluido: possuiEvidencias,
          descricao: possuiEvidencias
              ? 'Existem evidências registradas.'
              : 'As evidências serão incluídas na próxima etapa.',
        ),
      ],
    );
  }

  Widget _cardResumoFinal() {
    final motivoValido = !metaDefinida ||
        metaAtingida ||
        motivoController.text.trim().isNotEmpty;

    return _secao(
      titulo: 'Resumo executivo',
      icone: Icons.assignment_turned_in_outlined,
      filhos: [
        _linhaResumo(
          'Situação geral',
          _statusGeral,
          icone: Icons.assessment_outlined,
        ),
        _linhaResumo(
          'Dados de resultado',
          pessoasAlcancadas > 0 ? 'Preenchidos' : 'Pendentes',
          icone: Icons.edit_note_outlined,
        ),
        _linhaResumo(
          'Justificativa da meta',
          motivoValido ? 'Regular' : 'Pendente',
          icone: Icons.comment_outlined,
        ),
        _linhaResumo(
          'Próxima etapa',
          'Registro de evidências',
          icone: Icons.photo_camera_outlined,
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _resultadosValidos
                ? Colors.green.shade50
                : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _resultadosValidos
                ? 'Os resultados estão consistentes para avançar.'
                : 'Existem informações pendentes antes de avançar.',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _barraNavegacao() {
    return SafeArea(
      top: false,
      child: Material(
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: _voltar,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Voltar'),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _salvarEAvancar,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Próximo'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _voltar();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Resultados'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _cabecalhoEtapa(),
            const SizedBox(height: 16),
            _cardFaxita(),
            const SizedBox(height: 12),
            _cardRegistroResultados(),
            const SizedBox(height: 12),
            _cardMeta(),
            const SizedBox(height: 12),
            _painelExecutivo(),
            const SizedBox(height: 12),
            _cardIndicadores(),
            const SizedBox(height: 12),
            _cardInteligenciaOperacional(),
            const SizedBox(height: 12),
            _cardComposicaoIndice(),
            const SizedBox(height: 12),
            _cardResumoFinal(),
          ],
        ),
        bottomNavigationBar: _barraNavegacao(),
      ),
    );
  }
}

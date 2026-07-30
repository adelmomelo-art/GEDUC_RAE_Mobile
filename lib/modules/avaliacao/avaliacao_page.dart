import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../acoes/controllers/acao_controller.dart';

class AvaliacaoPage extends StatefulWidget {
  const AvaliacaoPage({super.key});

  @override
  State<AvaliacaoPage> createState() => _AvaliacaoPageState();
}

class _AvaliacaoPageState extends State<AvaliacaoPage> {
  final riscoController = TextEditingController();
  final positivosController = TextEditingController();
  final dificuldadesController = TextEditingController();
  final recomendacoesController = TextEditingController();

  int nota = 0;
  String? mudancaComportamentoId;
  bool _restaurandoDados = true;
  bool _navegando = false;

  static const mudancasComportamento = <String, String>{
    'mudanca_sim': 'Sim, foi observada',
    'mudanca_parcial': 'Parcialmente observada',
    'mudanca_nao': 'Não foi observada',
  };

  @override
  void initState() {
    super.initState();
    _restaurarRascunho();

    riscoController.addListener(_aoAlterarTexto);
    positivosController.addListener(_aoAlterarTexto);
    dificuldadesController.addListener(_aoAlterarTexto);
    recomendacoesController.addListener(_aoAlterarTexto);
  }

  void _restaurarRascunho() {
    final acao = context.read<AcaoController>().acaoAtual;

    if (acao != null) {
      nota = acao.notaAvaliacao.clamp(0, 5);
      mudancaComportamentoId = acao.mudancaComportamentoId.isEmpty
          ? null
          : acao.mudancaComportamentoId;
      riscoController.text = acao.fatorRiscoIds.join('\n');
      positivosController.text = acao.pontosPositivos;
      dificuldadesController.text = acao.dificuldadesEncontradas;
      recomendacoesController.text = acao.recomendacoes;
    }

    _restaurandoDados = false;
  }

  @override
  void dispose() {
    riscoController
      ..removeListener(_aoAlterarTexto)
      ..dispose();
    positivosController
      ..removeListener(_aoAlterarTexto)
      ..dispose();
    dificuldadesController
      ..removeListener(_aoAlterarTexto)
      ..dispose();
    recomendacoesController
      ..removeListener(_aoAlterarTexto)
      ..dispose();
    super.dispose();
  }

  void _aoAlterarTexto() {
    if (!mounted || _restaurandoDados) return;
    setState(() {});
    _persistirRascunho();
  }

  List<String> get _fatoresRisco {
    return riscoController.text
        .split(RegExp(r'[\n;,]+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  bool get _notaPreenchida => nota >= 1 && nota <= 5;
  bool get _mudancaPreenchida => mudancaComportamentoId != null;
  bool get _riscosPreenchidos => _fatoresRisco.isNotEmpty;
  bool get _positivosPreenchidos => positivosController.text.trim().isNotEmpty;
  bool get _dificuldadesPreenchidas =>
      dificuldadesController.text.trim().isNotEmpty;
  bool get _recomendacoesPreenchidas =>
      recomendacoesController.text.trim().isNotEmpty;

  int get _itensConcluidos {
    return [
      _notaPreenchida,
      _mudancaPreenchida,
      _riscosPreenchidos,
      _positivosPreenchidos,
      _dificuldadesPreenchidas,
      _recomendacoesPreenchidas,
    ].where((item) => item).length;
  }

  bool get _avaliacaoCompleta => _itensConcluidos == 6;

  Color get _corNota {
    if (!_notaPreenchida) return Colors.blueGrey;
    if (nota >= 4) return Colors.green;
    if (nota == 3) return Colors.orange;
    return Colors.red;
  }

  String get _textoNota {
    switch (nota) {
      case 5:
        return 'Excelente';
      case 4:
        return 'Boa';
      case 3:
        return 'Regular';
      case 2:
        return 'Ruim';
      case 1:
        return 'Crítica';
      default:
        return 'Não avaliada';
    }
  }

  String get _mensagemFaxita {
    if (!_notaPreenchida) {
      return 'Avalie a qualidade geral da ação para iniciarmos a análise final.';
    }

    if (!_mudancaPreenchida) {
      return 'Agora informe se houve mudança de comportamento observável no público.';
    }

    if (!_riscosPreenchidos) {
      return 'Registre os fatores de risco observados durante a atividade.';
    }

    if (!_positivosPreenchidos) {
      return 'Descreva os principais pontos positivos da ação.';
    }

    if (!_dificuldadesPreenchidas) {
      return 'Informe as dificuldades encontradas, mesmo quando forem pontuais.';
    }

    if (!_recomendacoesPreenchidas) {
      return 'Finalize registrando recomendações para as próximas ações.';
    }

    if (nota >= 4) {
      return 'Avaliação concluída com desempenho positivo. Revise os registros e avance para a consolidação do RAE.';
    }

    if (nota == 3) {
      return 'Avaliação concluída. Foram identificadas oportunidades de melhoria que devem orientar o planejamento futuro.';
    }

    return 'Avaliação concluída com pontos críticos. Recomenda-se atenção gerencial durante a revisão do relatório.';
  }

  void _persistirRascunho() {
    if (_restaurandoDados) return;

    context.read<AcaoController>().preencherAvaliacao(
          notaAvaliacao: nota,
          mudancaComportamentoId: mudancaComportamentoId ?? '',
          fatorRiscoIds: _fatoresRisco,
          pontosPositivos: positivosController.text,
          dificuldadesEncontradas: dificuldadesController.text,
          recomendacoes: recomendacoesController.text,
        );
  }

  void _selecionarNota(int valor) {
    setState(() => nota = valor);
    _persistirRascunho();
  }

  void _selecionarMudanca(String? valor) {
    setState(() => mudancaComportamentoId = valor);
    _persistirRascunho();
  }

  void _voltar() {
    if (_navegando) return;
    _persistirRascunho();
    _navegando = true;
    context.go('/evidencias');
  }

  void _salvarEAvancar() {
    if (!_avaliacaoCompleta) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A Faixita identificou informações obrigatórias ainda não preenchidas.',
          ),
        ),
      );
      return;
    }

    if (_navegando) return;
    _persistirRascunho();
    _navegando = true;
    context.go('/revisao');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Voltar',
          onPressed: _voltar,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Avaliação da ação'),
      ),
      bottomNavigationBar: SafeArea(
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
                  onPressed: _avaliacaoCompleta ? _salvarEAvancar : null,
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text('Revisar RAE'),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _cabecalho(),
                const SizedBox(height: 12),
                _faxitaCard(),
                const SizedBox(height: 12),
                _dashboard(),
                const SizedBox(height: 12),
                _secaoAvaliacaoGeral(),
                const SizedBox(height: 12),
                _secaoComportamentoERiscos(),
                const SizedBox(height: 12),
                _secaoAnaliseQualitativa(),
                const SizedBox(height: 12),
                _checklistFinal(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cabecalho() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primaryContainer,
            ],
          ),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 27,
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF1565C0),
              child: Icon(Icons.rate_review_outlined, size: 30),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Avaliação e aprendizagem operacional',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Consolide a percepção de qualidade antes da revisão final.',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'ETAPA 9/9',
                style: TextStyle(
                  color: Color(0xFF1565C0),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _faxitaCard() {
    final cor =
        _avaliacaoCompleta ? const Color(0xFF2E7D32) : const Color(0xFFF9A825);
    final fundo =
        _avaliacaoCompleta ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cor, width: 1.4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: cor,
            foregroundColor: Colors.white,
            child: Icon(
              _avaliacaoCompleta
                  ? Icons.check_circle_outline
                  : Icons.auto_awesome_outlined,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Faixita',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(_mensagemFaxita),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashboard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final largura = constraints.maxWidth;
        final colunas = largura >= 760 ? 4 : 2;
        final larguraCard = (largura - ((colunas - 1) * 12)) / colunas;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _indicadorExecutivo(
              largura: larguraCard,
              icone: Icons.star_outline,
              titulo: 'Nota',
              valor: _notaPreenchida ? '$nota/5' : 'Pendente',
              cor: _corNota,
            ),
            _indicadorExecutivo(
              largura: larguraCard,
              icone: Icons.psychology_alt_outlined,
              titulo: 'Comportamento',
              valor: mudancaComportamentoId == null
                  ? 'Pendente'
                  : mudancasComportamento[mudancaComportamentoId]!,
              cor: _mudancaPreenchida ? Colors.green : Colors.orange,
            ),
            _indicadorExecutivo(
              largura: larguraCard,
              icone: Icons.warning_amber_outlined,
              titulo: 'Riscos',
              valor: _riscosPreenchidos
                  ? '${_fatoresRisco.length} registrado(s)'
                  : 'Pendente',
              cor: _riscosPreenchidos ? Colors.green : Colors.orange,
            ),
            _indicadorExecutivo(
              largura: larguraCard,
              icone: Icons.task_alt_outlined,
              titulo: 'Conclusão',
              valor: '$_itensConcluidos/6',
              cor: _avaliacaoCompleta ? Colors.green : Colors.orange,
            ),
          ],
        );
      },
    );
  }

  Widget _indicadorExecutivo({
    required double largura,
    required IconData icone,
    required String titulo,
    required String valor,
    required Color cor,
  }) {
    return SizedBox(
      width: largura,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icone, color: cor),
              const SizedBox(height: 10),
              Text(
                titulo,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 3),
              Text(
                valor,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _secaoAvaliacaoGeral() {
    return _sectionCard(
      titulo: 'Avaliação geral',
      subtitulo: 'Classifique a qualidade global da execução da ação.',
      icone: Icons.assessment_outlined,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _corNota.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _corNota.withValues(alpha: 0.45),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.insights_outlined, color: _corNota),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$_textoNota${_notaPreenchida ? ' — nota $nota' : ''}',
                    style: TextStyle(
                      color: _corNota,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            children: List.generate(5, (index) {
              final valor = index + 1;
              return IconButton(
                tooltip: 'Nota $valor',
                onPressed: () => _selecionarNota(valor),
                iconSize: 40,
                color: Colors.amber.shade700,
                icon: Icon(
                  valor <= nota ? Icons.star : Icons.star_border,
                ),
              );
            }),
          ),
          const Text(
            '1 = crítica  •  3 = regular  •  5 = excelente',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _secaoComportamentoERiscos() {
    final mudancaSelecionadaSegura =
        mudancaComportamentoId != null &&
                mudancasComportamento.containsKey(mudancaComportamentoId)
            ? mudancaComportamentoId
            : null;

    return _sectionCard(
      titulo: 'Comportamento e riscos',
      subtitulo: 'Registre os efeitos observados e os riscos identificados.',
      icone: Icons.visibility_outlined,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey<String>(
              'mudanca_comportamento::${mudancaSelecionadaSegura ?? ''}::${mudancasComportamento.keys.join('|')}',
            ),
            initialValue: mudancaSelecionadaSegura,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Mudança de comportamento observável *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.change_circle_outlined),
            ),
            items: mudancasComportamento.entries
                .map(
                  (item) => DropdownMenuItem(
                    value: item.key,
                    child: Text(item.value),
                  ),
                )
                .toList(growable: false),
            onChanged: _selecionarMudanca,
          ),
          const SizedBox(height: 16),
          _campoTexto(
            controller: riscoController,
            label: 'Fatores de risco observados *',
            hint:
                'Informe um fator por linha. Também é possível separar por vírgula ou ponto e vírgula.',
            icone: Icons.warning_amber_outlined,
          ),
        ],
      ),
    );
  }

  Widget _secaoAnaliseQualitativa() {
    return _sectionCard(
      titulo: 'Análise qualitativa',
      subtitulo: 'Registre aprendizados para apoiar decisões futuras.',
      icone: Icons.edit_note_outlined,
      child: Column(
        children: [
          _campoTexto(
            controller: positivosController,
            label: 'Pontos positivos *',
            hint: 'Descreva o que funcionou bem durante a ação.',
            icone: Icons.thumb_up_alt_outlined,
          ),
          const SizedBox(height: 16),
          _campoTexto(
            controller: dificuldadesController,
            label: 'Dificuldades encontradas *',
            hint:
                'Informe limitações operacionais, estruturais ou de participação.',
            icone: Icons.report_problem_outlined,
          ),
          const SizedBox(height: 16),
          _campoTexto(
            controller: recomendacoesController,
            label: 'Recomendações *',
            hint:
                'Registre medidas de melhoria para as próximas ações educativas.',
            icone: Icons.lightbulb_outline,
          ),
        ],
      ),
    );
  }

  Widget _campoTexto({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icone,
  }) {
    return TextField(
      controller: controller,
      minLines: 3,
      maxLines: 6,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: true,
        border: const OutlineInputBorder(),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 70),
          child: Icon(icone),
        ),
      ),
    );
  }

  Widget _checklistFinal() {
    return _sectionCard(
      titulo: 'Checklist final',
      subtitulo: 'Confirme os registros necessários para avançar.',
      icone: Icons.checklist_outlined,
      child: Column(
        children: [
          _itemChecklist('Avaliação geral informada', _notaPreenchida),
          _itemChecklist(
            'Mudança de comportamento registrada',
            _mudancaPreenchida,
          ),
          _itemChecklist('Fatores de risco registrados', _riscosPreenchidos),
          _itemChecklist('Pontos positivos registrados', _positivosPreenchidos),
          _itemChecklist(
            'Dificuldades encontradas registradas',
            _dificuldadesPreenchidas,
          ),
          _itemChecklist(
            'Recomendações para ações futuras registradas',
            _recomendacoesPreenchidas,
          ),
        ],
      ),
    );
  }

  Widget _itemChecklist(String texto, bool concluido) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        concluido ? Icons.check_circle : Icons.radio_button_unchecked,
        color: concluido ? Colors.green : Colors.orange,
      ),
      title: Text(texto),
      trailing: Text(
        concluido ? 'Concluído' : 'Pendente',
        style: TextStyle(
          color: concluido ? Colors.green.shade700 : Colors.orange.shade800,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String titulo,
    required String subtitulo,
    required IconData icone,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(subtitulo),
            const Divider(height: 28),
            child,
          ],
        ),
      ),
    );
  }
}

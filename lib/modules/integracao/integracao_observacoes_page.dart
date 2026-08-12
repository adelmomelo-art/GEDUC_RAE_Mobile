import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../shared/widgets/journey/fenix_journey_header.dart';
import '../../shared/widgets/layout/fenix_app_bar.dart';
import '../acoes/controllers/acao_controller.dart';

class IntegracaoObservacoesPage extends StatefulWidget {
  const IntegracaoObservacoesPage({super.key});

  @override
  State<IntegracaoObservacoesPage> createState() =>
      _IntegracaoObservacoesPageState();
}

class _IntegracaoObservacoesPageState extends State<IntegracaoObservacoesPage> {
  bool houveParticipacaoOutroOrgao = false;
  final Set<String> orgaoParticipanteIds = <String>{};

  final pontosPositivosController = TextEditingController();
  final dificuldadesController = TextEditingController();
  final recomendacoesController = TextEditingController();

  final Map<String, String> orgaos = const {
    'orgao_amc': 'AMC',
    'orgao_detran': 'DETRAN',
    'orgao_sefin': 'SEFIN',
    'orgao_agefis': 'AGEFIS',
    'orgao_sesec': 'SESEC',
    'orgao_gmf': 'Guarda Municipal',
    'orgao_samu': 'SAMU',
    'orgao_prf': 'PRF',
    'orgao_pre': 'PRE',
    'orgao_outro': 'Outro órgão',
  };

  @override
  void initState() {
    super.initState();

    final acao = context.read<AcaoController>().acaoAtual;

    if (acao != null) {
      houveParticipacaoOutroOrgao = acao.houveParticipacaoOutroOrgao;
      orgaoParticipanteIds.addAll(acao.orgaosParticipantesEfetivos);
      pontosPositivosController.text = acao.pontosPositivos;
      dificuldadesController.text = acao.dificuldadesEncontradas;
      recomendacoesController.text = acao.recomendacoes;
    }

    pontosPositivosController.addListener(_atualizarInterface);
    dificuldadesController.addListener(_atualizarInterface);
    recomendacoesController.addListener(_atualizarInterface);
  }

  @override
  void dispose() {
    pontosPositivosController
      ..removeListener(_atualizarInterface)
      ..dispose();

    dificuldadesController
      ..removeListener(_atualizarInterface)
      ..dispose();

    recomendacoesController
      ..removeListener(_atualizarInterface)
      ..dispose();

    super.dispose();
  }

  void _atualizarInterface() {
    if (!mounted) return;
    setState(() {});
  }

  bool get _temPontosPositivos =>
      pontosPositivosController.text.trim().isNotEmpty;

  bool get _temDificuldades => dificuldadesController.text.trim().isNotEmpty;

  bool get _temRecomendacoes => recomendacoesController.text.trim().isNotEmpty;

  bool get _integracaoValida =>
      !houveParticipacaoOutroOrgao || orgaoParticipanteIds.isNotEmpty;

  _StatusPreenchimento get _statusPreenchimento {
    final semIntegracao = !houveParticipacaoOutroOrgao;
    final semObservacoes =
        !_temPontosPositivos && !_temDificuldades && !_temRecomendacoes;

    if (semIntegracao && semObservacoes) {
      return _StatusPreenchimento.naoIniciado;
    }

    if (!_integracaoValida) {
      return _StatusPreenchimento.emAndamento;
    }

    return _StatusPreenchimento.completo;
  }

  String get _mensagemFaxita {
    if (houveParticipacaoOutroOrgao && orgaoParticipanteIds.isEmpty) {
      return 'Selecione ao menos um órgão participante para concluir esta etapa.';
    }

    if (!houveParticipacaoOutroOrgao &&
        !_temPontosPositivos &&
        !_temDificuldades &&
        !_temRecomendacoes) {
      return 'Registre as informações de integração institucional e as observações operacionais da ação.';
    }

    if (houveParticipacaoOutroOrgao &&
        !_temPontosPositivos &&
        !_temDificuldades &&
        !_temRecomendacoes) {
      return 'A integração institucional foi registrada. Acrescente observações que possam apoiar ações futuras.';
    }

    if (_temRecomendacoes) {
      return 'Há recomendações registradas que poderão subsidiar o planejamento de próximas ações.';
    }

    if (!houveParticipacaoOutroOrgao) {
      return 'A ação foi registrada sem participação de outro órgão. Revise as observações antes de avançar.';
    }

    return 'As informações de integração e observações foram preenchidas. Revise o resumo antes de avançar.';
  }

  String get _nomesOrgaosSelecionados {
    if (!houveParticipacaoOutroOrgao) {
      return 'Não se aplica';
    }

    if (orgaoParticipanteIds.isEmpty) return 'Não informado';
    final nomes = orgaoParticipanteIds
        .map((id) => orgaos[id] ?? id)
        .toList(growable: false)
      ..sort();
    return nomes.join(', ');
  }

  void _persistirRascunho() {
    context.read<AcaoController>().preencherIntegracaoObservacoes(
          houveParticipacaoOutroOrgao: houveParticipacaoOutroOrgao,
          orgaoParticipanteIds: houveParticipacaoOutroOrgao
              ? orgaoParticipanteIds.toList(growable: false)
              : const <String>[],
          pontosPositivos: pontosPositivosController.text.trim(),
          dificuldadesEncontradas: dificuldadesController.text.trim(),
          recomendacoes: recomendacoesController.text.trim(),
        );
  }

  void _voltar() {
    FocusScope.of(context).unfocus();
    _persistirRascunho();
    context.go('/recursos-operacionais');
  }

  void _salvarEAvancar() {
    FocusScope.of(context).unfocus();

    if (!_integracaoValida) {
      _mostrarErro('Selecione ao menos um órgão participante.');
      return;
    }

    _persistirRascunho();
    context.go('/resultados');
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(mensagem)),
      );
  }

  Widget _cardSecao({
    required String titulo,
    required IconData icone,
    required List<Widget> children,
    String? subtitulo,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icone,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitulo != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitulo,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _painelFaxita() {
    final theme = Theme.of(context);
    final status = _statusPreenchimento;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            child: const Icon(Icons.auto_awesome),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Faixita',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _chipStatus(status),
                  ],
                ),
                const SizedBox(height: 6),
                Text(_mensagemFaxita),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipStatus(_StatusPreenchimento status) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Text(
        status.rotulo,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _campoTextoLongo({
    required String label,
    required TextEditingController controller,
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
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 72),
          child: Icon(icone),
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _linhaResumo({
    required String titulo,
    required String valor,
    IconData? icone,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icone != null) ...[
            Icon(
              icone,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(titulo),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumoExecutivo() {
    return _cardSecao(
      titulo: 'Resumo da Integração e Observações',
      icone: Icons.summarize_outlined,
      children: [
        _linhaResumo(
          titulo: 'Participação de outro órgão',
          valor: houveParticipacaoOutroOrgao ? 'Sim' : 'Não',
          icone: Icons.account_balance_outlined,
        ),
        _linhaResumo(
          titulo: 'Órgão participante',
          valor: _nomesOrgaosSelecionados,
          icone: Icons.apartment_outlined,
        ),
        _linhaResumo(
          titulo: 'Observações positivas',
          valor: _temPontosPositivos ? 'Registradas' : 'Não registradas',
          icone: Icons.thumb_up_alt_outlined,
        ),
        _linhaResumo(
          titulo: 'Dificuldades',
          valor: _temDificuldades ? 'Registradas' : 'Não registradas',
          icone: Icons.warning_amber_outlined,
        ),
        _linhaResumo(
          titulo: 'Recomendações',
          valor: _temRecomendacoes ? 'Registradas' : 'Não registradas',
          icone: Icons.lightbulb_outline,
        ),
      ],
    );
  }

  Widget _barraInferior() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _voltar,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Voltar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: _salvarEAvancar,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Confirmar e avançar'),
              ),
            ),
          ],
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
        appBar: FenixAppBar(
          title: 'Integração e Observações',
          onBack: _voltar,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            const FenixJourneyHeader(
              step: 5,
              totalSteps: 9,
              title: 'Integração e Observações',
              subtitle:
                  'Registre parcerias, aprendizados e recomendações da ação.',
              icon: Icons.hub_outlined,
            ),
            const SizedBox(height: 16),
            _painelFaxita(),
            const SizedBox(height: 16),
            _cardSecao(
              titulo: 'Integração institucional',
              icone: Icons.account_balance_outlined,
              subtitulo:
                  'Registre a participação de outros órgãos na realização da ação.',
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: houveParticipacaoOutroOrgao,
                  title: const Text(
                    'Houve participação de outro órgão?',
                  ),
                  subtitle: Text(
                    houveParticipacaoOutroOrgao
                        ? 'Participação institucional registrada.'
                        : 'Nenhuma participação institucional registrada.',
                  ),
                  onChanged: (value) {
                    setState(() {
                      houveParticipacaoOutroOrgao = value;

                      if (!value) {
                        orgaoParticipanteIds.clear();
                      }
                    });
                  },
                ),
                if (houveParticipacaoOutroOrgao) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Quais órgãos participaram? *',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: orgaos.entries.map((entry) {
                      final selecionado =
                          orgaoParticipanteIds.contains(entry.key);
                      return FilterChip(
                        selected: selecionado,
                        showCheckmark: true,
                        avatar: const Icon(
                          Icons.account_balance_outlined,
                          size: 18,
                        ),
                        label: Text(entry.value),
                        onSelected: (_) {
                          setState(() {
                            if (selecionado) {
                              orgaoParticipanteIds.remove(entry.key);
                            } else {
                              orgaoParticipanteIds.add(entry.key);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${orgaoParticipanteIds.length} '
                    '${orgaoParticipanteIds.length == 1 ? 'órgão selecionado' : 'órgãos selecionados'}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _cardSecao(
              titulo: 'Observações operacionais',
              icone: Icons.fact_check_outlined,
              subtitulo:
                  'Registre aprendizados, dificuldades e recomendações decorrentes da ação.',
              children: [
                _campoTextoLongo(
                  label: 'Observações positivas',
                  controller: pontosPositivosController,
                  hint: 'Registre aspectos positivos observados na ação.',
                  icone: Icons.thumb_up_alt_outlined,
                ),
                const SizedBox(height: 16),
                _campoTextoLongo(
                  label: 'Dificuldades encontradas',
                  controller: dificuldadesController,
                  hint: 'Registre dificuldades, limitações ou problemas.',
                  icone: Icons.warning_amber_outlined,
                ),
                const SizedBox(height: 16),
                _campoTextoLongo(
                  label: 'Recomendações para próximas ações',
                  controller: recomendacoesController,
                  hint: 'Sugira melhorias para futuras ações.',
                  icone: Icons.lightbulb_outline,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _resumoExecutivo(),
          ],
        ),
        bottomNavigationBar: _barraInferior(),
      ),
    );
  }
}

enum _StatusPreenchimento {
  naoIniciado('Não iniciado'),
  emAndamento('Em andamento'),
  completo('Completo');

  const _StatusPreenchimento(this.rotulo);

  final String rotulo;
}

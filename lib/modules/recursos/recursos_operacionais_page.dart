import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController agentesController =
      TextEditingController(text: '0');
  final TextEditingController terceirizadosController =
      TextEditingController(text: '0');

  bool coberturaMidia = false;
  bool _dadosCarregados = false;

  final Set<String> materialUtilizadoIds = <String>{};

  static const Map<String, String> materiais = <String, String>{
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

  static const Map<String, IconData> _iconesMateriais = <String, IconData>{
    'material_caixa_som': Icons.speaker_outlined,
    'material_tenda': Icons.holiday_village_outlined,
    'material_banner': Icons.view_carousel_outlined,
    'material_faixa': Icons.linear_scale,
    'material_cone': Icons.change_history_outlined,
    'material_cavalete': Icons.signpost_outlined,
    'material_minicircuito': Icons.route_outlined,
    'material_bicicletas': Icons.pedal_bike_outlined,
    'material_kit_educativo': Icons.school_outlined,
    'material_folders': Icons.description_outlined,
    'material_outros': Icons.more_horiz,
  };

  @override
  void initState() {
    super.initState();

    final acao = context.read<AcaoController>().acaoAtual;

    if (acao != null) {
      agentesController.text = acao.agentesTransito.toString();
      terceirizadosController.text = acao.equipeTerceirizada.toString();
      coberturaMidia = acao.coberturaMidia;
      materialUtilizadoIds.addAll(acao.materialUtilizadoIds);
    }

    agentesController.addListener(_atualizarInterface);
    terceirizadosController.addListener(_atualizarInterface);
    _dadosCarregados = true;
  }

  @override
  void dispose() {
    agentesController
      ..removeListener(_atualizarInterface)
      ..dispose();

    terceirizadosController
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

  int get _agentes => _valorInteiro(agentesController);

  int get _terceirizados => _valorInteiro(terceirizadosController);

  int get _efetivoTotal => _agentes + _terceirizados;

  bool get _quantidadesValidas => _agentes >= 0 && _terceirizados >= 0;

  bool get _recursosCompletos =>
      _quantidadesValidas && materialUtilizadoIds.isNotEmpty;

  _StatusPreenchimento get _statusPreenchimento {
    final semEquipe = _efetivoTotal == 0;
    final semMateriais = materialUtilizadoIds.isEmpty;

    if (semEquipe && semMateriais && !coberturaMidia) {
      return _StatusPreenchimento.naoIniciado;
    }

    if (!_recursosCompletos) {
      return _StatusPreenchimento.emAndamento;
    }

    return _StatusPreenchimento.completo;
  }

  String get _mensagemFaxita {
    if (!_quantidadesValidas) {
      return 'As quantidades informadas precisam ser iguais ou superiores a zero.';
    }

    if (_efetivoTotal == 0 && materialUtilizadoIds.isEmpty) {
      return 'Informe a equipe mobilizada e selecione os materiais efetivamente utilizados.';
    }

    if (_efetivoTotal == 0) {
      return 'Nenhum profissional foi informado para a realização da ação.';
    }

    if (materialUtilizadoIds.isEmpty) {
      return 'Selecione pelo menos um material utilizado na ação.';
    }

    return 'Os recursos operacionais foram preenchidos. Revise o resumo antes de avançar.';
  }

  void _persistirNoController() {
    context.read<AcaoController>().preencherRecursosOperacionais(
          agentesTransito: _agentes,
          equipeTerceirizada: _terceirizados,
          materialUtilizadoIds: materialUtilizadoIds.toList(),
          coberturaMidia: coberturaMidia,
        );
  }

  void _voltar() {
    FocusScope.of(context).unfocus();
    _persistirNoController();
    context.go('/caracterizacao-acao');
  }

  void _salvarEAvancar() {
    FocusScope.of(context).unfocus();

    if (!_quantidadesValidas) {
      _mostrarErro('As quantidades não podem ser negativas.');
      return;
    }

    if (materialUtilizadoIds.isEmpty) {
      _mostrarErro('Selecione ao menos um material utilizado.');
      return;
    }

    _persistirNoController();
    context.go('/integracao-observacoes');
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(mensagem)),
      );
  }

  void _alternarMaterial(String id) {
    setState(() {
      if (materialUtilizadoIds.contains(id)) {
        materialUtilizadoIds.remove(id);
      } else {
        materialUtilizadoIds.add(id);
      }
    });
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
                Icon(icone, color: theme.colorScheme.primary),
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

  Widget _campoNumero({
    required String label,
    required TextEditingController controller,
    required IconData icone,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      onTap: () {
        if (controller.text == '0') {
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        }
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icone),
        border: const OutlineInputBorder(),
        helperText: 'Informe um número inteiro igual ou superior a zero.',
      ),
    );
  }

  Widget _painelFaxita() {
    final theme = Theme.of(context);
    final status = _statusPreenchimento;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.28),
        ),
      ),
      padding: const EdgeInsets.all(16),
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
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(
        status.rotulo,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _seletorMateriais() {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: materiais.entries.map((entry) {
        final selecionado = materialUtilizadoIds.contains(entry.key);

        return FilterChip(
          selected: selecionado,
          showCheckmark: true,
          avatar: Icon(
            _iconesMateriais[entry.key] ?? Icons.inventory_2_outlined,
            size: 18,
            color: selecionado
                ? theme.colorScheme.onSecondaryContainer
                : theme.colorScheme.onSurfaceVariant,
          ),
          label: Text(entry.value),
          onSelected: (_) => _alternarMaterial(entry.key),
        );
      }).toList(),
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
        children: [
          if (icone != null) ...[
            Icon(
              icone,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
          ],
          Expanded(child: Text(titulo)),
          const SizedBox(width: 12),
          Text(
            valor,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _resumoExecutivo() {
    return _cardSecao(
      titulo: 'Resumo dos Recursos Operacionais',
      icone: Icons.summarize_outlined,
      children: [
        _linhaResumo(
          titulo: 'Agentes de trânsito',
          valor: '$_agentes',
          icone: Icons.badge_outlined,
        ),
        _linhaResumo(
          titulo: 'Equipe terceirizada',
          valor: '$_terceirizados',
          icone: Icons.groups_outlined,
        ),
        _linhaResumo(
          titulo: 'Efetivo total',
          valor: '$_efetivoTotal',
          icone: Icons.people_alt_outlined,
        ),
        _linhaResumo(
          titulo: 'Materiais selecionados',
          valor: '${materialUtilizadoIds.length}',
          icone: Icons.inventory_2_outlined,
        ),
        _linhaResumo(
          titulo: 'Cobertura de mídia',
          valor: coberturaMidia ? 'Sim' : 'Não',
          icone: Icons.campaign_outlined,
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
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _voltar();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recursos Operacionais'),
        ),
        bottomNavigationBar: _barraInferior(),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            Text(
              'Etapa 4 do preenchimento da ação',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const LinearProgressIndicator(value: 4 / 9),
            const SizedBox(height: 20),
            _painelFaxita(),
            const SizedBox(height: 16),
            _cardSecao(
              titulo: 'Equipe envolvida',
              icone: Icons.groups_2_outlined,
              subtitulo:
                  'Informe o efetivo diretamente mobilizado para a realização da ação.',
              children: [
                _campoNumero(
                  label: 'Quantidade de agentes de trânsito',
                  controller: agentesController,
                  icone: Icons.badge_outlined,
                ),
                const SizedBox(height: 16),
                _campoNumero(
                  label: 'Quantidade da equipe terceirizada',
                  controller: terceirizadosController,
                  icone: Icons.groups_outlined,
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer
                        .withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.people_alt_outlined),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text('Efetivo total mobilizado'),
                      ),
                      Text(
                        '$_efetivoTotal',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _cardSecao(
              titulo: 'Materiais utilizados',
              icone: Icons.inventory_2_outlined,
              subtitulo:
                  'Selecione somente os materiais efetivamente utilizados na ação.',
              children: [
                _seletorMateriais(),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${materialUtilizadoIds.length} '
                      '${materialUtilizadoIds.length == 1 ? 'material selecionado' : 'materiais selecionados'}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _cardSecao(
              titulo: 'Cobertura de mídia',
              icone: Icons.campaign_outlined,
              subtitulo:
                  'Considere imprensa, televisão, rádio, redes sociais ou cobertura institucional.',
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: coberturaMidia,
                  title: const Text('Houve cobertura de mídia?'),
                  subtitle: Text(
                    coberturaMidia
                        ? 'Cobertura registrada para esta ação.'
                        : 'Nenhuma cobertura registrada.',
                  ),
                  onChanged: (value) {
                    setState(() {
                      coberturaMidia = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _resumoExecutivo(),
          ],
        ),
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

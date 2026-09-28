import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/fenix_visual_tokens.dart';
import '../../data/models/tipo_acao_model.dart';
import '../../shared/widgets/layout/fenix_page_scaffold.dart';
import 'controllers/tipo_acao_controller.dart';
import 'tipo_acao_form_args.dart';

class TipoAcaoFormPage extends StatefulWidget {
  const TipoAcaoFormPage({super.key, required this.args});

  final TipoAcaoFormArgs args;

  @override
  State<TipoAcaoFormPage> createState() => _TipoAcaoFormPageState();
}

class _TipoAcaoFormPageState extends State<TipoAcaoFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _tipoController;
  late final TextEditingController _estimadoController;
  late final TextEditingController _minimoController;
  late final TextEditingController _materiaisController;
  late bool _ativo;

  TipoAcaoModel? get _origem => widget.args.tipoAcao;

  @override
  void initState() {
    super.initState();
    final origem = _origem;
    _nomeController = TextEditingController(text: origem?.nomeAcao ?? '');
    _tipoController = TextEditingController(text: origem?.tipoAcao ?? '');
    _estimadoController = TextEditingController(
      text: (origem?.publicoEstimadoPadrao ?? 0).toString(),
    );
    _minimoController = TextEditingController(
      text: (origem?.publicoMinimoPadrao ?? 0).toString(),
    );
    _materiaisController = TextEditingController(
      text: origem?.materiaisSugeridos.join(', ') ?? '',
    );
    _ativo = origem?.ativo ?? true;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _tipoController.dispose();
    _estimadoController.dispose();
    _minimoController.dispose();
    _materiaisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TipoAcaoController>();

    return PopScope(
      canPop: !controller.salvando,
      child: FenixPageScaffold(
        appBar: AppBar(
          title: Text(widget.args.editando
              ? 'Editar tipo de ação'
              : 'Novo tipo de ação'),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CabecalhoFormulario(editando: widget.args.editando),
                const SizedBox(height: FenixVisualTokens.space16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(FenixVisualTokens.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          key: const ValueKey('tipo-acao-nome'),
                          controller: _nomeController,
                          enabled: !controller.salvando,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Nome da ação',
                            prefixIcon: Icon(Icons.title_rounded),
                          ),
                          validator: (valor) =>
                              _obrigatorio(valor, 'o nome da ação'),
                        ),
                        const SizedBox(height: FenixVisualTokens.space16),
                        TextFormField(
                          key: const ValueKey('tipo-acao-classificacao'),
                          controller: _tipoController,
                          enabled: !controller.salvando,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Classificação',
                            hintText: 'Ex.: Escola, via pública, evento',
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          validator: (valor) =>
                              _obrigatorio(valor, 'a classificação'),
                        ),
                        const SizedBox(height: FenixVisualTokens.space16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final compacto = constraints.maxWidth < 620;
                            final estimado = _CampoNumero(
                              fieldKey: const ValueKey('tipo-acao-estimado'),
                              controller: _estimadoController,
                              label: 'Público estimado',
                              enabled: !controller.salvando,
                              validator: _validarNumero,
                            );
                            final minimo = _CampoNumero(
                              fieldKey: const ValueKey('tipo-acao-minimo'),
                              controller: _minimoController,
                              label: 'Público mínimo',
                              enabled: !controller.salvando,
                              validator: _validarMinimo,
                            );
                            if (compacto) {
                              return Column(
                                children: [
                                  estimado,
                                  const SizedBox(
                                      height: FenixVisualTokens.space16),
                                  minimo,
                                ],
                              );
                            }
                            return Row(
                              children: [
                                Expanded(child: estimado),
                                const SizedBox(
                                    width: FenixVisualTokens.space16),
                                Expanded(child: minimo),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: FenixVisualTokens.space16),
                        TextFormField(
                          key: const ValueKey('tipo-acao-materiais'),
                          controller: _materiaisController,
                          enabled: !controller.salvando,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Materiais sugeridos',
                            hintText:
                                'Separe por vírgula, ponto e vírgula ou nova linha',
                            alignLabelWithHint: true,
                            prefixIcon: Icon(Icons.inventory_2_outlined),
                          ),
                        ),
                        const SizedBox(height: FenixVisualTokens.space12),
                        SwitchListTile.adaptive(
                          key: const ValueKey('tipo-acao-ativo'),
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Disponível para novas ações'),
                          subtitle: const Text(
                            'Tipos inativos permanecem no histórico, mas não devem ser oferecidos em novos registros.',
                          ),
                          value: _ativo,
                          onChanged: controller.salvando
                              ? null
                              : (valor) => setState(() => _ativo = valor),
                        ),
                      ],
                    ),
                  ),
                ),
                if (controller.erro != null) ...[
                  const SizedBox(height: FenixVisualTokens.space12),
                  _ErroFormulario(mensagem: controller.erro!),
                ],
                const SizedBox(height: FenixVisualTokens.space20),
                FilledButton.icon(
                  key: const ValueKey('tipo-acao-salvar'),
                  onPressed: controller.salvando ? null : _salvar,
                  icon: controller.salvando
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(controller.salvando ? 'SALVANDO...' : 'SALVAR'),
                ),
                const SizedBox(height: FenixVisualTokens.space8),
                OutlinedButton(
                  onPressed:
                      controller.salvando ? null : () => Navigator.pop(context),
                  child: const Text('CANCELAR'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _obrigatorio(String? valor, String campo) {
    if (valor == null || valor.trim().isEmpty) return 'Informe $campo.';
    return null;
  }

  String? _validarNumero(String? valor) {
    final numero = int.tryParse(valor?.trim() ?? '');
    if (numero == null || numero < 0) {
      return 'Informe um inteiro igual ou maior que zero.';
    }
    return null;
  }

  String? _validarMinimo(String? valor) {
    final erro = _validarNumero(valor);
    if (erro != null) return erro;
    final minimo = int.parse(valor!.trim());
    final estimado = int.tryParse(_estimadoController.text.trim()) ?? 0;
    if (estimado > 0 && minimo > estimado) {
      return 'Não pode superar o público estimado.';
    }
    return null;
  }

  List<String> _materiais() {
    return _materiaisController.text
        .split(RegExp(r'[,;\n]+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final origem = _origem;
    final modelo = TipoAcaoModel(
      id: origem?.id ?? '',
      nomeAcao: _nomeController.text,
      tipoAcao: _tipoController.text,
      publicoEstimadoPadrao: int.parse(_estimadoController.text.trim()),
      publicoMinimoPadrao: int.parse(_minimoController.text.trim()),
      materiaisSugeridos: _materiais(),
      ativo: _ativo,
      criadoEm: origem?.criadoEm,
      atualizadoEm: origem?.atualizadoEm,
    );

    final controller = context.read<TipoAcaoController>();
    final sucesso = widget.args.editando
        ? await controller.atualizar(modelo)
        : await controller.criar(modelo) != null;

    if (!mounted || !sucesso) return;
    Navigator.of(context).pop(true);
  }
}

class _CabecalhoFormulario extends StatelessWidget {
  const _CabecalhoFormulario({required this.editando});
  final bool editando;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FenixVisualTokens.space16),
      decoration: BoxDecoration(
        color: FenixVisualTokens.tealLight,
        borderRadius: BorderRadius.circular(FenixVisualTokens.radiusMedium),
      ),
      child: Row(
        children: [
          const Icon(Icons.category_rounded, color: FenixVisualTokens.tealDark),
          const SizedBox(width: FenixVisualTokens.space12),
          Expanded(
            child: Text(
              editando
                  ? 'Atualize o catálogo administrativo sem alterar registros históricos.'
                  : 'Cadastre uma opção padronizada para o fluxo de ações educativas.',
            ),
          ),
        ],
      ),
    );
  }
}

class _CampoNumero extends StatelessWidget {
  const _CampoNumero({
    required this.fieldKey,
    required this.controller,
    required this.label,
    required this.enabled,
    required this.validator,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final String label;
  final bool enabled;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.groups_2_outlined),
      ),
      validator: validator,
    );
  }
}

class _ErroFormulario extends StatelessWidget {
  const _ErroFormulario({required this.mensagem});
  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FenixVisualTokens.danger.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(FenixVisualTokens.radiusSmall),
      child: Padding(
        padding: const EdgeInsets.all(FenixVisualTokens.space12),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: FenixVisualTokens.danger),
            const SizedBox(width: FenixVisualTokens.space8),
            Expanded(child: Text(mensagem)),
          ],
        ),
      ),
    );
  }
}

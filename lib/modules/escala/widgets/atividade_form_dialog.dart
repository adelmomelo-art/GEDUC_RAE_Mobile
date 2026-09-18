import 'package:flutter/material.dart';

import '../controllers/escala_gestao_controller.dart';
import '../models/escala_models.dart';

Future<EscalaAtividadeEntrada?> showEscalaAtividadeFormDialog({
  required BuildContext context,
  required EscalaGestaoController controller,
  EscalaAtividadeModel? atividade,
}) {
  return showDialog<EscalaAtividadeEntrada>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _EscalaAtividadeFormDialog(
      controller: controller,
      atividade: atividade,
    ),
  );
}

class _EscalaAtividadeFormDialog extends StatefulWidget {
  const _EscalaAtividadeFormDialog({
    required this.controller,
    required this.atividade,
  });

  final EscalaGestaoController controller;
  final EscalaAtividadeModel? atividade;

  @override
  State<_EscalaAtividadeFormDialog> createState() =>
      _EscalaAtividadeFormDialogState();
}

class _EscalaAtividadeFormDialogState
    extends State<_EscalaAtividadeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _natureza;
  late String _secao;
  late String _turno;
  String _coordenadorMembroEquipeId = '';
  late final TextEditingController _tipoController;
  late final TextEditingController _tituloController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _qtrController;
  late final TextEditingController _inicioController;
  late final TextEditingController _fimController;
  late final TextEditingController _qthController;
  late final TextEditingController _regionalController;
  late final TextEditingController _orientacaoController;
  List<EscalaEquipeSelecao> _equipe = <EscalaEquipeSelecao>[];
  List<String> _bloqueios = <String>[];

  @override
  void initState() {
    super.initState();
    final atividade = widget.atividade;
    _natureza = atividade?.naturezaAtividade ?? EscalaCodigos.naturezaEducativa;
    _secao = atividade?.secaoId.trim().isNotEmpty == true
        ? atividade!.secaoId
        : 'comandos_tematicos';
    _turno = atividade?.turnoId.trim().isNotEmpty == true
        ? atividade!.turnoId
        : 'manha';
    _coordenadorMembroEquipeId = atividade?.coordenadorMembroEquipeId ?? '';
    _tipoController = TextEditingController(
      text: atividade?.tipoAtividadeId ?? '',
    );
    _tituloController = TextEditingController(text: atividade?.titulo ?? '');
    _descricaoController = TextEditingController(
      text: atividade?.descricao ?? '',
    );
    _qtrController = TextEditingController(text: atividade?.qtrHorario ?? '');
    _inicioController = TextEditingController(
      text: atividade?.horaInicio ?? '',
    );
    _fimController = TextEditingController(text: atividade?.horaFim ?? '');
    _qthController = TextEditingController(text: atividade?.qthLocal ?? '');
    _regionalController = TextEditingController(
      text: atividade?.qthRegionalId ?? '',
    );
    _orientacaoController = TextEditingController(
      text: atividade?.orientacaoOperacional ?? '',
    );
    if (atividade != null) {
      _equipe =
          widget.controller.alocacoesDaAtividade(atividade.id).map((item) {
        return EscalaEquipeSelecao(
          membroEquipeId: item.membroEquipeId,
          tipoJornada: item.tipoJornada,
          motivoJornadaComplementar: item.motivoJornadaComplementar,
        );
      }).toList(growable: false);
    }
  }

  @override
  void dispose() {
    for (final controller in <TextEditingController>[
      _tipoController,
      _tituloController,
      _descricaoController,
      _qtrController,
      _inicioController,
      _fimController,
      _qthController,
      _regionalController,
      _orientacaoController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compacto = MediaQuery.sizeOf(context).width < 720;
    return Dialog(
      insetPadding: EdgeInsets.all(compacto ? 8 : 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 760),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.atividade == null
                          ? 'Nova atividade'
                          : 'Editar atividade',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fechar',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _titulo(context, 'O que será feito?'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _campoLargura(
                          compacto,
                          260,
                          DropdownButtonFormField<String>(
                            initialValue: _natureza,
                            decoration: const InputDecoration(
                              labelText: 'Natureza',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: EscalaCodigos.naturezaEducativa,
                                child: Text('Ação educativa'),
                              ),
                              DropdownMenuItem(
                                value: EscalaCodigos.naturezaAdministrativa,
                                child: Text('Missão administrativa'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _natureza = value);
                              }
                            },
                          ),
                        ),
                        _campoLargura(
                          compacto,
                          280,
                          DropdownButtonFormField<String>(
                            initialValue: _secao,
                            decoration: const InputDecoration(
                              labelText: 'Seção',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'administrativo',
                                child: Text('Administrativo'),
                              ),
                              DropdownMenuItem(
                                value: 'comandos_tematicos',
                                child: Text('Comandos e ações temáticas'),
                              ),
                              DropdownMenuItem(
                                value: 'programas_formacao',
                                child: Text('Programas de formação'),
                              ),
                              DropdownMenuItem(
                                value: 'apoio_geduc',
                                child: Text('Apoio GEDUC'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) setState(() => _secao = value);
                            },
                          ),
                        ),
                        _campoLargura(
                          compacto,
                          280,
                          TextFormField(
                            controller: _tipoController,
                            decoration: const InputDecoration(
                              labelText: 'Tipo da atividade',
                              border: OutlineInputBorder(),
                            ),
                            validator: _obrigatorio,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _tituloController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        border: OutlineInputBorder(),
                      ),
                      validator: _obrigatorio,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descricaoController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição complementar',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _titulo(context, 'Quando?'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _campoLargura(
                          compacto,
                          210,
                          DropdownButtonFormField<String>(
                            initialValue: _turno,
                            decoration: const InputDecoration(
                              labelText: 'Turno',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'manha',
                                child: Text('Manhã'),
                              ),
                              DropdownMenuItem(
                                value: 'tarde',
                                child: Text('Tarde'),
                              ),
                              DropdownMenuItem(
                                value: 'noite',
                                child: Text('Noite'),
                              ),
                              DropdownMenuItem(
                                value: 'administrativo',
                                child: Text('Administrativo'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) setState(() => _turno = value);
                            },
                          ),
                        ),
                        _campoLargura(
                          compacto,
                          180,
                          TextFormField(
                            controller: _qtrController,
                            decoration: const InputDecoration(
                              labelText: 'QTR',
                              hintText: '06:00',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        _campoLargura(
                          compacto,
                          180,
                          TextFormField(
                            controller: _inicioController,
                            decoration: const InputDecoration(
                              labelText: 'Início',
                              hintText: '07:00',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        _campoLargura(
                          compacto,
                          180,
                          TextFormField(
                            controller: _fimController,
                            decoration: const InputDecoration(
                              labelText: 'Fim',
                              hintText: '11:00',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _titulo(context, 'Onde?'),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _qthController,
                      decoration: const InputDecoration(
                        labelText: 'QTH / local',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _regionalController,
                      decoration: const InputDecoration(
                        labelText: 'Regional',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _titulo(context, 'Orientação operacional'),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _orientacaoController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Orientação / missão',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _titulo(context, 'Coordenação e equipe'),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _coordenadorMembroEquipeId.isEmpty
                          ? null
                          : _coordenadorMembroEquipeId,
                      decoration: const InputDecoration(
                        labelText: 'Coordenador',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('Sem coordenador'),
                        ),
                        for (final item
                            in widget.controller.coordenadoresDisponiveis)
                          DropdownMenuItem<String>(
                            value: item.membro.id,
                            child: Text('${item.nome} • ${item.cargaHoraria}'),
                          ),
                      ],
                      onChanged: (value) => setState(
                        () => _coordenadorMembroEquipeId = value ?? '',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      margin: EdgeInsets.zero,
                      elevation: 0,
                      child: ListTile(
                        leading: const Icon(Icons.groups_rounded),
                        title: Text(
                          _equipe.isEmpty
                              ? 'Nenhum agente selecionado'
                              : '${_equipe.length} agente(s) na equipe',
                        ),
                        trailing: OutlinedButton.icon(
                          onPressed: _abrirEquipe,
                          icon: const Icon(Icons.edit_rounded),
                          label: const Text('Gerenciar equipe'),
                        ),
                      ),
                    ),
                    if (_bloqueios.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _MensagemLista(
                        titulo: 'Corrija antes de salvar',
                        itens: _bloqueios,
                        erro: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _confirmar,
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Salvar atividade'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoLargura(bool compacto, double largura, Widget child) =>
      SizedBox(width: compacto ? double.infinity : largura, child: child);

  Widget _titulo(BuildContext context, String texto) => Text(
        texto,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
      );

  String? _obrigatorio(String? valor) =>
      valor == null || valor.trim().isEmpty ? 'Campo obrigatório' : null;

  Future<void> _abrirEquipe() async {
    final resultado = await showDialog<List<EscalaEquipeSelecao>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _EquipeSelectorDialog(
        controller: widget.controller,
        atividadeId: widget.atividade?.id,
        selecionados: _equipe,
      ),
    );
    if (resultado == null || !mounted) return;
    setState(() => _equipe = resultado);
  }

  EscalaAtividadeEntrada _entrada() => EscalaAtividadeEntrada(
        atividadeId: widget.atividade?.id,
        naturezaAtividade: _natureza,
        secaoId: _secao,
        tipoAtividadeId: _tipoController.text,
        titulo: _tituloController.text,
        descricao: _descricaoController.text,
        turnoId: _turno,
        qtrHorario: _qtrController.text,
        horaInicio: _inicioController.text,
        horaFim: _fimController.text,
        qthLocal: _qthController.text,
        qthEndereco: '',
        qthRegionalId: _regionalController.text,
        qthPontoReferencia: '',
        orientacaoOperacional: _orientacaoController.text,
        coordenadorMembroEquipeId: _coordenadorMembroEquipeId,
        equipe: List<EscalaEquipeSelecao>.unmodifiable(_equipe),
      );

  Future<void> _confirmar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final entrada = _entrada();
    final preparacao = widget.controller.prepararAtividade(entrada);
    if (!preparacao.valida) {
      setState(() => _bloqueios = preparacao.bloqueios);
      return;
    }
    if (preparacao.alertas.isNotEmpty) {
      final manter = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Alertas operacionais'),
          content: _MensagemLista(
            titulo:
                'Os alertas não bloqueiam o planejamento. Manter mesmo assim?',
            itens: preparacao.alertas,
            erro: false,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Voltar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Manter mesmo assim'),
            ),
          ],
        ),
      );
      if (manter != true || !mounted) return;
    }
    Navigator.pop(context, entrada);
  }
}

class _EquipeSelectorDialog extends StatefulWidget {
  const _EquipeSelectorDialog({
    required this.controller,
    required this.atividadeId,
    required this.selecionados,
  });

  final EscalaGestaoController controller;
  final String? atividadeId;
  final List<EscalaEquipeSelecao> selecionados;

  @override
  State<_EquipeSelectorDialog> createState() => _EquipeSelectorDialogState();
}

class _EquipeSelectorDialogState extends State<_EquipeSelectorDialog> {
  final _buscaController = TextEditingController();
  late final Map<String, EscalaEquipeSelecao> _selecionados;

  @override
  void initState() {
    super.initState();
    _selecionados = {
      for (final item in widget.selecionados) item.membroEquipeId: item,
    };
    _buscaController.addListener(_atualizar);
  }

  @override
  void dispose() {
    _buscaController
      ..removeListener(_atualizar)
      ..dispose();
    super.dispose();
  }

  void _atualizar() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final busca = _buscaController.text.trim().toLowerCase();
    final agentes = widget.controller.agentesDisponiveis.where((item) {
      return busca.isEmpty ||
          item.nome.toLowerCase().contains(busca) ||
          item.cargaHoraria.toLowerCase().contains(busca);
    }).toList(growable: false);

    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 760),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 10, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Equipe da atividade',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: TextField(
                controller: _buscaController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  labelText: 'Buscar agente',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: agentes.length,
                itemBuilder: (context, index) {
                  final agente = agentes[index];
                  final membroId = agente.membro.id;
                  final selecionado = _selecionados[membroId];
                  final marcado = selecionado != null;
                  final possuiOutra =
                      widget.controller.possuiOutraAlocacaoNoDia(
                    membroEquipeId: membroId,
                    ignorarAtividadeId: widget.atividadeId,
                  );
                  final situacoes = widget.controller.situacoesDoAgente(
                    membroId,
                  );

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Column(
                      children: [
                        CheckboxListTile(
                          value: marcado,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(
                            agente.nome,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(
                            [
                              agente.cargaHoraria,
                              'GEDUC',
                              if (!agente.identidadeCanonica)
                                'sem UID canônico',
                              if (possuiOutra) 'já alocado no dia',
                              ...situacoes.map(
                                (item) => item.replaceAll('_', ' '),
                              ),
                            ].join(' • '),
                          ),
                          onChanged: (valor) {
                            setState(() {
                              if (valor == true) {
                                _selecionados[membroId] = EscalaEquipeSelecao(
                                  membroEquipeId: membroId,
                                  tipoJornada: possuiOutra
                                      ? null
                                      : EscalaCodigos.jornadaNormal,
                                );
                              } else {
                                _selecionados.remove(membroId);
                              }
                            });
                          },
                        ),
                        if (marcado)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(48, 0, 12, 12),
                            child: Column(
                              children: [
                                DropdownButtonFormField<String>(
                                  key: ValueKey(
                                    '$membroId-${selecionado.tipoJornada}',
                                  ),
                                  initialValue: selecionado.tipoJornada,
                                  decoration: InputDecoration(
                                    labelText: possuiOutra
                                        ? 'Classificação da nova jornada *'
                                        : 'Tipo de jornada',
                                    helperText: possuiOutra &&
                                            !widget.controller
                                                .podeClassificarJornada
                                        ? 'Somente o agente responsável pode classificar.'
                                        : null,
                                    border: const OutlineInputBorder(),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: EscalaCodigos.jornadaNormal,
                                      child: Text('Jornada normal'),
                                    ),
                                    DropdownMenuItem(
                                      value: EscalaCodigos.jornadaHoraExtra,
                                      child: Text('Hora extra'),
                                    ),
                                    DropdownMenuItem(
                                      value: EscalaCodigos.jornadaBancoHoras,
                                      child: Text('Banco de horas'),
                                    ),
                                  ],
                                  onChanged: possuiOutra &&
                                          !widget
                                              .controller.podeClassificarJornada
                                      ? null
                                      : (valor) {
                                          setState(() {
                                            _selecionados[membroId] =
                                                selecionado.copyWith(
                                              tipoJornada: valor,
                                            );
                                          });
                                        },
                                ),
                                if (selecionado.tipoJornada ==
                                        EscalaCodigos.jornadaHoraExtra ||
                                    selecionado.tipoJornada ==
                                        EscalaCodigos.jornadaBancoHoras) ...[
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    initialValue:
                                        selecionado.motivoJornadaComplementar,
                                    decoration: const InputDecoration(
                                      labelText:
                                          'Motivo da jornada complementar',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (valor) {
                                      _selecionados[membroId] =
                                          selecionado.copyWith(
                                        motivoJornadaComplementar: valor,
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Text(
                    '${_selecionados.length} selecionado(s)',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      final resultado =
                          _selecionados.values.toList(growable: false)
                            ..sort(
                              (a, b) =>
                                  a.membroEquipeId.compareTo(b.membroEquipeId),
                            );
                      Navigator.pop(context, resultado);
                    },
                    child: const Text('Aplicar equipe'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MensagemLista extends StatelessWidget {
  const _MensagemLista({
    required this.titulo,
    required this.itens,
    required this.erro,
  });
  final String titulo;
  final List<String> itens;
  final bool erro;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final fundo = erro ? cores.errorContainer : cores.tertiaryContainer;
    final frente = erro ? cores.onErrorContainer : cores.onTertiaryContainer;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: DefaultTextStyle(
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: frente),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              for (final item in itens) Text('• $item'),
            ],
          ),
        ),
      ),
    );
  }
}

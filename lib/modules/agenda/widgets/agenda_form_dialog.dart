import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../controllers/agenda_controller.dart';
import '../models/agenda_compromisso.dart';
import '../services/agenda_service.dart';

Future<AgendaCompromisso?> showAgendaForm({
  required BuildContext context,
  required AgendaController controller,
  AgendaCompromisso? item,
}) =>
    showDialog<AgendaCompromisso>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AgendaForm(controller: controller, item: item),
    );

class _AgendaForm extends StatefulWidget {
  const _AgendaForm({required this.controller, this.item});
  final AgendaController controller;
  final AgendaCompromisso? item;
  @override
  State<_AgendaForm> createState() => _AgendaFormState();
}

class _AgendaFormState extends State<_AgendaForm> {
  final _form = GlobalKey<FormState>();
  final Map<String, TextEditingController> _campos = {};
  late DateTime _data;
  late String _turno, _natureza, _projeto, _regional, _origem, _secao;
  static const _textos = [
    'titulo',
    'instituicao',
    'horaInicio',
    'horaFim',
    'local',
    'endereco',
    'bairro',
    'referencia',
    'contatoNome',
    'contatoTelefone',
    'descricao',
    'publico',
    'quantidadePublico',
    'integrantesNecessarios',
    'materiais',
    'observacoesInternas',
    'orientacaoEquipe',
    'processo',
    'motivo',
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    final m = item?.toMap() ?? <String, dynamic>{};
    for (final key in _textos) {
      _campos[key] = TextEditingController(text: m[key]?.toString() ?? '');
    }
    // O motivo descreve a operação atual, não reutiliza uma justificativa anterior.
    _campos['motivo']!.clear();
    _data = item?.data ?? widget.controller.diaSelecionado;
    _turno = item?.turno ?? 'manha';
    _natureza = item?.natureza ?? 'educativa';
    _projeto = item?.projetoId ?? '';
    _regional = item?.regionalId ?? '';
    _origem = item?.origem ?? 'contato_direto';
    _secao = item?.secaoId ?? 'comandos_tematicos';
  }

  @override
  void dispose() {
    for (final c in _campos.values) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _campo(
    String key,
    String label, {
    bool obrigatorio = false,
    bool numero = false,
    int linhas = 1,
    String? ajuda,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextFormField(
          key: ValueKey('agenda-$key'),
          controller: _campos[key],
          maxLines: linhas,
          maxLength: 4000,
          keyboardType: numero
              ? TextInputType.number
              : linhas > 1
                  ? TextInputType.multiline
                  : TextInputType.text,
          decoration: InputDecoration(
            labelText: label,
            helperText: ajuda,
            counterText: '',
            border: const OutlineInputBorder(),
          ),
          validator: (v) {
            if (obrigatorio && (v ?? '').trim().isEmpty) {
              return 'Campo obrigatório';
            }
            if (numero &&
                (v ?? '').trim().isNotEmpty &&
                (int.tryParse(v!.trim()) == null || int.parse(v.trim()) < 0)) {
              return 'Informe um número inteiro maior ou igual a zero';
            }
            return null;
          },
        ),
      );

  Widget _opcoes(
    String label,
    String valor,
    Map<String, String> opcoes,
    ValueChanged<String> onChange,
  ) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: DropdownButtonFormField<String>(
          initialValue: valor,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          items: opcoes.entries
              .map(
                (e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => onChange(v));
          },
        ),
      );

  Widget _grupo(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 14),
        child: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final projetos = {
      '': 'Definir durante o planejamento',
      for (final p in widget.controller.projetos) p.id: p.nome,
    };
    if (!projetos.containsKey(_projeto)) {
      projetos[_projeto] = 'Projeto anterior (selecione um ativo)';
    }
    final regionais = {
      '': 'Ainda não definida',
      for (final r in widget.controller.regionais) r.id: r.nome,
    };
    if (!regionais.containsKey(_regional)) {
      regionais[_regional] = 'Regional anterior';
    }
    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780, maxHeight: 800),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.item == null
                          ? 'Agendar ação'
                          : 'Editar planejamento',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    tooltip: 'Fechar',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Form(
                key: _form,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _grupo('Compromisso'),
                    _campo('titulo', 'Título da ação *', obrigatorio: true),
                    _campo('instituicao', 'Instituição solicitante'),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final nova = await showDatePicker(
                          context: context,
                          initialDate: _data,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (nova != null && mounted) {
                          setState(() => _data = nova);
                        }
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: Text(
                        'Data: ${DateFormat('dd/MM/yyyy').format(_data)}',
                      ),
                    ),
                    const SizedBox(height: 14),
                    _opcoes(
                        'Turno *',
                        _turno,
                        {
                          'manha': 'Manhã',
                          'tarde': 'Tarde',
                          'noite': 'Noite',
                        },
                        (v) => _turno = v),
                    _opcoes(
                        'Natureza',
                        _natureza,
                        {
                          'educativa': 'Ação educativa (RAE)',
                          'administrativa': 'Missão administrativa',
                        },
                        (v) => _natureza = v),
                    _opcoes(
                      'Projeto do Catálogo Institucional',
                      _projeto,
                      projetos,
                      (v) => _projeto = v,
                    ),
                    _opcoes(
                        'Seção da escala',
                        _secao,
                        {
                          'administrativo': 'Administrativo',
                          'comandos_tematicos': 'Comandos temáticos',
                          'apoio_geduc': 'Apoio GEDUC',
                          if (![
                            'administrativo',
                            'comandos_tematicos',
                            'apoio_geduc',
                          ].contains(_secao))
                            _secao: _secao,
                        },
                        (v) => _secao = v),
                    _campo(
                      'horaInicio',
                      'Horário inicial',
                      ajuda:
                          'HH:mm. Deixe ambos os horários vazios se estiverem a combinar.',
                    ),
                    _campo('horaFim', 'Horário final'),
                    _grupo('Local'),
                    _campo('local', 'Nome do local'),
                    _campo('endereco', 'Endereço'),
                    _campo('bairro', 'Bairro'),
                    _opcoes(
                      'Regional administrativa',
                      _regional,
                      regionais,
                      (v) => _regional = v,
                    ),
                    _campo('referencia', 'Ponto de referência'),
                    _grupo('Contato externo · acesso restrito'),
                    _campo('contatoNome', 'Responsável externo'),
                    _campo('contatoTelefone', 'Telefone do contato'),
                    _grupo('Preparação'),
                    _campo(
                      'descricao',
                      'Descrição da atividade',
                      linhas: 3,
                      ajuda: 'Este texto será aproveitado na escala da equipe.',
                    ),
                    _campo('publico', 'Público previsto'),
                    _campo(
                      'quantidadePublico',
                      'Quantidade estimada de público',
                      numero: true,
                      ajuda: 'Deixe vazio quando ainda não souber.',
                    ),
                    _campo(
                      'integrantesNecessarios',
                      'Quantidade necessária de integrantes',
                      numero: true,
                    ),
                    _campo(
                      'materiais',
                      'Materiais e recursos necessários',
                      linhas: 3,
                    ),
                    _campo(
                      'observacoesInternas',
                      'Observações internas · acesso restrito',
                      linhas: 3,
                    ),
                    _campo(
                      'orientacaoEquipe',
                      'Orientações destinadas à equipe',
                      linhas: 3,
                      ajuda:
                          'Somente este campo de orientações será copiado para a escala.',
                    ),
                    _opcoes(
                        'Origem da demanda',
                        _origem,
                        {
                          'contato_direto': 'Contato direto',
                          'processo': 'Processo',
                          'chefia': 'Demanda da chefia',
                        },
                        (v) => _origem = v),
                    _campo('processo', 'Número do processo'),
                    if (widget.item != null)
                      _campo(
                        'motivo',
                        'Motivo da alteração / remarcação',
                        linhas: 2,
                        ajuda: 'Obrigatório quando mudar a data.',
                      ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Voltar'),
                  ),
                  FilledButton.icon(
                    key: const ValueKey('agenda-salvar'),
                    onPressed: _salvar,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Salvar planejamento'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _salvar() {
    if (!_form.currentState!.validate()) return;
    final base = widget.item ??
        AgendaCompromisso(
          id: widget.controller.repository.novoId(),
          data: _data,
          titulo: '',
          turno: _turno,
        );
    final map = <String, dynamic>{
      for (final e in _campos.entries) e.key: e.value.text.trim(),
      'data': _data,
      'turno': _turno,
      'natureza': _natureza,
      'projetoId': _projeto,
      'regionalId': _regional,
      'origem': _origem,
      'secaoId': _secao,
      'situacao': 'planejamento',
    };
    for (final key in ['quantidadePublico', 'integrantesNecessarios']) {
      map[key] = int.tryParse(_campos[key]!.text.trim());
    }
    final item = base.alterar(map);
    final erros = AgendaService.validar(item);
    if (widget.item != null &&
        AgendaService.dataId(widget.item!.data) !=
            AgendaService.dataId(item.data) &&
        item.motivo.isEmpty) {
      erros.add('Informe o motivo da remarcação.');
    }
    if (erros.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(erros.join('\n'))));
      return;
    }
    Navigator.pop(context, item);
  }
}

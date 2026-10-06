import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../controllers/agenda_controller.dart';
import '../data/agenda_repository.dart';
import '../data/firestore_agenda_repository.dart';
import '../models/agenda_compromisso.dart';
import '../services/agenda_service.dart';
import '../services/agenda_calendario_service.dart';
import '../widgets/agenda_form_dialog.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({
    super.key,
    required this.usuarioId,
    required this.perfilAcesso,
    this.repository,
    this.dataInicial,
    this.agora,
  });
  final String usuarioId, perfilAcesso;
  final AgendaRepository? repository;
  final DateTime? dataInicial;
  final DateTime Function()? agora;
  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  late final AgendaController _c;
  final _cartoes = <String, GlobalKey>{};
  String? _acaoDestacada;
  @override
  void initState() {
    super.initState();
    _c = AgendaController(
      repository: widget.repository ?? FirestoreAgendaRepository(),
      usuarioId: widget.usuarioId,
      perfilAcesso: widget.perfilAcesso,
      dataInicial: widget.dataInicial,
    );
    _c.addListener(_atualizar);
    _c.carregar();
  }

  void _atualizar() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _c.removeListener(_atualizar);
    _c.dispose();
    super.dispose();
  }

  bool get _ocupado => _c.carregando || _c.salvando;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Agenda Operacional'),
          actions: [
            IconButton(
              onPressed: _ocupado ? null : _c.carregar,
              tooltip: 'Atualizar agenda',
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _c.carregar,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Plano Operacional',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const Text(
                          'Planeje as ações do mês e prepare a escala. Acesso restrito ao responsável pela escala.',
                        ),
                        const SizedBox(height: 16),
                        if (_ocupado) const LinearProgressIndicator(),
                        if (_c.erro != null)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(_c.erro!),
                            ),
                          ),
                        if (_c.autorizado && _c.dados != null) ...[
                          _calendario(),
                          const SizedBox(height: 16),
                          _filtros(),
                          const SizedBox(height: 16),
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              Text(
                                DateFormat('dd/MM/yyyy')
                                    .format(_c.diaSelecionado),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              FilledButton.icon(
                                key: const ValueKey('agenda-nova'),
                                onPressed: _ocupado ? null : () => _editar(),
                                icon: const Icon(Icons.add),
                                label: const Text('Agendar ação'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_c.doDia.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'Nenhum compromisso para este dia com os filtros selecionados.',
                              ),
                            ),
                          for (final turno in ['manha', 'tarde', 'noite'])
                            if (_c.doDia.any((i) => i.turno == turno)) ...[
                              Text(
                                _rotuloTurno(turno),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              for (final item in _c.doDia.where(
                                (i) => i.turno == turno,
                              ))
                                _card(item),
                              const SizedBox(height: 12),
                            ],
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _calendario() {
    final mes = _c.mes;
    final hoje = widget.agora?.call() ?? DateTime.now();
    final primeiro = mes.weekday - 1;
    final total = DateTime(mes.year, mes.month + 1, 0).day;
    final celulas = ((primeiro + total + 6) ~/ 7) * 7;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: _ocupado ? null : () => _c.outroMes(-1),
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Mês anterior',
                ),
                Expanded(
                  child: Text(
                    DateFormat('MMMM yyyy', 'pt_BR').format(mes),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: _ocupado ? null : () => _c.outroMes(1),
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Próximo mês',
                ),
              ],
            ),
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                _legenda(const Color(0xFF1B5E20), 'Agendada'),
                _legenda(const Color(0xFFB8860B), 'Hoje / próximos 3 dias'),
                _legenda(const Color(0xFFB71C1C), 'Cancelada'),
              ],
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final compacto = constraints.maxWidth < 650;
                return Column(
                  key: const ValueKey('agenda-calendario-mes'),
                  children: [
                    Row(
                      children:
                          ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom']
                              .map((dia) => Expanded(
                                      child: Center(
                                          child: Text(
                                    dia,
                                    maxLines: 1,
                                    overflow: TextOverflow.clip,
                                    style: compacto
                                        ? const TextStyle(fontSize: 11)
                                        : null,
                                  ))))
                              .toList(),
                    ),
                    const SizedBox(height: 8),
                    for (var semana = 0; semana < celulas ~/ 7; semana++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var coluna = 0; coluna < 7; coluna++)
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: compacto ? 1 : 2),
                                    child: _celulaCalendario(
                                      semana * 7 + coluna,
                                      primeiro,
                                      total,
                                      mes,
                                      hoje,
                                      compacto: compacto,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _celulaCalendario(
      int index, int primeiro, int total, DateTime mes, DateTime hoje,
      {required bool compacto}) {
    final escalaTexto = MediaQuery.textScalerOf(context).scale(1);
    final dia = index - primeiro + 1;
    if (dia < 1 || dia > total) {
      return const SizedBox.shrink();
    }
    final data = DateTime(mes.year, mes.month, dia);
    final selecionado =
        AgendaService.dataId(data) == AgendaService.dataId(_c.diaSelecionado);
    final itens = _c.filtrados
        .where(
          (i) => AgendaService.dataId(i.data) == AgendaService.dataId(data),
        )
        .toList();
    return Material(
      color: selecionado
          ? Theme.of(
              context,
            ).colorScheme.primaryContainer
          : Theme.of(
              context,
            ).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            selected: selecionado,
            label: DateFormat(
              'dd/MM/yyyy',
            ).format(data),
            child: InkWell(
              key: ValueKey('agenda-dia-$dia'),
              onTap: _ocupado ? null : () => _c.selecionarDia(data),
              child: SizedBox(
                width: double.infinity,
                height: 48 * escalaTexto,
                child: Center(child: Text('$dia')),
              ),
            ),
          ),
          for (final item in itens.take(2))
            _nomeNoCalendario(item, hoje, compacto: compacto),
          if (itens.length > 2)
            TextButton(
              key: ValueKey('agenda-mais-$dia'),
              onPressed: _ocupado ? null : () => _abrirDetalhes(itens[2]),
              style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 2)),
              child: Tooltip(
                message: 'Ver mais ${itens.length - 2} ações deste dia',
                child: Text(
                  compacto
                      ? '+${itens.length - 2}'
                      : '+${itens.length - 2} ações',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _legenda(Color cor, String texto) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: cor, size: 12),
          const SizedBox(width: 4),
          Flexible(child: Text(texto)),
        ],
      );

  Widget _nomeNoCalendario(AgendaCompromisso item, DateTime hoje,
      {required bool compacto}) {
    final sinal = AgendaCalendarioService.sinal(
      item,
      hoje: hoje,
    );
    final cor = switch (sinal) {
      AgendaSinal.cancelada => const Color(0xFFB71C1C),
      AgendaSinal.proxima => const Color(0xFF795400),
      AgendaSinal.agendada => const Color(0xFF1B5E20),
    };
    final fundo = switch (sinal) {
      AgendaSinal.cancelada => const Color(0xFFFFEBEE),
      AgendaSinal.proxima => const Color(0xFFFFF8E1),
      AgendaSinal.agendada => const Color(0xFFE8F5E9),
    };
    final rotulo = AgendaCalendarioService.rotulo(sinal);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compacto ? 0 : 3, vertical: 2),
      child: Semantics(
        link: true,
        label: '${item.titulo}, $rotulo. Abrir cartão de detalhes.',
        child: Tooltip(
          message: '${item.titulo} · $rotulo',
          child: TextButton(
            key: ValueKey('agenda-link-${item.id}'),
            style: TextButton.styleFrom(
              foregroundColor: cor,
              backgroundColor: fundo,
              minimumSize: const Size(double.infinity, 48),
              padding: EdgeInsets.symmetric(
                  horizontal: compacto ? 2 : 4, vertical: 6),
              textStyle: compacto
                  ? Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(fontSize: 11)
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: _ocupado ? null : () => _abrirDetalhes(item),
            child: Text(
              item.titulo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _abrirDetalhes(AgendaCompromisso item) async {
    _acaoDestacada = item.id;
    _c.selecionarDia(item.data);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    final contexto = _cartoes[item.id]?.currentContext;
    if (contexto != null && contexto.mounted) {
      await Scrollable.ensureVisible(
        contexto,
        alignment: 0.05,
        duration: const Duration(milliseconds: 250),
      );
    }
  }

  Widget _filtros() => LayoutBuilder(
        builder: (context, constraints) {
          final largura = constraints.maxWidth < 650
              ? constraints.maxWidth
              : (constraints.maxWidth - 24) / 3;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: largura,
                child: TextField(
                  onChanged: (v) => _c.filtrar(texto: v),
                  decoration: const InputDecoration(
                    labelText: 'Pesquisar ação / instituição',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(
                width: largura,
                child: DropdownButtonFormField<String>(
                  initialValue: '',
                  decoration: const InputDecoration(
                    labelText: 'Turno',
                    border: OutlineInputBorder(),
                  ),
                  items: ['', 'manha', 'tarde', 'noite']
                      .map(
                        (v) => DropdownMenuItem(
                          value: v,
                          child: Text(v.isEmpty ? 'Todos' : _rotuloTurno(v)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => _c.filtrar(turno: v),
                ),
              ),
              SizedBox(
                width: largura,
                child: DropdownButtonFormField<String>(
                  initialValue: '',
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Situação',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    '',
                    'Em planejamento',
                    'Pronta para escala',
                    'Escala em elaboração',
                    'Escala publicada',
                    'Cancelada',
                  ]
                      .map(
                        (v) => DropdownMenuItem(
                          value: v,
                          child: Text(
                            v.isEmpty ? 'Todas' : v,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => _c.filtrar(situacao: v),
                ),
              ),
            ],
          );
        },
      );

  Widget _card(AgendaCompromisso item) {
    final escala = _c.dados?.escalas[item.id];
    return KeyedSubtree(
      key: _cartoes.putIfAbsent(item.id, GlobalKey.new),
      child: Card(
        key: ValueKey('agenda-item-${item.id}'),
        shape: _acaoDestacada == item.id
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.titulo,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(AgendaService.situacaoExibida(item, escala)),
              if (_c.pendente(item))
                const Text(
                  'Planejamento alterado: aplicação à escala pendente.',
                  style: TextStyle(color: Colors.deepOrange),
                ),
              const SizedBox(height: 8),
              Text(
                item.horarioACombinar
                    ? 'Horário a combinar'
                    : '${item.horaInicio} às ${item.horaFim}',
              ),
              if (item.instituicao.isNotEmpty) Text(item.instituicao),
              if (item.local.isNotEmpty) Text(item.local),
              if (item.endereco.isNotEmpty) Text(item.endereco),
              if (item.contatoNome.isNotEmpty ||
                  item.contatoTelefone.isNotEmpty)
                Text('Contato: ${item.contatoNome} · ${item.contatoTelefone}'),
              if (item.publico.isNotEmpty) Text('Público: ${item.publico}'),
              if (item.quantidadePublico != null)
                Text('Público estimado: ${item.quantidadePublico}'),
              if (item.integrantesNecessarios != null)
                Text('Integrantes necessários: ${item.integrantesNecessarios}'),
              if (item.materiais.isNotEmpty)
                Text('Materiais: ${item.materiais}'),
              if (item.observacoesInternas.isNotEmpty)
                Text('Observações internas: ${item.observacoesInternas}'),
              if (item.orientacaoEquipe.isNotEmpty)
                Text('Orientações à equipe: ${item.orientacaoEquipe}'),
              if (item.cancelada) Text('Motivo: ${item.motivo}'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (!item.cancelada)
                    OutlinedButton(
                      onPressed: _ocupado ? null : () => _editar(item),
                      child: const Text('Editar / remarcar'),
                    ),
                  if (!item.cancelada && !item.pronta)
                    OutlinedButton(
                      onPressed: _ocupado
                          ? null
                          : () => _operar(() => _c.pronta(item)),
                      child: const Text('Pronta para escala'),
                    ),
                  if (!item.cancelada && item.pronta)
                    FilledButton(
                      onPressed: _ocupado ? null : () => _montar(item),
                      child: Text(
                        item.vinculada
                            ? 'Aplicar planejamento'
                            : 'Montar escala',
                      ),
                    ),
                  if (item.vinculada)
                    OutlinedButton(
                      onPressed: _ocupado
                          ? null
                          : () => _abrirEscala(item.dataVinculada ?? item.data),
                      child: const Text('Abrir escala'),
                    ),
                  if (!item.cancelada)
                    TextButton(
                      onPressed: _ocupado ? null : () => _cancelar(item),
                      child: const Text('Cancelar ação'),
                    ),
                  TextButton(
                    onPressed: _ocupado ? null : () => _historico(item),
                    child: const Text('Histórico'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editar([AgendaCompromisso? item]) async {
    final novo = await showAgendaForm(
      context: context,
      controller: _c,
      item: item,
    );
    if (novo != null && mounted) await _operar(() => _c.salvar(novo));
  }

  Future<void> _montar(AgendaCompromisso item) async {
    await _operar(() async {
      await _c.montarEscala(item);
      if (mounted) await _abrirEscala(item.data);
    });
  }

  Future<void> _abrirEscala(DateTime data) async {
    await context.push('/escala/gestao?data=${AgendaService.dataId(data)}');
    if (mounted) await _c.carregar();
  }

  Future<void> _cancelar(AgendaCompromisso item) async {
    final resposta = await showDialog<String>(
      context: context,
      builder: (_) => const _CancelarAgendaDialog(),
    );
    if (resposta != null && mounted) {
      await _operar(() => _c.cancelar(item, resposta));
    }
  }

  Future<void> _historico(AgendaCompromisso item) async {
    await _operar(() async {
      final itens = await _c.repository.historico(item.id);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Histórico do compromisso'),
          content: SizedBox(
            width: 600,
            height: 350,
            child: ListView(
              children: [
                for (final h in itens)
                  ListTile(
                    title: Text('${h.acao} · revisão ${h.revisao}'),
                    subtitle: Text(
                      '${DateFormat('dd/MM/yyyy HH:mm').format(h.em)} · ${h.usuarioId}\n'
                      '${h.dataAnterior == null ? '' : DateFormat('dd/MM/yyyy').format(h.dataAnterior!)} → '
                      '${h.dataNova == null ? '' : DateFormat('dd/MM/yyyy').format(h.dataNova!)}\n${h.motivo}',
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _operar(Future<void> Function() acao) async {
    try {
      await acao();
    } catch (e, stack) {
      if (kDebugMode) {
        // Não registrar planejamento, contatos ou conteúdo da exceção.
        debugPrint(
          'AGO-001 operação: ${e.runtimeType}'
          '${e is FirebaseException ? ' (${e.code})' : ''}',
        );
        debugPrintStack(stackTrace: stack);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is StateError
                  ? e.message.toString()
                  : e is FirebaseException
                      ? 'Não foi possível concluir (${e.code}). Atualize a agenda e tente novamente.'
                      : 'Não foi possível concluir. Atualize a agenda e tente novamente.',
            ),
          ),
        );
      }
    }
  }

  String _rotuloTurno(String t) => switch (t) {
        'manha' => 'Manhã',
        'tarde' => 'Tarde',
        _ => 'Noite',
      };
}

class _CancelarAgendaDialog extends StatefulWidget {
  const _CancelarAgendaDialog();
  @override
  State<_CancelarAgendaDialog> createState() => _CancelarAgendaDialogState();
}

class _CancelarAgendaDialogState extends State<_CancelarAgendaDialog> {
  final _motivo = TextEditingController();
  final _form = GlobalKey<FormState>();
  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Cancelar compromisso'),
        content: Form(
          key: _form,
          child: TextFormField(
            key: const ValueKey('agenda-motivo-cancelamento'),
            controller: _motivo,
            maxLength: 4000,
            decoration: const InputDecoration(labelText: 'Motivo obrigatório'),
            validator: (v) =>
                (v ?? '').trim().isEmpty ? 'Informe o motivo' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () {
              if (_form.currentState!.validate()) {
                Navigator.pop(context, _motivo.text.trim());
              }
            },
            child: const Text('Confirmar cancelamento'),
          ),
        ],
      );
}

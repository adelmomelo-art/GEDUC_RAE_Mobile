import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../controllers/escala_historico_controller.dart';
import '../data/escala_repository.dart';
import '../data/firestore_escala_repository.dart';
import '../services/escala_horas_service.dart';
import '../services/escala_indicadores_historicos_service.dart';

class EscalaHistoricoPage extends StatefulWidget {
  const EscalaHistoricoPage({
    super.key,
    required this.usuarioId,
    required this.perfilAcesso,
    this.membroEquipeId = '',
    this.repository,
    this.inicioInicial,
    this.fimInicial,
    this.iniciarSomenteMinhasHoras = false,
    this.agora,
  });

  final String usuarioId;
  final String perfilAcesso;
  final String membroEquipeId;
  final EscalaRepository? repository;
  final DateTime? inicioInicial;
  final DateTime? fimInicial;
  final bool iniciarSomenteMinhasHoras;
  final DateTime Function()? agora;

  @override
  State<EscalaHistoricoPage> createState() => _EscalaHistoricoPageState();
}

class _EscalaHistoricoPageState extends State<EscalaHistoricoPage> {
  late EscalaHistoricoController _controller;

  @override
  void initState() {
    super.initState();
    _criarController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.carregar();
    });
  }

  @override
  void didUpdateWidget(covariant EscalaHistoricoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.usuarioId == widget.usuarioId &&
        oldWidget.perfilAcesso == widget.perfilAcesso &&
        oldWidget.membroEquipeId == widget.membroEquipeId &&
        oldWidget.repository == widget.repository &&
        oldWidget.inicioInicial == widget.inicioInicial &&
        oldWidget.fimInicial == widget.fimInicial &&
        oldWidget.iniciarSomenteMinhasHoras ==
            widget.iniciarSomenteMinhasHoras &&
        oldWidget.agora == widget.agora) {
      return;
    }
    _controller
      ..removeListener(_atualizar)
      ..dispose();
    _criarController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.carregar();
    });
  }

  void _criarController() {
    _controller = EscalaHistoricoController(
      repository: widget.repository ?? FirestoreEscalaRepository(),
      usuarioId: widget.usuarioId,
      perfilAcesso: widget.perfilAcesso,
      membroEquipeId: widget.membroEquipeId,
      inicioInicial: widget.inicioInicial,
      fimInicial: widget.fimInicial,
      iniciarSomenteMinhasHoras: widget.iniciarSomenteMinhasHoras,
      agora: widget.agora,
    )..addListener(_atualizar);
  }

  void _atualizar() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_atualizar)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de horas')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _controller.carregar,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _FiltroHistorico(
                        controller: _controller,
                        onSelecionarInicio: () => _selecionarData(true),
                        onSelecionarFim: () => _selecionarData(false),
                        onConsultar: _controller.carregar,
                      ),
                      const SizedBox(height: 12),
                      if (_controller.carregando)
                        const LinearProgressIndicator(
                          key: ValueKey('historico-loading'),
                        ),
                      if (_controller.carregando) const SizedBox(height: 12),
                      _conteudo(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _conteudo() {
    if (_controller.erro != null) {
      return _EstadoHistorico(
        key: const ValueKey('historico-erro'),
        icon: Icons.cloud_off_rounded,
        title: 'Não foi possível carregar o histórico',
        message:
            'Verifique a conexão e tente novamente. Nenhum dado foi alterado.',
        actionLabel: 'Tentar novamente',
        onAction: _controller.carregar,
      );
    }

    if (_controller.carregando && _controller.resumo == null) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final resumo = _controller.resumo;
    if (resumo == null) return const SizedBox.shrink();
    if (resumo.diasPublicados == 0) {
      return const _EstadoHistorico(
        key: ValueKey('historico-vazio'),
        icon: Icons.event_busy_rounded,
        title: 'Nenhuma escala publicada no período',
        message: 'Altere as datas para consultar outro intervalo.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ResumoHistorico(resumo: resumo),
        if (resumo.possuiPendencias) ...[
          const SizedBox(height: 12),
          _PendenciasHistorico(resumo: resumo),
        ],
        if (resumo.pessoas.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SaldosPessoas(
            pessoas: resumo.pessoas,
            somenteMinhasHoras: _controller.somenteMinhasHoras,
          ),
        ],
        const SizedBox(height: 12),
        _DiasPublicados(controller: _controller),
      ],
    );
  }

  Future<void> _selecionarData(bool inicio) async {
    final atual = inicio ? _controller.inicio : _controller.fim;
    final selecionada = await showDatePicker(
      context: context,
      initialDate: atual,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: inicio ? 'Data inicial' : 'Data final',
    );
    if (selecionada == null || !mounted) return;

    try {
      _controller.selecionarPeriodo(
        inicio: inicio ? selecionada : _controller.inicio,
        fim: inicio ? _controller.fim : selecionada,
      );
    } on ArgumentError catch (erro) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_mensagemArgumento(erro))));
    }
  }

  static String _mensagemArgumento(ArgumentError erro) {
    final mensagem = erro.message?.toString().trim() ?? '';
    return mensagem.isEmpty ? 'Período inválido.' : mensagem;
  }
}

class _FiltroHistorico extends StatelessWidget {
  const _FiltroHistorico({
    required this.controller,
    required this.onSelecionarInicio,
    required this.onSelecionarFim,
    required this.onConsultar,
  });

  final EscalaHistoricoController controller;
  final VoidCallback onSelecionarInicio;
  final VoidCallback onSelecionarFim;
  final VoidCallback onConsultar;

  @override
  Widget build(BuildContext context) {
    final formato = DateFormat('dd/MM/yyyy');
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Período da consulta',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Intervalo inclusivo de até 366 dias. Somente escalas publicadas.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  key: const ValueKey('historico-data-inicio'),
                  onPressed: controller.carregando ? null : onSelecionarInicio,
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text('Início: ${formato.format(controller.inicio)}'),
                ),
                OutlinedButton.icon(
                  key: const ValueKey('historico-data-fim'),
                  onPressed: controller.carregando ? null : onSelecionarFim,
                  icon: const Icon(Icons.event_available_outlined),
                  label: Text('Fim: ${formato.format(controller.fim)}'),
                ),
                TextButton(
                  key: const ValueKey('historico-mes-atual'),
                  onPressed: controller.carregando
                      ? null
                      : controller.selecionarMesAtual,
                  child: const Text('Mês atual'),
                ),
                FilledButton.icon(
                  key: const ValueKey('historico-consultar'),
                  onPressed: controller.carregando ? null : onConsultar,
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Consultar'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (controller.podeConsultarGeral)
              Align(
                alignment: Alignment.centerLeft,
                child: SegmentedButton<bool>(
                  key: const ValueKey('historico-escopo'),
                  segments: const [
                    ButtonSegment<bool>(
                      value: false,
                      icon: Icon(Icons.groups_rounded),
                      label: Text('Visão geral'),
                    ),
                    ButtonSegment<bool>(
                      value: true,
                      icon: Icon(Icons.person_rounded),
                      label: Text('Minhas horas'),
                    ),
                  ],
                  selected: <bool>{controller.somenteMinhasHoras},
                  onSelectionChanged: controller.carregando
                      ? null
                      : (valor) {
                          controller.definirSomenteMinhasHoras(valor.first);
                          controller.carregar();
                        },
                ),
              )
            else
              const Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  avatar: Icon(Icons.lock_person_outlined),
                  label: Text('Minhas horas'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResumoHistorico extends StatelessWidget {
  const _ResumoHistorico({required this.resumo});

  final EscalaIndicadoresHistoricosResumo resumo;

  @override
  Widget build(BuildContext context) {
    final itens = <({IconData icon, String rotulo, String valor})>[
      (
        icon: Icons.calendar_view_month_rounded,
        rotulo: 'Dias publicados',
        valor: resumo.diasPublicados.toString(),
      ),
      (
        icon: Icons.assignment_ind_outlined,
        rotulo: 'Alocações',
        valor: resumo.totalAlocacoes.toString(),
      ),
      (
        icon: Icons.schedule_rounded,
        rotulo: 'Horas planejadas',
        valor: EscalaHorasService.formatarMinutos(resumo.minutosPlanejados),
      ),
      (
        icon: Icons.timer_outlined,
        rotulo: 'Horas realizadas',
        valor: EscalaHorasService.formatarMinutos(
          resumo.totalMinutosRealizados,
        ),
      ),
      (
        icon: Icons.check_circle_outline_rounded,
        rotulo: 'Jornada normal',
        valor: EscalaHorasService.formatarMinutos(
          resumo.minutosRealizadosNormal,
        ),
      ),
      (
        icon: Icons.more_time_rounded,
        rotulo: 'Hora extra',
        valor: EscalaHorasService.formatarMinutos(
          resumo.minutosRealizadosHoraExtra,
        ),
      ),
      (
        icon: Icons.add_card_rounded,
        rotulo: 'Crédito no banco',
        valor: EscalaHorasService.formatarMinutos(resumo.minutosCreditoBanco),
      ),
      (
        icon: Icons.event_available_outlined,
        rotulo: 'Compensado',
        valor: EscalaHorasService.formatarMinutos(
          resumo.minutosCompensadosBanco,
        ),
      ),
      (
        icon: Icons.account_balance_wallet_outlined,
        rotulo: 'Saldo do banco',
        valor: _formatarSaldo(resumo.saldoBancoMinutos),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final colunas = constraints.maxWidth >= 960
            ? 4
            : constraints.maxWidth >= 600
                ? 3
                : constraints.maxWidth >= 380
                    ? 2
                    : 1;
        const espaco = 8.0;
        final largura =
            (constraints.maxWidth - espaco * (colunas - 1)) / colunas;
        return Wrap(
          spacing: espaco,
          runSpacing: espaco,
          children: [
            for (final item in itens)
              SizedBox(
                width: largura,
                child: _IndicadorCard(
                  icon: item.icon,
                  rotulo: item.rotulo,
                  valor: item.valor,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _IndicadorCard extends StatelessWidget {
  const _IndicadorCard({
    required this.icon,
    required this.rotulo,
    required this.valor,
  });

  final IconData icon;
  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(rotulo, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 2),
            Text(
              valor,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendenciasHistorico extends StatelessWidget {
  const _PendenciasHistorico({required this.resumo});

  final EscalaIndicadoresHistoricosResumo resumo;

  @override
  Widget build(BuildContext context) {
    final itens = <String>[
      if (resumo.alocacoesSemHorasRealizadas > 0)
        '${resumo.alocacoesSemHorasRealizadas} alocação(ões) sem horas realizadas',
      if (resumo.alocacoesHorasInvalidas > 0)
        '${resumo.alocacoesHorasInvalidas} alocação(ões) com horas inválidas',
      if (resumo.compensacoesSemHoras > 0)
        '${resumo.compensacoesSemHoras} compensação(ões) sem horário',
      if (resumo.compensacoesInvalidas > 0)
        '${resumo.compensacoesInvalidas} compensação(ões) inválida(s)',
      if (resumo.registrosSemIdentidade > 0)
        '${resumo.registrosSemIdentidade} registro(s) sem identidade',
    ];
    return Card(
      key: const ValueKey('historico-pendencias'),
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pendências de registro',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  for (final item in itens) Text('• $item'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaldosPessoas extends StatelessWidget {
  const _SaldosPessoas({
    required this.pessoas,
    required this.somenteMinhasHoras,
  });

  final List<EscalaSaldoBancoPessoa> pessoas;
  final bool somenteMinhasHoras;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              somenteMinhasHoras ? 'Meu banco de horas' : 'Banco por pessoa',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            for (var indice = 0; indice < pessoas.length; indice++) ...[
              _SaldoPessoaLinha(pessoa: pessoas[indice]),
              if (indice < pessoas.length - 1) const Divider(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

class _SaldoPessoaLinha extends StatelessWidget {
  const _SaldoPessoaLinha({required this.pessoa});

  final EscalaSaldoBancoPessoa pessoa;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(child: Text(_iniciais(pessoa.nome))),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pessoa.nome,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                'Crédito ${EscalaHorasService.formatarMinutos(pessoa.minutosCredito)} • '
                'Compensado ${EscalaHorasService.formatarMinutos(pessoa.minutosCompensados)}',
              ),
              if (pessoa.possuiPendencia)
                Text(
                  'Registro pendente de conferência',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _formatarSaldo(pessoa.saldoMinutos),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: pessoa.saldoNegativo
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  static String _iniciais(String nome) {
    final partes = nome
        .trim()
        .split(RegExp(r'\s+'))
        .where((item) => item.isNotEmpty)
        .take(2)
        .toList();
    if (partes.isEmpty) return '?';
    return partes.map((item) => item[0].toUpperCase()).join();
  }
}

class _DiasPublicados extends StatelessWidget {
  const _DiasPublicados({required this.controller});

  final EscalaHistoricoController controller;

  @override
  Widget build(BuildContext context) {
    final dias = controller.periodo?.dias ?? const <EscalaDiaConsulta>[];
    final formato = DateFormat('dd/MM/yyyy');
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Escalas publicadas',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            for (var indice = 0; indice < dias.length; indice++) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_available_rounded),
                title: Text(formato.format(dias[indice].data)),
                subtitle: Text(
                  '${dias[indice].alocacoes.length} alocação(ões)',
                ),
                trailing: Text('v${dias[indice].escala?.versao ?? 0}'),
              ),
              if (indice < dias.length - 1) const Divider(height: 1),
            ],
          ],
        ),
      ),
    );
  }
}

class _EstadoHistorico extends StatelessWidget {
  const _EstadoHistorico({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Column(
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

String _formatarSaldo(int minutos) {
  final sinal = minutos < 0 ? '−' : '+';
  return '$sinal${EscalaHorasService.formatarMinutos(minutos.abs())}';
}

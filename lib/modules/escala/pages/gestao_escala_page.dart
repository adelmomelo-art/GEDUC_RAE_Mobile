import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../controllers/escala_gestao_controller.dart';
import '../data/escala_gestao_repository.dart';
import '../data/firestore_escala_repository.dart';
import '../models/escala_models.dart';
import '../services/escala_horas_service.dart';
import '../widgets/atividade_form_dialog.dart';

class GestaoEscalaPage extends StatefulWidget {
  const GestaoEscalaPage({
    super.key,
    required this.usuarioId,
    required this.perfilAcesso,
    this.repository,
    this.dataInicial,
  });

  final String usuarioId;
  final String perfilAcesso;
  final EscalaGestaoRepository? repository;
  final DateTime? dataInicial;

  @override
  State<GestaoEscalaPage> createState() => _GestaoEscalaPageState();
}

class _GestaoEscalaPageState extends State<GestaoEscalaPage> {
  late final EscalaGestaoController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EscalaGestaoController(
      repository: widget.repository ?? FirestoreEscalaRepository(),
      usuarioId: widget.usuarioId,
      perfilAcesso: widget.perfilAcesso,
      dataInicial: widget.dataInicial,
    )..addListener(_atualizar);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.carregar();
    });
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_atualizar)
      ..dispose();
    super.dispose();
  }

  void _atualizar() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestão da Escala')),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
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
                          _CabecalhoGestao(controller: _controller),
                          const SizedBox(height: 12),
                          if (_controller.carregando)
                            const LinearProgressIndicator(),
                          if (_controller.carregando)
                            const SizedBox(height: 12),
                          _conteudo(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_controller.salvando)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x22000000),
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Salvando...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _conteudo() {
    if (_controller.erro != null && _controller.dados == null) {
      return _EstadoGestao(
        icon: Icons.cloud_off_rounded,
        titulo: 'Não foi possível carregar a gestão',
        mensagem: 'Verifique a conexão e tente novamente.',
        acao: FilledButton.icon(
          onPressed: _controller.carregar,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Tentar novamente'),
        ),
      );
    }
    if (_controller.carregando && _controller.dados == null) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_controller.possuiEscala) return _semEscala();
    return _comEscala();
  }

  Widget _semEscala() {
    return _EstadoGestao(
      key: const ValueKey('gestao-sem-escala'),
      icon: Icons.edit_calendar_rounded,
      titulo: 'Nenhuma escala criada para esta data',
      mensagem: _controller.podeCriarEscala
          ? 'O agente responsável pode iniciar o rascunho diário.'
          : 'A criação do rascunho é exclusiva do agente responsável.',
      acao: _controller.podeCriarEscala
          ? FilledButton.icon(
              key: const ValueKey('criar-rascunho'),
              onPressed: _criarRascunho,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Criar rascunho'),
            )
          : null,
    );
  }

  Widget _comEscala() {
    final escala = _controller.escala!;
    final conferencia = _controller.conferencia;
    final resumo = _controller.resumoHoras;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ResumoGestao(
          status: escala.status,
          versao: escala.versao,
          atividades: _controller.atividades.length,
          agentes: resumo.totalAgentesUnicos,
          coberturaAtual: conferencia?.totalExplicados ?? 0,
          coberturaTotal: conferencia?.totalEfetivo ?? 0,
          minutosNormal: resumo.minutosNormal,
          minutosExtra: resumo.minutosHoraExtra,
          minutosBanco: resumo.minutosBancoHoras,
        ),
        const SizedBox(height: 12),
        if (_controller.alertasGerais.isNotEmpty) ...[
          _AlertasGestao(alertas: _controller.alertasGerais),
          const SizedBox(height: 12),
        ],
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (_controller.podeEditarEscala)
                  FilledButton.icon(
                    key: const ValueKey('nova-atividade'),
                    onPressed: () => _editarAtividade(),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Nova atividade'),
                  ),
                if (_controller.rascunho &&
                    !_controller.revisaoPreparacaoPendente)
                  FilledButton.tonalIcon(
                    key: const ValueKey('revisar-publicacao'),
                    onPressed: _abrirRevisaoPublicacao,
                    icon: const Icon(Icons.fact_check_rounded),
                    label: const Text('Revisar publicação'),
                  ),
                if (_controller.podeRevisarEscala)
                  FilledButton.tonalIcon(
                    key: const ValueKey('revisar-escala'),
                    onPressed: _abrirMotivoRevisao,
                    icon: const Icon(Icons.history_rounded),
                    label: const Text('Revisar escala'),
                  ),
                OutlinedButton.icon(
                  onPressed: _abrirConsulta,
                  icon: const Icon(Icons.visibility_rounded),
                  label: const Text('Ver escala'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_controller.revisaoPreparacaoPendente)
          _EstadoGestao(
            key: const ValueKey('gestao-revisao-pendente'),
            icon: Icons.sync_rounded,
            titulo: 'Preparação da revisão interrompida',
            mensagem:
                'A versão publicada continua disponível. Retome a preparação '
                'antes de editar ou publicar a nova versão.',
            acao: FilledButton.icon(
              key: const ValueKey('retomar-revisao'),
              onPressed: _retomarRevisao,
              icon: const Icon(Icons.sync_rounded),
              label: const Text('Retomar revisão'),
            ),
          )
        else if (_controller.publicada)
          _EstadoGestao(
            key: const ValueKey('gestao-publicada'),
            icon: Icons.verified_rounded,
            titulo: 'Escala publicada',
            mensagem:
                'Versão ${escala.versao} publicada. Para alterar a estrutura, '
                'inicie uma nova revisão versionada.',
          )
        else if (_controller.atividades.isEmpty)
          const _EstadoGestao(
            key: ValueKey('gestao-sem-atividades'),
            icon: Icons.assignment_outlined,
            titulo: 'Rascunho sem atividades',
            mensagem: 'Adicione a primeira atividade e depois monte a equipe.',
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final colunas = constraints.maxWidth >= 900 ? 2 : 1;
              const espaco = 10.0;
              final largura =
                  (constraints.maxWidth - espaco * (colunas - 1)) / colunas;
              return Wrap(
                spacing: espaco,
                runSpacing: espaco,
                children: [
                  for (final atividade in _controller.atividades)
                    SizedBox(
                      width: largura,
                      child: _AtividadeGestaoCard(
                        atividade: atividade,
                        alocacoes: _controller.alocacoesDaAtividade(
                          atividade.id,
                        ),
                        onEditar: _controller.podeEditarEscala
                            ? () => _editarAtividade(atividade)
                            : null,
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }

  Future<void> _criarRascunho() async {
    try {
      await _controller.criarRascunho();
    } catch (erro) {
      _mostrarErro(erro);
    }
  }

  Future<void> _editarAtividade([EscalaAtividadeModel? atividade]) async {
    final entrada = await showEscalaAtividadeFormDialog(
      context: context,
      controller: _controller,
      atividade: atividade,
    );
    if (entrada == null || !mounted) return;
    try {
      await _controller.salvarAtividade(entrada);
    } catch (erro) {
      _mostrarErro(erro);
    }
  }

  Future<void> _abrirRevisaoPublicacao() async {
    final analise = _controller.analisePublicacao;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revisão da escala'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy').format(_controller.dataSelecionada),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                Text('Atividades: ${analise.totalAtividades}'),
                Text('Agentes: ${analise.totalAgentes}'),
                Text('Ações educativas: ${analise.totalEducativas}'),
                Text(
                  'Missões administrativas: '
                  '${analise.totalAdministrativas}',
                ),
                const SizedBox(height: 14),
                Text(
                  'ALERTAS (${analise.alertas.length})',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                if (analise.alertas.isEmpty)
                  const Text('Nenhum alerta operacional.')
                else
                  for (final alerta in analise.alertas) Text('• $alerta'),
                const SizedBox(height: 14),
                Text(
                  'ERROS (${analise.bloqueios.length})',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                if (analise.bloqueios.isEmpty)
                  const Text('✓ Nenhum blocker estrutural.')
                else
                  for (final bloqueio in analise.bloqueios) Text('• $bloqueio'),
                const SizedBox(height: 14),
                const Text(
                  'Alertas não bloqueiam a decisão operacional. '
                  'Erros estruturais bloqueiam a publicação.',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: analise.podePublicar
                ? () => Navigator.pop(context, true)
                : null,
            child: const Text('Publicar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      await _controller.publicarEscala();
    } catch (erro) {
      _mostrarErro(erro);
    }
  }

  Future<void> _abrirMotivoRevisao() async {
    final motivoController = TextEditingController();

    final motivo = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revisar escala publicada'),
        content: TextField(
          controller: motivoController,
          autofocus: true,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Motivo da revisão',
            hintText: 'Descreva por que a nova versão é necessária.',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, motivoController.text),
            child: const Text('Criar nova versão'),
          ),
        ],
      ),
    );

    motivoController.dispose();

    if (motivo == null || !mounted) return;

    try {
      await _controller.iniciarRevisao(motivo);
    } catch (erro) {
      _mostrarErro(erro);
    }
  }

  Future<void> _retomarRevisao() async {
    try {
      await _controller.retomarRevisao();
    } catch (erro) {
      _mostrarErro(erro);
    }
  }

  void _abrirConsulta() {
    context.push(
      '/escala?data=${_formatarIdData(_controller.dataSelecionada)}',
    );
  }

  void _mostrarErro(Object erro) {
    if (!mounted) return;
    final mensagem = erro is EscalaGestaoValidationException
        ? erro.mensagens.join('\n')
        : erro.toString();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  static String _formatarIdData(DateTime data) =>
      '${data.year.toString().padLeft(4, '0')}-'
      '${data.month.toString().padLeft(2, '0')}-'
      '${data.day.toString().padLeft(2, '0')}';
}

class _CabecalhoGestao extends StatelessWidget {
  const _CabecalhoGestao({required this.controller});
  final EscalaGestaoController controller;

  @override
  Widget build(BuildContext context) {
    final data = controller.dataSelecionada;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Dia anterior',
                  onPressed:
                      controller.carregando ? null : controller.diaAnterior,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 150),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _diaSemana(data.weekday),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy').format(data),
                        key: const ValueKey('gestao-data'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Próximo dia',
                  onPressed:
                      controller.carregando ? null : controller.proximoDia,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
                IconButton(
                  key: const ValueKey('selecionar-data-gestao'),
                  tooltip: 'Selecionar data',
                  onPressed: controller.carregando
                      ? null
                      : () async {
                          final selecionada = await showDatePicker(
                            context: context,
                            initialDate: data,
                            firstDate: DateTime(data.year - 2),
                            lastDate: DateTime(data.year + 2, 12, 31),
                          );
                          if (selecionada != null) {
                            await controller.selecionarData(selecionada);
                          }
                        },
                  icon: const Icon(Icons.calendar_month_rounded),
                ),
                TextButton(
                  onPressed: controller.carregando ? null : controller.hoje,
                  child: const Text('Hoje'),
                ),
              ],
            ),
            Chip(
              avatar: Icon(
                controller.ehResponsavel
                    ? Icons.badge_rounded
                    : Icons.manage_accounts_rounded,
                size: 18,
              ),
              label: Text(
                controller.ehResponsavel ? 'Agente responsável' : 'Gerente',
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _diaSemana(int weekday) =>
      const <int, String>{
        DateTime.monday: 'Segunda-feira',
        DateTime.tuesday: 'Terça-feira',
        DateTime.wednesday: 'Quarta-feira',
        DateTime.thursday: 'Quinta-feira',
        DateTime.friday: 'Sexta-feira',
        DateTime.saturday: 'Sábado',
        DateTime.sunday: 'Domingo',
      }[weekday] ??
      '';
}

class _ResumoGestao extends StatelessWidget {
  const _ResumoGestao({
    required this.status,
    required this.versao,
    required this.atividades,
    required this.agentes,
    required this.coberturaAtual,
    required this.coberturaTotal,
    required this.minutosNormal,
    required this.minutosExtra,
    required this.minutosBanco,
  });

  final String status;
  final int versao;
  final int atividades;
  final int agentes;
  final int coberturaAtual;
  final int coberturaTotal;
  final int minutosNormal;
  final int minutosExtra;
  final int minutosBanco;

  @override
  Widget build(BuildContext context) {
    final itens = <(IconData, String, String)>[
      (
        Icons.fact_check_rounded,
        'Status',
        '${status.toUpperCase()} • v$versao',
      ),
      (Icons.assignment_rounded, 'Atividades', atividades.toString()),
      (Icons.groups_rounded, 'Agentes escalados', agentes.toString()),
      (
        Icons.how_to_reg_rounded,
        'Cobertura',
        '$coberturaAtual/$coberturaTotal',
      ),
      (
        Icons.schedule_rounded,
        'Normal',
        EscalaHorasService.formatarMinutos(minutosNormal),
      ),
      (
        Icons.more_time_rounded,
        'Hora extra',
        EscalaHorasService.formatarMinutos(minutosExtra),
      ),
      (
        Icons.account_balance_wallet_outlined,
        'Banco de horas',
        EscalaHorasService.formatarMinutos(minutosBanco),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final colunas = constraints.maxWidth >= 960
            ? 4
            : constraints.maxWidth >= 560
                ? 2
                : 1;
        const espaco = 10.0;
        final largura =
            (constraints.maxWidth - espaco * (colunas - 1)) / colunas;
        return Wrap(
          spacing: espaco,
          runSpacing: espaco,
          children: [
            for (final item in itens)
              SizedBox(
                width: largura,
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Icon(item.$1),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.$2,
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              Text(
                                item.$3,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AlertasGestao extends StatelessWidget {
  const _AlertasGestao({required this.alertas});
  final List<String> alertas;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: cores.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alertas operacionais',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: cores.onTertiaryContainer,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 6),
            for (final alerta in alertas)
              Text(
                '• $alerta',
                style: TextStyle(color: cores.onTertiaryContainer),
              ),
            const SizedBox(height: 4),
            Text(
              'Alertas não bloqueiam a decisão operacional.',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: cores.onTertiaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AtividadeGestaoCard extends StatelessWidget {
  const _AtividadeGestaoCard({
    required this.atividade,
    required this.alocacoes,
    required this.onEditar,
  });
  final EscalaAtividadeModel atividade;
  final List<EscalaAlocacaoModel> alocacoes;
  final VoidCallback? onEditar;

  @override
  Widget build(BuildContext context) {
    final qtr = atividade.horaInicio.trim().isNotEmpty &&
            atividade.horaFim.trim().isNotEmpty
        ? '${atividade.horaInicio}–${atividade.horaFim}'
        : atividade.qtrHorario.trim().isNotEmpty
            ? atividade.qtrHorario
            : 'Não informado';
    return Card(
      key: ValueKey('gestao-atividade-${atividade.id}'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              atividade.titulo,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text('QTR: $qtr'),
            Text(
              'QTH: ${atividade.qthLocal.trim().isEmpty ? 'Não informado' : atividade.qthLocal}',
            ),
            Text('Equipe: ${alocacoes.length} agente(s)'),
            if (atividade.coordenadorNomeSnapshot.trim().isNotEmpty)
              Text('Coordenador: ${atividade.coordenadorNomeSnapshot}'),
            if (onEditar != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: onEditar,
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Editar'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EstadoGestao extends StatelessWidget {
  const _EstadoGestao({
    super.key,
    required this.icon,
    required this.titulo,
    required this.mensagem,
    this.acao,
  });
  final IconData icon;
  final String titulo;
  final String mensagem;
  final Widget? acao;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              Icon(icon, size: 42),
              const SizedBox(height: 12),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(mensagem, textAlign: TextAlign.center),
              if (acao != null) ...[const SizedBox(height: 16), acao!],
            ],
          ),
        ),
      );
}

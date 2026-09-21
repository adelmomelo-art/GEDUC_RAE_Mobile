import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routes/app_routes.dart';
import '../controllers/escala_consulta_controller.dart';
import '../data/escala_repository.dart';
import '../data/firestore_escala_repository.dart';
import '../models/escala_models.dart';
import '../security/escala_access_policy.dart';
import '../security/escala_permission.dart';
import '../services/escala_horas_service.dart';

class EscalaPage extends StatefulWidget {
  const EscalaPage({
    super.key,
    required this.usuarioId,
    this.perfilAcesso = '',
    this.repository,
    this.dataInicial,
    this.iniciarMinhaEscala = false,
  });

  final String usuarioId;
  final String perfilAcesso;
  final EscalaRepository? repository;
  final DateTime? dataInicial;
  final bool iniciarMinhaEscala;

  @override
  State<EscalaPage> createState() => _EscalaPageState();
}

class _EscalaPageState extends State<EscalaPage> {
  late final EscalaConsultaController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EscalaConsultaController(
      repository: widget.repository ?? FirestoreEscalaRepository(),
      usuarioId: widget.usuarioId,
      dataInicial: widget.dataInicial,
      iniciarMinhaEscala: widget.iniciarMinhaEscala,
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
      appBar: AppBar(title: const Text('Escala GEDUC')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _controller.carregar,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _CabecalhoConsulta(controller: _controller),
                      const SizedBox(height: 12),
                      if (_controller.carregando)
                        const LinearProgressIndicator(
                          key: ValueKey('escala-loading'),
                        ),
                      if (_controller.carregando) const SizedBox(height: 12),
                      _conteudo(context),
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

  Widget _conteudo(BuildContext context) {
    if (_controller.erro != null) {
      return _EstadoCard(
        icon: Icons.cloud_off_rounded,
        title: 'Não foi possível carregar a escala',
        message:
            'Verifique a conexão e tente novamente. Nenhum dado foi alterado.',
        actionLabel: 'Tentar novamente',
        onAction: _controller.carregar,
      );
    }

    if (_controller.carregando && _controller.dia == null) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_controller.escalaEncontrada) {
      return const _EstadoCard(
        key: ValueKey('escala-vazia'),
        icon: Icons.event_busy_rounded,
        title: 'Nenhuma escala encontrada',
        message: 'Não existe escala registrada para esta data.',
      );
    }

    final escala = _controller.escala!;

    if (!_controller.escalaPublicada) {
      return _EstadoCard(
        key: const ValueKey('escala-nao-publicada'),
        icon: Icons.edit_calendar_rounded,
        title: 'Escala ainda não publicada',
        message:
            'Existe uma versão ${escala.status.toUpperCase()} para esta data. '
            'A consulta operacional é liberada após a publicação.',
      );
    }

    final atividades = _controller.atividadesVisiveis;
    final indisponibilidades = _controller.indisponibilidadesVisiveis;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ResumoEscala(controller: _controller),
        const SizedBox(height: 12),
        const _JornadasReferencia(),
        const SizedBox(height: 12),
        if (_controller.conflitosSobreposicao.isNotEmpty ||
            _controller.multiplasAlocacoes.isNotEmpty)
          _AlertasConsulta(controller: _controller),
        if (_controller.conflitosSobreposicao.isNotEmpty ||
            _controller.multiplasAlocacoes.isNotEmpty)
          const SizedBox(height: 12),
        if (atividades.isEmpty && indisponibilidades.isEmpty)
          _EstadoCard(
            key: const ValueKey('escala-sem-itens'),
            icon: _controller.minhaEscala
                ? Icons.person_search_rounded
                : Icons.assignment_outlined,
            title: _controller.minhaEscala
                ? 'Você não possui item nesta escala'
                : 'Escala publicada sem itens',
            message: _controller.minhaEscala
                ? 'Use "Escala completa" para consultar toda a programação do dia.'
                : 'A escala está publicada, mas não possui atividades ou '
                    'indisponibilidades cadastradas.',
          )
        else ...[
          for (final secao in _agruparAtividades(atividades).entries) ...[
            _SecaoAtividades(
              titulo: _rotuloSecao(secao.key),
              atividades: secao.value,
              controller: _controller,
              perfilAcesso: widget.perfilAcesso,
            ),
            const SizedBox(height: 12),
          ],
          if (indisponibilidades.isNotEmpty)
            _SecaoIndisponibilidades(itens: indisponibilidades),
        ],
      ],
    );
  }

  static Map<String, List<EscalaAtividadeModel>> _agruparAtividades(
    List<EscalaAtividadeModel> atividades,
  ) {
    final grupos = <String, List<EscalaAtividadeModel>>{};

    for (final atividade in atividades) {
      final chave = atividade.secaoId.trim().isEmpty
          ? 'outras'
          : atividade.secaoId.trim();
      grupos.putIfAbsent(chave, () => <EscalaAtividadeModel>[]).add(atividade);
    }

    final entradas = grupos.entries.toList()
      ..sort((a, b) {
        final ordemA = _ordemSecao(a.key);
        final ordemB = _ordemSecao(b.key);
        if (ordemA != ordemB) return ordemA.compareTo(ordemB);
        return a.key.compareTo(b.key);
      });

    return Map<String, List<EscalaAtividadeModel>>.fromEntries(entradas);
  }

  static int _ordemSecao(String secao) {
    final normalizada = secao.toLowerCase();
    if (normalizada.contains('administr')) return 10;
    if (normalizada.contains('comando') || normalizada.contains('tematic')) {
      return 20;
    }
    if (normalizada.contains('program') ||
        normalizada.contains('formacao') ||
        normalizada.contains('formação')) {
      return 30;
    }
    if (normalizada.contains('apoio')) return 40;
    return 90;
  }

  static String _rotuloSecao(String secao) {
    final normalizada = secao.toLowerCase();

    if (normalizada.contains('administr')) return 'ADMINISTRATIVO';
    if (normalizada.contains('comando') || normalizada.contains('tematic')) {
      return 'COMANDOS E AÇÕES TEMÁTICAS';
    }
    if (normalizada.contains('program') ||
        normalizada.contains('formacao') ||
        normalizada.contains('formação')) {
      return 'PROGRAMAS DE FORMAÇÃO E CAPACITAÇÃO';
    }
    if (normalizada.contains('apoio')) return 'APOIO GEDUC';
    if (normalizada == 'outras') return 'OUTRAS ATIVIDADES';

    return secao.replaceAll('_', ' ').replaceAll('-', ' ').trim().toUpperCase();
  }
}

class _CabecalhoConsulta extends StatelessWidget {
  const _CabecalhoConsulta({required this.controller});

  final EscalaConsultaController controller;

  @override
  Widget build(BuildContext context) {
    final data = controller.dataSelecionada;
    final dataFormatada = DateFormat('dd/MM/yyyy').format(data);
    final diaSemana = _diaSemana(data.weekday);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
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
                        diaSemana,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text(
                        dataFormatada,
                        key: const ValueKey('escala-data'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
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
                TextButton(
                  onPressed: controller.carregando ? null : controller.hoje,
                  child: const Text('Hoje'),
                ),
              ],
            ),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: false,
                  icon: Icon(Icons.groups_rounded),
                  label: Text('Escala completa'),
                ),
                ButtonSegment<bool>(
                  value: true,
                  icon: Icon(Icons.person_rounded),
                  label: Text('Minha Escala'),
                ),
              ],
              selected: <bool>{controller.minhaEscala},
              onSelectionChanged: (selecionado) {
                controller.definirMinhaEscala(selecionado.first);
              },
            ),
          ],
        ),
      ),
    );
  }

  static String _diaSemana(int weekday) {
    const dias = <int, String>{
      DateTime.monday: 'Segunda-feira',
      DateTime.tuesday: 'Terça-feira',
      DateTime.wednesday: 'Quarta-feira',
      DateTime.thursday: 'Quinta-feira',
      DateTime.friday: 'Sexta-feira',
      DateTime.saturday: 'Sábado',
      DateTime.sunday: 'Domingo',
    };
    return dias[weekday] ?? '';
  }
}

class _ResumoEscala extends StatelessWidget {
  const _ResumoEscala({required this.controller});

  final EscalaConsultaController controller;

  @override
  Widget build(BuildContext context) {
    final escala = controller.escala!;
    final resumo = controller.resumoHoras;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _InfoChip(
              icon: Icons.verified_rounded,
              label: 'PUBLICADA • v${escala.versao}',
            ),
            _InfoChip(
              icon: Icons.people_alt_rounded,
              label: '${resumo.totalAgentesUnicos} agente(s)',
            ),
            _InfoChip(
              icon: Icons.schedule_rounded,
              label:
                  '${EscalaHorasService.formatarMinutos(resumo.totalMinutosProgramados)} programadas',
            ),
            if (resumo.minutosHoraExtra > 0)
              _InfoChip(
                icon: Icons.more_time_rounded,
                label:
                    'Hora extra ${EscalaHorasService.formatarMinutos(resumo.minutosHoraExtra)}',
              ),
            if (resumo.minutosBancoHoras > 0)
              _InfoChip(
                icon: Icons.account_balance_wallet_outlined,
                label:
                    'Banco ${EscalaHorasService.formatarMinutos(resumo.minutosBancoHoras)}',
              ),
          ],
        ),
      ),
    );
  }
}

class _JornadasReferencia extends StatelessWidget {
  const _JornadasReferencia();

  @override
  Widget build(BuildContext context) {
    const jornadas = [
      (turno: 'MANHÃ', h180: '180H • 06:00–11:52', h240: '240H • 06:00–12:32'),
      (turno: 'TARDE', h180: '180H • 12:00–18:00', h240: '240H • 12:00–18:40'),
      (turno: 'NOITE', h180: '180H • 18:00–23:31', h240: '240H • 18:00–23:58'),
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Jornadas de referência',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Horários informativos. Não são usados como trava de validação.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final colunas = constraints.maxWidth >= 900
                    ? 3
                    : constraints.maxWidth >= 560
                        ? 2
                        : 1;
                const espaco = 8.0;
                final largura =
                    (constraints.maxWidth - espaco * (colunas - 1)) / colunas;

                return Wrap(
                  spacing: espaco,
                  runSpacing: espaco,
                  children: [
                    for (final jornada in jornadas)
                      SizedBox(
                        width: largura,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  jornada.turno,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 6),
                                Text(jornada.h180),
                                Text(jornada.h240),
                              ],
                            ),
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
}

class _AlertasConsulta extends StatelessWidget {
  const _AlertasConsulta({required this.controller});

  final EscalaConsultaController controller;

  @override
  Widget build(BuildContext context) {
    final conflitos = controller.conflitosSobreposicao.length;
    final multiplas = controller.multiplasAlocacoes.length;

    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: Theme.of(context).colorScheme.onTertiaryContainer,
            ),
            if (multiplas > 0)
              Text(
                '$multiplas agente(s) com múltiplas alocações',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            if (conflitos > 0)
              Text(
                '$conflitos sobreposição(ões) de horário',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
          ],
        ),
      ),
    );
  }
}

class _SecaoAtividades extends StatelessWidget {
  const _SecaoAtividades({
    required this.titulo,
    required this.atividades,
    required this.controller,
    required this.perfilAcesso,
  });

  final String titulo;
  final List<EscalaAtividadeModel> atividades;
  final EscalaConsultaController controller;
  final String perfilAcesso;

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
              titulo,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final colunas = constraints.maxWidth >= 1080
                    ? 3
                    : constraints.maxWidth >= 700
                        ? 2
                        : 1;
                const espaco = 12.0;
                final largura =
                    (constraints.maxWidth - espaco * (colunas - 1)) / colunas;

                return Wrap(
                  spacing: espaco,
                  runSpacing: espaco,
                  children: [
                    for (final atividade in atividades)
                      SizedBox(
                        width: largura,
                        child: _AtividadeCard(
                          atividade: atividade,
                          alocacoes: controller.alocacoesDaAtividade(
                            atividade.id,
                          ),
                          usuarioId: controller.usuarioId,
                          perfilAcesso: perfilAcesso,
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
}

class _AtividadeCard extends StatelessWidget {
  const _AtividadeCard({
    required this.atividade,
    required this.alocacoes,
    required this.usuarioId,
    required this.perfilAcesso,
  });

  final EscalaAtividadeModel atividade;
  final List<EscalaAlocacaoModel> alocacoes;
  final String usuarioId;
  final String perfilAcesso;

  @override
  Widget build(BuildContext context) {
    final resumo = EscalaHorasService.resumir(alocacoes);
    final equipe = alocacoes.take(8).toList();
    final restantes = alocacoes.length - equipe.length;
    final podeAbrirMissao = atividade.administrativa &&
        !atividade.geraRae &&
        EscalaAccessPolicy.autoriza(
          perfilAcesso: perfilAcesso,
          usuarioId: usuarioId,
          responsavelEscalaUsuarioId: '',
          permissao: EscalaPermission.registrarExecucaoMissao,
          ehParticipanteAtividade:
              atividade.participanteUsuarioIds.contains(usuarioId.trim()),
          ehCoordenadorAtividade:
              atividade.coordenadorUsuarioId.trim() == usuarioId.trim(),
        );

    return Card(
      key: ValueKey('atividade-${atividade.id}'),
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    atividade.titulo.trim().isEmpty
                        ? 'Atividade sem título'
                        : atividade.titulo.trim(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                _StatusPill(status: atividade.status),
              ],
            ),
            if (atividade.tipoAtividadeId.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                atividade.tipoAtividadeId
                    .replaceAll('_', ' ')
                    .replaceAll('-', ' ')
                    .toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
            const SizedBox(height: 12),
            _LinhaInfo(
              icon: Icons.schedule_rounded,
              titulo: 'QTR',
              valor: _qtr(atividade),
            ),
            const SizedBox(height: 8),
            _LinhaInfo(
              icon: Icons.place_rounded,
              titulo: 'QTH',
              valor: atividade.qthLocal.trim().isEmpty
                  ? 'Não informado'
                  : atividade.qthLocal.trim(),
            ),
            if (atividade.coordenadorNomeSnapshot.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              _LinhaInfo(
                icon: Icons.supervisor_account_rounded,
                titulo: 'Coordenação',
                valor: atividade.coordenadorNomeSnapshot.trim(),
              ),
            ],
            if (atividade.orientacaoOperacional.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              _LinhaInfo(
                icon: Icons.assignment_outlined,
                titulo: 'Orientação',
                valor: atividade.orientacaoOperacional.trim(),
              ),
            ],
            if (alocacoes.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                'Equipe (${alocacoes.length})',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final item in equipe)
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text(
                        item.usuarioId.trim() == usuarioId.trim() &&
                                usuarioId.trim().isNotEmpty
                            ? '${item.nomeSnapshot} • você'
                            : item.nomeSnapshot,
                      ),
                    ),
                  if (restantes > 0)
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text('+$restantes'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (resumo.minutosNormal > 0)
                    _JornadaPill(
                      label:
                          'NORMAL • ${EscalaHorasService.formatarMinutos(resumo.minutosNormal)}',
                    ),
                  if (resumo.minutosHoraExtra > 0)
                    _JornadaPill(
                      label:
                          'HORA EXTRA • ${EscalaHorasService.formatarMinutos(resumo.minutosHoraExtra)}',
                    ),
                  if (resumo.minutosBancoHoras > 0)
                    _JornadaPill(
                      label:
                          'BANCO HORAS • ${EscalaHorasService.formatarMinutos(resumo.minutosBancoHoras)}',
                    ),
                ],
              ),
            ],
            if (podeAbrirMissao) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: ValueKey('abrir-missao-${atividade.id}'),
                onPressed: () => context.push(
                  AppRoutes.execucaoMissaoLocation(atividade.id),
                ),
                icon: const Icon(Icons.assignment_turned_in_outlined),
                label: const Text('Execução da Missão'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _qtr(EscalaAtividadeModel atividade) {
    final inicio = atividade.horaInicio.trim();
    final fim = atividade.horaFim.trim();

    if (inicio.isNotEmpty && fim.isNotEmpty) return '$inicio–$fim';
    if (atividade.qtrHorario.trim().isNotEmpty) {
      return atividade.qtrHorario.trim();
    }
    return 'Não informado';
  }
}

class _SecaoIndisponibilidades extends StatelessWidget {
  const _SecaoIndisponibilidades({required this.itens});

  final List<EscalaIndisponibilidadeModel> itens;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('escala-indisponibilidades'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'COMPENSAÇÕES, FÉRIAS E FOLGAS',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in itens)
                  Chip(
                    avatar: const Icon(Icons.event_busy_rounded, size: 18),
                    label: Text('${item.nomeSnapshot} • ${_tipo(item.tipoId)}'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _tipo(String tipo) {
    final normalizado = tipo.trim().toLowerCase();
    switch (normalizado) {
      case 'ferias':
        return 'Férias';
      case 'compensacao':
        return 'Compensação';
      case 'folga':
        return 'Folga';
      default:
        return tipo.replaceAll('_', ' ').replaceAll('-', ' ').trim();
    }
  }
}

class _LinhaInfo extends StatelessWidget {
  const _LinhaInfo({
    required this.icon,
    required this.titulo,
    required this.valor,
  });

  final IconData icon;
  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$titulo: ',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(text: valor),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }
}

class _JornadaPill extends StatelessWidget {
  const _JornadaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          status.replaceAll('_', ' ').toUpperCase(),
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _EstadoCard extends StatelessWidget {
  const _EstadoCard({
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
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

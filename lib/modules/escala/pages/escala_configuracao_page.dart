import 'package:flutter/material.dart';

import '../controllers/escala_configuracao_controller.dart';
import '../data/escala_configuracao_repository.dart';
import '../data/firestore_escala_repository.dart';

class EscalaConfiguracaoPage extends StatefulWidget {
  const EscalaConfiguracaoPage({
    super.key,
    required this.usuarioId,
    required this.perfilAcesso,
    this.repository,
  });

  final String usuarioId;
  final String perfilAcesso;
  final EscalaConfiguracaoRepository? repository;

  @override
  State<EscalaConfiguracaoPage> createState() => _EscalaConfiguracaoPageState();
}

class _EscalaConfiguracaoPageState extends State<EscalaConfiguracaoPage> {
  late final EscalaConfiguracaoController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EscalaConfiguracaoController(
      repository: widget.repository ?? FirestoreEscalaRepository(),
      usuarioId: widget.usuarioId,
      perfilAcesso: widget.perfilAcesso,
    );
    _controller.carregar();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Configuração da Escala GEDUC'),
            actions: [
              IconButton(
                tooltip: 'Atualizar',
                onPressed: _controller.loading || _controller.saving
                    ? null
                    : _controller.carregar,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: _corpo(),
        );
      },
    );
  }

  Widget _corpo() {
    if (_controller.loading && _controller.dados == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_controller.podeConfigurar) {
      return const _MensagemEstado(
        icon: Icons.lock_rounded,
        titulo: 'Acesso restrito',
        mensagem:
            'Somente Gerente ou Administrador podem configurar a Escala GEDUC.',
      );
    }

    if (_controller.dados == null) {
      return _MensagemEstado(
        icon: Icons.error_outline_rounded,
        titulo: 'Não foi possível carregar',
        mensagem: _controller.erro?.toString() ?? 'Tente novamente.',
      );
    }

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _cabecalho(),
                    const SizedBox(height: 16),
                    _responsavelCard(),
                    const SizedBox(height: 16),
                    _equipeCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (_controller.saving)
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }

  Widget _cabecalho() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.settings_suggest_rounded, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Parâmetros operacionais',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'A identidade continua na Equipe Operacional. Aqui são '
                    'mantidos apenas participação na Escala GEDUC, carga '
                    'horária e responsável fixo.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _responsavelCard() {
    final candidatos = _controller.candidatosResponsavel;
    final atual = _controller.responsavelAtualMembroId;
    final valorAtual =
        candidatos.any((item) => item.membro.id == atual) ? atual : null;

    return Card(
      key: const ValueKey('config-responsavel-card'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Responsável fixo',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Pode criar a escala diária. A conta selecionada deve ser '
              'Agente ativa e possuir vínculo canônico.',
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              key: const ValueKey('responsavel-fixo-dropdown'),
              initialValue: valorAtual,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Agente responsável',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final item in candidatos)
                  DropdownMenuItem(
                    value: item.membro.id,
                    child: Text(item.membro.nome),
                  ),
              ],
              onChanged: _controller.saving || candidatos.isEmpty
                  ? null
                  : (valor) {
                      if (valor != null) {
                        _salvarResponsavel(valor);
                      }
                    },
            ),
            if (candidatos.isEmpty) ...[
              const SizedBox(height: 10),
              const Text(
                'Nenhum candidato elegível. Ative um Agente na Equipe GEDUC '
                'com usuário canônico antes de designá-lo.',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _equipeCard() {
    final membros = _controller.membros;

    return Card(
      key: const ValueKey('config-equipe-card'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Equipe GEDUC',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Ative quem participa da Escala GEDUC e informe 180H ou 240H. '
              'Nome, vínculo e identidade vêm da Equipe Operacional.',
            ),
            const SizedBox(height: 12),
            if (membros.isEmpty)
              const Text('Nenhum integrante encontrado.')
            else
              for (final item in membros)
                _MembroConfiguracaoCard(
                  key: ValueKey('membro-config-${item.membro.id}'),
                  item: item,
                  responsavelAtual:
                      _controller.responsavelAtualMembroId == item.membro.id,
                  saving: _controller.saving,
                  onAtivoChanged: (ativo) => _salvarPerfil(
                    item,
                    ativo: ativo,
                    carga: item.cargaHorariaCodigo,
                  ),
                  onCargaChanged: (carga) => _salvarPerfil(
                    item,
                    ativo: item.ativoNaEscala,
                    carga: carga,
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Future<void> _salvarResponsavel(String membroId) async {
    try {
      await _controller.salvarResponsavel(membroId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Responsável atualizado.')));
    } catch (erro) {
      _mostrarErro(erro);
    }
  }

  Future<void> _salvarPerfil(
    EscalaConfiguracaoMembro item, {
    required bool ativo,
    required String carga,
  }) async {
    try {
      await _controller.salvarPerfil(
        membroEquipeId: item.membro.id,
        ativo: ativo,
        cargaHorariaCodigo: carga,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Perfil GEDUC atualizado.')));
    } catch (erro) {
      _mostrarErro(erro);
    }
  }

  void _mostrarErro(Object erro) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(erro.toString())));
  }
}

class _MembroConfiguracaoCard extends StatelessWidget {
  const _MembroConfiguracaoCard({
    super.key,
    required this.item,
    required this.responsavelAtual,
    required this.saving,
    required this.onAtivoChanged,
    required this.onCargaChanged,
  });

  final EscalaConfiguracaoMembro item;
  final bool responsavelAtual;
  final bool saving;
  final ValueChanged<bool> onAtivoChanged;
  final ValueChanged<String> onCargaChanged;

  @override
  Widget build(BuildContext context) {
    final membro = item.membro;
    final habilitado = membro.ativo && !saving;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compacto = constraints.maxWidth < 700;

              final identidade = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          membro.nome,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (responsavelAtual)
                        const Chip(label: Text('Responsável')),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${membro.vinculo.rotulo}'
                    '${membro.podeCoordenar ? ' • Pode coordenar' : ''}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    membro.usuarioId.trim().isEmpty
                        ? 'Sem UID canônico'
                        : 'UID canônico vinculado',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (!membro.ativo)
                    Text(
                      'Inativo na Equipe Operacional',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              );

              final controles = Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Ativo na escala'),
                      Switch(
                        key: ValueKey('perfil-ativo-${membro.id}'),
                        value: item.ativoNaEscala,
                        onChanged: habilitado ? onAtivoChanged : null,
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 150,
                    child: DropdownButtonFormField<String>(
                      key: ValueKey('carga-${membro.id}'),
                      initialValue: item.cargaHorariaCodigo,
                      decoration: const InputDecoration(
                        labelText: 'Carga horária',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        for (final carga
                            in EscalaConfiguracaoController.cargasHorarias)
                          DropdownMenuItem(value: carga, child: Text(carga)),
                      ],
                      onChanged: habilitado
                          ? (valor) {
                              if (valor != null) onCargaChanged(valor);
                            }
                          : null,
                    ),
                  ),
                ],
              );

              if (compacto) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [identidade, const SizedBox(height: 12), controles],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: identidade),
                  const SizedBox(width: 16),
                  controles,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MensagemEstado extends StatelessWidget {
  const _MensagemEstado({
    required this.icon,
    required this.titulo,
    required this.mensagem,
  });

  final IconData icon;
  final String titulo;
  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40),
                const SizedBox(height: 12),
                Text(
                  titulo,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(mensagem, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

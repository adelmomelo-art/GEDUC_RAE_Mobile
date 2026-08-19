import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/security/access_scope.dart';
import '../../core/security/authorization_service.dart';
import '../../core/security/rae_identity_resolver.dart';
import '../../core/security/rae_scope_resolver.dart';
import '../../core/services/equipe_operacional_service.dart';
import '../../core/services/rae_scope_catalog_service.dart';
import '../../data/models/equipe_model.dart';
import '../../data/models/membro_equipe_model.dart';
import '../../data/models/projeto_model.dart';
import '../../shared/widgets/journey/fenix_journey_header.dart';
import '../../shared/widgets/layout/fenix_app_bar.dart';
import '../acoes/controllers/acao_controller.dart';

class RecursosOperacionaisPage extends StatefulWidget {
  const RecursosOperacionaisPage({
    super.key,
    this.listarMembros,
    this.responsavelUserId,
    this.escopoAcesso,
    this.listarEquipes,
    this.listarProjetos,
  });

  final Future<List<MembroEquipeModel>> Function()? listarMembros;
  final String? responsavelUserId;
  final AccessScope? escopoAcesso;
  final Future<List<EquipeModel>> Function()? listarEquipes;
  final Future<List<ProjetoModel>> Function()? listarProjetos;

  @override
  State<RecursosOperacionaisPage> createState() =>
      _RecursosOperacionaisPageState();
}

class _RecursosOperacionaisPageState extends State<RecursosOperacionaisPage> {
  final Set<String> _agenteIds = <String>{};
  final Set<String> _terceirizadoIds = <String>{};
  final Map<String, String> _nomesPersistidos = <String, String>{};

  List<MembroEquipeModel> _membros = const <MembroEquipeModel>[];
  List<EquipeModel> _equipesAcl = const <EquipeModel>[];
  List<ProjetoModel> _projetosAcl = const <ProjetoModel>[];
  bool _catalogosAclProntos = false;

  String? _coordenadorMembroId;
  bool _coordenadorResolvidoPorFallbackNome = false;

  bool _carregandoEquipe = true;
  String? _erroEquipe;

  bool _registroLegadoSemNomes = false;
  int _agentesLegado = 0;
  int _terceirizadosLegado = 0;

  bool coberturaMidia = false;

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
      _agenteIds.addAll(acao.agenteEquipeIds);
      _terceirizadoIds.addAll(acao.terceirizadoEquipeIds);

      for (var i = 0;
          i < acao.agenteEquipeIds.length && i < acao.agenteEquipeNomes.length;
          i++) {
        _nomesPersistidos[acao.agenteEquipeIds[i]] = acao.agenteEquipeNomes[i];
      }

      for (var i = 0;
          i < acao.terceirizadoEquipeIds.length &&
              i < acao.terceirizadoEquipeNomes.length;
          i++) {
        _nomesPersistidos[acao.terceirizadoEquipeIds[i]] =
            acao.terceirizadoEquipeNomes[i];
      }

      _agentesLegado = acao.agentesTransito;
      _terceirizadosLegado = acao.equipeTerceirizada;

      _registroLegadoSemNomes = _agenteIds.isEmpty &&
          _terceirizadoIds.isEmpty &&
          (_agentesLegado + _terceirizadosLegado) > 0;

      coberturaMidia = acao.coberturaMidia;
      materialUtilizadoIds.addAll(acao.materialUtilizadoIds);
    }

    _carregarEquipe();
    _carregarCatalogosAcl();
  }

  Future<void> _carregarEquipe() async {
    final acao = context.read<AcaoController>().acaoAtual;

    try {
      final membros = await (widget.listarMembros?.call() ??
          EquipeOperacionalService().listarMembros());

      MembroEquipeModel? coordenador;
      var resolvidoPorFallbackNome = false;

      if (acao != null) {
        final candidatos = membros.where(
          (membro) =>
              membro.id == acao.coordenadorId ||
              membro.usuarioId == acao.coordenadorId,
        );

        if (candidatos.isNotEmpty) {
          coordenador = candidatos.first;
        } else {
          final nomeCoordenador = acao.coordenadorNome.trim().toLowerCase();

          if (nomeCoordenador.isNotEmpty) {
            final porNome = membros.where(
              (membro) => membro.nome.trim().toLowerCase() == nomeCoordenador,
            );

            if (porNome.length == 1) {
              coordenador = porNome.first;
              resolvidoPorFallbackNome = true;
            }
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _membros = membros;
        _coordenadorMembroId = coordenador?.id;
        _coordenadorResolvidoPorFallbackNome = resolvidoPorFallbackNome;
        _carregandoEquipe = false;
        _erroEquipe = null;

        if (!_registroLegadoSemNomes &&
            !_coordenadorResolvidoPorFallbackNome &&
            coordenador != null &&
            coordenador.ativo &&
            coordenador.podeCoordenar) {
          _selecionarObrigatorio(coordenador);
        }
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _carregandoEquipe = false;
        _erroEquipe = 'Não foi possível carregar a Equipe Operacional.';
      });
    }
  }

  Future<void> _carregarCatalogosAcl() async {
    try {
      final equipes = widget.listarEquipes != null
          ? await widget.listarEquipes!.call()
          : await RaeScopeCatalogService().listarEquipes();

      final projetos = widget.listarProjetos != null
          ? await widget.listarProjetos!.call()
          : await RaeScopeCatalogService().listarProjetos();

      if (!mounted) {
        return;
      }

      _equipesAcl = equipes;
      _projetosAcl = projetos;
      _catalogosAclProntos = true;
    } catch (_) {
      if (!mounted) {
        return;
      }

      _equipesAcl = const <EquipeModel>[];
      _projetosAcl = const <ProjetoModel>[];
      _catalogosAclProntos = false;
    }
  }

  String _resolverResponsavelUserId() {
    final injetado = widget.responsavelUserId?.trim() ?? '';

    if (injetado.isNotEmpty) {
      return injetado;
    }

    try {
      return context.read<AuthorizationService>().usuarioAtual?.id.trim() ?? '';
    } on ProviderNotFoundException {
      return '';
    }
  }

  AccessScope _resolverEscopoAcesso() {
    final injetado = widget.escopoAcesso;

    if (injetado != null) {
      return injetado;
    }

    try {
      return context.read<AuthorizationService>().escopoAtual;
    } on ProviderNotFoundException {
      return AccessScope();
    }
  }

  void _selecionarObrigatorio(MembroEquipeModel membro) {
    _agenteIds.remove(membro.id);
    _terceirizadoIds.remove(membro.id);

    if (membro.vinculo == VinculoOperacional.agente) {
      _agenteIds.add(membro.id);
    } else {
      _terceirizadoIds.add(membro.id);
    }

    _nomesPersistidos[membro.id] = membro.nome;
  }

  MembroEquipeModel? _membro(String id) {
    final encontrados = _membros.where((item) => item.id == id);
    return encontrados.isEmpty ? null : encontrados.first;
  }

  MembroEquipeModel? get _coordenadorMembro {
    final id = _coordenadorMembroId;

    if (id == null) {
      return null;
    }

    return _membro(id);
  }

  bool get _coordenadorVinculado {
    final coordenador = _coordenadorMembro;

    return coordenador != null &&
        !_coordenadorResolvidoPorFallbackNome &&
        coordenador.ativo &&
        coordenador.podeCoordenar;
  }

  String _nomeDo(String id) =>
      _membro(id)?.nome ?? _nomesPersistidos[id] ?? 'Membro $id';

  List<String> _nomesDos(Set<String> ids) =>
      ids.map(_nomeDo).toList(growable: false)..sort();

  int get _agentes =>
      _registroLegadoSemNomes ? _agentesLegado : _agenteIds.length;

  int get _terceirizados =>
      _registroLegadoSemNomes ? _terceirizadosLegado : _terceirizadoIds.length;

  int get _efetivoTotal => _agentes + _terceirizados;

  bool get _recursosCompletos =>
      _coordenadorVinculado &&
      _efetivoTotal > 0 &&
      materialUtilizadoIds.isNotEmpty;

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
    if (!_carregandoEquipe && !_coordenadorVinculado) {
      final coordenador = _coordenadorMembro;

      if (_coordenadorResolvidoPorFallbackNome) {
        return 'O coordenador foi localizado apenas pelo nome, sem vínculo '
            'canônico de identidade. Regularize a Equipe Operacional antes '
            'de avançar.';
      }

      if (coordenador != null && !coordenador.ativo) {
        return 'O coordenador vinculado está inativo na Equipe Operacional. '
            'Regularize a situação administrativa antes de avançar.';
      }

      if (coordenador != null && !coordenador.podeCoordenar) {
        return 'O membro vinculado como coordenador não está habilitado para '
            'coordenar. Regularize a Equipe Operacional antes de avançar.';
      }

      return 'O coordenador não está vinculado à Equipe Operacional. '
          'Atualize a fundação administrativa antes de avançar.';
    }

    if (_efetivoTotal == 0 && materialUtilizadoIds.isEmpty) {
      return 'Informe a equipe mobilizada e selecione os materiais '
          'efetivamente utilizados.';
    }

    if (_efetivoTotal == 0) {
      return 'Nenhum profissional foi informado para a realização da ação.';
    }

    if (materialUtilizadoIds.isEmpty) {
      return 'Selecione pelo menos um material utilizado na ação.';
    }

    return 'Os recursos operacionais foram preenchidos. '
        'Revise o resumo antes de avançar.';
  }

  void _persistirNoController() {
    final agentesIds = _agenteIds.toList(growable: false)
      ..sort((a, b) => _nomeDo(a).compareTo(_nomeDo(b)));

    final terceirizadosIds = _terceirizadoIds.toList(growable: false)
      ..sort((a, b) => _nomeDo(a).compareTo(_nomeDo(b)));

    final controller = context.read<AcaoController>();

    controller.preencherRecursosOperacionais(
      agentesTransito: _agentes,
      equipeTerceirizada: _terceirizados,
      agenteEquipeIds: _registroLegadoSemNomes ? const <String>[] : agentesIds,
      agenteEquipeNomes: _registroLegadoSemNomes
          ? const <String>[]
          : agentesIds.map(_nomeDo).toList(growable: false),
      terceirizadoEquipeIds:
          _registroLegadoSemNomes ? const <String>[] : terceirizadosIds,
      terceirizadoEquipeNomes: _registroLegadoSemNomes
          ? const <String>[]
          : terceirizadosIds.map(_nomeDo).toList(growable: false),
      materialUtilizadoIds: materialUtilizadoIds.toList(),
      coberturaMidia: coberturaMidia,
    );

    String coordenadorUserIdResolvido = '';

    if (_coordenadorVinculado) {
      final coordenador = _coordenadorMembro;

      if (coordenador != null) {
        final identidade = RaeIdentityResolver.resolve(
          responsavelUserId: _resolverResponsavelUserId(),
          coordenadorId: coordenador.id,
          membros: _membros,
        );

        coordenadorUserIdResolvido = identidade.coordenadorUserId;

        if (identidade.completa) {
          controller.vincularIdentidadeAcl(
            responsavelUserId: identidade.responsavelUserId,
            coordenadorUserId: identidade.coordenadorUserId,
          );
        }
      }
    }

    if (!_catalogosAclProntos) {
      return;
    }

    final acao = controller.acaoAtual;

    if (acao == null) {
      return;
    }

    final escopo = _resolverEscopoAcesso();

    final resolucao = RaeScopeResolver.resolve(
      regionalId: acao.regionalId,
      coordenadorUserId: coordenadorUserIdResolvido,
      equipeIdsPermitidas: escopo.equipeIds,
      projetoIdsPermitidos: escopo.projetoIds,
      equipes: _equipesAcl,
      projetos: _projetosAcl,
    );

    controller.vincularEscopoAcl(
      equipeId: resolucao.resolvido ? resolucao.equipeId : '',
      projetoId: resolucao.resolvido ? resolucao.projetoId : '',
    );
  }

  void _voltar() {
    FocusScope.of(context).unfocus();
    _persistirNoController();
    context.go('/caracterizacao-acao');
  }

  void _salvarEAvancar() {
    FocusScope.of(context).unfocus();

    if (!_coordenadorVinculado) {
      _mostrarErro(
        'Vincule o coordenador à Equipe Operacional antes de avançar.',
      );
      return;
    }

    if (_efetivoTotal == 0) {
      _mostrarErro(
        'Selecione ao menos uma pessoa da Equipe Operacional.',
      );
      return;
    }

    if (materialUtilizadoIds.isEmpty) {
      _mostrarErro(
        'Selecione ao menos um material utilizado.',
      );
      return;
    }

    _persistirNoController();
    context.go('/integracao-observacoes');
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensagem),
        ),
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

  Future<bool> _confirmarMigracaoRegistroLegado() async {
    if (!_registroLegadoSemNomes) {
      return true;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Atualizar equipe histórica?',
        ),
        content: Text(
          'Este registro possui $_agentesLegado agente(s) e '
          '$_terceirizadosLegado terceirizado(s) registrados apenas por '
          'quantidade, sem identificação nominal.\n\n'
          'Ao continuar, os quantitativos históricos serão substituídos '
          'pelos participantes nominalmente selecionados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              false,
            ),
            child: const Text(
              'CANCELAR',
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              true,
            ),
            child: const Text(
              'CONTINUAR',
            ),
          ),
        ],
      ),
    );

    return confirmar == true;
  }

  Future<void> _abrirSeletor(VinculoOperacional vinculo) async {
    final selecionados = Set<String>.from(
      vinculo == VinculoOperacional.agente ? _agenteIds : _terceirizadoIds,
    );

    final pesquisaController = TextEditingController();

    final resultado = await showDialog<Set<String>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final termo = pesquisaController.text.trim().toLowerCase();

          final disponiveis = _membros.where((membro) {
            return membro.vinculo == vinculo &&
                (membro.ativo || selecionados.contains(membro.id)) &&
                (termo.isEmpty || membro.nome.toLowerCase().contains(termo));
          }).toList(growable: false);

          return AlertDialog(
            title: Text(
              'Selecionar ${vinculo.rotulo.toLowerCase()}s',
            ),
            content: SizedBox(
              width: 520,
              height: 480,
              child: Column(
                children: [
                  TextField(
                    controller: pesquisaController,
                    onChanged: (_) => setDialogState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Pesquisar por nome',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: disponiveis.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhum membro disponível.',
                            ),
                          )
                        : ListView.builder(
                            itemCount: disponiveis.length,
                            itemBuilder: (context, index) {
                              final membro = disponiveis[index];

                              final coordenador =
                                  membro.id == _coordenadorMembroId &&
                                      !_coordenadorResolvidoPorFallbackNome &&
                                      membro.ativo &&
                                      membro.podeCoordenar;

                              return CheckboxListTile(
                                value: selecionados.contains(membro.id),
                                onChanged: coordenador
                                    ? null
                                    : (marcado) => setDialogState(() {
                                          if (marcado == true) {
                                            selecionados.add(membro.id);
                                          } else {
                                            selecionados.remove(membro.id);
                                          }
                                        }),
                                title: Text(membro.nome),
                                subtitle: Text(
                                  [
                                    membro.vinculo.rotulo,
                                    if (coordenador) 'Coordenador',
                                    if (!membro.ativo) 'Inativo',
                                  ].join(' • '),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(
                  dialogContext,
                ),
                child: const Text(
                  'CANCELAR',
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(
                  dialogContext,
                  selecionados,
                ),
                child: const Text(
                  'CONFIRMAR',
                ),
              ),
            ],
          );
        },
      ),
    );

    pesquisaController.dispose();

    if (resultado == null || !mounted) {
      return;
    }

    if (_registroLegadoSemNomes) {
      final confirmouMigracao = await _confirmarMigracaoRegistroLegado();

      if (!confirmouMigracao || !mounted) {
        return;
      }
    }

    setState(() {
      _registroLegadoSemNomes = false;

      final destino =
          vinculo == VinculoOperacional.agente ? _agenteIds : _terceirizadoIds;

      destino
        ..clear()
        ..addAll(resultado);

      for (final id in resultado) {
        final membro = _membro(id);

        if (membro != null) {
          _nomesPersistidos[id] = membro.nome;
        }
      }

      final coordenador = _coordenadorMembro;

      if (coordenador != null &&
          !_coordenadorResolvidoPorFallbackNome &&
          coordenador.ativo &&
          coordenador.podeCoordenar) {
        _selecionarObrigatorio(coordenador);
      }
    });
  }

  Widget _seletorEquipe({
    required VinculoOperacional vinculo,
    required IconData icone,
  }) {
    final ids =
        vinculo == VinculoOperacional.agente ? _agenteIds : _terceirizadoIds;

    final nomes = _nomesDos(ids);

    final quantidade =
        vinculo == VinculoOperacional.agente ? _agentes : _terceirizados;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${vinculo.rotulo}s ($quantidade)',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _carregandoEquipe || _erroEquipe != null
                    ? null
                    : () => _abrirSeletor(vinculo),
                icon: const Icon(
                  Icons.person_add_alt_1,
                ),
                label: const Text(
                  'Selecionar',
                ),
              ),
            ],
          ),
          if (_registroLegadoSemNomes && quantidade > 0) ...[
            const SizedBox(height: 8),
            Text(
              '$quantidade participante(s) sem identificação nominal '
              '(registro anterior).',
            ),
          ] else if (nomes.isEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Nenhuma pessoa selecionada.',
            ),
          ] else ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: nomes
                  .map(
                    (nome) => Chip(
                      label: Text(nome),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _painelFaxita() {
    final theme = Theme.of(context);
    final status = _statusPreenchimento;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(
          alpha: 0.42,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(
            alpha: 0.28,
          ),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            child: const Icon(
              Icons.auto_awesome,
            ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
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

  Widget _seletorMateriais() {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: materiais.entries.map((entry) {
        final selecionado = materialUtilizadoIds.contains(
          entry.key,
        );

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
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
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
          Expanded(
            child: Text(titulo),
          ),
          const SizedBox(width: 12),
          Text(
            valor,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
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
        padding: const EdgeInsets.fromLTRB(
          16,
          10,
          16,
          12,
        ),
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
                icon: const Icon(
                  Icons.arrow_back,
                ),
                label: const Text(
                  'Voltar',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: _salvarEAvancar,
                icon: const Icon(
                  Icons.arrow_forward,
                ),
                label: const Text(
                  'Confirmar e avançar',
                ),
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
        appBar: FenixAppBar(
          title: 'Recursos Operacionais',
          onBack: _voltar,
        ),
        bottomNavigationBar: _barraInferior(),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            120,
          ),
          children: [
            const FenixJourneyHeader(
              step: 4,
              totalSteps: 9,
              title: 'Recursos Operacionais',
              subtitle:
                  'Registre equipe, materiais e apoio mobilizados na ação.',
              icon: Icons.groups_2_outlined,
            ),
            const SizedBox(height: 16),
            _painelFaxita(),
            const SizedBox(height: 16),
            _cardSecao(
              titulo: 'Equipe envolvida',
              icone: Icons.groups_2_outlined,
              subtitulo:
                  'Selecione nominalmente agentes e terceirizados mobilizados.',
              children: [
                if (_carregandoEquipe)
                  const LinearProgressIndicator()
                else if (_erroEquipe != null)
                  ListTile(
                    leading: const Icon(
                      Icons.error_outline,
                    ),
                    title: Text(
                      _erroEquipe!,
                    ),
                    trailing: TextButton(
                      onPressed: () {
                        setState(() {
                          _carregandoEquipe = true;
                          _erroEquipe = null;
                        });

                        _carregarEquipe();
                      },
                      child: const Text(
                        'TENTAR NOVAMENTE',
                      ),
                    ),
                  ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    child: Icon(
                      Icons.supervisor_account_outlined,
                    ),
                  ),
                  title: const Text(
                    'Coordenador da ação',
                  ),
                  subtitle: Text(
                    context.read<AcaoController>().acaoAtual?.coordenadorNome ??
                        'Não informado',
                  ),
                  trailing: const Chip(
                    label: Text(
                      'Obrigatório',
                    ),
                  ),
                ),
                if (!_carregandoEquipe && !_coordenadorVinculado)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: Text(
                      _coordenadorResolvidoPorFallbackNome
                          ? 'O coordenador foi localizado apenas pelo nome. '
                              'Regularize o vínculo de identidade na Equipe '
                              'Operacional antes de avançar.'
                          : _coordenadorMembro == null
                              ? 'Coordenador não encontrado na Equipe '
                                  'Operacional. Use Administração > Equipe '
                                  'Operacional para sincronizar.'
                              : !_coordenadorMembro!.ativo
                                  ? 'O coordenador está inativo na Equipe '
                                      'Operacional. Regularize a situação '
                                      'administrativa antes de avançar.'
                                  : 'O membro vinculado como coordenador não '
                                      'está habilitado para coordenar. '
                                      'Regularize a Equipe Operacional antes '
                                      'de avançar.',
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                _seletorEquipe(
                  vinculo: VinculoOperacional.agente,
                  icone: Icons.badge_outlined,
                ),
                const SizedBox(height: 16),
                _seletorEquipe(
                  vinculo: VinculoOperacional.terceirizado,
                  icone: Icons.groups_outlined,
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withValues(
                      alpha: 0.55,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.people_alt_outlined,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Efetivo total mobilizado',
                        ),
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
                  'Selecione somente os materiais efetivamente utilizados '
                  'na ação.',
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
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
                  'Considere imprensa, televisão, rádio, redes sociais ou '
                  'cobertura institucional.',
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: coberturaMidia,
                  title: const Text(
                    'Houve cobertura de mídia?',
                  ),
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

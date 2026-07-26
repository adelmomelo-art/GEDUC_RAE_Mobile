import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'controllers/acao_controller.dart';

class CaracterizacaoAcaoPage extends StatefulWidget {
  const CaracterizacaoAcaoPage({super.key});

  @override
  State<CaracterizacaoAcaoPage> createState() =>
      _CaracterizacaoAcaoPageState();
}

class _CaracterizacaoAcaoPageState extends State<CaracterizacaoAcaoPage> {
  String? formacaoId;
  String? publicoId;
  String? sexoPredominanteId;
  String? mudancaComportamentoId;

  final instituicaoParceiraController = TextEditingController();

  final tipoParticipacaoIds = <String>{};
  final focoTematicoIds = <String>{};
  final perfilUsuarioIds = <String>{};
  final fatorRiscoIds = <String>{};

  bool _restaurandoDados = true;

  final formacoes = const {
    'formacao_palestra': 'Palestra',
    'formacao_oficina': 'Oficina',
    'formacao_curso': 'Curso',
  };

  final publicos = const {
    'publico_interno': 'Público interno',
    'publico_externo': 'Público externo',
    'publico_misto': 'Público interno e externo',
  };

  final sexos = const {
    'sexo_feminino': 'Predominantemente feminino',
    'sexo_masculino': 'Predominantemente masculino',
    'sexo_misto': 'Público misto/equilibrado',
    'sexo_nao_identificado': 'Não foi possível identificar',
  };

  final mudancas = const {
    'mudanca_sim': 'Sim',
    'mudanca_parcial': 'Parcialmente',
    'mudanca_nao': 'Não observada',
  };

  final tiposParticipacao = const {
    'participacao_presencial': 'Presencial',
    'participacao_abordagem': 'Abordagem educativa',
    'participacao_evento': 'Evento',
  };

  final focosTematicos = const {
    'tema_velocidade': 'Velocidade',
    'tema_alcool_direcao': 'Álcool e direção',
    'tema_capacete': 'Uso do capacete',
    'tema_cinto': 'Uso do cinto de segurança',
    'tema_celular': 'Uso do celular ao volante',
  };

  final perfisUsuario = const {
    'perfil_crianca': 'Crianças',
    'perfil_adolescente': 'Adolescentes',
    'perfil_adulto': 'Adultos',
    'perfil_idoso': 'Pessoas idosas',
    'perfil_estudante': 'Estudantes',
    'perfil_servidor': 'Servidores públicos',
    'perfil_trabalhador': 'Trabalhadores',
    'perfil_pedestre': 'Pedestres',
    'perfil_ciclista': 'Ciclistas',
    'perfil_motociclista': 'Motociclistas',
    'perfil_condutor': 'Condutores',
    'perfil_passageiro': 'Passageiros',
    'perfil_pcd': 'Pessoas com deficiência',
    'perfil_profissional_transito': 'Profissionais do trânsito',
    'perfil_comunidade': 'Comunidade em geral',
  };

  final fatoresRisco = const {
    'risco_velocidade': 'Excesso de velocidade',
    'risco_celular': 'Uso do celular',
    'risco_capacete': 'Não utilização do capacete',
    'risco_cinto': 'Não utilização do cinto',
    'risco_alcool': 'Álcool e direção',
  };

  bool get _camposObrigatoriosPreenchidos {
    return formacaoId != null &&
        publicoId != null &&
        sexoPredominanteId != null &&
        mudancaComportamentoId != null &&
        tipoParticipacaoIds.isNotEmpty &&
        focoTematicoIds.isNotEmpty &&
        perfilUsuarioIds.isNotEmpty &&
        fatorRiscoIds.isNotEmpty;
  }


  String? _normalizarPublicoLegado(String valor) {
    switch (valor) {
      case 'publico_criancas':
        perfilUsuarioIds.add('perfil_crianca');
        return null;
      case 'publico_adolescentes':
        perfilUsuarioIds.add('perfil_adolescente');
        return null;
      case 'publico_adultos':
        perfilUsuarioIds.add('perfil_adulto');
        return null;
      case 'publico_idosos':
        perfilUsuarioIds.add('perfil_idoso');
        return null;
      default:
        return publicos.containsKey(valor) ? valor : null;
    }
  }

  String get _resumoPublicoSelecionado {
    final tipo = publicoId == null ? null : publicos[publicoId];
    final perfis = perfilUsuarioIds
        .map((id) => perfisUsuario[id])
        .whereType<String>()
        .toList();

    if (tipo == null && perfis.isEmpty) {
      return 'Informe se o público é interno, externo ou misto e selecione '
          'ao menos um perfil de usuário.';
    }

    if (tipo != null && perfis.isEmpty) {
      return '$tipo selecionado. Agora identifique os perfis atendidos.';
    }

    final quantidade = perfis.length;
    final descricaoPerfis =
        quantidade == 1 ? perfis.first : '$quantidade perfis selecionados';

    return '${tipo ?? 'Tipo de público pendente'} • $descricaoPerfis';
  }

  @override
  void initState() {
    super.initState();
    _restaurarRascunho();
    instituicaoParceiraController.addListener(_aoAlterarInstituicao);
  }

  void _restaurarRascunho() {
    final acao = context.read<AcaoController>().acaoAtual;

    if (acao != null) {
      formacaoId = acao.formacaoId.isEmpty ? null : acao.formacaoId;
      publicoId = _normalizarPublicoLegado(acao.publicoId);
      sexoPredominanteId =
          acao.sexoPredominanteId.isEmpty ? null : acao.sexoPredominanteId;
      mudancaComportamentoId = acao.mudancaComportamentoId.isEmpty
          ? null
          : acao.mudancaComportamentoId;

      tipoParticipacaoIds.addAll(acao.tipoParticipacaoIds);
      focoTematicoIds.addAll(acao.focoTematicoIds);
      perfilUsuarioIds.addAll(acao.perfilUsuarioIds);
      fatorRiscoIds.addAll(acao.fatorRiscoIds);
      instituicaoParceiraController.text = acao.instituicaoParceira;
    }

    _restaurandoDados = false;
  }

  @override
  void dispose() {
    instituicaoParceiraController.removeListener(_aoAlterarInstituicao);
    instituicaoParceiraController.dispose();
    super.dispose();
  }

  void _aoAlterarInstituicao() {
    if (!_restaurandoDados) {
      _persistirRascunho();
    }
  }

  void _persistirRascunho() {
    context.read<AcaoController>().preencherCaracterizacao(
          fatorRiscoIds: fatorRiscoIds.toList(),
          mudancaComportamentoId: mudancaComportamentoId ?? '',
          formacaoId: formacaoId ?? '',
          publicoId: publicoId ?? '',
          tipoParticipacaoIds: tipoParticipacaoIds.toList(),
          focoTematicoIds: focoTematicoIds.toList(),
          perfilUsuarioIds: perfilUsuarioIds.toList(),
          sexoPredominanteId: sexoPredominanteId ?? '',
          instituicaoParceira: instituicaoParceiraController.text.trim(),
        );
  }

  void _atualizar(VoidCallback alteracao) {
    setState(alteracao);
    _persistirRascunho();
  }

  void _voltar() {
    _persistirRascunho();
    context.go('/localizacao');
  }

  void _salvarEAvancar() {
    if (!_camposObrigatoriosPreenchidos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A Faxita identificou campos obrigatórios ainda não preenchidos.',
          ),
        ),
      );
      return;
    }

    _persistirRascunho();
    context.go('/recursos-operacionais');
  }

  Widget _faxitaCard() {
    final concluido = _camposObrigatoriosPreenchidos;
    final corFundo = concluido
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFFFF8E1);
    final corBorda = concluido
        ? const Color(0xFF2E7D32)
        : const Color(0xFFF9A825);
    final icone = concluido
        ? Icons.check_circle_outline
        : Icons.info_outline;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: corBorda, width: 1.4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: corBorda,
            foregroundColor: Colors.white,
            child: Icon(icone),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Faxita',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  concluido
                      ? 'Caracterização preenchida. Os dados obrigatórios estão completos e você já pode avançar.'
                      : 'Vamos caracterizar a ação educativa. Os campos identificados com * são obrigatórios. Preencha a formação, o público, os temas, os riscos e a avaliação comportamental.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _secao({
    required String titulo,
    required String descricao,
    required IconData icone,
    required List<Widget> filhos,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icone,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        descricao,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ...filhos,
          ],
        ),
      ),
    );
  }

  Widget _rotuloObrigatorio(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          text: texto,
          style: const TextStyle(fontWeight: FontWeight.w700),
          children: [
            TextSpan(
              text: ' *',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required Map<String, String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: '$label *',
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: options.entries
          .map(
            (entry) => DropdownMenuItem<String>(
              value: entry.key,
              child: Text(
                entry.value,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _checkboxGroup({
    required Map<String, String> options,
    required Set<String> selected,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final duasColunas = constraints.maxWidth >= 700;
        final largura = duasColunas
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 8,
          children: options.entries.map((entry) {
            final marcado = selected.contains(entry.key);

            return SizedBox(
              width: largura,
              child: Material(
                color: marcado
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                child: CheckboxListTile(
                  value: marcado,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  title: Text(entry.value),
                  onChanged: (value) {
                    _atualizar(() {
                      if (value == true) {
                        selected.add(entry.key);
                      } else {
                        selected.remove(entry.key);
                      }
                    });
                  },
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _campoInstituicaoParceira() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Instituição ou empresa parceira',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Campo opcional',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: instituicaoParceiraController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Ex.: PM, GMF, DETRAN, Honda',
            prefixIcon: Icon(Icons.handshake_outlined),
            border: OutlineInputBorder(),
          ),
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _voltar();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Caracterização da Ação'),
        ),
        bottomNavigationBar: _barraInferior(),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _faxitaCard(),
              const SizedBox(height: 12),
              _secao(
                titulo: 'Dados institucionais da ação',
                descricao:
                    'Defina o formato da atividade e a forma de participação.',
                icone: Icons.account_balance_outlined,
                filhos: [
                  _dropdown(
                    label: 'Formação',
                    value: formacaoId,
                    options: formacoes,
                    onChanged: (value) =>
                        _atualizar(() => formacaoId = value),
                  ),
                  const SizedBox(height: 16),
                  _rotuloObrigatorio('Tipo de participação'),
                  _checkboxGroup(
                    options: tiposParticipacao,
                    selected: tipoParticipacaoIds,
                  ),
                  const SizedBox(height: 18),
                  _campoInstituicaoParceira(),
                ],
              ),
              _secao(
                titulo: 'Público-alvo',
                descricao:
                    'Identifique a origem institucional e os perfis atendidos.',
                icone: Icons.groups_outlined,
                filhos: [
                  _dropdown(
                    label: 'Público',
                    value: publicoId,
                    options: publicos,
                    onChanged: (value) =>
                        _atualizar(() => publicoId = value),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Considere como público interno os servidores e equipes '
                    'do próprio órgão. Público externo corresponde à '
                    'comunidade e às instituições atendidas.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 18),
                  _rotuloObrigatorio('Perfil do usuário'),
                  _checkboxGroup(
                    options: perfisUsuario,
                    selected: perfilUsuarioIds,
                  ),
                  const SizedBox(height: 18),
                  _dropdown(
                    label: 'Sexo predominante',
                    value: sexoPredominanteId,
                    options: sexos,
                    onChanged: (value) =>
                        _atualizar(() => sexoPredominanteId = value),
                  ),
                  const SizedBox(height: 14),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.summarize_outlined, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(_resumoPublicoSelecionado),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              _secao(
                titulo: 'Temas e fatores de risco',
                descricao:
                    'Identifique os conteúdos trabalhados e os riscos observados.',
                icone: Icons.health_and_safety_outlined,
                filhos: [
                  _rotuloObrigatorio('Foco temático'),
                  _checkboxGroup(
                    options: focosTematicos,
                    selected: focoTematicoIds,
                  ),
                  const SizedBox(height: 16),
                  _rotuloObrigatorio('Principais fatores de risco observados'),
                  _checkboxGroup(
                    options: fatoresRisco,
                    selected: fatorRiscoIds,
                  ),
                ],
              ),
              _secao(
                titulo: 'Avaliação comportamental',
                descricao:
                    'Registre se houve mudança de comportamento observável.',
                icone: Icons.psychology_alt_outlined,
                filhos: [
                  _dropdown(
                    label: 'Houve mudança de comportamento observável?',
                    value: mudancaComportamentoId,
                    options: mudancas,
                    onChanged: (value) =>
                        _atualizar(() => mudancaComportamentoId = value),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

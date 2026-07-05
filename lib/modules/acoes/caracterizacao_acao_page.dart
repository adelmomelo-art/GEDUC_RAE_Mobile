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

  final formacoes = const {
    'formacao_palestra': 'Palestra',
    'formacao_oficina': 'Oficina',
    'formacao_curso': 'Curso',
  };

  final publicos = const {
    'publico_criancas': 'Crianças',
    'publico_adolescentes': 'Adolescentes',
    'publico_adultos': 'Adultos',
    'publico_idosos': 'Idosos',
  };

  final sexos = const {
    'sexo_feminino': 'Feminino',
    'sexo_masculino': 'Masculino',
    'sexo_misto': 'Misto',
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
    'perfil_pedestre': 'Pedestre',
    'perfil_ciclista': 'Ciclista',
    'perfil_motociclista': 'Motociclista',
    'perfil_condutor': 'Condutor',
    'perfil_passageiro': 'Passageiro',
  };

  final fatoresRisco = const {
    'risco_velocidade': 'Excesso de velocidade',
    'risco_celular': 'Uso do celular',
    'risco_capacete': 'Não utilização do capacete',
    'risco_cinto': 'Não utilização do cinto',
    'risco_alcool': 'Álcool e direção',
  };

  @override
  void initState() {
    super.initState();

    final acao = context.read<AcaoController>().acaoAtual;

    if (acao == null) return;

    formacaoId = acao.formacaoId.isEmpty ? null : acao.formacaoId;
    publicoId = acao.publicoId.isEmpty ? null : acao.publicoId;
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

  @override
  void dispose() {
    instituicaoParceiraController.dispose();
    super.dispose();
  }

  void salvar() {
    if (formacaoId == null ||
        publicoId == null ||
        sexoPredominanteId == null ||
        mudancaComportamentoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha os campos obrigatórios.'),
        ),
      );
      return;
    }

    if (tipoParticipacaoIds.isEmpty ||
        focoTematicoIds.isEmpty ||
        perfilUsuarioIds.isEmpty ||
        fatorRiscoIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione ao menos uma opção em cada bloco.'),
        ),
      );
      return;
    }

    context.read<AcaoController>().preencherCaracterizacao(
          fatorRiscoIds: fatorRiscoIds.toList(),
          mudancaComportamentoId: mudancaComportamentoId!,
          formacaoId: formacaoId!,
          publicoId: publicoId!,
          tipoParticipacaoIds: tipoParticipacaoIds.toList(),
          focoTematicoIds: focoTematicoIds.toList(),
          perfilUsuarioIds: perfilUsuarioIds.toList(),
          sexoPredominanteId: sexoPredominanteId!,
          instituicaoParceira: instituicaoParceiraController.text.trim(),
        );

    context.go('/recursos-operacionais');
  }

  Widget _secao(String titulo, List<Widget> filhos) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...filhos,
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
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: options.entries
          .map(
            (entry) => DropdownMenuItem(
              value: entry.key,
              child: Text(entry.value),
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
    return Column(
      children: options.entries.map((entry) {
        return CheckboxListTile(
          value: selected.contains(entry.key),
          title: Text(entry.value),
          onChanged: (value) {
            setState(() {
              if (value == true) {
                selected.add(entry.key);
              } else {
                selected.remove(entry.key);
              }
            });
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caracterização da Ação'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _secao(
            'Contexto da ação',
            [
              _dropdown(
                label: 'Formação',
                value: formacaoId,
                options: formacoes,
                onChanged: (value) => setState(() => formacaoId = value),
              ),
              const SizedBox(height: 16),
              _dropdown(
                label: 'Público',
                value: publicoId,
                options: publicos,
                onChanged: (value) => setState(() => publicoId = value),
              ),
              const SizedBox(height: 16),
              const Text('Tipo de participação'),
              _checkboxGroup(
                options: tiposParticipacao,
                selected: tipoParticipacaoIds,
              ),
            ],
          ),
          _secao(
            'Perfil do público',
            [
              const Text('Perfil do usuário'),
              _checkboxGroup(
                options: perfisUsuario,
                selected: perfilUsuarioIds,
              ),
              const SizedBox(height: 16),
              _dropdown(
                label: 'Sexo predominante',
                value: sexoPredominanteId,
                options: sexos,
                onChanged: (value) =>
                    setState(() => sexoPredominanteId = value),
              ),
            ],
          ),
          _secao(
            'Tema e riscos observados',
            [
              const Text('Foco temático'),
              _checkboxGroup(
                options: focosTematicos,
                selected: focoTematicoIds,
              ),
              const SizedBox(height: 16),
              const Text('Principais fatores de risco observados'),
              _checkboxGroup(
                options: fatoresRisco,
                selected: fatorRiscoIds,
              ),
            ],
          ),
          _secao(
            'Avaliação comportamental',
            [
              _dropdown(
                label: 'Houve mudança de comportamento observável?',
                value: mudancaComportamentoId,
                options: mudancas,
                onChanged: (value) =>
                    setState(() => mudancaComportamentoId = value),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: instituicaoParceiraController,
                decoration: const InputDecoration(
                  labelText: 'Instituição ou empresa parceira',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: const Text('SALVAR E AVANÇAR'),
              onPressed: salvar,
            ),
          ),
        ],
      ),
    );
  }
}

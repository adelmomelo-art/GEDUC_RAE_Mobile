import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../controllers/escala_execucao_controller.dart';
import '../data/escala_execucao_repository.dart';
import '../data/firestore_escala_execucao_repository.dart';
import '../models/escala_models.dart';

/// Execução individual de uma missão administrativa de uma escala publicada.
class EscalaExecucaoMissaoPage extends StatefulWidget {
  const EscalaExecucaoMissaoPage({
    super.key,
    required this.atividadeId,
    required this.usuarioId,
    required this.perfilAcesso,
    this.repository,
  });

  final String atividadeId;
  final String usuarioId;
  final String perfilAcesso;
  final EscalaExecucaoRepository? repository;

  @override
  State<EscalaExecucaoMissaoPage> createState() =>
      _EscalaExecucaoMissaoPageState();
}

class _EscalaExecucaoMissaoPageState extends State<EscalaExecucaoMissaoPage> {
  late final EscalaExecucaoController _controller;
  final TextEditingController _resultado = TextEditingController();
  final TextEditingController _observacao = TextEditingController();
  bool _camposCarregados = false;

  @override
  void initState() {
    super.initState();
    _controller = EscalaExecucaoController(
      repository: widget.repository ?? FirestoreEscalaExecucaoRepository(),
      atividadeId: widget.atividadeId,
      usuarioId: widget.usuarioId,
      perfilAcesso: widget.perfilAcesso,
    )..addListener(_atualizar);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _carregar();
    });
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_atualizar)
      ..dispose();
    _resultado.dispose();
    _observacao.dispose();
    super.dispose();
  }

  void _atualizar() {
    if (mounted) setState(() {});
  }

  Future<void> _carregar() async {
    await _controller.carregar();
    if (!mounted) return;
    if (_controller.contexto != null) _sincronizarCampos();
  }

  void _sincronizarCampos() {
    _resultado.text = _controller.execucao?.resultadoResumo ?? '';
    _observacao.text = _controller.execucao?.observacao ?? '';
    setState(() => _camposCarregados = true);
  }

  Future<void> _executar(Future<void> Function() operacao) async {
    try {
      await operacao();
      if (mounted) setState(() {});
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível registrar a execução: $erro')),
      );
    }
  }

  Future<bool> _confirmar(String titulo, String mensagem) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(titulo),
            content: Text(mensagem),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Voltar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirmar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _concluir() async {
    if (_resultado.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o resultado/entrega da missão.')),
      );
      return;
    }
    if (!await _confirmar(
      'Concluir missão?',
      'A execução ficará encerrada e não poderá ser alterada.',
    )) {
      return;
    }
    if (!mounted) return;
    await _executar(() => _controller.concluir(
          resultadoResumo: _resultado.text,
          observacao: _observacao.text,
        ));
  }

  Future<void> _cancelar() async {
    if (!await _confirmar(
      'Cancelar missão?',
      'A execução ficará encerrada. O resultado ainda não salvo não será registrado.',
    )) {
      return;
    }
    if (!mounted) return;
    await _executar(() => _controller.cancelar(observacao: _observacao.text));
    if (mounted && _controller.terminal) _sincronizarCampos();
  }

  @override
  Widget build(BuildContext context) {
    final carregando = _controller.carregando || !_camposCarregados;
    final atividade = _controller.atividade;
    final execucao = _controller.execucao;
    final editavel = _controller.podeEditar && !_controller.salvando;

    return Scaffold(
      appBar: AppBar(title: const Text('Execução da Missão')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                if (_controller.salvando) const LinearProgressIndicator(),
                if (carregando && _controller.erro == null)
                  const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_controller.erro != null && atividade == null)
                  _aviso(
                    'Não foi possível abrir a missão. Verifique o acesso e tente novamente.',
                    acao: TextButton(
                      onPressed: _controller.carregando ? null : _carregar,
                      child: const Text('Tentar novamente'),
                    ),
                  )
                else if (atividade != null) ...[
                  Text(
                    'MISSÃO ADMINISTRATIVA',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    atividade.titulo.trim().isEmpty
                        ? 'Atividade sem título'
                        : atividade.titulo.trim(),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  _informacao(
                      'Data', DateFormat('dd/MM/yyyy').format(atividade.data)),
                  _informacao(
                      'Equipe', '${_controller.equipe.length} agente(s)'),
                  _informacao('Executor', _controller.contexto!.executor.nome),
                  if (atividade.orientacaoOperacional.trim().isNotEmpty)
                    _informacao('Orientação', atividade.orientacaoOperacional),
                  const SizedBox(height: 16),
                  _informacao('Status', _status(execucao)),
                  if (!_controller.podeExecutar)
                    _aviso('Você não pode registrar a execução desta missão.')
                  else if (execucao == null)
                    FilledButton.icon(
                      key: const ValueKey('missao-iniciar'),
                      onPressed: _controller.salvando
                          ? null
                          : () => _executar(() async {
                                await _controller.iniciar();
                                if (mounted) _sincronizarCampos();
                              }),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Iniciar missão'),
                    )
                  else ...[
                    const SizedBox(height: 12),
                    TextField(
                      key: const ValueKey('missao-resultado'),
                      controller: _resultado,
                      enabled: editavel,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Resultado / Entrega',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const ValueKey('missao-observacao'),
                      controller: _observacao,
                      enabled: editavel,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Observação (opcional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _informacao('Evidências registradas',
                        '${execucao.evidencias.length}'),
                    if (execucao.evidencias.isNotEmpty)
                      for (final evidencia in execucao.evidencias)
                        ListTile(
                          title: Text(evidencia.descricao.trim().isEmpty
                              ? evidencia.tipo
                              : evidencia.descricao),
                          subtitle: Text(evidencia.tipo),
                        ),
                    if (editavel) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            key: const ValueKey('missao-salvar'),
                            onPressed: () => _executar(
                                () => _controller.salvarResultadoObservacao(
                                      resultadoResumo: _resultado.text,
                                      observacao: _observacao.text,
                                    )),
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('Salvar andamento'),
                          ),
                          FilledButton.icon(
                            key: const ValueKey('missao-concluir'),
                            onPressed: _concluir,
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('Concluir missão'),
                          ),
                          TextButton(
                            key: const ValueKey('missao-cancelar'),
                            onPressed: _cancelar,
                            child: const Text('Cancelar missão'),
                          ),
                        ],
                      ),
                    ],
                    if (_controller.terminal)
                      _aviso(
                          'Execução encerrada. Registro disponível para consulta.'),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _informacao(String titulo, String valor) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text('$titulo: $valor'),
      );

  Widget _aviso(String mensagem, {Widget? acao}) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(mensagem), if (acao != null) acao],
          ),
        ),
      );

  String _status(ExecucaoMissaoModel? execucao) {
    switch (execucao?.status) {
      case EscalaCodigos.execucaoEmExecucao:
        return 'Em execução';
      case EscalaCodigos.execucaoConcluida:
        return 'Concluída';
      case EscalaCodigos.execucaoCancelada:
        return 'Cancelada';
      default:
        return 'Não iniciada';
    }
  }
}

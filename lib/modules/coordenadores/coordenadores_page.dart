import 'package:flutter/material.dart';

import '../../core/services/equipe_operacional_service.dart';
import '../../data/models/membro_equipe_model.dart';

class CoordenadoresPage extends StatefulWidget {
  const CoordenadoresPage({super.key});

  @override
  State<CoordenadoresPage> createState() => _CoordenadoresPageState();
}

class _CoordenadoresPageState extends State<CoordenadoresPage> {
  final EquipeOperacionalService _service = EquipeOperacionalService();
  bool _sincronizando = false;

  Future<void> _sincronizar() async {
    setState(() => _sincronizando = true);
    try {
      final resultado = await _service.sincronizarFundacao();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${resultado.usuariosSincronizados} usuário(s) sincronizado(s) e '
            '${resultado.coordenadoresImportados} coordenador(es) '
            'compatibilizado(s).',
          ),
        ),
      );
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível sincronizar: $erro')),
      );
    } finally {
      if (mounted) setState(() => _sincronizando = false);
    }
  }

  Future<void> _editar(MembroEquipeModel membro) async {
    var vinculo = membro.vinculo;
    var podeCoordenar = membro.podeCoordenar;
    var ativo = membro.ativo;

    final salvar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(membro.nome),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vínculo operacional',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<VinculoOperacional>(
                  initialValue: vinculo,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: VinculoOperacional.values
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item.rotulo),
                        ),
                      )
                      .toList(),
                  onChanged: (valor) {
                    if (valor != null) {
                      setDialogState(() => vinculo = valor);
                    }
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: podeCoordenar,
                  title: const Text('Pode coordenar ações'),
                  subtitle: const Text(
                    'Disponibiliza esta pessoa na escolha de coordenador.',
                  ),
                  onChanged: (valor) =>
                      setDialogState(() => podeCoordenar = valor),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: ativo,
                  title: const Text('Membro ativo'),
                  onChanged: (valor) => setDialogState(() => ativo = valor),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('CANCELAR'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('SALVAR'),
            ),
          ],
        ),
      ),
    );

    if (salvar != true) return;
    try {
      await _service.atualizarClassificacao(
        id: membro.id,
        vinculo: vinculo,
        podeCoordenar: podeCoordenar,
        ativo: ativo,
      );
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível salvar: $erro')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Equipe Operacional')),
      body: StreamBuilder<List<MembroEquipeModel>>(
        stream: _service.observarMembros(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _EstadoInicial(
              sincronizando: _sincronizando,
              onSincronizar: _sincronizar,
              mensagem: 'O catálogo ainda não está disponível.',
            );
          }

          final membros = snapshot.data ?? const <MembroEquipeModel>[];
          if (membros.isEmpty) {
            return _EstadoInicial(
              sincronizando: _sincronizando,
              onSincronizar: _sincronizar,
              mensagem: 'Prepare o catálogo com os usuários atuais.',
            );
          }

          final agentes = membros
              .where((item) => item.vinculo == VinculoOperacional.agente)
              .length;
          final terceirizados = membros.length - agentes;
          final coordenadores =
              membros.where((item) => item.podeCoordenar).length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ResumoEquipe(
                agentes: agentes,
                terceirizados: terceirizados,
                coordenadores: coordenadores,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _sincronizando ? null : _sincronizar,
                icon: _sincronizando
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
                label: const Text('SINCRONIZAR USUÁRIOS E COORDENADORES'),
              ),
              const SizedBox(height: 12),
              ...membros.map(
                (membro) => Card(
                  child: ListTile(
                    onTap: () => _editar(membro),
                    leading: CircleAvatar(
                      child: Icon(
                        membro.vinculo == VinculoOperacional.agente
                            ? Icons.badge_outlined
                            : Icons.groups_outlined,
                      ),
                    ),
                    title: Text(membro.nome),
                    subtitle: Text(
                      '${membro.vinculo.rotulo} • '
                      '${membro.podeCoordenar ? 'Pode coordenar' : 'Participante'}'
                      '${membro.ativo ? '' : ' • Inativo'}',
                    ),
                    trailing: const Icon(Icons.edit_outlined),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EstadoInicial extends StatelessWidget {
  const _EstadoInicial({
    required this.sincronizando,
    required this.onSincronizar,
    required this.mensagem,
  });

  final bool sincronizando;
  final VoidCallback onSincronizar;
  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.groups_2_outlined, size: 64),
            const SizedBox(height: 16),
            Text(mensagem, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: sincronizando ? null : onSincronizar,
              icon: const Icon(Icons.sync),
              label: const Text('PREPARAR EQUIPE OPERACIONAL'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumoEquipe extends StatelessWidget {
  const _ResumoEquipe({
    required this.agentes,
    required this.terceirizados,
    required this.coordenadores,
  });

  final int agentes;
  final int terceirizados;
  final int coordenadores;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 24,
          runSpacing: 12,
          children: [
            Text('$agentes agente(s)'),
            Text('$terceirizados terceirizado(s)'),
            Text('$coordenadores habilitado(s) para coordenar'),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/services/firebase_acao_service.dart';
import '../../data/models/acao_model.dart';
import 'detalhe_acao_page.dart';

class RaeVinculadoPage extends StatefulWidget {
  const RaeVinculadoPage({super.key, required this.raeId, this.service});

  final String raeId;
  final FirebaseAcaoService? service;

  @override
  State<RaeVinculadoPage> createState() => _RaeVinculadoPageState();
}

class _RaeVinculadoPageState extends State<RaeVinculadoPage> {
  late Future<AcaoModel?> _carregamento;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    _carregamento = (widget.service ?? FirebaseAcaoService()).buscarAcaoPorId(
      widget.raeId.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AcaoModel?>(
      future: _carregamento,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: const Text('RAE da Escala')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return _estado(
            icon: Icons.cloud_off_rounded,
            titulo: 'Não foi possível abrir o RAE',
            mensagem: 'Verifique a conexão e tente novamente.',
            tentarNovamente: true,
          );
        }

        final acao = snapshot.data;
        if (acao == null) {
          return _estado(
            icon: Icons.assignment_late_outlined,
            titulo: 'RAE não encontrado',
            mensagem: 'O vínculo existe, mas o registro não está disponível.',
          );
        }

        return DetalheAcaoPage(acao: acao);
      },
    );
  }

  Widget _estado({
    required IconData icon,
    required String titulo,
    required String mensagem,
    bool tentarNovamente = false,
  }) {
    return Scaffold(
      appBar: AppBar(title: const Text('RAE da Escala')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48),
              const SizedBox(height: 12),
              Text(titulo, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(mensagem, textAlign: TextAlign.center),
              if (tentarNovamente) ...[
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => setState(_carregar),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

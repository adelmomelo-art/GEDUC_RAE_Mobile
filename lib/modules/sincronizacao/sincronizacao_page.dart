import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/status_acao_chip.dart';
import '../acoes/controllers/acao_controller.dart';

class SincronizacaoPage extends StatefulWidget {
  const SincronizacaoPage({super.key});

  @override
  State<SincronizacaoPage> createState() => _SincronizacaoPageState();
}

class _SincronizacaoPageState extends State<SincronizacaoPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AcaoController>().carregarPendentesSincronizacao();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AcaoController>();
    final pendentes = controller.pendentesSincronizacao;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sincronização Offline'),
      ),
      body: RefreshIndicator(
        onRefresh: controller.carregarPendentesSincronizacao,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.blue.shade50,
              child: ListTile(
                leading: const Icon(Icons.cloud_sync),
                title: const Text('Central de Sincronização'),
                subtitle: Text(
                  pendentes.isEmpty
                      ? 'Nenhuma ação pendente de sincronização.'
                      : '${pendentes.length} ação(ões) pendente(s).',
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (controller.erroSincronizacao != null)
              Card(
                color: Colors.red.shade50,
                child: ListTile(
                  leading: const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                  ),
                  title: const Text('Erro de sincronização'),
                  subtitle: Text(controller.erroSincronizacao!),
                ),
              ),
            if (controller.carregandoPendentes)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (pendentes.isEmpty)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.check_circle_outline),
                  title: Text('Tudo sincronizado'),
                  subtitle: Text(
                    'Não existem ações pendentes neste dispositivo.',
                  ),
                ),
              )
            else ...[
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  icon: controller.sincronizandoPendentes
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync),
                  label: Text(
                    controller.sincronizandoPendentes
                        ? 'SINCRONIZANDO...'
                        : 'SINCRONIZAR TUDO',
                  ),
                  onPressed: controller.sincronizandoPendentes
                      ? null
                      : () async {
                          await controller.sincronizarPendentes();

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sincronização finalizada.'),
                            ),
                          );
                        },
                ),
              ),
              const SizedBox(height: 16),
              ...pendentes.map(
                (acao) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.description),
                    title: Text(
                      acao.nomeAcao.isEmpty
                          ? 'Ação educativa'
                          : acao.nomeAcao,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RAE: ${acao.numeroRAE.isEmpty ? 'Não gerado' : acao.numeroRAE}',
                        ),
                        Text(
                          '${acao.regional} • ${acao.bairro}',
                        ),
                        const SizedBox(height: 8),
                        StatusAcaoChip(
                          status: acao.status,
                          sincronizado: acao.sincronizado,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
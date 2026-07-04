import 'package:flutter/material.dart';

import '../../../core/widgets/status_acao_chip.dart';
import '../../../data/models/acao_model.dart';

class UltimosRaesWidget extends StatelessWidget {
  final List<AcaoModel> acoes;

  const UltimosRaesWidget({
    super.key,
    required this.acoes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.history,
                  color: Colors.blue,
                ),
                SizedBox(width: 8),
                Text(
                  'Últimos RAEs',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (acoes.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'Nenhum RAE cadastrado.',
                  ),
                ),
              ),
            ...acoes.map(
              (acao) => Card(
                elevation: 0,
                color: Colors.grey.shade100,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(
                      Icons.description,
                      color: Colors.blue,
                    ),
                  ),
                  title: Text(
                    acao.nomeAcao,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RAE ${acao.numeroRAE}\n'
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
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
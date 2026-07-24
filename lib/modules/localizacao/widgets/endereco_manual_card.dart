import 'package:flutter/material.dart';

class EnderecoManualCard extends StatelessWidget {
  const EnderecoManualCard({
    super.key,
    required this.pesquisaController,
    required this.onPesquisar,
    this.pesquisando = false,
  });

  final TextEditingController pesquisaController;
  final VoidCallback? onPesquisar;
  final bool pesquisando;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pesquisar local da ação',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Informe rua, número, bairro e cidade para melhorar '
              'a precisão da pesquisa.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pesquisaController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onPesquisar?.call(),
              decoration: InputDecoration(
                labelText: 'Endereço para pesquisa',
                hintText: 'Ex.: Av. Beira-Mar, 2500, Fortaleza',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: pesquisando
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: pesquisando ? null : onPesquisar,
                icon: const Icon(Icons.travel_explore),
                label: Text(
                  pesquisando ? 'Pesquisando...' : 'Pesquisar endereço',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

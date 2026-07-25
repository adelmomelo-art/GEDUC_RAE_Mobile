import 'package:flutter/material.dart';

class LocalizacaoFormCard extends StatelessWidget {
  const LocalizacaoFormCard({
    super.key,
    required this.nomeLocalController,
    required this.enderecoController,
    required this.bairroController,
    required this.regionalController,
    required this.pontoReferenciaController,
    this.onBairroChanged,
    this.onRegionalChanged,
    this.onDadosChanged,
  });

  final TextEditingController nomeLocalController;
  final TextEditingController enderecoController;
  final TextEditingController bairroController;
  final TextEditingController regionalController;
  final TextEditingController pontoReferenciaController;
  final ValueChanged<String>? onBairroChanged;
  final ValueChanged<String>? onRegionalChanged;
  final VoidCallback? onDadosChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dados do local',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nomeLocalController,
              onChanged: (_) => onDadosChanged?.call(),
              decoration: const InputDecoration(
                labelText: 'Nome do local',
                hintText: 'Ex.: Escola Paulo Freire',
                prefixIcon: Icon(Icons.apartment_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: enderecoController,
              onChanged: (_) => onDadosChanged?.call(),
              decoration: const InputDecoration(
                labelText: 'Endereço *',
                hintText: 'Informe o endereço da ação',
                prefixIcon: Icon(Icons.route_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final usarDuasColunas = constraints.maxWidth >= 620;

                final bairro = TextField(
                  controller: bairroController,
                  onChanged: (valor) {
                    onDadosChanged?.call();
                    onBairroChanged?.call(valor);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Bairro *',
                    prefixIcon: Icon(Icons.location_city_outlined),
                    border: OutlineInputBorder(),
                  ),
                );

                final regional = TextField(
                  controller: regionalController,
                  onChanged: (valor) {
                    onRegionalChanged?.call(valor);
                    onDadosChanged?.call();
                  },
                  decoration: const InputDecoration(
                    labelText: 'Regional *',
                    prefixIcon: Icon(Icons.map_outlined),
                    helperText: 'Preenchida automaticamente. Caso não seja '
                        'identificada, informe manualmente.',
                    border: OutlineInputBorder(),
                  ),
                );

                if (!usarDuasColunas) {
                  return Column(
                    children: [
                      bairro,
                      const SizedBox(height: 14),
                      regional,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: bairro),
                    const SizedBox(width: 14),
                    Expanded(child: regional),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            TextField(
              controller: pontoReferenciaController,
              onChanged: (_) => onDadosChanged?.call(),
              decoration: const InputDecoration(
                labelText: 'Ponto de referência *',
                hintText: 'Ex.: em frente ao terminal',
                prefixIcon: Icon(Icons.near_me_outlined),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

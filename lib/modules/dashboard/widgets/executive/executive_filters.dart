import 'package:flutter/material.dart';

import '../common/dashboard_colors.dart';
import '../common/dashboard_panel.dart';
import '../common/dashboard_title.dart';

class ExecutiveFilters extends StatelessWidget {
  const ExecutiveFilters({
    required this.periodoSelecionado,
    required this.onPeriodoSelecionado,
    super.key,
  });

  

  static const List<String> _periodos = [
    'Hoje',
    'Semana',
    'Mês',
    'Ano',
    'Geral',
  ];

  final String periodoSelecionado;
  final ValueChanged<String> onPeriodoSelecionado;

  @override
  Widget build(BuildContext context) {
    return DashboardPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardTitle(
            title: 'Período de análise',
            icon: Icons.filter_alt_outlined,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _periodos.map((periodo) {
              final selecionado = periodoSelecionado == periodo;

              return ChoiceChip(
                label: Text(periodo),
                selected: selecionado,
                onSelected: (_) => onPeriodoSelecionado(periodo),
                selectedColor: DashboardColors.primary,
                backgroundColor: const Color(0xFFF1F5F5),
                labelStyle: TextStyle(
                  color: selecionado
                      ? Colors.white
                      : const Color(0xFF455A64),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                side: BorderSide(
                  color: selecionado
                      ? DashboardColors.primary
                      : const Color(0xFFD6E1E1),
                ),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nesta versão, o filtro está preparado visualmente. '
            'A filtragem por período será conectada aos dados na próxima etapa.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

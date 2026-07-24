import 'package:flutter/material.dart';

import '../common/dashboard_colors.dart';
import '../common/dashboard_panel.dart';
import '../common/dashboard_radius.dart';
import '../common/dashboard_spacing.dart';

/// Grade responsiva dos principais indicadores executivos do CIO.
class ExecutiveKpiGrid extends StatelessWidget {
  const ExecutiveKpiGrid({
    required this.larguraDisponivel,
    required this.totalAcoes,
    required this.totalPessoas,
    required this.totalVeiculos,
    required this.totalCredenciais,
    super.key,
  });

  final double larguraDisponivel;
  final int totalAcoes;
  final int totalPessoas;
  final int totalVeiculos;
  final int totalCredenciais;

  @override
  Widget build(BuildContext context) {
    final colunas = larguraDisponivel >= 1100
        ? 4
        : larguraDisponivel >= 620
            ? 2
            : 1;

    final indicadores = [
      _IndicadorExecutivo(
        titulo: 'Ações registradas',
        valor: totalAcoes,
        legenda: 'RAEs consolidados',
        icone: Icons.assignment_turned_in_outlined,
        cor: DashboardColors.blue,
      ),
      _IndicadorExecutivo(
        titulo: 'Pessoas alcançadas',
        valor: totalPessoas,
        legenda: 'Público total',
        icone: Icons.groups_2_outlined,
        cor: DashboardColors.primary,
      ),
      _IndicadorExecutivo(
        titulo: 'Veículos abordados',
        valor: totalVeiculos,
        legenda: 'Abordagens educativas',
        icone: Icons.directions_car_filled_outlined,
        cor: DashboardColors.orange,
      ),
      _IndicadorExecutivo(
        titulo: 'Credenciais emitidas',
        valor: totalCredenciais,
        legenda: 'Emissões registradas',
        icone: Icons.badge_outlined,
        cor: DashboardColors.purple,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: indicadores.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: colunas,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: colunas == 1 ? 2.9 : 1.7,
      ),
      itemBuilder: (context, index) {
        return _ExecutiveKpiCard(indicador: indicadores[index]);
      },
    );
  }
}

class _ExecutiveKpiCard extends StatelessWidget {
  const _ExecutiveKpiCard({required this.indicador});

  final _IndicadorExecutivo indicador;

  @override
  Widget build(BuildContext context) {
    return DashboardPanel(
      padding: const EdgeInsets.all(DashboardSpacing.md),
      borderRadius: DashboardRadius.large,
      borderColor: indicador.cor.withValues(alpha: 0.14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: indicador.cor.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(DashboardRadius.medium),
            ),
            child: Icon(indicador.icone, color: indicador.cor, size: 24),
          ),
          const SizedBox(width: DashboardSpacing.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _formatarNumero(indicador.valor),
                    style: TextStyle(
                      color: indicador.cor,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  indicador.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF263238),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  indicador.legenda,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatarNumero(int valor) {
    final texto = valor.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < texto.length; i++) {
      final posicaoRestante = texto.length - i;
      buffer.write(texto[i]);

      if (posicaoRestante > 1 && posicaoRestante % 3 == 1) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }
}

class _IndicadorExecutivo {
  const _IndicadorExecutivo({
    required this.titulo,
    required this.valor,
    required this.legenda,
    required this.icone,
    required this.cor,
  });

  final String titulo;
  final int valor;
  final String legenda;
  final IconData icone;
  final Color cor;
}

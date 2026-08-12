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
    required this.metasAtingidas,
    required this.profissionaisMobilizados,
    this.comparacaoAcoes,
    this.comparacaoPessoas,
    this.comparacaoMetas,
    this.comparacaoProfissionais,
    super.key,
  });

  final double larguraDisponivel;
  final int totalAcoes;
  final int totalPessoas;
  final int metasAtingidas;
  final int profissionaisMobilizados;
  final int? comparacaoAcoes;
  final int? comparacaoPessoas;
  final int? comparacaoMetas;
  final int? comparacaoProfissionais;

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
        comparacao: comparacaoAcoes,
      ),
      _IndicadorExecutivo(
        titulo: 'Pessoas alcançadas',
        valor: totalPessoas,
        legenda: 'Público total',
        icone: Icons.groups_2_outlined,
        cor: DashboardColors.primary,
        comparacao: comparacaoPessoas,
      ),
      _IndicadorExecutivo(
        titulo: 'Metas atingidas',
        valor: metasAtingidas,
        legenda: 'Ações com meta alcançada',
        icone: Icons.flag_outlined,
        cor: DashboardColors.orange,
        comparacao: comparacaoMetas,
      ),
      _IndicadorExecutivo(
        titulo: 'Profissionais mobilizados',
        valor: profissionaisMobilizados,
        legenda: 'Agentes e terceirizados',
        icone: Icons.badge_outlined,
        cor: DashboardColors.purple,
        comparacao: comparacaoProfissionais,
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
        childAspectRatio: colunas == 1 ? 2.45 : 1.45,
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
                if (indicador.comparacao != null)
                  Text(
                    _variacao(indicador.valor, indicador.comparacao!),
                    style: TextStyle(
                      color: indicador.valor >= indicador.comparacao!
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
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

  String _variacao(int atual, int anterior) {
    if (anterior == 0) return atual == 0 ? 'Sem variação' : 'Novo no período';
    final percentual = ((atual - anterior) / anterior * 100).round();
    return '${percentual >= 0 ? '+' : ''}$percentual% na comparação';
  }
}

class _IndicadorExecutivo {
  const _IndicadorExecutivo({
    required this.titulo,
    required this.valor,
    required this.legenda,
    required this.icone,
    required this.cor,
    this.comparacao,
  });

  final String titulo;
  final int valor;
  final String legenda;
  final IconData icone;
  final Color cor;
  final int? comparacao;
}

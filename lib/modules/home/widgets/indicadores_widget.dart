import 'package:flutter/material.dart';

class IndicadoresWidget extends StatelessWidget {
  const IndicadoresWidget({
    super.key,
    required this.totalAcoes,
    required this.totalPessoas,
    required this.totalVeiculos,
    required this.totalCredenciais,
  });

  final int totalAcoes;
  final int totalPessoas;
  final int totalVeiculos;
  final int totalCredenciais;

  static const Color verdeInstitucional = Color(0xFF007A78);
  static const Color laranjaInstitucional = Color(0xFFF37021);
  static const Color fundoSecao = Color(0xFFF8FBFB);

  @override
  Widget build(BuildContext context) {
    final indicadores = [
      _IndicadorData(
        titulo: 'Ações registradas',
        valor: totalAcoes,
        icone: Icons.assignment_turned_in_outlined,
        cor: const Color(0xFF0B66C3),
        legenda: 'Registros consolidados',
      ),
      _IndicadorData(
        titulo: 'Pessoas alcançadas',
        valor: totalPessoas,
        icone: Icons.groups_2_outlined,
        cor: verdeInstitucional,
        legenda: 'Público total registrado',
      ),
      _IndicadorData(
        titulo: 'Veículos abordados',
        valor: totalVeiculos,
        icone: Icons.directions_car_filled_outlined,
        cor: laranjaInstitucional,
        legenda: 'Abordagens educativas',
      ),
      _IndicadorData(
        titulo: 'Credenciais emitidas',
        valor: totalCredenciais,
        icone: Icons.badge_outlined,
        cor: const Color(0xFF7A4FB7),
        legenda: 'Emissões registradas',
      ),
    ];

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: fundoSecao,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: verdeInstitucional.withValues(alpha: 0.10),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _IndicadoresHeader(),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final largura = constraints.maxWidth;
                final colunas = largura >= 1050
                    ? 4
                    : largura >= 560
                        ? 2
                        : 1;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: indicadores.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: colunas,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: colunas == 1 ? 2.80 : 1.62,
                  ),
                  itemBuilder: (context, index) {
                    return _IndicadorExecutivoCard(
                      indicador: indicadores[index],
                      destaque: index == 0,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _IndicadoresHeader extends StatelessWidget {
  const _IndicadoresHeader();

  static const Color verdeInstitucional = Color(0xFF007A78);

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFFEAF7F7),
          child: Icon(
            Icons.analytics_outlined,
            color: verdeInstitucional,
            size: 20,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Indicadores executivos\n',
                  style: TextStyle(
                    color: verdeInstitucional,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    height: 1.05,
                  ),
                ),
                TextSpan(
                  text:
                      'Visão consolidada dos principais resultados operacionais.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    height: 1.20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _IndicadorExecutivoCard extends StatelessWidget {
  const _IndicadorExecutivoCard({
    required this.indicador,
    required this.destaque,
  });

  final _IndicadorData indicador;
  final bool destaque;

  static const Color verdeInstitucional = Color(0xFF007A78);

  @override
  Widget build(BuildContext context) {
    final backgroundColor = destaque
        ? verdeInstitucional
        : indicador.cor.withValues(alpha: 0.08);

    final foregroundColor = destaque ? Colors.white : indicador.cor;
    final secondaryColor = destaque ? Colors.white70 : Colors.black54;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: destaque
              ? verdeInstitucional
              : indicador.cor.withValues(alpha: 0.16),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: destaque ? 8 : 5,
            offset: const Offset(0, 3),
            color: Colors.black.withValues(
              alpha: destaque ? 0.10 : 0.04,
            ),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: destaque
                      ? Colors.white.withValues(alpha: 0.14)
                      : Colors.white.withValues(alpha: 0.86),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  indicador.icone,
                  color: foregroundColor,
                  size: 21,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _formatarNumero(indicador.valor),
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              indicador.titulo.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.45,
                height: 1.10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              indicador.legenda,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: secondaryColor,
                fontSize: 10,
                height: 1.15,
              ),
            ),
          ],
        ),
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

class _IndicadorData {
  const _IndicadorData({
    required this.titulo,
    required this.valor,
    required this.icone,
    required this.cor,
    required this.legenda,
  });

  final String titulo;
  final int valor;
  final IconData icone;
  final Color cor;
  final String legenda;
}

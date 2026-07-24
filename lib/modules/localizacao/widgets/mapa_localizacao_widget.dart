import 'package:flutter/material.dart';

class MapaLocalizacaoWidget extends StatelessWidget {
  const MapaLocalizacaoWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.possuiLocalizacao,
    this.altura = 260,
    this.onCentralizar,
  });

  final double latitude;
  final double longitude;
  final bool possuiLocalizacao;
  final double altura;
  final VoidCallback? onCentralizar;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: altura,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.surfaceContainerHighest,
                    scheme.surfaceContainerLow,
                  ],
                ),
              ),
              child: CustomPaint(
                painter: _MapaGradePainter(
                  lineColor: scheme.outlineVariant,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    possuiLocalizacao
                        ? Icons.location_on
                        : Icons.map_outlined,
                    size: possuiLocalizacao ? 52 : 44,
                    color: possuiLocalizacao
                        ? scheme.primary
                        : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    possuiLocalizacao
                        ? 'Localização selecionada'
                        : 'Mapa preparado para integração',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    possuiLocalizacao
                        ? '${latitude.toStringAsFixed(6)}, '
                            '${longitude.toStringAsFixed(6)}'
                        : 'O Google Maps será ativado no Bloco B.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: FloatingActionButton.small(
                heroTag: 'centralizar_mapa_localizacao',
                tooltip: 'Centralizar mapa',
                onPressed: onCentralizar,
                child: const Icon(Icons.my_location),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapaGradePainter extends CustomPainter {
  const _MapaGradePainter({
    required this.lineColor,
  });

  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor.withValues(alpha: 0.55)
      ..strokeWidth = 1;

    const spacing = 36.0;

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MapaGradePainter oldDelegate) {
    return oldDelegate.lineColor != lineColor;
  }
}

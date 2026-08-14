import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/cartography/cio_cartographic_models.dart';
import '../models/cartography/cio_geometry_models.dart';

class CioTerritorialMapPanel extends StatefulWidget {
  const CioTerritorialMapPanel({
    super.key,
    required this.geometry,
    required this.aggregation,
    required this.online,
    required this.foundationUnavailable,
    this.enabled = false,
  });

  final CioGeometryDataset? geometry;
  final CioCartographicAggregation? aggregation;
  final bool online;
  final bool foundationUnavailable;
  final bool enabled;

  @override
  State<CioTerritorialMapPanel> createState() => _CioTerritorialMapPanelState();
}

class _CioTerritorialMapPanelState extends State<CioTerritorialMapPanel> {
  bool _byRegional = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return _statusCard(
        context,
        icon: Icons.lock_outline_rounded,
        title: 'Mapa territorial protegido',
        message: 'Visualização territorial desativada pela configuração de '
            'segurança desta compilação.',
      );
    }
    if (widget.foundationUnavailable ||
        widget.geometry == null ||
        widget.aggregation == null) {
      return _statusCard(
        context,
        icon: Icons.map_outlined,
        title: 'Mapa territorial indisponível',
        message: 'A geometria oficial ou a política de elegibilidade não pôde '
            'ser validada. Nenhuma simulação será exibida.',
      );
    }
    final geometry = widget.geometry!;
    final aggregation = widget.aggregation!;
    final counts = <String, int>{
      for (final item in aggregation.neighborhoods)
        item.neighborhood: item.actionCount,
    };
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Mapa territorial oficial',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Bairro')),
                    ButtonSegment(value: true, label: Text('Regional')),
                  ],
                  selected: {_byRegional},
                  onSelectionChanged: (value) =>
                      setState(() => _byRegional = value.single),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${aggregation.totalEligible} RAEs elegíveis · '
              '${aggregation.totalExcluded} excluídos pela política',
            ),
            if (!widget.online) ...[
              const SizedBox(height: 8),
              const Text(
                'Mapa-base indisponível; limites oficiais preservados.',
                key: Key('cio_map_offline_message'),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              height: 360,
              child: FlutterMap(
                options: const MapOptions(
                  initialCenter: LatLng(-3.79, -38.54),
                  initialZoom: 10.7,
                  minZoom: 9,
                  maxZoom: 15,
                  interactionOptions: InteractionOptions(
                    flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                  ),
                ),
                children: [
                  if (widget.online)
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'br.gov.fortaleza.geduc_rae_mobile',
                      maxNativeZoom: 19,
                    ),
                  PolygonLayer(
                    polygons: _polygons(geometry, counts, aggregation),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Wrap(
              spacing: 12,
              children: [
                Text('Sem RAE: cinza'),
                Text('1 RAE: verde claro'),
                Text('2–3 RAEs: verde'),
                Text('4+ RAEs: laranja'),
              ],
            ),
            const SizedBox(height: 8),
            Text(geometry.manifest.attribution),
            if (widget.online) const Text('© OpenStreetMap contributors'),
          ],
        ),
      ),
    );
  }

  List<Polygon> _polygons(
    CioGeometryDataset geometry,
    Map<String, int> neighborhoodCounts,
    CioCartographicAggregation aggregation,
  ) =>
      geometry.neighborhoods.expand((neighborhood) {
        final count = _byRegional
            ? aggregation.regionals[_regionalCode(neighborhood.regional)] ?? 0
            : neighborhoodCounts[neighborhood.name] ?? 0;
        return neighborhood.polygons.map((polygon) => Polygon(
              points: polygon.rings.first.map(_latLng).toList(growable: false),
              holePointsList: polygon.rings
                  .skip(1)
                  .map((ring) => ring.map(_latLng).toList(growable: false))
                  .toList(growable: false),
              color: _color(count).withValues(alpha: 0.58),
              borderColor: Colors.white,
              borderStrokeWidth: 0.8,
            ));
      }).toList(growable: false);

  LatLng _latLng(CioGeoPoint point) => LatLng(point.latitude, point.longitude);

  Color _color(int count) {
    if (count == 0) return const Color(0xFF9E9E9E);
    if (count == 1) return const Color(0xFF80CBC4);
    if (count <= 3) return const Color(0xFF007A78);
    return const Color(0xFFF37021);
  }

  String _regionalCode(String value) {
    final match = RegExp(r'(\d+)\s*$').firstMatch(value);
    return match == null
        ? ''
        : 'SER ${int.parse(match.group(1)!).toString().padLeft(2, '0')}';
  }

  Widget _statusCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
  }) =>
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(message),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

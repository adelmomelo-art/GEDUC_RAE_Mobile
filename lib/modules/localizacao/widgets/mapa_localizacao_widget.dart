import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Mapa interativo de localização da Plataforma Fênix.
///
/// Responsabilidades:
/// - exibir os blocos cartográficos do OpenStreetMap;
/// - mostrar o marcador da ação;
/// - centralizar automaticamente após uma captura de GPS;
/// - permitir movimentação e zoom pelo usuário;
/// - permitir a seleção manual de coordenadas por toque no mapa;
/// - manter um ponto inicial seguro quando ainda não houver coordenadas.
class MapaLocalizacaoWidget extends StatefulWidget {
  const MapaLocalizacaoWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.possuiLocalizacao,
    this.altura = 320,
    this.onCentralizar,
    this.onSelecionarLocal,
    this.selecaoHabilitada = false,
  });

  final double latitude;
  final double longitude;
  final bool possuiLocalizacao;
  final double altura;

  /// Quando não existe uma localização, solicita à página a captura
  /// das coordenadas pelo GPS.
  final VoidCallback? onCentralizar;

  /// Recebe as coordenadas selecionadas pelo usuário no mapa.
  final void Function(double latitude, double longitude)? onSelecionarLocal;

  /// Controla se o toque no mapa pode selecionar uma nova localização.
  final bool selecaoHabilitada;

  @override
  State<MapaLocalizacaoWidget> createState() => _MapaLocalizacaoWidgetState();
}

class _MapaLocalizacaoWidgetState extends State<MapaLocalizacaoWidget> {
  static const LatLng _centroInicialFortaleza = LatLng(
    -3.7319,
    -38.5267,
  );

  static const double _zoomInicial = 12;
  static const double _zoomComLocalizacao = 17;

  final MapController _mapController = MapController();

  bool _mapaPronto = false;

  LatLng get _coordenadaAtual {
    if (!widget.possuiLocalizacao) {
      return _centroInicialFortaleza;
    }

    return LatLng(
      widget.latitude,
      widget.longitude,
    );
  }

  @override
  void didUpdateWidget(covariant MapaLocalizacaoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final coordenadasMudaram = oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude;

    final localizacaoFoiObtida =
        !oldWidget.possuiLocalizacao && widget.possuiLocalizacao;

    if (widget.possuiLocalizacao &&
        (coordenadasMudaram || localizacaoFoiObtida)) {
      _centralizarAposRenderizacao();
    }
  }

  void _centralizarAposRenderizacao() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_mapaPronto || !widget.possuiLocalizacao) {
        return;
      }

      _mapController.move(
        _coordenadaAtual,
        _zoomComLocalizacao,
      );
    });
  }

  void _acaoCentralizar() {
    if (widget.possuiLocalizacao && _mapaPronto) {
      _mapController.move(
        _coordenadaAtual,
        _zoomComLocalizacao,
      );
      return;
    }

    widget.onCentralizar?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: widget.altura,
        child: Stack(
          children: [
            Positioned.fill(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _coordenadaAtual,
                  initialZoom: widget.possuiLocalizacao
                      ? _zoomComLocalizacao
                      : _zoomInicial,
                  minZoom: 3,
                  maxZoom: 19,
                  onMapReady: () {
                    _mapaPronto = true;

                    if (widget.possuiLocalizacao) {
                      _centralizarAposRenderizacao();
                    }
                  },
                  onTap: widget.selecaoHabilitada &&
                          widget.onSelecionarLocal != null
                      ? (_, coordenada) {
                          widget.onSelecionarLocal!(
                            coordenada.latitude,
                            coordenada.longitude,
                          );
                        }
                      : null,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'br.gov.fortaleza.geduc_rae_mobile',
                    maxNativeZoom: 19,
                  ),
                  if (widget.possuiLocalizacao)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _coordenadaAtual,
                          width: 64,
                          height: 64,
                          alignment: Alignment.topCenter,
                          child: _MarcadorLocalizacao(
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Identificação operacional do mapa.
            Positioned(
              top: 12,
              left: 12,
              right: 64,
              child: Align(
                alignment: Alignment.centerLeft,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.possuiLocalizacao
                              ? Icons.location_on
                              : Icons.map_outlined,
                          size: 20,
                          color: widget.possuiLocalizacao
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            widget.possuiLocalizacao
                                ? 'Localização da ação'
                                : 'Mapa de Fortaleza',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Mensagem exibida enquanto ainda não houver coordenadas.
            if (!widget.possuiLocalizacao && !widget.selecaoHabilitada)
              Positioned(
                left: 16,
                right: 16,
                bottom: 46,
                child: Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        widget.onCentralizar == null
                            ? 'Capture ou pesquise uma localização para '
                                'exibir o marcador.'
                            : 'Toque no botão para obter sua localização.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
              ),

            // Botão de captura ou recentralização.
            Positioned(
              top: 12,
              right: 12,
              child: FloatingActionButton.small(
                heroTag: 'centralizar_mapa_localizacao',
                tooltip: widget.possuiLocalizacao
                    ? 'Centralizar na localização'
                    : 'Obter localização',
                onPressed:
                    widget.possuiLocalizacao || widget.onCentralizar != null
                        ? _acaoCentralizar
                        : null,
                child: Icon(
                  widget.possuiLocalizacao
                      ? Icons.center_focus_strong
                      : Icons.my_location,
                ),
              ),
            ),

            if (widget.selecaoHabilitada)
              Positioned(
                left: 16,
                right: 16,
                bottom: widget.possuiLocalizacao ? 48 : 46,
                child: Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.touch_app_outlined,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Toque no mapa para marcar o local da ação.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Atribuição obrigatória do OpenStreetMap.
            Positioned(
              left: 6,
              bottom: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  child: Text(
                    '© OpenStreetMap contributors',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 9,
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ),
            ),

            if (widget.possuiLocalizacao)
              Positioned(
                right: 8,
                bottom: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    child: Text(
                      '${widget.latitude.toStringAsFixed(6)}, '
                      '${widget.longitude.toStringAsFixed(6)}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
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

class _MarcadorLocalizacao extends StatelessWidget {
  const _MarcadorLocalizacao({
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Localização registrada da ação',
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 39,
            child: Container(
              width: 24,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          Icon(
            Icons.location_on,
            size: 52,
            color: color,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.32),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          Positioned(
            top: 10,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_car_filled,
                size: 10,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

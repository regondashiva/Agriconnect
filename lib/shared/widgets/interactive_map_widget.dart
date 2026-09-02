import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';
import '../../models/logistics_route_model.dart';

class InteractiveMapWidget extends StatefulWidget {
  final List<RouteStopPoint> stops;
  final List<LatLng> polylinePoints;
  final LatLng? liveVehicleLocation;
  final LatLng initialCenter;
  final double initialZoom;
  final bool showControls;
  final bool isDashedPolyline;

  const InteractiveMapWidget({
    super.key,
    required this.stops,
    required this.polylinePoints,
    this.liveVehicleLocation,
    required this.initialCenter,
    this.initialZoom = 10.8,
    this.showControls = true,
    this.isDashedPolyline = true,
  });

  @override
  State<InteractiveMapWidget> createState() => _InteractiveMapWidgetState();
}

class _InteractiveMapWidgetState extends State<InteractiveMapWidget> {
  late final MapController _mapController;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  void _recenter() {
    _mapController.move(widget.initialCenter, widget.initialZoom);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: const Color(0xFFF3F4F6),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.map_outlined, size: 40, color: AppColors.textMuted),
              const SizedBox(height: 8),
              const Text(
                'Map tiles temporarily unavailable',
                style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textNavy, fontSize: 13),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => setState(() => _hasError = false),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.initialCenter,
            initialZoom: widget.initialZoom,
            minZoom: 6.0,
            maxZoom: 18.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            // High-Performance, Clean CartoDB / OSM Tiles matching Stitch Aesthetic
            TileLayer(
              urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.example.agriconnect',
              errorTileCallback: (tile, error, stackTrace) {
                // Silently handle offline/slow tiles without crashing
              },
            ),

            // Route Polyline (Glow Background + Green Route)
            PolylineLayer(
              polylines: [
                // Outer glow shadow
                Polyline(
                  points: widget.polylinePoints,
                  strokeWidth: 6.0,
                  color: const Color(0x33164E2A),
                ),
                // Main route line
                Polyline(
                  points: widget.polylinePoints,
                  strokeWidth: 3.5,
                  color: const Color(0xFF164E2A),
                  pattern: widget.isDashedPolyline
                      ? StrokePattern.dashed(segments: const [10, 6])
                      : const StrokePattern.solid(),
                ),
              ],
            ),

            // Custom Stitch-Styled Markers
            MarkerLayer(
              markers: [
                // Stop Markers (Farm A, Farm B, Buyer Hub)
                for (final stop in widget.stops)
                  Marker(
                    point: stop.location,
                    width: 110,
                    height: 80,
                    alignment: Alignment.topCenter,
                    child: _buildCustomStopMarker(stop),
                  ),

                // Live Moving Vehicle Marker (if active)
                if (widget.liveVehicleLocation != null)
                  Marker(
                    point: widget.liveVehicleLocation!,
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    child: _buildVehicleMarker(),
                  ),
              ],
            ),
          ],
        ),

        // Interactive Map Floating Controls (+ / - / Recenter)
        if (widget.showControls)
          Positioned(
            right: 12,
            bottom: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMapButton(icon: Icons.add, tooltip: 'Zoom In', onTap: _zoomIn),
                const SizedBox(height: 6),
                _buildMapButton(icon: Icons.remove, tooltip: 'Zoom Out', onTap: _zoomOut),
                const SizedBox(height: 6),
                _buildMapButton(icon: Icons.my_location_rounded, tooltip: 'Focus Route', onTap: _recenter),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMapButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0x1F000000), width: 1),
      ),
      elevation: 3,
      shadowColor: const Color(0x29000000),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, size: 18, color: const Color(0xFF164E2A)),
        ),
      ),
    );
  }

  Widget _buildCustomStopMarker(RouteStopPoint stop) {
    final bool isBuyer = stop.type == StopType.buyerDropoff;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rounded Text Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0x1F000000), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            stop.label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 3),

        // Circular Icon Badge
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isBuyer ? const Color(0xFF0F3E1E) : const Color(0xFF164E2A),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3D000000),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            isBuyer ? Icons.storefront_rounded : Icons.agriculture_rounded,
            color: Colors.white,
            size: 19,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleMarker() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF164E2A), width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40164E2A),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: const Icon(
        Icons.local_shipping_rounded,
        color: Color(0xFF164E2A),
        size: 24,
      ),
    );
  }
}

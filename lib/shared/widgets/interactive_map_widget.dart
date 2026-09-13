import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/logistics_route_model.dart';

enum MapLayerType { streets, satellite, voyager }

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

class _InteractiveMapWidgetState extends State<InteractiveMapWidget>
    with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  MapLayerType _currentLayer = MapLayerType.streets;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
      lowerBound: 0.9,
      upperBound: 1.25,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
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
    if (widget.liveVehicleLocation != null) {
      _mapController.move(widget.liveVehicleLocation!, widget.initialZoom + 0.5);
    } else {
      _mapController.move(widget.initialCenter, widget.initialZoom);
    }
  }

  void _openFullScreenMap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          appBar: AppBar(
            title: const Text('Live Route & Order Navigation'),
            backgroundColor: const Color(0xFF164E2A),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(
                  _currentLayer == MapLayerType.satellite
                      ? Icons.map_rounded
                      : Icons.satellite_alt_rounded,
                  color: Colors.white,
                ),
                tooltip: 'Switch Map View',
                onPressed: () {
                  setState(() {
                    _currentLayer = _currentLayer == MapLayerType.satellite
                        ? MapLayerType.streets
                        : MapLayerType.satellite;
                  });
                  (ctx as Element).markNeedsBuild();
                },
              ),
            ],
          ),
          body: InteractiveMapWidget(
            stops: widget.stops,
            polylinePoints: widget.polylinePoints,
            liveVehicleLocation: widget.liveVehicleLocation,
            initialCenter: widget.initialCenter,
            initialZoom: widget.initialZoom + 0.5,
            showControls: true,
            isDashedPolyline: widget.isDashedPolyline,
          ),
        ),
      ),
    );
  }

  String _getTileUrl() {
    switch (_currentLayer) {
      case MapLayerType.satellite:
        // Real Photographic High-Resolution Satellite Imagery (ESRI World Imagery - Free, No API Key needed)
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case MapLayerType.voyager:
        // Clean Voyager cartographic view
        return 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';
      case MapLayerType.streets:
        // Official Real OpenStreetMap Streets & Roads (Global, Free, No API Key needed)
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSatellite = _currentLayer == MapLayerType.satellite;

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.initialCenter,
            initialZoom: widget.initialZoom,
            minZoom: 4.0,
            maxZoom: 18.5,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            // 1. Real Tile Layer (OpenStreetMap / ESRI Satellite - Zero API Key required)
            TileLayer(
              urlTemplate: _getTileUrl(),
              userAgentPackageName: 'com.example.agriconnect',
              maxZoom: 19,
              errorTileCallback: (tile, error, stackTrace) {
                // Silently fallback without crashing
              },
            ),

            // 2. Real Route Polyline with shadow glow
            PolylineLayer(
              polylines: [
                // Outer glow shadow
                Polyline(
                  points: widget.polylinePoints,
                  strokeWidth: 6.5,
                  color: isSatellite
                      ? const Color(0x9922C55E)
                      : const Color(0x44164E2A),
                ),
                // Main route line
                Polyline(
                  points: widget.polylinePoints,
                  strokeWidth: 4.0,
                  color: isSatellite ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
                  pattern: widget.isDashedPolyline
                      ? StrokePattern.dashed(segments: const [10, 6])
                      : const StrokePattern.solid(),
                ),
              ],
            ),

            // 3. Custom Markers
            MarkerLayer(
              markers: [
                // Stop Markers (Farm Pickup, Mandi Dropoff, FPO Hub)
                for (final stop in widget.stops)
                  Marker(
                    point: stop.location,
                    width: 120,
                    height: 85,
                    alignment: Alignment.topCenter,
                    child: _buildCustomStopMarker(stop, isSatellite),
                  ),

                // Live Moving Vehicle Marker
                if (widget.liveVehicleLocation != null)
                  Marker(
                    point: widget.liveVehicleLocation!,
                    width: 54,
                    height: 54,
                    alignment: Alignment.center,
                    child: _buildVehicleMarker(),
                  ),
              ],
            ),
          ],
        ),

        // Layer Switcher Pill (Streets ↔ Satellite) on Top Left
        Positioned(
          left: 10,
          top: 10,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLayerPill('🗺️ Streets', MapLayerType.streets),
                const SizedBox(width: 4),
                _buildLayerPill('🛰️ Satellite', MapLayerType.satellite),
              ],
            ),
          ),
        ),

        // Interactive Map Floating Controls on Right (+, -, Recenter, Fullscreen)
        if (widget.showControls)
          Positioned(
            right: 10,
            bottom: 10,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMapButton(
                  icon: Icons.fullscreen_rounded,
                  tooltip: 'Fullscreen View',
                  onTap: () => _openFullScreenMap(context),
                ),
                const SizedBox(height: 6),
                _buildMapButton(icon: Icons.add_rounded, tooltip: 'Zoom In', onTap: _zoomIn),
                const SizedBox(height: 6),
                _buildMapButton(icon: Icons.remove_rounded, tooltip: 'Zoom Out', onTap: _zoomOut),
                const SizedBox(height: 6),
                _buildMapButton(
                  icon: Icons.my_location_rounded,
                  tooltip: 'Focus Vehicle / Route',
                  onTap: _recenter,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLayerPill(String label, MapLayerType type) {
    final isSelected = _currentLayer == type;
    return InkWell(
      onTap: () => setState(() => _currentLayer = type),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF15803D) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ),
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
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0x1F000000), width: 1),
      ),
      elevation: 4,
      shadowColor: const Color(0x33000000),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, size: 19, color: const Color(0xFF15803D)),
        ),
      ),
    );
  }

  Widget _buildCustomStopMarker(RouteStopPoint stop, bool isSatellite) {
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
            border: Border.all(
              color: isBuyer ? const Color(0xFF0369A1) : const Color(0xFF15803D),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            stop.label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: isBuyer ? const Color(0xFF0369A1) : const Color(0xFF15803D),
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
            color: isBuyer ? const Color(0xFF0284C7) : const Color(0xFF15803D),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 6,
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
    return ScaleTransition(
      scale: _pulseController,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF15803D), width: 2.8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x5015803D),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.local_shipping_rounded,
            color: Color(0xFF15803D),
            size: 24,
          ),
        ),
      ),
    );
  }
}

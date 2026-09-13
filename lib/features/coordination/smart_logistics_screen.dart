import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';
import '../../models/logistics_route_model.dart';
import '../../services/app_state.dart';
import '../../services/logistics_service.dart';
import '../../shared/widgets/interactive_map_widget.dart';

class SmartLogisticsScreen extends StatefulWidget {
  final AppState appState;

  const SmartLogisticsScreen({super.key, required this.appState});

  @override
  State<SmartLogisticsScreen> createState() => _SmartLogisticsScreenState();
}

class _SmartLogisticsScreenState extends State<SmartLogisticsScreen> {
  late SmartRouteData _routeData;
  bool _isPickupStarted = false;

  @override
  void initState() {
    super.initState();
    _routeData = LogisticsService.getDemoSmartRoute();
  }

  void _handleStartPickup() {
    setState(() {
      _isPickupStarted = !_isPickupStarted;
      _routeData = _routeData.copyWith(
        status: _isPickupStarted ? RouteStatus.pickupStarted : RouteStatus.optimized,
        currentVehiclePosition: _isPickupStarted
            ? const LatLng(17.3450, 78.2380) // At Farm B
            : LogisticsService.farmALocation,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isPickupStarted
              ? 'Pickup Started! Optimized multi-farm aggregation en route.'
              : 'Route reset to Optimized state.',
        ),
        backgroundColor: const Color(0xFF78350F),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF164E2A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Smart Route',
          style: TextStyle(
            color: Color(0xFF164E2A),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF111827)),
            onPressed: () {
              _showRouteMenu(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalHeight = constraints.maxHeight;
            // Map occupies 48-52% of the viewport height on any mobile screen
            final mapHeight = (totalHeight * 0.48).clamp(260.0, 420.0);

            return Column(
              children: [
                // 1. REAL INTERACTIVE MAP
                SizedBox(
                  height: mapHeight,
                  width: double.infinity,
                  child: InteractiveMapWidget(
                    stops: _routeData.stops,
                    polylinePoints: _routeData.polylinePoints,
                    liveVehicleLocation: _isPickupStarted
                        ? const LatLng(17.3450, 78.2380)
                        : null,
                    initialCenter: const LatLng(17.3380, 78.3400),
                    initialZoom: 10.4,
                    isDashedPolyline: true,
                    showControls: true,
                  ),
                ),

                // 2. BOTTOM INFORMATION PANEL
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFFCFDFD),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 10,
                          offset: Offset(0, -3),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Handle Pill
                          Center(
                            child: Container(
                              width: 44,
                              height: 4.5,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1D5DB),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Title & ETA Box Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Pickup Route',
                                      style: TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 20,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Container(
                                          width: 7,
                                          height: 7,
                                          decoration: BoxDecoration(
                                            color: _isPickupStarted
                                                ? const Color(0xFFD97706)
                                                : const Color(0xFF16A34A),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Route Status: ${_routeData.statusDisplay}',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              color: _isPickupStarted
                                                  ? const Color(0xFF92400E)
                                                  : const Color(0xFF14532D),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              // ETA Box
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFBBF7D0)),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _routeData.estimatedDuration,
                                      style: const TextStyle(
                                        color: Color(0xFF164E2A),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const Text(
                                      'Est. Time',
                                      style: TextStyle(
                                        color: Color(0xFF4B5563),
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Two Statistics Cards Row
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.alt_route_rounded,
                                  iconBg: const Color(0xFFEFF6FF),
                                  iconColor: const Color(0xFF1D4ED8),
                                  label: 'Total Distance',
                                  value: '${_routeData.totalDistanceKm.toInt()} km',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.hourglass_top_rounded,
                                  iconBg: const Color(0xFFF0FDF4),
                                  iconColor: const Color(0xFF15803D),
                                  label: 'Capacity',
                                  value: '${_routeData.totalCapacityKg.toInt()} kg',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Route Stops Card
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x06000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Route Stops',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Stop 1
                                _buildRouteStopItem(
                                  dotColor: const Color(0xFF16A34A),
                                  title: 'Farm 1 (Pickup Stop)',
                                  subtitle: 'Pickup: 300kg Wheat',
                                  time: '10:00 AM',
                                  showConnector: true,
                                ),

                                // Stop 2
                                _buildRouteStopItem(
                                  dotColor: const Color(0xFF94A3B8),
                                  title: 'Farm 2 (Cluster Stop)',
                                  subtitle: 'Pickup: 700kg Wheat',
                                  time: '11:30 AM',
                                  showConnector: true,
                                ),

                                // Stop 3
                                _buildRouteStopItem(
                                  dotColor: const Color(0xFF164E2A),
                                  title: 'Urban Buyer Hub',
                                  subtitle: 'Dropoff: 1000kg Total',
                                  time: '2:20 PM',
                                  showConnector: false,
                                  isDestination: true,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Start Pickup Primary Button
                          InkWell(
                            onTap: _handleStartPickup,
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFF78350F), // Warm brown/amber
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x4078350F),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.navigation_rounded, color: Color(0xFFFEF3C7), size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isPickupStarted ? 'PAUSE PICKUP ROUTE' : 'Start Pickup',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14.5,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteStopItem({
    required Color dotColor,
    required String title,
    required String subtitle,
    required String time,
    required bool showConnector,
    bool isDestination = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indicator dot and connector line
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            if (showConnector)
              Container(
                width: 1.5,
                height: 38,
                color: const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 10),

        // Stop content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: showConnector ? 14 : 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: isDestination ? const Color(0xFF164E2A) : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showRouteMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.share_location_rounded, color: AppColors.primary),
                title: const Text('Share Live Route with Buyer'),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const Icon(Icons.refresh_rounded, color: AppColors.secondary),
                title: const Text('Re-calculate with Traffic Data'),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const Icon(Icons.track_changes_rounded, color: AppColors.textNavy),
                title: const Text('Open Order Tracking View'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, '/coordination/tracking');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

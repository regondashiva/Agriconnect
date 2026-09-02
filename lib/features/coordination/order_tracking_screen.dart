import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../models/logistics_route_model.dart';
import '../../services/app_state.dart';
import '../../services/logistics_service.dart';
import '../../shared/widgets/interactive_map_widget.dart';

class OrderTrackingScreen extends StatefulWidget {
  final AppState appState;

  const OrderTrackingScreen({super.key, required this.appState});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  bool _isLiveActive = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFDFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF164E2A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Order #AGR1024',
          style: TextStyle(
            color: Color(0xFF164E2A),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: Color(0xFF111827)),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP PRODUCE CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            '500 kg Tomato',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.local_shipping_rounded, color: Color(0xFF16A34A), size: 14),
                              SizedBox(width: 4),
                              Text(
                                'In Transit',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Grade A • Organic',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 2. REAL INTERACTIVE MAP CONTAINER WITH LIVE OVERLAY
              Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    children: [
                      // Real Interactive Map
                      InteractiveMapWidget(
                        stops: [
                          RouteStopPoint(
                            id: 'p1',
                            label: 'Oakwood Farm Pickup',
                            personName: 'Ramesh',
                            crop: 'Tomato',
                            quantityKg: 500,
                            scheduledTime: '10:00 AM',
                            location: const LatLng(17.3100, 78.1400),
                            type: StopType.farmPickup,
                            isCompleted: true,
                          ),
                          RouteStopPoint(
                            id: 'p2',
                            label: 'Urban Buyer Mandi',
                            personName: '',
                            crop: 'Tomato',
                            quantityKg: 500,
                            scheduledTime: '4:30 PM',
                            location: const LatLng(17.3680, 78.5420),
                            type: StopType.buyerDropoff,
                            isCompleted: false,
                          ),
                        ],
                        polylinePoints: LogisticsService.smartRoutePolyline,
                        liveVehicleLocation: LogisticsService.vehicleLiveLocation,
                        initialCenter: const LatLng(17.3450, 78.3300),
                        initialZoom: 10.2,
                        isDashedPolyline: false,
                        showControls: false,
                      ),

                      // Overlay Badge at Bottom of Map
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1F000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    'Estimated Arrival',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '4:30 PM',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF164E2A),
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() => _isLiveActive = !_isLiveActive);
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _isLiveActive ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.navigation_rounded,
                                        size: 14,
                                        color: _isLiveActive ? const Color(0xFF14532D) : const Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Live',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: _isLiveActive ? const Color(0xFF14532D) : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 3. TWO STATS BOXES
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      icon: Icons.location_on_outlined,
                      number: '3',
                      label: 'Pickup Locations',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      icon: Icons.shopping_bag_outlined,
                      number: '1',
                      label: 'Buyer Destination',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 4. JOURNEY CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
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
                      'Journey',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 14),

                    _buildJourneyStep(
                      title: 'Order Created',
                      time: 'Oct 24, 08:00 AM',
                      isCompleted: true,
                    ),
                    _buildJourneyStep(
                      title: 'Supply Matched',
                      time: 'Oct 24, 09:30 AM',
                      isCompleted: true,
                    ),
                    _buildJourneyStep(
                      title: 'Supply Aggregated',
                      time: 'Oct 25, 11:15 AM',
                      isCompleted: true,
                    ),
                    _buildJourneyStep(
                      title: 'Quality Evidence Submitted',
                      time: 'Oct 25, 01:00 PM',
                      isCompleted: true,
                    ),
                    _buildJourneyStep(
                      title: 'Pickup Scheduled',
                      time: 'Oct 26, 07:00 AM',
                      isCompleted: true,
                    ),
                    _buildJourneyStep(
                      title: 'In Transit',
                      time: 'Current Status',
                      isCurrent: true,
                      extraBadge: 'Vehicle: HR 26 DK 1234',
                    ),
                    _buildJourneyStep(
                      title: 'Delivered',
                      time: 'Pending',
                      isPending: true,
                    ),
                    _buildJourneyStep(
                      title: 'Settlement',
                      time: 'Pending',
                      isPending: true,
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Button to open full route
              Center(
                child: TextButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/coordination/logistics'),
                  icon: const Icon(Icons.alt_route_rounded, size: 16, color: Color(0xFF164E2A)),
                  label: const Text(
                    'View Full Multi-Farm Smart Route',
                    style: TextStyle(
                      color: Color(0xFF164E2A),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String number,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF164E2A), size: 22),
          const SizedBox(height: 6),
          Text(
            number,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyStep({
    required String title,
    required String time,
    bool isCompleted = false,
    bool isCurrent = false,
    bool isPending = false,
    bool isLast = false,
    String? extraBadge,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left timeline node
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF14532D)
                    : isCurrent
                        ? const Color(0xFF86EFAC)
                        : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? const Color(0xFF14532D)
                      : isCurrent
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : isCurrent
                        ? Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF14532D),
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
              ),
            ),
            if (!isLast)
              Container(
                width: 1.8,
                height: 36,
                color: isCompleted ? const Color(0xFF14532D) : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 12),

        // Step content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: isPending ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: isPending ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (extraBadge != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_shipping_outlined, size: 12, color: Color(0xFF475569)),
                        const SizedBox(width: 4),
                        Text(
                          extraBadge,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Order Tracking Help'),
        content: const Text(
          'AgriConnect monitors aggregated multi-farm produce in real-time. Supply is verified via AI quality grading and tracked till mandi or household delivery.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

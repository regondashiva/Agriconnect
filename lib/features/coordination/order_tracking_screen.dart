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
  SmartRouteData? _routeData;

  @override
  void initState() {
    super.initState();
    _loadDynamicRoute();
  }

  Future<void> _loadDynamicRoute() async {
    final route = await LogisticsService.getOptimizedRoute();
    if (mounted) {
      setState(() {
        _routeData = route;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.appState.currentBulkOrder;
    final isDelivered = widget.appState.isEscrowSettled;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFDFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF164E2A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Order #${order.orderId}',
          style: const TextStyle(
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
                        Expanded(
                          child: Text(
                            '${order.totalQuantityKg.toInt()} kg ${order.cropName}',
                            style: const TextStyle(
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
                            color: isDelivered ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isDelivered ? Icons.check_circle_rounded : Icons.local_shipping_rounded,
                                color: isDelivered ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isDelivered ? 'Delivered' : 'In Transit (20% Escrow)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isDelivered ? const Color(0xFF15803D) : const Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Total Value: ₹${order.totalAmount.toInt()} • 3 Verified Farmers',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 2. REAL INTERACTIVE MAP CONTAINER (OpenStreetMap & Satellite)
              Container(
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0E000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: InteractiveMapWidget(
                    stops: _routeData?.stops ?? const [
                      RouteStopPoint(
                        id: 'p1',
                        label: 'Oakwood Farm Pickup',
                        personName: 'Cluster Verified Farmer',
                        crop: 'Tomato',
                        quantityKg: 300,
                        scheduledTime: '10:00 AM',
                        location: LatLng(17.3060, 78.1360),
                        type: StopType.farmPickup,
                        isCompleted: true,
                      ),
                      RouteStopPoint(
                        id: 'p2',
                        label: 'Urban Buyer Mandi',
                        personName: 'FreshBasket Mandi',
                        crop: 'Tomato',
                        quantityKg: 500,
                        scheduledTime: '4:30 PM',
                        location: LatLng(17.3680, 78.5420),
                        type: StopType.buyerDropoff,
                        isCompleted: false,
                      ),
                    ],
                    polylinePoints: _routeData?.polylinePoints ?? LogisticsService.smartRoutePolyline,
                    liveVehicleLocation: LogisticsService.vehicleLiveLocation,
                    initialCenter: const LatLng(17.3450, 78.3300),
                    initialZoom: 10.4,
                    isDashedPolyline: false,
                    showControls: true,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Live Route Status Bar (Neat and unobstructed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFDCFCE7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.schedule_rounded, color: Color(0xFF15803D), size: 18),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Estimated Arrival',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '4:30 PM (On Schedule)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF164E2A),
                              ),
                            ),
                          ],
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
                              'Live GPS',
                              style: TextStyle(
                                fontSize: 11.5,
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
                      time: isDelivered ? 'Completed' : 'Current Status',
                      isCompleted: isDelivered,
                      isCurrent: !isDelivered,
                      extraBadge: 'Vehicle: TS 07 UA 4821 (20% Escrow Locked)',
                    ),
                    _buildJourneyStep(
                      title: 'Delivered',
                      time: isDelivered ? 'Delivered & Confirmed' : 'Awaiting 6-digit Delivery OTP',
                      isCompleted: isDelivered,
                      isCurrent: isDelivered,
                      isPending: !isDelivered,
                    ),
                    _buildJourneyStep(
                      title: 'Direct Jan Dhan Settlement',
                      time: isDelivered ? '₹${order.totalAmount.toInt()} Disbursed' : 'Pending OTP verification',
                      isCompleted: isDelivered,
                      isPending: !isDelivered,
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Escrow Milestone Action Container
              if (!isDelivered)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lock_clock_rounded, color: Color(0xFF15803D), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Escrow Milestone: 20% Locked',
                            style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF166534), fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹${(order.totalAmount * 0.20).toInt()} advance is locked in escrow. Upon arrival at Mandi, verify receiver 6-digit OTP to release remaining 80% (₹${(order.totalAmount * 0.80).toInt()}) directly to farmer Jan Dhan accounts.',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF164E2A),
                          minimumSize: const Size(double.infinity, 46),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.pin_outlined, color: Colors.white, size: 18),
                        label: const Text(
                          'VERIFY DELIVERY OTP & RELEASE 80% ESCROW',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12.5),
                        ),
                        onPressed: () => _showOtpReleaseDialog(context, order.orderId),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Delivery Verified & 100% Settled',
                            style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF15803D), fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Delivery confirmed. All ₹${order.totalAmount.toInt()} has been disbursed directly to 3 registered Jan Dhan farmer accounts.',
                        style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155)),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF164E2A),
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 18),
                        label: const Text(
                          'VIEW JAN DHAN SETTLEMENT DETAILS',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5),
                        ),
                        onPressed: () => Navigator.pushNamed(context, '/coordination/settlement'),
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

  void _showOtpReleaseDialog(BuildContext context, String orderId) {
    final otpController = TextEditingController(text: widget.appState.deliveryOtp);
    bool isSubmitting = false;
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final remainingAmount = (widget.appState.currentBulkOrder.totalAmount * 0.8).toInt();

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.verified_user_rounded, color: Color(0xFF16A34A), size: 28),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Delivery OTP Verification',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter the 6-digit OTP provided by the buyer/receiver at Mandi to confirm produce delivery and release ₹$remainingAmount (80%) directly to farmer Jan Dhan accounts.',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 18, color: Color(0xFF164E2A)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Test 6-digit OTP: ${widget.appState.deliveryOtp}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF164E2A)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 8),
                  decoration: InputDecoration(
                    hintText: '459012',
                    counterText: '',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    errorText: errorText,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF164E2A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (otpController.text.trim().length != 6) {
                          setDialogState(() => errorText = 'Please enter a valid 6-digit OTP');
                          return;
                        }
                        setDialogState(() {
                          isSubmitting = true;
                          errorText = null;
                        });

                        final success = await widget.appState.verifyDeliveryAndReleaseEscrow(
                          orderId: orderId,
                          otp: otpController.text.trim(),
                        );

                        setDialogState(() => isSubmitting = false);

                        if (context.mounted) {
                          if (success) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF15803D),
                                content: Text('Delivery Verified! ₹$remainingAmount released to farmer Jan Dhan accounts.'),
                              ),
                            );
                            setState(() {});
                            Navigator.pushNamed(context, '/coordination/settlement');
                          } else {
                            setDialogState(() {
                              errorText = widget.appState.errorMessage ?? 'OTP verification failed';
                            });
                          }
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Verify & Release 80%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );
  }
}

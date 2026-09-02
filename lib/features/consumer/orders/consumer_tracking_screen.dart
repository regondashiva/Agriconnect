import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/logistics_route_model.dart';
import '../../../services/app_state.dart';
import '../../../services/logistics_service.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/interactive_map_widget.dart';
import '../../../shared/widgets/order_timeline.dart';
import '../../../shared/widgets/status_chip.dart';

class ConsumerTrackingScreen extends StatelessWidget {
  final AppState appState;

  const ConsumerTrackingScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final order = appState.currentConsumerOrder;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Track Order #${order.orderId}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Status Top Header
              AppCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order #${order.orderId}',
                                style: AppTypography.headlineSmall.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(order.cropName, style: AppTypography.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusChip.success(order.currentStatusText),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _buildMetric('ETA', order.eta)),
                          Container(width: 1, height: 26, color: AppColors.outlineVariant),
                          Expanded(child: _buildMetric('Amount', '₹${order.totalAmount.toInt()}')),
                          Container(width: 1, height: 26, color: AppColors.outlineVariant),
                          Expanded(child: _buildMetric('Status', 'Out for Delivery')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Interactive Delivery Map Card
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceContainerHigh),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: InteractiveMapWidget(
                    stops: [
                      RouteStopPoint(
                        id: 'fpo_hub',
                        label: 'FPO Hub',
                        personName: 'Ranga Reddy',
                        crop: 'Produce',
                        quantityKg: 3.0,
                        scheduledTime: '2:00 PM',
                        location: LogisticsService.fpoHubLocation,
                        type: StopType.fpoHub,
                        isCompleted: true,
                      ),
                      RouteStopPoint(
                        id: 'consumer_home',
                        label: 'Home',
                        personName: 'Ananya',
                        crop: 'Produce',
                        quantityKg: 3.0,
                        scheduledTime: '4:30 PM',
                        location: LogisticsService.consumerLocation,
                        type: StopType.consumerDelivery,
                        isCompleted: false,
                      ),
                    ],
                    polylinePoints: LogisticsService.consumerOrderPolyline,
                    liveVehicleLocation: LogisticsService.vehicleLiveLocation,
                    initialCenter: const LatLng(17.3850, 78.3100),
                    initialZoom: 10.5,
                    isDashedPolyline: false,
                    showControls: false,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Delivery Partner Card
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primaryContainer,
                      child: Icon(Icons.two_wheeler_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Delivery Agent: Mahesh', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 1),
                          Text('Direct from Ranga Reddy FPO Hub • 2.4 km away', style: AppTypography.bodySmall.copyWith(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone, color: AppColors.primary),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Calling Delivery Partner Mahesh (+91 98765 00112)...')),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Live Delivery Stages',
                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 10),

              OrderTimelineWidget(steps: order.timeline),

              const SizedBox(height: 14),

              PrimaryButton(
                text: 'BACK TO PRODUCE STORE',
                icon: Icons.storefront_outlined,
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/consumer/home', (r) => false);
                },
              ),

              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String val) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(val, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 1),
        Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

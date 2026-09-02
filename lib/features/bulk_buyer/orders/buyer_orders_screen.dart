import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../services/app_state.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_chip.dart';

class BuyerOrdersScreen extends StatelessWidget {
  final AppState appState;

  const BuyerOrdersScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final order = appState.currentBulkOrder;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Wholesale Orders'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Consignments',
              style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Track incoming farm-aggregated deliveries in real-time.',
              style: AppTypography.bodySmall,
            ),

            const SizedBox(height: 16),

            AppCard(
              onTap: () {
                Navigator.pushNamed(context, '/coordination/tracking');
              },
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order #${order.orderId}', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w800)),
                          Text('500 kg Tomato (Grade A Aggregated)', style: AppTypography.bodySmall.copyWith(fontSize: 12)),
                        ],
                      ),
                      StatusChip.orange(order.currentStatusText),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCol('Total Amount', '₹10,000'),
                      _buildCol('Supply Sources', '3 Farmers'),
                      _buildCol('ETA at Gate', order.eta),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_shipping_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Driver Mahesh (AP 28 TA 4512) en route to Mandi Gate #3',
                            style: AppTypography.bodySmall.copyWith(fontSize: 12, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'View Live Route & Settlement Details →',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCol(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
        const SizedBox(height: 2),
        Text(val, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary)),
      ],
    );
  }
}

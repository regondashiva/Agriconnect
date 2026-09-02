import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../services/app_state.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_chip.dart';

class ManageFarmersScreen extends StatelessWidget {
  final AppState appState;

  const ManageFarmersScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Enrolled Farmers (Cluster)'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        children: [
          Text(
            'Member Farmers & Ready Supply',
            style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Cluster farmers available for bulk consignment aggregation.',
            style: AppTypography.bodySmall,
          ),

          const SizedBox(height: 16),

          _buildFarmerItem(
            name: 'Ramesh Reddy',
            location: 'Chevella Village',
            phone: '+91 98765 43210',
            crop: 'Tomato (Hybrid Red)',
            qty: '100 kg',
            status: 'Ready for Pickup',
            qualityScore: '87/100',
          ),
          const SizedBox(height: 10),
          _buildFarmerItem(
            name: 'Suresh Rao',
            location: 'Shabad Center Farm',
            phone: '+91 98480 55443',
            crop: 'Tomato (Hybrid Red)',
            qty: '150 kg',
            status: 'Ready for Pickup',
            qualityScore: '89/100',
          ),
          const SizedBox(height: 10),
          _buildFarmerItem(
            name: 'Ravi Kumar',
            location: 'Moinabad Cluster',
            phone: '+91 99123 77889',
            crop: 'Tomato (Hybrid Red)',
            qty: '250 kg',
            status: 'Ready for Pickup',
            qualityScore: '86/100',
          ),
          const SizedBox(height: 10),
          _buildFarmerItem(
            name: 'Venkat Narayana',
            location: 'Vikarabad Border',
            phone: '+91 94400 11223',
            crop: 'Potato (Jyoti)',
            qty: '400 kg',
            status: 'Harvesting in 2 days',
            qualityScore: '88/100',
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerItem({
    required String name,
    required String location,
    required String phone,
    required String crop,
    required String qty,
    required String status,
    required String qualityScore,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primaryContainer,
                      child: Text(name.substring(0, 1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w800, fontSize: 13.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '$location • $phone',
                            style: AppTypography.bodySmall.copyWith(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusChip.success(status),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Supply: $crop ($qty)', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700)),
                Text('AI Quality: $qualityScore', style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

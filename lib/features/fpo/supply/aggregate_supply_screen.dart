import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../services/app_state.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_chip.dart';

class AggregateSupplyScreen extends StatefulWidget {
  final AppState appState;

  const AggregateSupplyScreen({super.key, required this.appState});

  @override
  State<AggregateSupplyScreen> createState() => _AggregateSupplyScreenState();
}

class _AggregateSupplyScreenState extends State<AggregateSupplyScreen> {
  final Set<String> _selectedFarmerIds = {'farmer_001', 'farmer_002', 'farmer_003'};

  @override
  Widget build(BuildContext context) {
    double totalKg = 0;
    if (_selectedFarmerIds.contains('farmer_001')) totalKg += 100;
    if (_selectedFarmerIds.contains('farmer_002')) totalKg += 150;
    if (_selectedFarmerIds.contains('farmer_003')) totalKg += 250;

    final isTargetFulfilled = totalKg >= 500;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Aggregate Cluster Supply'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Target Demand Header
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Target Wholesale Demand', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w800)),
                        StatusChip.orange('500 kg Required'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Buyer: FreshBasket Wholesale Mandi • Kothapet', style: AppTypography.bodySmall),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (totalKg / 500.0).clamp(0.0, 1.0),
                        minHeight: 10,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Selected Supply: ${totalKg.toInt()} / 500 kg', style: AppTypography.labelSmall),
                        Text(
                          isTargetFulfilled ? '100% Target Met' : '${((totalKg / 500) * 100).toInt()}% Met',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isTargetFulfilled ? AppColors.success : AppColors.harvestOrangeDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Select Member Farmer Lots to Batch',
                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Combine compatible lots into one unified logistics pickup consignment.',
                style: AppTypography.bodySmall,
              ),

              const SizedBox(height: 12),

              _buildSelectableLot(
                id: 'farmer_001',
                name: 'Ramesh Reddy (Chevella)',
                crop: 'Tomato Grade A',
                qtyKg: 100,
                quality: '87/100',
              ),
              const SizedBox(height: 10),
              _buildSelectableLot(
                id: 'farmer_002',
                name: 'Suresh Rao (Shabad)',
                crop: 'Tomato Grade A',
                qtyKg: 150,
                quality: '89/100',
              ),
              const SizedBox(height: 10),
              _buildSelectableLot(
                id: 'farmer_003',
                name: 'Ravi Kumar (Moinabad)',
                crop: 'Tomato Grade A',
                qtyKg: 250,
                quality: '86/100',
              ),

              const SizedBox(height: 24),

              PrimaryButton(
                text: 'CREATE AGGREGATED SUPPLY & MATCH',
                icon: Icons.check_circle_rounded,
                onPressed: () {
                  Navigator.pushNamed(context, '/coordination/aggregation');
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectableLot({
    required String id,
    required String name,
    required String crop,
    required double qtyKg,
    required String quality,
  }) {
    final isSelected = _selectedFarmerIds.contains(id);

    return AppCard(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedFarmerIds.remove(id);
          } else {
            _selectedFarmerIds.add(id);
          }
        });
      },
      backgroundColor: isSelected ? AppColors.surfaceContainerLow : Colors.white,
      borderColor: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            activeColor: AppColors.primary,
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _selectedFarmerIds.add(id);
                } else {
                  _selectedFarmerIds.remove(id);
                }
              });
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('$crop • AI Quality: $quality', style: AppTypography.bodySmall.copyWith(fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${qtyKg.toInt()} kg',
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

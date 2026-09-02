import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/produce_model.dart';
import '../../../services/app_state.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_card.dart';

class CreateRequirementScreen extends StatefulWidget {
  final AppState appState;

  const CreateRequirementScreen({super.key, required this.appState});

  @override
  State<CreateRequirementScreen> createState() => _CreateRequirementScreenState();
}

class _CreateRequirementScreenState extends State<CreateRequirementScreen> {
  final _cropController = TextEditingController(text: 'Tomato (Hybrid Red)');
  final _quantityController = TextEditingController(text: '500');
  final _locationController = TextEditingController(text: 'Plot 42, Kothapet Wholesale Mandi, Hyderabad');
  final _minPriceController = TextEditingController(text: '19');
  final _maxPriceController = TextEditingController(text: '22');
  QualityGrade _grade = QualityGrade.gradeA;
  bool _isSearching = false;

  void _handleSubmit() {
    setState(() => _isSearching = true);

    Future.delayed(const Duration(milliseconds: 1400), () {
      final double qty = double.tryParse(_quantityController.text) ?? 500.0;
      final double minP = double.tryParse(_minPriceController.text) ?? 19.0;
      final double maxP = double.tryParse(_maxPriceController.text) ?? 22.0;

      widget.appState.createBulkRequirement(
        cropName: _cropController.text,
        quantityKg: qty,
        grade: _grade,
        location: _locationController.text,
        priceMin: minP,
        priceMax: maxP,
      );

      setState(() => _isSearching = false);
      Navigator.pushReplacementNamed(context, '/buyer/matches');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Bulk Demand'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Post Volume Requirement',
                style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'AgriConnect AI coordinates smallholder farmers & FPOs to aggregate and fulfill your lot.',
                style: AppTypography.bodySmall,
              ),

              const SizedBox(height: 20),

              Text('Produce / Crop', style: AppTypography.labelLarge),
              const SizedBox(height: 6),
              TextField(
                controller: _cropController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Tomato, Potato, Onion',
                  prefixIcon: Icon(Icons.eco_rounded, color: AppColors.primary),
                ),
              ),

              const SizedBox(height: 16),

              Text('Required Quantity (kg)', style: AppTypography.labelLarge),
              const SizedBox(height: 6),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '500',
                  suffixText: 'kg',
                  prefixIcon: Icon(Icons.scale_rounded, color: AppColors.primary),
                ),
              ),

              const SizedBox(height: 16),

              Text('Quality Grade Requirement', style: AppTypography.labelLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildGradeChip('Grade A (Wholesale Premium)', QualityGrade.gradeA),
                  const SizedBox(width: 10),
                  _buildGradeChip('Grade B (Standard)', QualityGrade.gradeB),
                ],
              ),

              const SizedBox(height: 16),

              Text('Delivery Destination Location', style: AppTypography.labelLarge),
              const SizedBox(height: 6),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: 'Mandi gate or warehouse address',
                  prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primary),
                ),
              ),

              const SizedBox(height: 16),

              // Price Range & AI Price Insight
              Text('Target Price Range (₹ / kg)', style: AppTypography.labelLarge),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(prefixText: '₹ ', hintText: 'Min (19)'),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('to', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _maxPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(prefixText: '₹ ', hintText: 'Max (22)'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              AppCard(
                backgroundColor: AppColors.surfaceContainerLow,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.harvestOrange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AI Recommendation: ₹19–₹21/kg aligns with local cluster harvest & Mandi index.',
                        style: AppTypography.bodySmall.copyWith(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              PrimaryButton(
                text: _isSearching ? 'FINDING & AGGREGATING SUPPLY…' : 'FIND SUPPLY (92% MATCH)',
                icon: Icons.search_rounded,
                isLoading: _isSearching,
                onPressed: _handleSubmit,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradeChip(String label, QualityGrade grade) {
    final isSelected = _grade == grade;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _grade = grade),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceContainerLow : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

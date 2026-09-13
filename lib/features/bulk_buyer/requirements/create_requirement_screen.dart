import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  String _selectedCrop = 'Tomato';
  final List<String> _cropOptions = [
    'Tomato',
    'Onion',
    'Potato',
    'Chilli',
    'Cotton',
    'Wheat',
    'Rice',
    'Carrot',
    'Cabbage',
    'Maize',
  ];
  final _quantityController = TextEditingController(text: '500');
  final _locationController = TextEditingController(text: 'Plot 42, Kothapet Wholesale Mandi, Hyderabad');
  final _minPriceController = TextEditingController(text: '19');
  final _maxPriceController = TextEditingController(text: '22');
  DateTime _requiredDate = DateTime.now().add(const Duration(days: 2));
  final double _deliveryLat = 17.3850;
  final double _deliveryLng = 78.4867;
  QualityGrade _grade = QualityGrade.gradeA;
  bool _isSearching = false;

  Future<void> _handleSubmit() async {
    final double qty = double.tryParse(_quantityController.text) ?? 0.0;
    final double minP = double.tryParse(_minPriceController.text) ?? 0.0;
    final double maxP = double.tryParse(_maxPriceController.text) ?? 0.0;

    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid quantity greater than 0 kg'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (minP <= 0 || maxP <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid target prices greater than ₹0'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (maxP < minP) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum price cannot be less than minimum price'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSearching = true);
    try {
      await widget.appState.createBulkRequirement(
        cropName: _selectedCrop,
        quantityKg: qty,
        grade: _grade,
        location: _locationController.text.trim(),
        priceMin: minP,
        priceMax: maxP,
        requiredDate: _requiredDate,
        deliveryLat: _deliveryLat,
        deliveryLng: _deliveryLng,
      );

      if (!mounted) return;
      if (widget.appState.errorMessage == null) {
        Navigator.pushReplacementNamed(context, '/buyer/matches');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.appState.errorMessage ?? 'Failed to post requirement'),
          backgroundColor: AppColors.error,
        ));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: AppColors.error,
      ));
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
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
              DropdownButtonFormField<String>(
                value: _selectedCrop,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.eco_rounded, color: AppColors.primary),
                  border: OutlineInputBorder(),
                ),
                items: _cropOptions.map((crop) {
                  return DropdownMenuItem<String>(
                    value: crop,
                    child: Text(crop, style: const TextStyle(fontWeight: FontWeight.w600)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCrop = val);
                  }
                },
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

              // Required By Date Picker
              Text('Required By Date', style: AppTypography.labelLarge),
              const SizedBox(height: 6),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _requiredDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (picked != null) {
                    setState(() => _requiredDate = picked);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('yyyy-MM-dd (EEEE)').format(_requiredDate),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      const Text(
                        'Change',
                        style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
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

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/produce_model.dart';
import '../../../services/app_state.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_card.dart';

class AddProduceScreen extends StatefulWidget {
  final AppState appState;

  const AddProduceScreen({super.key, required this.appState});

  @override
  State<AddProduceScreen> createState() => _AddProduceScreenState();
}

class _AddProduceScreenState extends State<AddProduceScreen> {
  final _cropController = TextEditingController(text: 'Tomato (Hybrid Red)');
  final _quantityController = TextEditingController(text: '100');
  final _locationController = TextEditingController(text: 'Chevella Farm Hub');
  QualityGrade _grade = QualityGrade.gradeA;
  int _photosAttached = 4;
  bool _isAnalyzing = false;
  bool _isSuccess = false;

  void _handleSubmit() {
    setState(() => _isAnalyzing = true);

    Future.delayed(const Duration(milliseconds: 1400), () {
      final double qty = double.tryParse(_quantityController.text) ?? 100.0;
      final newItem = ProduceItem(
        id: 'PROD-${DateTime.now().millisecondsSinceEpoch}',
        farmerId: widget.appState.currentUser.id,
        farmerName: widget.appState.currentUser.name,
        cropName: _cropController.text,
        quantityKg: qty,
        grade: _grade,
        availableDate: DateTime.now().add(const Duration(days: 1)),
        location: _locationController.text,
        qualityScore: 87.0,
        confidenceScore: 91.0,
      );

      widget.appState.addProduceItem(newItem);

      setState(() {
        _isAnalyzing = false;
        _isSuccess = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Produce Listed')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.successLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
                ),
                const SizedBox(height: 20),
                Text(
                  'Produce Listed Successfully!',
                  style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '100 kg Tomato is now active in AgriConnect pool and eligible for 92% Smart Buyer Match.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: 'VIEW BUYER OPPORTUNITIES',
                  icon: Icons.auto_awesome,
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/farmer/matches/detail');
                  },
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  text: 'VIEW MY LISTINGS',
                  icon: Icons.inventory_2_outlined,
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/farmer/home');
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('List Your Produce'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'List Farm Harvest',
                style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Add details and photo evidence for AI-assisted quality grading.',
                style: AppTypography.bodySmall,
              ),

              const SizedBox(height: 20),

              // Crop Name
              Text('Crop / Variety', style: AppTypography.labelLarge),
              const SizedBox(height: 6),
              TextField(
                controller: _cropController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Tomato (Hybrid Red)',
                  prefixIcon: Icon(Icons.eco_rounded, color: AppColors.primary),
                ),
              ),

              const SizedBox(height: 16),

              // Quantity & Unit
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quantity', style: AppTypography.labelLarge),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '100',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Unit', style: AppTypography.labelLarge),
                        const SizedBox(height: 6),
                        Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.outlineVariant, width: 1.5),
                          ),
                          child: const Center(
                            child: Text(
                              'Kilograms (kg)',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Quality Grade Selection
              Text('Quality Grade', style: AppTypography.labelLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildGradeChip('Grade A (Premium)', QualityGrade.gradeA),
                  const SizedBox(width: 10),
                  _buildGradeChip('Grade B (Standard)', QualityGrade.gradeB),
                ],
              ),

              const SizedBox(height: 20),

              // Photo Quality Evidence
              Text('Quality Evidence Photos (Required)', style: AppTypography.labelLarge),
              const SizedBox(height: 4),
              Text(
                'Upload 3-5 clear photos of batch for AI quality confidence analysis.',
                style: AppTypography.bodySmall.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 10),

              AppCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildPhotoSlot('Top View', true),
                        _buildPhotoSlot('Cross-Sec', true),
                        _buildPhotoSlot('Batch Box', true),
                        _buildPhotoSlot('+ Add', false),
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
                        children: [
                          const Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            '$_photosAttached photos ready for AI assistive grading',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // AI Disclaimer
              Text(
                AppStrings.aiQualityDisclaimer,
                style: AppTypography.bodySmall.copyWith(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 28),

              PrimaryButton(
                text: _isAnalyzing ? 'ANALYZING BATCH & LISTING…' : 'LIST PRODUCE',
                icon: Icons.cloud_upload_outlined,
                isLoading: _isAnalyzing,
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
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSlot(String label, bool hasPhoto) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: hasPhoto ? const Color(0xFFFFEBEE) : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasPhoto ? AppColors.primary : AppColors.outlineVariant,
            ),
          ),
          child: Center(
            child: hasPhoto
                ? const Text('🍅', style: TextStyle(fontSize: 26))
                : const Icon(Icons.add_a_photo_outlined, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }
}

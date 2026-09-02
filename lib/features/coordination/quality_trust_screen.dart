import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../shared/widgets/app_buttons.dart';
import '../../shared/widgets/app_card.dart';

class QualityTrustScreen extends StatelessWidget {
  const QualityTrustScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quality Trust Evidence'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'AI-Assisted Quality Assessment',
                style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w800, fontSize: 20),
              ),
              const SizedBox(height: 4),
              Text(
                'Computer vision assessment computed from multi-angle photo samples across all 3 aggregated farmer lots.',
                style: AppTypography.bodySmall,
              ),

              const SizedBox(height: 16),

              // Score Summary Card
              AppCard(
                borderColor: AppColors.primaryLight,
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Batch Quality Index', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '87',
                                style: AppTypography.headlineLarge.copyWith(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                '/100',
                                style: AppTypography.labelLarge.copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.success),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.shield_rounded, size: 14, color: AppColors.success),
                              const SizedBox(width: 4),
                              Text(
                                'Risk: LOW',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '91% AI Confidence Score',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textNavy,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Image Evidence Carousel / Gallery Grid
              Text(
                'Multi-Farmer Sample Batch Photos',
                style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  _buildPhotoCard('Farmer A (100kg)', '🍅 Top Canopy', 'Color: 92%'),
                  const SizedBox(width: 8),
                  _buildPhotoCard('Farmer B (150kg)', '🍅 Cross Section', 'Firmness: 88%'),
                  const SizedBox(width: 8),
                  _buildPhotoCard('Farmer C (250kg)', '🍅 Crate Batch', 'Size: 85%'),
                ],
              ),

              const SizedBox(height: 16),

              // Detailed Observations
              AppCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Computer Vision Observations:',
                      style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    _buildCheckItem('✓ Good colour consistency across all 3 farmer lots', true),
                    _buildCheckItem('✓ Good size consistency (diameters within 55mm - 68mm)', true),
                    _buildCheckItem('✓ Appearance acceptable for institutional wholesale standard', true),
                    _buildCheckItem('⚠ Minor visible surface marks on <4% of batch (Grade A acceptable)', false),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Assistive Disclaimer Callout Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceContainerHigh),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: AppColors.textNavy),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Decision Support Notice',
                            style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppStrings.aiQualityDisclaimer,
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              PrimaryButton(
                text: 'CONTINUE TO LOGISTICS',
                icon: Icons.local_shipping_outlined,
                onPressed: () {
                  Navigator.pushNamed(context, '/coordination/logistics');
                },
              ),

              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoCard(String farmer, String caption, String metric) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.surfaceContainerHigh),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('🍅', style: TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              farmer,
              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.primary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(caption, style: const TextStyle(fontSize: 8.5, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 1),
            Text(metric, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(String text, bool isPositive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isPositive ? AppColors.textDark : AppColors.warning,
                fontWeight: isPositive ? FontWeight.w500 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

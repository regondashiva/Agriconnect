import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/produce_model.dart';
import '../../../services/app_state.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_chip.dart';

class ProduceDetailsScreen extends StatelessWidget {
  final AppState appState;
  final ProduceItem? produceItem;

  const ProduceDetailsScreen({
    super.key,
    required this.appState,
    this.produceItem,
  });

  @override
  Widget build(BuildContext context) {
    final item = produceItem ??
        appState.selectedProduceItem ??
        (appState.produceList.isNotEmpty ? appState.produceList.first : null);

    if (item == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Produce Batch Details')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textMuted),
                const SizedBox(height: 16),
                Text(
                  'No Produce Batch Listed',
                  style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'You do not have any produce batches listed yet. List your farm harvest to run AI quality grading and connect with bulk buyers.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'LIST NEW PRODUCE',
                  icon: Icons.add_circle_outline_rounded,
                  onPressed: () => Navigator.pushReplacementNamed(context, '/farmer/add-produce'),
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
        title: const Text('Produce Batch Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Crop Header Card
              AppCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item.cropName} (${item.variety})',
                                style: AppTypography.headlineMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Batch ID: #${item.id.toUpperCase()}',
                                style: AppTypography.bodySmall.copyWith(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (item.assessmentId != null && item.assessmentId!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'AI Assessment: #${item.assessmentId}',
                                  style: AppTypography.bodySmall.copyWith(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusChip.success(item.status),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _buildField('Quantity', '${item.quantityKg.toInt()} kg')),
                          Container(width: 1, height: 26, color: AppColors.outlineVariant),
                          Expanded(child: _buildField('Grade', item.gradeLabel)),
                          Container(width: 1, height: 26, color: AppColors.outlineVariant),
                          Expanded(child: _buildField('Expected Price', '₹${item.expectedPricePerKg.toStringAsFixed(0)} / kg')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.location,
                            style: AppTypography.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // AI-Assisted Quality Assessment Section
              Text(
                'AI-Assisted Quality Evidence',
                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Multi-angle batch images scanned for physical uniformity and defect probability.',
                style: AppTypography.bodySmall,
              ),

              const SizedBox(height: 12),

              AppCard(
                borderColor: AppColors.primaryLight,
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
                            Row(
                              children: [
                                Text(
                                  item.qualityScore.toInt().toString(),
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
                            Text(
                              'Quality Score',
                              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.successLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Risk: ${item.riskLevel}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.confidenceScore.toInt()}% AI Confidence',
                              style: AppTypography.bodySmall.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 10),

                    Text(
                      'AI Computer Vision Observations:',
                      style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    if (item.observations.isNotEmpty)
                      ...item.observations.map((obs) => _buildObservation('✓ $obs'))
                    else ...[
                      _buildObservation('✓ Good colour consistency across sample batch'),
                      _buildObservation('✓ Uniform diameter and weight consistency'),
                      _buildObservation('✓ Farm freshness index: 94%'),
                      _buildObservation('⚠ Minor superficial blemishes (within Grade A tolerance)'),
                    ],

                    const SizedBox(height: 14),

                    // Disclaimer
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppStrings.aiQualityDisclaimer,
                              style: AppTypography.bodySmall.copyWith(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              PrimaryButton(
                text: 'VIEW BUYER MATCHES (92%)',
                icon: Icons.auto_awesome,
                onPressed: () {
                  Navigator.pushNamed(context, '/farmer/matches/detail');
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textNavy,
            fontSize: 13,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(fontSize: 10),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildObservation(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textDark,
          fontSize: 13,
        ),
      ),
    );
  }
}

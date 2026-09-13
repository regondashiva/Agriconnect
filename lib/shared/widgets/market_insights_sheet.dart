import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/market_insights_model.dart';
import '../../repositories/market_insights_repository.dart';

class MarketInsightsSheet extends StatefulWidget {
  final String crop;
  final ValueChanged<double>? onApplyPrice;

  const MarketInsightsSheet({
    super.key,
    required this.crop,
    this.onApplyPrice,
  });

  static Future<void> show(
    BuildContext context, {
    required String crop,
    ValueChanged<double>? onApplyPrice,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MarketInsightsSheet(
        crop: crop,
        onApplyPrice: onApplyPrice,
      ),
    );
  }

  @override
  State<MarketInsightsSheet> createState() => _MarketInsightsSheetState();
}

class _MarketInsightsSheetState extends State<MarketInsightsSheet> {
  MarketInsightsData? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final insights = await MarketInsightsRepository.instance.getHistoricalDemand(widget.crop);
    if (mounted) {
      setState(() {
        _data = insights;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.trending_up_rounded, color: Color(0xFF15803D), size: 22),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.crop} Market Insights',
                            style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const Text(
                            'Official Agmarknet + Platform Buyer Demand',
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_data != null) ...[
                // Price Stat Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Government Mandi Rate',
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${_data!.latestModalPrice.toStringAsFixed(1)} / kg',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _data!.isDemandRising ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _data!.isDemandRising ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                              size: 14,
                              color: _data!.isDemandRising ? const Color(0xFF15803D) : const Color(0xFFDC2626),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_data!.priceChangePercent.abs().toStringAsFixed(1)}% (30d)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: _data!.isDemandRising ? const Color(0xFF15803D) : const Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Official Recommendation Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEFCE8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFEF08A)),
                  ),
                  child: Row(
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _data!.recommendationText,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF854D0E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Visual 30-day Line Chart
                const Text(
                  '30-Day Price & Search Volume Trend',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 8),

                Container(
                  height: 140,
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 10, right: 10, bottom: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: CustomPaint(
                    painter: _MarketChartPainter(
                      prices: _data!.historicalPrices.map((p) => p.modalPrice).toList(),
                      volumes: _data!.searchVolume.map((v) => v.requiredQuantityKg).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '30 Days Ago (₹${_data!.initialModalPrice.toInt()})',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: Color(0xFF16A34A)),
                        SizedBox(width: 4),
                        Text('Mandi Price (₹)', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                      ],
                    ),
                    Text(
                      'Today (₹${_data!.latestModalPrice.toInt()})',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF16A34A)),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Apply Price Button
                if (widget.onApplyPrice != null)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                    label: Text(
                      'Apply Recommended ₹${_data!.latestModalPrice.toStringAsFixed(1)} / kg',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5),
                    ),
                    onPressed: () {
                      widget.onApplyPrice!(_data!.latestModalPrice);
                      Navigator.pop(context);
                    },
                  ),

                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MarketChartPainter extends CustomPainter {
  final List<double> prices;
  final List<double> volumes;

  _MarketChartPainter({required this.prices, required this.volumes});

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.isEmpty) return;

    final double minP = prices.reduce((a, b) => a < b ? a : b) * 0.9;
    final double maxP = prices.reduce((a, b) => a > b ? a : b) * 1.05;
    final double rangeP = (maxP - minP) > 0 ? (maxP - minP) : 1.0;

    // Draw background subtle volume bars
    if (volumes.isNotEmpty) {
      final double maxV = volumes.reduce((a, b) => a > b ? a : b);
      final barPaint = Paint()..color = const Color(0xFFDCFCE7);
      final barWidth = size.width / (volumes.length * 2);

      for (int i = 0; i < volumes.length; i++) {
        final x = (size.width / volumes.length) * (i + 0.5);
        final barHeight = (volumes[i] / (maxV > 0 ? maxV : 1.0)) * (size.height * 0.6);
        final y = size.height - barHeight;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x - (barWidth / 2), y, barWidth, barHeight),
            const Radius.circular(2),
          ),
          barPaint,
        );
      }
    }

    // Draw price curve
    final linePaint = Paint()
      ..color = const Color(0xFF16A34A)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < prices.length; i++) {
      final x = (size.width / (prices.length - 1)) * i;
      final y = size.height - (((prices[i] - minP) / rangeP) * size.height * 0.85) - 10;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    // Draw active dot at the last point
    final lastX = size.width;
    final lastY = size.height - (((prices.last - minP) / rangeP) * size.height * 0.85) - 10;

    final dotPaint = Paint()..color = const Color(0xFF15803D);
    final dotRing = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(lastX, lastY), 5, dotPaint);
    canvas.drawCircle(Offset(lastX, lastY), 5, dotRing);
  }

  @override
  bool shouldRepaint(covariant _MarketChartPainter oldDelegate) => true;
}

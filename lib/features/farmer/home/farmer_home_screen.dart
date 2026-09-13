import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/produce_model.dart';
import '../../../services/app_state.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/match_score_badge.dart';
import '../../../shared/widgets/role_switcher_sheet.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/market_insights_sheet.dart';
import '../produce/my_produce_screen.dart';
import '../matches/farmer_matches_screen.dart';
import '../orders/farmer_orders_screen.dart';
import '../assistant/farmer_ai_agent_button.dart';

class FarmerHomeScreen extends StatefulWidget {
  final AppState appState;

  const FarmerHomeScreen({super.key, required this.appState});

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch real produce data from backend on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.appState.fetchProduceList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              appState: widget.appState,
              title: 'Good Morning, ${widget.appState.currentUser.name}',
              location: widget.appState.currentUser.location,
            ),
            Expanded(
              child: IndexedStack(
                index: _currentTabIndex,
                children: [
                  _buildHomeTab(context),
                  MyProduceScreen(appState: widget.appState),
                  FarmerMatchesScreen(appState: widget.appState),
                  FarmerOrdersScreen(appState: widget.appState),
                  _buildFarmerProfileTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FarmerAiAgentButton(appState: widget.appState),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentTabIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        onTap: (idx) => setState(() => _currentTabIndex = idx),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Produce'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_outlined), activeIcon: Icon(Icons.auto_awesome), label: 'Matches'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), activeIcon: Icon(Icons.local_shipping), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    final hasProduce = widget.appState.produceList.isNotEmpty;
    final activeProduce = hasProduce ? widget.appState.produceList.first : null;
    final String cropName = activeProduce?.cropName ?? 'Tomato';
    final double userQty = activeProduce != null ? activeProduce.availableQuantityKg : 100.0;
    final double pricePerKg = activeProduce != null ? activeProduce.expectedPricePerKg : 20.0;
    final double userPayout = userQty * pricePerKg;
    final double totalLot = userQty + 400.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Action Hub
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  title: 'Add Produce',
                  icon: Icons.add_circle_outline_rounded,
                  color: AppColors.primary,
                  onTap: () => Navigator.pushNamed(context, '/farmer/add-produce'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionCard(
                  title: 'Buyer Matches',
                  icon: Icons.auto_awesome,
                  color: AppColors.secondary,
                  onTap: () => setState(() => _currentTabIndex = 2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionCard(
                  title: 'Live Orders',
                  icon: Icons.local_shipping_outlined,
                  color: AppColors.textNavy,
                  onTap: () => setState(() => _currentTabIndex = 3),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Central Demo Opportunity Card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Top Buyer Opportunity',
                  style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              StatusChip.orange('High Match'),
            ],
          ),

          const SizedBox(height: 10),

          AppCard(
            borderColor: AppColors.primaryLight,
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('🍅', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$cropName Bulk Demand',
                            style: AppTypography.headlineSmall.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'FreshBasket Mandi • Kothapet',
                            style: AppTypography.bodySmall.copyWith(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const MatchScoreBadge(scorePercent: 92),
                  ],
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildMetricCol('Buyer Needs', '${totalLot.toInt()} kg')),
                      Container(width: 1, height: 26, color: AppColors.outlineVariant),
                      Expanded(child: _buildMetricCol('Your Supply', '${userQty.toInt()} kg')),
                      Container(width: 1, height: 26, color: AppColors.outlineVariant),
                      Expanded(child: _buildMetricCol('Est. Payout', '₹${userPayout.toInt()}')),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Aggregated with nearby cluster farms to fulfill ${totalLot.toInt()} kg wholesale demand',
                        style: AppTypography.bodySmall.copyWith(fontSize: 11),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                PrimaryButton(
                  text: 'VIEW OPPORTUNITY DETAILS',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () {
                    Navigator.pushNamed(context, '/farmer/matches/detail');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Mandi Price & Demand Trends Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.show_chart_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Mandi Price & Demand Trends',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    StatusChip.success('Agmarknet'),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tap any crop to see 30-day price trends and platform buyer demand forecasting.',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCropTrendChip(context, 'Tomato', '🍅', '₹25.0', '+12%'),
                      const SizedBox(width: 8),
                      _buildCropTrendChip(context, 'Onion', '🧅', '₹32.0', '+8%'),
                      const SizedBox(width: 8),
                      _buildCropTrendChip(context, 'Potato', '🥔', '₹22.0', '+5%'),
                      const SizedBox(width: 8),
                      _buildCropTrendChip(context, 'Chilli', '🌶️', '₹45.0', '+18%'),
                      const SizedBox(width: 8),
                      _buildCropTrendChip(context, 'Carrot', '🥕', '₹30.0', '+10%'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Active Listings Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'My Active Produce',
                  style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _currentTabIndex = 1),
                child: const Text('View All'),
              ),
            ],
          ),

          const SizedBox(height: 6),

          ...widget.appState.produceList.take(3).map((ProduceItem item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                onTap: () {
                  widget.appState.setSelectedProduceItem(item);
                  Navigator.pushNamed(context, '/farmer/produce/detail', arguments: item);
                },
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _getProduceColor(item.cropName),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(_getProduceEmoji(item.cropName), style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.cropName} (${item.variety})',
                                  style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              StatusChip.green('${item.gradeLabel} (${item.qualityScore.toInt()})'),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${item.quantityKg.toInt()} kg available • ₹${item.expectedPricePerKg.toStringAsFixed(0)}/kg',
                            style: AppTypography.bodySmall.copyWith(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceContainerHigh),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: AppColors.textNavy,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCol(String label, String val) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          val,
          style: AppTypography.headlineSmall.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textNavy,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(fontSize: 9.5),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFarmerProfileTab(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primaryContainer,
                  child: Text(
                    widget.appState.currentUser.name.isNotEmpty
                        ? widget.appState.currentUser.name[0].toUpperCase()
                        : 'F',
                    style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.appState.currentUser.name,
                  style: AppTypography.headlineSmall.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Farmer • ${widget.appState.currentUser.location}',
                  style: AppTypography.bodySmall.copyWith(fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              children: [
                _buildProfileRow('Mobile', widget.appState.currentUser.phoneNumber),
                const Divider(),
                _buildProfileRow('Language', widget.appState.currentUser.preferredLanguage ?? 'Telugu / English'),
                const Divider(),
                _buildProfileRow('FPO Hub', widget.appState.currentUser.fpoCluster ?? 'Ranga Reddy Organic Producers FPO'),
                const Divider(),
                _buildProfileRow('Verified ID', 'SIH-AP-FARMER-2026'),
              ],
            ),
          ),

          const SizedBox(height: 18),

          PrimaryButton(
            text: 'SWITCH ROLE FOR DEMO',
            icon: Icons.swap_horiz,
            onPressed: () => RoleSwitcherSheet.show(context, widget.appState),
          ),

          const SizedBox(height: 10),

          SecondaryButton(
            text: 'LOG OUT',
            icon: Icons.logout_rounded,
            borderColor: AppColors.error,
            textColor: AppColors.error,
            onPressed: () {
              widget.appState.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              title,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 12.5),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              val,
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getProduceEmoji(String cropName) {
    final lower = cropName.toLowerCase();
    if (lower.contains('tomato')) return '🍅';
    if (lower.contains('potato')) return '🥔';
    if (lower.contains('onion')) return '🧅';
    if (lower.contains('chilli') || lower.contains('pepper')) return '🌶️';
    if (lower.contains('capsicum')) return '🫑';
    if (lower.contains('wheat')) return '🌾';
    if (lower.contains('rice') || lower.contains('paddy')) return '🍚';
    return '🥬';
  }

  Color _getProduceColor(String cropName) {
    final lower = cropName.toLowerCase();
    if (lower.contains('tomato')) return const Color(0xFFFFEBEE);
    if (lower.contains('potato')) return const Color(0xFFFFF8E1);
    if (lower.contains('onion')) return const Color(0xFFF3E5F5);
    if (lower.contains('chilli')) return const Color(0xFFE8F5E9);
    if (lower.contains('capsicum')) return const Color(0xFFE0F2F1);
    return const Color(0xFFF1F8E9);
  }

  Widget _buildCropTrendChip(BuildContext context, String crop, String emoji, String price, String trend) {
    return InkWell(
      onTap: () => MarketInsightsSheet.show(context, crop: crop),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(crop, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                Row(
                  children: [
                    Text(price, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF16A34A))),
                    const SizedBox(width: 4),
                    Text(trend, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF15803D))),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

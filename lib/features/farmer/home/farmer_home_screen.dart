import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../services/app_state.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/match_score_badge.dart';
import '../../../shared/widgets/role_switcher_sheet.dart';
import '../../../shared/widgets/status_chip.dart';
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

          const SizedBox(height: 18),

          // High Priority Opportunity Card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Your Opportunities',
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
                            'Tomato Bulk Demand',
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
                      Expanded(child: _buildMetricCol('Buyer Needs', '500 kg')),
                      Container(width: 1, height: 26, color: AppColors.outlineVariant),
                      Expanded(child: _buildMetricCol('Your Supply', '100 kg')),
                      Container(width: 1, height: 26, color: AppColors.outlineVariant),
                      Expanded(child: _buildMetricCol('Est. Payout', '₹2,000')),
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
                        'Aggregated with 2 nearby farmers (Farmer B 150kg + Farmer C 250kg)',
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

          AppCard(
            onTap: () => Navigator.pushNamed(context, '/farmer/produce/detail'),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('🍅', style: TextStyle(fontSize: 22)),
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
                              'Tomato (Hybrid Red)',
                              style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          StatusChip.green('Grade A (87)'),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '100 kg available • Ready for pickup',
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
}

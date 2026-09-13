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
import '../matches/matched_supply_screen.dart';
import '../orders/buyer_orders_screen.dart';

class BulkBuyerHomeScreen extends StatefulWidget {
  final AppState appState;

  const BulkBuyerHomeScreen({super.key, required this.appState});

  @override
  State<BulkBuyerHomeScreen> createState() => _BulkBuyerHomeScreenState();
}

class _BulkBuyerHomeScreenState extends State<BulkBuyerHomeScreen> {
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.appState.fetchRequirements();
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
              title: widget.appState.currentUser.name,
              subtitle: 'Wholesale Buyer • Kothapet Mandi',
            ),
            Expanded(
              child: IndexedStack(
                index: _currentTabIndex,
                children: [
                  _buildBuyerHomeTab(context),
                  _buildRequirementsTab(context),
                  MatchedSupplyScreen(appState: widget.appState),
                  BuyerOrdersScreen(appState: widget.appState),
                  _buildBuyerProfileTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentTabIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        onTap: (idx) => setState(() => _currentTabIndex = idx),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.post_add_outlined), activeIcon: Icon(Icons.post_add), label: 'Demand'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_outlined), activeIcon: Icon(Icons.auto_awesome), label: 'Matches'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), activeIcon: Icon(Icons.local_shipping), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBuyerHomeTab(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Demand Action Banner
          AppCard(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Need Bulk Agri Produce?',
                        style: AppTypography.headlineSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Post volume requirements. AI aggregates directly from local farmers & FPOs.',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/buyer/create-requirement');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.add_circle_outline, size: 16),
                        label: const Text('Post Bulk Demand', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.storefront_rounded, color: Colors.white24, size: 48),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Price Intelligence Widget
          AppCard(
            borderColor: AppColors.harvestOrangeLight,
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.harvestOrangeLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.trending_up_rounded, color: AppColors.harvestOrangeDark, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'AI Price Intelligence',
                              style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w800, fontSize: 13.5),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          StatusChip.orange('Tomato: ₹19-22/kg'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cluster Mandi forecast indicates steady wholesale pricing. Optimal sourcing window active.',
                        style: AppTypography.bodySmall.copyWith(fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Active Matched Demand
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Current Open Requirements',
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
            onTap: () => setState(() => _currentTabIndex = 2),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '500 kg Tomato (Grade A)',
                        style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w800, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const MatchScoreBadge(scorePercent: 92),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Delivery to Kothapet Mandi • Required Tomorrow', style: AppTypography.bodySmall.copyWith(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildMetric('Matched Supply', '500 kg (100%)')),
                      Container(width: 1, height: 24, color: AppColors.outlineVariant),
                      Expanded(child: _buildMetric('Est. Amount', '₹10,000')),
                      Container(width: 1, height: 24, color: AppColors.outlineVariant),
                      Expanded(child: _buildMetric('FPO Source', 'Ranga Reddy')),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: 'INSPECT SUPPLY MATCH & LOGISTICS',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => Navigator.pushNamed(context, '/buyer/matches'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRequirementsTab(BuildContext context) {
    final reqs = widget.appState.requirements;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Posted Requirements', style: AppTypography.headlineMedium.copyWith(fontSize: 18, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Post New', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                onPressed: () => Navigator.pushNamed(context, '/buyer/create-requirement'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...reqs.map((req) {
            return AppCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${req.requiredQuantityKg.toStringAsFixed(0)} kg ${req.cropName}',
                          style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w800),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      StatusChip.green('Matched 92%'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Location: ${req.deliveryLocation}', style: AppTypography.bodySmall.copyWith(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('Price Target: ₹${req.priceRangeMin.toStringAsFixed(0)} - ₹${req.priceRangeMax.toStringAsFixed(0)} / kg', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String val) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(val, style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 1),
        Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 9), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildBuyerProfileTab(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primaryContainer,
            child: const Icon(Icons.storefront_rounded, size: 30, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(widget.appState.currentUser.name, style: AppTypography.headlineSmall.copyWith(fontSize: 18, fontWeight: FontWeight.w700), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('Wholesale Buyer • ${widget.appState.currentUser.location}', style: AppTypography.bodySmall.copyWith(fontSize: 12), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 18),

          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              children: [
                _buildProfileRow('Entity', widget.appState.currentUser.businessName ?? 'FreshBasket Wholesale Pvt Ltd'),
                const Divider(),
                _buildProfileRow('Location', widget.appState.currentUser.location),
                const Divider(),
                _buildProfileRow('Contact', widget.appState.currentUser.phoneNumber),
                const Divider(),
                _buildProfileRow('Verified ID', 'SIH-AP-BUYER-2026'),
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
            child: Text(title, style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 12.5)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              val,
              style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 12.5),
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

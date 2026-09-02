import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../services/app_state.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/role_switcher_sheet.dart';
import '../../../shared/widgets/status_chip.dart';
import '../farmers/manage_farmers_screen.dart';
import '../supply/aggregate_supply_screen.dart';
import '../../bulk_buyer/orders/buyer_orders_screen.dart';

class FpoHomeScreen extends StatefulWidget {
  final AppState appState;

  const FpoHomeScreen({super.key, required this.appState});

  @override
  State<FpoHomeScreen> createState() => _FpoHomeScreenState();
}

class _FpoHomeScreenState extends State<FpoHomeScreen> {
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
              title: widget.appState.currentUser.name,
              subtitle: 'FPO Coordinator • Ranga Reddy Cluster',
            ),
            Expanded(
              child: IndexedStack(
                index: _currentTabIndex,
                children: [
                  _buildFpoHomeTab(context),
                  ManageFarmersScreen(appState: widget.appState),
                  AggregateSupplyScreen(appState: widget.appState),
                  BuyerOrdersScreen(appState: widget.appState),
                  _buildFpoProfileTab(context),
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
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Farmers'),
          BottomNavigationBarItem(icon: Icon(Icons.hub_outlined), activeIcon: Icon(Icons.hub), label: 'Supply'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), activeIcon: Icon(Icons.local_shipping), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildFpoHomeTab(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cluster Stats Card
          AppCard(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.appState.currentUser.businessName ?? 'Ranga Reddy Organic Producers FPO',
                  style: AppTypography.headlineSmall.copyWith(color: Colors.white, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text('Active Cluster Coordination Hub', style: TextStyle(color: Colors.white70, fontSize: 11)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildFpoMetric('Enrolled', '48 Farmers')),
                      Container(width: 1, height: 26, color: Colors.white24),
                      Expanded(child: _buildFpoMetric('Active Lots', '12 Lots')),
                      Container(width: 1, height: 26, color: Colors.white24),
                      Expanded(child: _buildFpoMetric('Aggregation', '3,450 kg')),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Active Aggregation Lot Card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Active Aggregation Request',
                  style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              StatusChip.success('Ready to Dispatch'),
            ],
          ),

          const SizedBox(height: 10),

          AppCard(
            borderColor: AppColors.primary,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('500 kg Tomato Lot (Grade A)', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('Aggregated from Ramesh (100kg), Suresh (150kg), Ravi (250kg)', style: AppTypography.bodySmall.copyWith(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('100% Filled', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: 1.0,
                  backgroundColor: AppColors.surfaceContainer,
                  color: AppColors.primary,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.hub_outlined, size: 16),
                        label: const Text('MANAGE LOT', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                        onPressed: () => setState(() => _currentTabIndex = 2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                        icon: const Icon(Icons.local_shipping_outlined, size: 16),
                        label: const Text('TRACK DISPATCH', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                        onPressed: () => Navigator.pushNamed(context, '/coordination/tracking'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Quick Management Actions
          Row(
            children: [
              Expanded(
                child: _buildFpoActionCard(
                  title: 'Manage Farmers',
                  subtitle: '48 registered members',
                  icon: Icons.people_alt_rounded,
                  color: AppColors.primary,
                  onTap: () => setState(() => _currentTabIndex = 1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFpoActionCard(
                  title: 'Quality Center',
                  subtitle: 'AI camera lot grading',
                  icon: Icons.auto_awesome,
                  color: AppColors.secondary,
                  onTap: () => Navigator.pushNamed(context, '/coordination/quality'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFpoMetric(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 9.5),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFpoActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceContainerHigh),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(title, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w800, fontSize: 12.5), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(subtitle, style: AppTypography.bodySmall.copyWith(fontSize: 10.5), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildFpoProfileTab(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primaryContainer,
            child: const Icon(Icons.hub_rounded, size: 30, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(widget.appState.currentUser.name, style: AppTypography.headlineSmall.copyWith(fontSize: 18, fontWeight: FontWeight.w700), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('FPO Coordinator • ${widget.appState.currentUser.location}', style: AppTypography.bodySmall.copyWith(fontSize: 12), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 18),

          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              children: [
                _buildProfileRow('FPO Name', widget.appState.currentUser.businessName ?? 'Ranga Reddy Organic Producers FPO'),
                const Divider(),
                _buildProfileRow('Hub Location', widget.appState.currentUser.location),
                const Divider(),
                _buildProfileRow('Contact', widget.appState.currentUser.phoneNumber),
                const Divider(),
                _buildProfileRow('Verified ID', 'SIH-AP-FPO-2026'),
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

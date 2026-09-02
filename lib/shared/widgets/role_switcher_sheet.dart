import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/user_model.dart';
import '../../services/app_state.dart';

class RoleSwitcherSheet extends StatelessWidget {
  final AppState appState;

  const RoleSwitcherSheet({super.key, required this.appState});

  static void show(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => RoleSwitcherSheet(appState: appState),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.swap_horiz_rounded, color: AppColors.primary, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'SIH Demo: Switch User Role',
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Select any role to test its full end-to-end dedicated workflow.',
                style: AppTypography.bodySmall.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 14),
              _buildRoleOption(
                context,
                role: UserRole.farmer,
                title: 'Farmer (Ramesh Reddy)',
                desc: 'Add produce, view 92% tomato match, voice assistance, settlements',
                icon: Icons.agriculture_rounded,
              ),
              _buildRoleOption(
                context,
                role: UserRole.fpo,
                title: 'FPO Coordinator (Suresh Rao)',
                desc: 'Manage cluster farmers, batch aggregate 500kg supply & logistics',
                icon: Icons.hub_rounded,
              ),
              _buildRoleOption(
                context,
                role: UserRole.bulkBuyer,
                title: 'Bulk Buyer (FreshBasket Mandi)',
                desc: 'Post 500kg demand, inspect 3-farmer aggregation, AI quality & route',
                icon: Icons.storefront_rounded,
              ),
              _buildRoleOption(
                context,
                role: UserRole.consumer,
                title: 'Consumer / Household (Ananya)',
                desc: 'Buy 2kg tomatoes + 1kg potatoes directly from FPO, instant tracking',
                icon: Icons.shopping_bag_outlined,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption(
    BuildContext context, {
    required UserRole role,
    required String title,
    required String desc,
    required IconData icon,
  }) {
    final isSelected = appState.activeRole == role;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          appState.selectRole(role);
          Navigator.pop(context);
          switch (role) {
            case UserRole.farmer:
              Navigator.pushNamedAndRemoveUntil(context, '/farmer/home', (r) => false);
              break;
            case UserRole.fpo:
              Navigator.pushNamedAndRemoveUntil(context, '/fpo/home', (r) => false);
              break;
            case UserRole.bulkBuyer:
              Navigator.pushNamedAndRemoveUntil(context, '/buyer/home', (r) => false);
              break;
            case UserRole.consumer:
              Navigator.pushNamedAndRemoveUntil(context, '/consumer/home', (r) => false);
              break;
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceContainerLow : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.labelLarge.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textNavy,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: AppTypography.bodySmall.copyWith(fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

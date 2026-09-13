import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/user_model.dart';
import '../../services/app_state.dart';
import '../../shared/widgets/app_buttons.dart';
import '../../shared/widgets/app_card.dart';

class RoleSelectionScreen extends StatefulWidget {
  final AppState appState;

  const RoleSelectionScreen({super.key, required this.appState});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole _selectedRole = UserRole.farmer;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.appState.activeRole;
  }

  void _handleContinue() {
    widget.appState.selectRole(_selectedRole);

    switch (_selectedRole) {
      case UserRole.farmer:
        Navigator.pushNamed(context, '/farmer/onboarding');
        break;
      case UserRole.fpo:
        Navigator.pushNamed(context, '/fpo/registration');
        break;
      case UserRole.bulkBuyer:
        Navigator.pushNamed(context, '/buyer/registration');
        break;
      case UserRole.consumer:
        Navigator.pushNamed(context, '/consumer/registration');
        break;
      case UserRole.deliveryPartner:
        Navigator.pushNamed(context, '/delivery/registration');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFDFD),
      appBar: AppBar(
        title: const Text('Select Your Role'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How will you use AgriConnect?',
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your role determines your personalized coordination workspace.',
                style: AppTypography.bodySmall.copyWith(fontSize: 12.5),
              ),

              const SizedBox(height: 14),

              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildRoleCard(
                      role: UserRole.farmer,
                      title: 'FARMER',
                      subtitle: 'Sell your produce and discover buyer opportunities.',
                      icon: Icons.agriculture_rounded,
                      badgeText: 'Supply & Opportunities',
                    ),
                    const SizedBox(height: 10),
                    _buildRoleCard(
                      role: UserRole.fpo,
                      title: 'FPO (Producer Org)',
                      subtitle: 'Aggregate farmer supply and fulfill bulk demand.',
                      icon: Icons.hub_rounded,
                      badgeText: 'Cluster Aggregation',
                    ),
                    const SizedBox(height: 10),
                    _buildRoleCard(
                      role: UserRole.bulkBuyer,
                      title: 'BULK BUYER',
                      subtitle: 'Source agricultural produce in bulk.',
                      icon: Icons.storefront_rounded,
                      badgeText: 'Wholesale Demand',
                    ),
                    const SizedBox(height: 10),
                    _buildRoleCard(
                      role: UserRole.consumer,
                      title: 'CONSUMER / HOUSEHOLD',
                      subtitle: 'Buy fresh produce directly for your home.',
                      icon: Icons.shopping_bag_outlined,
                      badgeText: 'Household Grocery',
                    ),
                    const SizedBox(height: 10),
                    _buildRoleCard(
                      role: UserRole.deliveryPartner,
                      title: 'DELIVERY PARTNER',
                      subtitle: 'Pick up sorted vegetables from FPO hubs & deliver to households.',
                      icon: Icons.two_wheeler_rounded,
                      badgeText: 'Earn per Trip • Jan Dhan UPI',
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              PrimaryButton(
                text: 'CONTINUE',
                icon: Icons.arrow_forward_rounded,
                onPressed: _handleContinue,
              ),

              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
    required String badgeText,
  }) {
    final isSelected = _selectedRole == role;

    return AppCard(
      onTap: () {
        setState(() => _selectedRole = role);
      },
      backgroundColor: isSelected ? const Color(0xFFEFF8F1) : Colors.white,
      borderColor: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.primary,
              size: 24,
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
                        title,
                        style: AppTypography.labelLarge.copyWith(
                          color: isSelected ? AppColors.primary : AppColors.textNavy,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          fontSize: 13.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Radio<UserRole>(
                      value: role,
                      groupValue: _selectedRole,
                      activeColor: AppColors.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedRole = val);
                      },
                    ),
                  ],
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textDark,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.textNavy,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

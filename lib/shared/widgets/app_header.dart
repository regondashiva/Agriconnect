import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../services/app_state.dart';
import 'role_switcher_sheet.dart';

class AppHeader extends StatelessWidget {
  final AppState appState;
  final String title;
  final String? subtitle;
  final String? location;
  final bool showNotification;

  const AppHeader({
    super.key,
    required this.appState,
    required this.title,
    this.subtitle,
    this.location,
    this.showNotification = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          // User Avatar & Initial
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryContainer,
            child: Text(
              appState.currentUser.name.isNotEmpty
                  ? appState.currentUser.name.substring(0, 1).toUpperCase()
                  : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Title, Greeting & Location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.headlineSmall.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (location != null) ...[
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 12, color: AppColors.secondary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          location!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ] else if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Role Badge (Tappable for Quick Role Switch in SIH Demo)
          InkWell(
            onTap: () => RoleSwitcherSheet.show(context, appState),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryLight),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 80),
                    child: Text(
                      appState.currentUser.roleDisplayName,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_drop_down, size: 14, color: AppColors.primary),
                ],
              ),
            ),
          ),

          const SizedBox(width: 4),

          // Notification Bell
          if (showNotification)
            IconButton(
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              onPressed: () {
                Navigator.pushNamed(context, '/notifications');
              },
              icon: const Badge(
                label: Text('2', style: TextStyle(fontSize: 9)),
                backgroundColor: AppColors.harvestOrange,
                child: Icon(Icons.notifications_none_rounded, color: AppColors.textNavy, size: 22),
              ),
              tooltip: 'Notifications',
            ),
        ],
      ),
    );
  }
}

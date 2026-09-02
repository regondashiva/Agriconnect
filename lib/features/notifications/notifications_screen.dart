import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/notification_model.dart';
import '../../services/app_state.dart';
import '../../shared/widgets/app_card.dart';

class NotificationsScreen extends StatelessWidget {
  final AppState appState;

  const NotificationsScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final notifications = appState.getCurrentRoleNotifications();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${appState.currentUser.roleDisplayName} Notifications'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getIconColor(item.type).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIcon(item.type),
                      color: _getIconColor(item.type),
                      size: 20,
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
                                item.title,
                                style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            Text(
                              item.timeAgo,
                              style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.body,
                          style: AppTypography.bodySmall.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.opportunity:
        return Icons.auto_awesome;
      case NotificationType.aggregation:
        return Icons.hub_rounded;
      case NotificationType.logistics:
        return Icons.local_shipping_outlined;
      case NotificationType.settlement:
        return Icons.payments_outlined;
      case NotificationType.orderUpdate:
        return Icons.check_circle_outline;
    }
  }

  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.opportunity:
        return AppColors.harvestOrange;
      case NotificationType.aggregation:
        return AppColors.secondary;
      case NotificationType.logistics:
        return AppColors.primary;
      case NotificationType.settlement:
        return AppColors.success;
      case NotificationType.orderUpdate:
        return AppColors.info;
    }
  }
}

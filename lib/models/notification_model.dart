import 'user_model.dart';

enum NotificationType { opportunity, aggregation, logistics, settlement, orderUpdate }

class NotificationItem {
  final String id;
  final UserRole targetRole;
  final String title;
  final String body;
  final String timeAgo;
  final bool isRead;
  final NotificationType type;

  const NotificationItem({
    required this.id,
    required this.targetRole,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.isRead = false,
    required this.type,
  });
}

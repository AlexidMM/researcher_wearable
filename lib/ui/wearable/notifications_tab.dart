import 'package:flutter/material.dart';

import '../../models/app_notification.dart';

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key, required this.notifications});

  final List<AppNotification> notifications;

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Sin alertas por ahora.\nCuando abras o cierres una convocatoria en la web, aparecerá aquí.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final notification = notifications[index];

        return ListTile(
          leading: Icon(
            notification.isOpened ? Icons.campaign : Icons.pause_circle_outline,
            color: notification.isOpened ? const Color(0xFFF6C844) : const Color(0xFFEF4444),
          ),
          title: Text(
            notification.message,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w700,
            ),
          ),
          subtitle: Text(_formatDate(notification.createdAt)),
          trailing: notification.isRead
              ? null
              : const Icon(Icons.fiber_manual_record, size: 10, color: Color(0xFFF6C844)),
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Reciente';

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inHours < 1) return 'Hace ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Hace ${diff.inHours} h';
    return '${date.day}/${date.month}/${date.year}';
  }
}

import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';

enum NotificationType { reminder, financial, system }

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String timeAgo;
  final NotificationType type;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.type,
    this.isRead = false,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Maintenance Due',
      description: 'Crane #501 (50-ton) requires a standard hydraulic oil check by tomorrow.',
      timeAgo: '2m ago',
      type: NotificationType.reminder,
    ),
    NotificationItem(
      id: '2',
      title: 'Payment Received',
      description: 'Invoice #QN-4501 for Al-Fajr Group has been successfully processed.',
      timeAgo: '1h ago',
      type: NotificationType.financial,
      isRead: true,
    ),
    NotificationItem(
      id: '3',
      title: 'System Update',
      description: 'New quoting formulas for high-capacity cranes (above 200 ton) are now active.',
      timeAgo: '5h ago',
      type: NotificationType.system,
    ),
    NotificationItem(
      id: '4',
      title: 'New Quotation Request',
      description: 'Emaar Group requested a quote for shifting heavy machinery at Downtown Dubai.',
      timeAgo: 'Yesterday',
      type: NotificationType.financial,
    ),
  ];

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n.isRead = true;
      }
    });
  }

  void _removeNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Center'),
        centerTitle: true,
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark as read',
                style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState(theme)
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: _notifications.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _notifications[index];
                    return _buildNotificationTile(context, item, theme);
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, NotificationItem item, ThemeData theme) {
    IconData getIcon() {
      switch (item.type) {
        case NotificationType.reminder:
          return Icons.alarm_on;
        case NotificationType.financial:
          return Icons.payments;
        case NotificationType.system:
          return Icons.settings_suggest;
      }
    }

    Color getIconColor() {
      switch (item.type) {
        case NotificationType.reminder:
          return Colors.orange;
        case NotificationType.financial:
          return Colors.green;
        case NotificationType.system:
          return theme.colorScheme.primary;
      }
    }

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.redAccent,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => _removeNotification(item.id),
      child: Container(
        color: item.isRead ? Colors.transparent : theme.colorScheme.primary.withValues(alpha: 0.05),
        child: ListTile(
          onTap: () {
            setState(() {
              item.isRead = true;
            });
          },
          contentPadding: EdgeInsets.symmetric(
            horizontal: Responsive.scale(context, 16).clamp(16.0, 24.0),
            vertical: 8,
          ),
          leading: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: getIconColor().withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(getIcon(), color: getIconColor(), size: Responsive.scale(context, 24).clamp(24.0, 28.0)),
              ),
              if (!item.isRead)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            item.title,
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: Responsive.scale(context, 16).clamp(14.0, 18.0),
              fontWeight: FontWeight.bold,
              color: item.isRead ? theme.colorScheme.primary.withValues(alpha: 0.7) : theme.colorScheme.primary,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: Responsive.scale(context, 13).clamp(12.0, 14.0),
                color: Colors.grey[600],
              ),
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.timeAgo,
                style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'All caught up!',
            style: theme.textTheme.displayLarge?.copyWith(fontSize: 22, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Text(
            'No new notifications for you right now.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

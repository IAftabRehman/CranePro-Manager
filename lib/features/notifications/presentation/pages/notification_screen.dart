import 'package:flutter/material.dart';
import 'package:extend_crane_services/shared/global_widgets/premium_background.dart';

class NotificationItem {
  final String id;
  final String clientName;
  final String location;
  final String timeAgo;
  final bool isPendingQuotation;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.clientName,
    required this.location,
    required this.timeAgo,
    this.isPendingQuotation = true,
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
      clientName: 'Emaar Constructions',
      location: 'Downtown Dubai',
      timeAgo: '2m ago',
    ),
    NotificationItem(
      id: '2',
      clientName: 'Al-Nakheel Group',
      location: 'Palm Jumeirah',
      timeAgo: '1h ago',
    ),
    NotificationItem(
      id: '3',
      clientName: 'Binladin Contracting',
      location: 'Jeddah Tower',
      timeAgo: '5h ago',
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

    return PremiumScaffold(
      appBar: AppBar(
        title: const Text('Work Update Center', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all, color: Colors.amber),
              tooltip: 'Mark as read',
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
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  itemCount: _notifications.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
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
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent, size: 28),
      ),
      onDismissed: (_) => _removeNotification(item.id),
      child: Card(
        elevation: 0,
        color: Colors.white.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: item.isRead ? Colors.white10 : Colors.amber.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.pending_actions_rounded, color: Colors.amber, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'PENDING QUOTATION',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.amber,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    item.timeAgo,
                    style: theme.textTheme.labelSmall?.copyWith(color: Colors.white38),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                item.clientName,
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: Colors.white38, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    item.location,
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white60),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Logic to update status
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Update status for ${item.clientName}')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('UPDATE STATUS', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
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
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 80,
              color: Colors.white24,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'All clear!',
            style: theme.textTheme.displayLarge?.copyWith(fontSize: 22, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'No pending work updates at the moment.',
            style: TextStyle(color: Colors.white38),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:extend_crane_services/shared/global_widgets/premium_background.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../auth/presentation/controllers/login_notifier.dart';
import '../providers/notification_providers.dart';
import '../../data/models/notification_model.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    // Only watch the user ID and user role to prevent screen rebuilds on other profile field changes
    final userId = ref.watch(currentUserProvider.select((userAsync) => userAsync.asData?.value?.id));
    final userRole = ref.watch(currentUserProvider.select((userAsync) => userAsync.asData?.value?.role));

    return PremiumScaffold(
      appBar: AppBar(
        title: const Text(
          'Work Update Center',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: userId == null || userRole == null
          ? const Center(
              child: RepaintBoundary(
                child: CircularProgressIndicator(color: Colors.amber),
              ),
            )
          : Consumer(
              builder: (context, ref, child) {
                final notificationsAsync = ref.watch(
                  notificationsStreamProvider((userId, userRole)),
                );

                return notificationsAsync.when(
                  data: (notifications) {
                    final unreadNotifications = notifications.where(
                      (n) => !n.readBy.contains(userId),
                    ).toList();

                    return Scaffold(
                      backgroundColor: Colors.transparent,
                      appBar: unreadNotifications.isNotEmpty
                          ? AppBar(
                              automaticallyImplyLeading: false,
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              toolbarHeight: 40,
                              actions: [
                                TextButton.icon(
                                  onPressed: () {
                                    final unreadIds = unreadNotifications
                                        .map((n) => n.id)
                                        .toList();
                                    ref
                                        .read(notificationRepositoryProvider)
                                        .markAllAsRead(unreadIds, userId);
                                  },
                                  icon: const Icon(
                                    Icons.done_all,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Mark all as read',
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                              ],
                            )
                          : null,
                      body: notifications.isEmpty
                          ? const EmptyStateWidget()
                          : Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 700),
                                child: ListView.separated(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 16,
                                  ),
                                  itemCount: notifications.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    // Component Extraction: 
                                    // Isolated each NotificationTile as a ConsumerWidget. 
                                    // Tapping to read or swiping to dismiss will only rebuild/animate this tile.
                                    return NotificationTile(
                                      item: notifications[index],
                                      currentUserId: userId,
                                    );
                                  },
                                ),
                              ),
                            ),
                    );
                  },
                  loading: () => const Center(
                    child: RepaintBoundary(
                      child: CircularProgressIndicator(color: Colors.amber),
                    ),
                  ),
                  error: (err, stack) => Center(
                    child: Text(
                      'Error: $err',
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// Extracted NotificationTile Widget (ConsumerWidget with const constructor)
class NotificationTile extends ConsumerWidget {
  final NotificationModel item;
  final String currentUserId;

  const NotificationTile({
    super.key,
    required this.item,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isRead = item.readBy.contains(currentUserId);
    final titleLower = item.title.toLowerCase();

    IconData iconData = Icons.notifications_active_outlined;
    Color iconColor = Colors.blueAccent;

    if (titleLower.contains('complete') || titleLower.contains('approved')) {
      iconData = Icons.check_circle_outline_rounded;
      iconColor = Colors.green;
    } else if (titleLower.contains('cancel') || titleLower.contains('block') || titleLower.contains('reject')) {
      iconData = Icons.cancel_outlined;
      iconColor = Colors.redAccent;
    } else if (titleLower.contains('pending') || titleLower.contains('new')) {
      iconData = Icons.pending_actions_rounded;
      iconColor = Colors.amber;
    }

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: const Color(0x33FF5252),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: const Icon(
          Icons.delete_sweep_outlined,
          color: Colors.redAccent,
          size: 28,
        ),
      ),
      onDismissed: (_) {
        ref
            .read(notificationRepositoryProvider)
            .dismissNotification(item.id, currentUserId);
      },
      child: Card(
        elevation: 0,
        color: const Color(0x0DFFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isRead
                ? Colors.white10
                : const Color(0x4DFFC107),
            width: 1.5,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (!isRead) {
              ref
                  .read(notificationRepositoryProvider)
                  .markAsRead(item.id, currentUserId);
            }
          },
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
                            color: iconColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(iconData, color: iconColor, size: 15),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          item.title.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: iconColor,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      timeago.format(item.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.deepOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  item.body,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                if (!isRead)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Tap to mark as read',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white38,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Extracted EmptyState Widget (StatelessWidget with const constructor)
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: const BoxDecoration(
              color: Color(0x0DFFFFFF),
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
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No notifications at the moment.',
            style: TextStyle(color: Colors.white38),
          ),
        ],
      ),
    );
  }
}

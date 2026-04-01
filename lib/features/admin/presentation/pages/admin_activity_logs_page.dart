import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:extend_crane_services/features/admin/presentation/providers/activity_logs_provider.dart';
import 'package:extend_crane_services/features/admin/presentation/widgets/activity_tracker_widget.dart';

class AdminActivityLogsPage extends ConsumerWidget {
  const AdminActivityLogsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activityLogsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: activitiesAsync.when(
        data: (activities) {
          return RefreshIndicator(
            onRefresh: () => ref.refresh(activityLogsProvider.future),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: ActivityTrackerWidget(activities: activities),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error loading activity: $err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

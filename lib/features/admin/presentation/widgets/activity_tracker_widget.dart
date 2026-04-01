import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityTrackerWidget extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const ActivityTrackerWidget({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 48, color: AppTheme.deepNavyBlue.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text(
              'No recent activity',
              style: TextStyle(color: AppTheme.deepNavyBlue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: activities.length,
      separatorBuilder: (context, index) => Divider(color: AppTheme.deepNavyBlue.withOpacity(0.1)),
      itemBuilder: (context, index) {
        final activity = activities[index];
        
        // Detection Logic
        final isUser = activity.containsKey('email') && !activity.containsKey('clientName');
        final isWorkOrder = activity.containsKey('workOrderId');
        final isBill = !isUser && !isWorkOrder;

        final timestamp = (activity['createdAt'] as Timestamp).toDate();

        // UI Configuration based on activity type
        IconData iconData = Icons.receipt_long_rounded;
        Color iconColor = AppTheme.deepNavyBlue;
        String titleText = "";

        if (isUser) {
          iconData = Icons.person_add_rounded;
          titleText = "New User: ${activity['fullName'] ?? 'Unknown'} joined as ${activity['role'] ?? 'user'}";
        } else if (isWorkOrder) {
          iconData = Icons.engineering_rounded;
          iconColor = Colors.orange.shade800;
          titleText = "Work Generated: ${activity['operatorName'] ?? 'Operator'} started job for ${activity['clientName'] ?? 'Unknown'}";
        } else if (isBill) {
          iconData = Icons.receipt_long_rounded;
          titleText = "New Bill: ${activity['operatorName'] ?? 'Operator'} created a quotation for ${activity['clientName'] ?? 'Unknown'}";
        }

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: 24,
            ),
          ),
          title: Text(
            titleText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppTheme.deepNavyBlue,
            ),
          ),
          subtitle: Text(
            timeago.format(timestamp),
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.deepNavyBlue.withOpacity(0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}

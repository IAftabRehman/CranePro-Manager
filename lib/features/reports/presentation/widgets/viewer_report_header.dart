import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';

class ViewerReportHeader extends StatelessWidget {
  final String title;
  final String summaryLabel;
  final String summaryValue;
  final DateTime fromDate;
  final DateTime toDate;
  final VoidCallback onSelectDateRange;

  const ViewerReportHeader({
    super.key,
    required this.title,
    required this.summaryLabel,
    required this.summaryValue,
    required this.fromDate,
    required this.toDate,
    required this.onSelectDateRange,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = '${DateFormat('dd MMM').format(fromDate)} - ${DateFormat('dd MMM').format(toDate)}';

    return Column(
      children: [
        // Title & Summary Row
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                summaryLabel.toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.deepNavyBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                summaryValue,
                style: const TextStyle(
                  color: AppTheme.deepNavyBlue,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Date Selector Row
        GestureDetector(
          onTap: onSelectDateRange,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.deepNavyBlue.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_rounded, color: AppTheme.deepNavyBlue, size: 20),
                const SizedBox(width: 12),
                Text(
                  dateStr,
                  style: const TextStyle(
                    color: AppTheme.deepNavyBlue,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                const Text(
                  'FILTER',
                  style: TextStyle(
                    color: AppTheme.deepNavyBlue,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.deepNavyBlue, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


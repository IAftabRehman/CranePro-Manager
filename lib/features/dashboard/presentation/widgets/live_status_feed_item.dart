import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/features/quotation/data/models/quotation_model.dart';

class LiveStatusFeedItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final QuotationStatus status;
  final String? reason;

  const LiveStatusFeedItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.status,
    this.reason,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusLabel;

    switch (status) {
      case QuotationStatus.completed:
        statusColor = const Color(0xFF2E7D32);
        statusIcon = Icons.check_circle_rounded;
        statusLabel = 'COMPLETED';
        break;
      case QuotationStatus.pending:
        statusColor = const Color(0xFFE65100);
        statusIcon = Icons.hourglass_top_rounded;
        statusLabel = 'PENDING';
        break;
      case QuotationStatus.cancelled:
        statusColor = const Color(0xFFB71C1C);
        statusIcon = Icons.cancel_rounded;
        statusLabel = 'CANCELLED';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0x66FFFFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 12),
              Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              Text(
                amount,
                style: const TextStyle(
                  color: AppTheme.deepNavyBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.deepNavyBlue,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0x990A1931),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          
          if (status == QuotationStatus.cancelled && reason != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0x1AF44336),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Reason: $reason',
                style: const TextStyle(
                  color: Color(0xFFB71C1C),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

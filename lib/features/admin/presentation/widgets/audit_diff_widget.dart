import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';

class AuditDiffWidget extends StatelessWidget {
  final String label;
  final String? before;
  final String? after;

  const AuditDiffWidget({
    super.key,
    required this.label,
    this.before,
    this.after,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: AppTheme.deepNavyBlue.withValues(alpha: 0.5),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (before != null && before!.isNotEmpty)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('BEFORE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.red)),
                      Text(
                        before!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.red,
                          decorationThickness: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              if (before != null && before!.isNotEmpty && after != null && after!.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Icon(Icons.arrow_forward_rounded, size: 20, color: AppTheme.deepNavyBlue),
                ),
              if (after != null && after!.isNotEmpty)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AFTER', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.green.shade900)),
                      Text(
                        after!,
                        style: TextStyle(
                          color: Colors.green.shade900,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

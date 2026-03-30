import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/features/admin/data/models/activity_log_model.dart';

class AdminActivityLogsPage extends StatefulWidget {
  const AdminActivityLogsPage({super.key});

  @override
  State<AdminActivityLogsPage> createState() => _AdminActivityLogsPageState();
}

class _AdminActivityLogsPageState extends State<AdminActivityLogsPage> {
  final StreamController<List<ActivityLog>> _logController = StreamController<List<ActivityLog>>();
  final List<ActivityLog> _logs = [
    ActivityLog(id: '1', userName: 'Aftab Rehman', category: LogCategory.login, message: 'Logged in from Dubai Terminal', timestamp: DateTime.now().subtract(const Duration(minutes: 5))),
    ActivityLog(id: '2', userName: 'John Doe', category: LogCategory.work, message: 'Generated a new Quotation for Emaar Sites', timestamp: DateTime.now().subtract(const Duration(minutes: 15))),
    ActivityLog(id: '3', userName: 'Jane Smith', category: LogCategory.signup, message: 'New user Jane Smith is waiting for approval', timestamp: DateTime.now().subtract(const Duration(minutes: 45))),
  ];

  Timer? _mockTimer;

  @override
  void initState() {
    super.initState();
    _logController.add(_logs);
    _startMockStream();
  }

  @override
  void dispose() {
    _mockTimer?.cancel();
    _logController.close();
    super.dispose();
  }

  void _startMockStream() {
    _mockTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      final newLog = _generateRandomLog();
      setState(() {
        _logs.insert(0, newLog);
        _logController.add(_logs);
      });
    });
  }

  ActivityLog _generateRandomLog() {
    final names = ['Ali Qasim', 'Sarah Khan', 'Hamza Ali', 'Omar Farooq'];
    final actions = [
      {'val': 'Logged in', 'cat': LogCategory.login},
      {'val': 'Added 500 AED Fuel Expense', 'cat': LogCategory.maintenance},
      {'val': 'Completed worksite: Binladin Group', 'cat': LogCategory.work},
      {'val': 'Logged out', 'cat': LogCategory.cancellation},
    ];
    final selectedAction = (actions..shuffle()).first;
    
    return ActivityLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: (names..shuffle()).first,
      category: selectedAction['cat'] as LogCategory,
      message: selectedAction['val'] as String,
      timestamp: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ActivityLog>>(
      stream: _logController.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final logs = snapshot.data!;
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            return TimelineTile(
              log: logs[index],
              isFirst: index == 0,
              isLast: index == logs.length - 1,
            );
          },
        );
      },
    );
  }
}

class TimelineTile extends StatelessWidget {
  final ActivityLog log;
  final bool isFirst;
  final bool isLast;

  const TimelineTile({
    super.key,
    required this.log,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          _buildTimelineIndicator(),
          const SizedBox(width: 16),
          Expanded(
            child: _buildLogCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineIndicator() {
    return Column(
      children: [
        Container(
          width: 2,
          height: 12,
          color: isFirst ? Colors.transparent : AppTheme.deepNavyBlue.withOpacity(0.2),
        ),
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            color: log.category.color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: log.category.color, width: 2),
            boxShadow: [
              BoxShadow(
                color: log.category.color.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(log.category.icon, color: log.category.color, size: 16),
        ),
        Expanded(
          child: Container(
            width: 2,
            color: isLast ? Colors.transparent : AppTheme.deepNavyBlue.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildLogCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      log.userName,
                      style: const TextStyle(
                        color: AppTheme.deepNavyBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      DateFormat('HH:mm').format(log.timestamp),
                      style: TextStyle(
                        color: AppTheme.deepNavyBlue.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  log.message,
                  style: TextStyle(
                    color: AppTheme.deepNavyBlue.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  log.category.name,
                  style: TextStyle(
                    color: log.category.color,
                    fontSize: 12,
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

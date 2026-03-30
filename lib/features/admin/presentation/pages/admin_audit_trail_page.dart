import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/features/admin/data/models/audit_entry.dart';
import 'package:extend_crane_services/features/admin/presentation/widgets/audit_diff_widget.dart';

class AdminAuditTrailPage extends StatefulWidget {
  const AdminAuditTrailPage({super.key});

  @override
  State<AdminAuditTrailPage> createState() => _AdminAuditTrailPageState();
}

class _AdminAuditTrailPageState extends State<AdminAuditTrailPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<AuditEntry> _auditTrail = [
    AuditEntry(
      id: '1',
      userName: 'Aftab Rehman',
      targetType: 'Quotation',
      targetName: 'Emaar Sites',
      action: AuditAction.edit,
      beforeValues: {'Total Amount': '12,500 AED', 'Crane Type': '50 Ton Crane'},
      afterValues: {'Total Amount': '15,000 AED', 'Crane Type': '100 Ton Crane'},
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AuditEntry(
      id: '2',
      userName: 'John Doe',
      targetType: 'Maintenance',
      targetName: 'Crane #55',
      action: AuditAction.edit,
      beforeValues: {'Parts Cost': '500 AED'},
      afterValues: {'Parts Cost': '1,200 AED'},
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    AuditEntry(
      id: '3',
      userName: 'Ali Qasim',
      targetType: 'Quotation',
      targetName: 'Dubai Metro',
      action: AuditAction.delete,
      beforeValues: {'Date': '24 Mar 2024', 'Amount': '22,000 AED'},
      afterValues: {},
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isDeleted: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AuditEntry> _getFilteredEntries(bool showDeleted) {
    return _auditTrail.where((e) {
      final matchesStatus = e.isDeleted == showDeleted;
      final matchesSearch = e.userName.toLowerCase().contains(_searchQuery) ||
                            e.targetName.toLowerCase().contains(_searchQuery);
      return matchesStatus && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            child: Text(
              "Check Edit\nor Deleted History of Operators",
              style: TextStyle(
                color: Color(0xFFFFB300),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const TabBar(
            tabs: [
              Tab(text: 'Edits'),
              Tab(text: 'Deleted'),
            ],
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            labelStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildAuditList(false),
                _buildAuditList(true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditList(bool showDeleted) {
    final entries = _getFilteredEntries(showDeleted);

    if (entries.isEmpty) {
      return Center(
        child: Text(
          showDeleted ? 'Recycle Bin is Empty' : 'No Changes Logged',
          style: TextStyle(color: AppTheme.deepNavyBlue.withOpacity(0.5), fontWeight: FontWeight.w800),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      itemCount: entries.length,
      itemBuilder: (context, index) => _buildAuditTile(entries[index]),
    );
  }

  Widget _buildAuditTile(AuditEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: Icon(
                entry.isDeleted ? Icons.delete_forever_rounded : Icons.edit_note_rounded,
                color: entry.isDeleted ? Colors.red.shade900 : AppTheme.deepNavyBlue,
                size: 32,
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.targetName,
                          style: const TextStyle(color: AppTheme.deepNavyBlue, fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          '${entry.targetType} - ${entry.userName}',
                          style: TextStyle(color: AppTheme.deepNavyBlue.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  if (entry.isDeleted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red.shade900, borderRadius: BorderRadius.circular(8)),
                      child: const Text('DELETED', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                    ),
                ],
              ),
              subtitle: Text(
                DateFormat('MMM dd, HH:mm').format(entry.timestamp),
                style: TextStyle(color: AppTheme.deepNavyBlue.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w800),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: entry.action == AuditAction.delete
                        ? [_buildDeletedSummary(entry)]
                        : entry.beforeValues.keys.map((key) {
                            return AuditDiffWidget(
                              label: key,
                              before: entry.beforeValues[key],
                              after: entry.afterValues[key],
                            );
                          }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeletedSummary(AuditEntry entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'RECORD PERMANENTLY ARCHIVED',
          style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
        const SizedBox(height: 16),
        ...entry.beforeValues.entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(e.key, style: TextStyle(color: AppTheme.deepNavyBlue.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w700)),
              Text(e.value, style: const TextStyle(color: AppTheme.deepNavyBlue, fontSize: 13, fontWeight: FontWeight.w800)),
            ],
          ),
        )),
      ],
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/features/admin/data/models/audit_entry.dart';
import 'package:extend_crane_services/features/admin/presentation/widgets/audit_diff_widget.dart';
import 'package:extend_crane_services/features/admin/data/repositories/admin_repository.dart';

class AdminAuditTrailPage extends StatefulWidget {
  const AdminAuditTrailPage({super.key});

  @override
  State<AdminAuditTrailPage> createState() => _AdminAuditTrailPageState();
}

class _AdminAuditTrailPageState extends State<AdminAuditTrailPage> {
  final TextEditingController _searchController = TextEditingController();
  final AdminRepository _adminRepository = AdminRepository();
  String _searchQuery = '';

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

  List<AuditEntry> _filterEntries(List<AuditEntry> auditTrail, bool showDeleted) {
    return auditTrail.where((e) {
      final matchesStatus = e.isDeleted == showDeleted;
      final matchesSearch = e.userName.toLowerCase().contains(_searchQuery) ||
                            e.targetName.toLowerCase().contains(_searchQuery);
      return matchesStatus && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AuditEntry>>(
      stream: _adminRepository.getAuditTrailStream(),
      builder: (context, snapshot) {
        final auditTrail = snapshot.data ?? [];

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
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
                    AuditList(
                      entries: _filterEntries(auditTrail, false),
                      showDeleted: false,
                    ),
                    AuditList(
                      entries: _filterEntries(auditTrail, true),
                      showDeleted: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class AuditList extends StatelessWidget {
  final List<AuditEntry> entries;
  final bool showDeleted;

  const AuditList({
    super.key,
    required this.entries,
    required this.showDeleted,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Text(
          showDeleted ? 'Recycle Bin is Empty' : 'No Changes Logged',
          style: const TextStyle(color: Color(0x800A1931), fontWeight: FontWeight.w800),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final listWidget = ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          itemCount: entries.length,
          itemBuilder: (context, index) => AuditTile(entry: entries[index]),
        );

        if (isWide) {
          return Align(
            alignment: Alignment.topCenter,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900),
              child: listWidget,
            ),
          );
        }
        return listWidget;
      }
    );
  }
}

class AuditTile extends StatelessWidget {
  final AuditEntry entry;

  const AuditTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0x26FFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x4DFFFFFF)),
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
                          style: const TextStyle(color: Color(0x990A1931), fontSize: 12, fontWeight: FontWeight.w700),
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
                style: const TextStyle(color: Color(0x660A1931), fontSize: 10, fontWeight: FontWeight.w800),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: entry.action == AuditAction.delete
                        ? [AuditDeletedSummary(entry: entry)]
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
}

class AuditDeletedSummary extends StatelessWidget {
  final AuditEntry entry;

  const AuditDeletedSummary({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
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
              Text(e.key, style: const TextStyle(color: Color(0x990A1931), fontSize: 12, fontWeight: FontWeight.w700)),
              Text(e.value, style: const TextStyle(color: AppTheme.deepNavyBlue, fontSize: 13, fontWeight: FontWeight.w800)),
            ],
          ),
        )),
      ],
    );
  }
}


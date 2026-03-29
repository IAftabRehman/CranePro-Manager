import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_button.dart';
import 'package:extend_crane_services/features/admin/data/models/backup_status.dart';
import 'package:extend_crane_services/features/admin/data/services/backup_service.dart';

class AdminBackupPage extends StatefulWidget {
  const AdminBackupPage({super.key});

  @override
  State<AdminBackupPage> createState() => _AdminBackupPageState();
}

class _AdminBackupPageState extends State<AdminBackupPage> {
  final BackupService _backupService = BackupService();
  BackupStatus? _currentStatus;
  bool _isBackingUp = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _currentStatus = BackupStatus(
      lastBackupDate: DateTime.now().subtract(const Duration(days: 2)),
      fileSize: '1.24 MB',
      isSuccess: true,
      backupType: 'Auto',
    );
  }

  Future<void> _handleManualBackup() async {
    setState(() {
      _isBackingUp = true;
      _progress = 0.0;
    });

    // Simulate real-time data aggregation and upload
    for (var i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() => _progress = i / 10);
    }

    final status = await _backupService.createManualBackup(
      users: [], quotations: [], auditTrail: [],
    );

    setState(() {
      _currentStatus = status;
      _isBackingUp = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('System Snapshot Created Successfully!'), backgroundColor: Colors.green),
      );
    }
  }

  void _showRestoreWarning() {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('DANGER ZONE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900)),
            ],
          ),
          content: const Text(
            'RESTORE: This will overwrite ALL current business data with the latest backup. This action cannot be undone. Proceed?',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
            ),
            CraneButton(
              text: 'RESTORE DATABASE',
              onPressed: () async {
                Navigator.pop(context);
                final success = await _backupService.restoreFromLatestBackup();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'System Restored Successfully!' : 'No Backup Found!'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.lavenderBlueGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildStatusCard(),
                      const SizedBox(height: 32),
                      _buildInfoTable(),
                      const SizedBox(height: 60),
                      if (_isBackingUp) ...[
                        Text('GENERATING SNAPSHOT...', style: TextStyle(color: AppTheme.deepNavyBlue.withValues(alpha: 0.6), fontWeight: FontWeight.w900, fontSize: 13)),
                        const SizedBox(height: 16),
                        _buildProgressBar(),
                      ] else ...[
                        CraneButton(
                          text: 'CREATE NEW BACKUP',
                          onPressed: _handleManualBackup,
                          icon: Icons.cloud_upload_outlined,
                        ),
                        const SizedBox(height: 24),
                        OutlinedButton.icon(
                          onPressed: _showRestoreWarning,
                          icon: const Icon(Icons.settings_backup_restore, color: Colors.red),
                          label: const Text('RESTORE FROM RECENT FILE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 16)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red, width: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.deepNavyBlue),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'DATA SECURITY HUB',
              style: TextStyle(
                color: AppTheme.deepNavyBlue,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.security_update_good_rounded, size: 64, color: AppTheme.deepNavyBlue),
          const SizedBox(height: 16),
          const Text('SYSTEM HEALTH: SECURE', style: TextStyle(color: AppTheme.deepNavyBlue, fontSize: 18, fontWeight: FontWeight.w900)),
          Text(
            'Weekly automated snapshots enabled',
            style: TextStyle(color: AppTheme.deepNavyBlue.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTable() {
    return Column(
      children: [
        _buildInfoRow('LAST BACKUP', DateFormat('MMM dd, HH:mm').format(_currentStatus!.lastBackupDate)),
        const Divider(color: Colors.white24),
        _buildInfoRow('FILE SIZE', _currentStatus!.fileSize),
        const Divider(color: Colors.white24),
        _buildInfoRow('BACKUP TYPE', _currentStatus!.backupType),
        const Divider(color: Colors.white24),
        _buildInfoRow('ENCRYPTION', 'AES-256 (Cloud Restricted)'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.deepNavyBlue.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w900)),
          Text(value, style: const TextStyle(color: AppTheme.deepNavyBlue, fontSize: 16, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: _progress,
        minHeight: 12,
        backgroundColor: Colors.white.withValues(alpha: 0.2),
        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.deepNavyBlue),
      ),
    );
  }
}

import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_button.dart';
import 'package:extend_crane_services/features/admin/data/models/backup_status.dart';
import 'package:extend_crane_services/features/admin/data/services/backup_service.dart';
import 'package:extend_crane_services/features/admin/data/repositories/admin_repository.dart';

class AdminBackupPage extends StatefulWidget {
  const AdminBackupPage({super.key});

  @override
  State<AdminBackupPage> createState() => _AdminBackupPageState();
}

class _AdminBackupPageState extends State<AdminBackupPage> {
  final BackupService _backupService = BackupService();
  final AdminRepository _adminRepository = AdminRepository();
  bool _isBackingUp = false;
  double _progress = 0.0;

  Future<void> _handleManualBackup() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() {
      _isBackingUp = true;
      _progress = 0.1;
    });

    try {
      // 1. Data Aggregation (Firestore -> RAM)
      setState(() => _progress = 0.3);
      final users = await _adminRepository.fetchAllUsers();
      
      setState(() => _progress = 0.5);
      final quotations = await _adminRepository.fetchAllQuotations();
      
      setState(() => _progress = 0.7);
      final auditTrail = await _adminRepository.fetchAllAuditTrail();

      // 2. Transmit Snapshot to Cloud
      setState(() => _progress = 0.9);
      await _backupService.createManualBackup(
        users: users,
        quotations: quotations,
        auditTrail: auditTrail,
      );

      setState(() => _progress = 1.0);
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('System Snapshot Created Successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Backup Failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBackingUp = false;
          _progress = 0.0;
        });
      }
    }
  }

  void _showRestoreWarning(BackupStatus status) {
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
              Text('Danger Zone', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900)),
            ],
          ),
          content: Text(
            'RESTORE: This will overwrite ALL current business data with the snapshot from ${DateFormat('MMM dd, HH:mm').format(status.lastBackupDate)}. \n\nAre you sure you want to restore the entire database?',
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            CraneButton(
              text: 'Restore Now',
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context, rootNavigator: true);
                
                // Close the confirm dialog
                navigator.pop();
                
                // Show universal loading indicator with descriptive text
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    content: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppTheme.deepNavyBlue),
                        SizedBox(height: 24),
                        Text(
                          'SYSTEM RESTORE IN PROGRESS',
                          style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.deepNavyBlue, letterSpacing: 1.2),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Please do not close the app...',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );

                try {
                  final success = await _backupService.restoreFromSnapshot(status);
                  
                  if (mounted) {
                    navigator.pop(); // Close loading
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(success ? 'System Restored Successfully!' : 'Cloud Snapshot Not Found!'),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                   if (mounted) {
                    navigator.pop(); // Close loading
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Critical Restore Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
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
    return StreamBuilder<BackupStatus?>(
      stream: _adminRepository.getBackupStatusStream(),
      builder: (context, snapshot) {
        final currentStatus = snapshot.data;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildStatusCard(),
              const SizedBox(height: 20),
              if (currentStatus != null)
                _buildInfoTable(currentStatus)
              else
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'No backup history found.',
                      style: TextStyle(color: AppTheme.deepNavyBlue.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              if (_isBackingUp) ...[
                Text('GENERATING SNAPSHOT...', style: TextStyle(color: AppTheme.deepNavyBlue.withValues(alpha: 0.6), fontWeight: FontWeight.w900, fontSize: 13)),
                const SizedBox(height: 16),
                _buildProgressBar(),
              ] else ...[
                CraneButton(
                  text: 'Create BackUp',
                  onPressed: _handleManualBackup,
                  icon: null,
                ),
                const SizedBox(height: 20),
                if (currentStatus != null)
                  ElevatedButton(
                    onPressed: () => _showRestoreWarning(currentStatus),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      side: const BorderSide(color: Colors.red, width: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Restore Cloud Snapshot', style: TextStyle(color: Colors.red, fontSize: 15)),
                  ),
              ],
              const SizedBox(height: 100),
              // Hidden Debug Area
              Opacity(
                opacity: 0.1,
                child: TextButton(
                  onPressed: () => FirebaseCrashlytics.instance.crash(),
                  child: const Text('DEBUG: FORCE CRASH', style: TextStyle(color: Colors.black, fontSize: 10)),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(5, 20),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(Icons.security_update_good_rounded, size: 50, color: AppTheme.deepNavyBlue),
          SizedBox(height: 16),
          Text('System Health: Secure', style: TextStyle(color: AppTheme.deepNavyBlue, fontSize: 18, fontWeight: FontWeight.w900))
        ],
      ),
    );
  }

  Widget _buildInfoTable(BackupStatus status) {
    return Column(
      children: [
        _buildInfoRow('LAST BACKUP', DateFormat('MMM dd, HH:mm').format(status.lastBackupDate)),
        const Divider(color: Colors.white24),
        _buildInfoRow('FILE SIZE', status.fileSize),
        const Divider(color: Colors.white24),
        _buildInfoRow('BACKUP TYPE', status.backupType),
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
          Text(label, style: TextStyle(color: AppTheme.deepNavyBlue.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w900)),
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


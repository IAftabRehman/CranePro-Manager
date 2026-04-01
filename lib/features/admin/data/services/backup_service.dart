import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:extend_crane_services/features/admin/data/models/backup_status.dart';
import 'package:extend_crane_services/features/admin/data/repositories/admin_repository.dart';

class BackupService {
  final AdminRepository _repository = AdminRepository();

  Future<BackupStatus> createManualBackup({
    required List<dynamic> users,
    required List<dynamic> quotations,
    required List<dynamic> auditTrail,
  }) async {
    // 1. Aggregate Data
    final backupData = {
      'version': '1.0.0',
      'timestamp': DateTime.now().toIso8601String(),
      'users': users.map((e) => e.toMap()).toList(),
      'quotations': quotations,
      'auditTrail': auditTrail,
    };

    final jsonString = jsonEncode(backupData);
    final snapshotId = "snapshot_${DateTime.now().millisecondsSinceEpoch}";
    
    // 3. Cloud Snapshot Upload
    await _repository.uploadSnapshot(snapshotId, backupData);

    // 4. Calculate File Size
    final sizeInBytes = jsonString.length;
    final sizeInKB = (sizeInBytes / 1024).toStringAsFixed(2);

    final status = BackupStatus(
      lastBackupDate: DateTime.now(),
      fileSize: "$sizeInKB KB",
      isSuccess: true,
      backupType: 'Manual',
    );

    // 5. Log Metadata to Firestore
    await _repository.logBackupStatus(status);

    return status;
  }

  Future<bool> restoreFromSnapshot(BackupStatus status) async {
    try {
      final snapshotId = "snapshot_${status.lastBackupDate.millisecondsSinceEpoch}";
      final data = await _repository.fetchSnapshot(snapshotId);
      
      if (data == null) return false;

      await _repository.performSystemRestore(data);
      return true;
    } catch (e) {
      print('Cloud Restore Error: $e');
      return false;
    }
  }

  Future<bool> restoreFromLatestBackup() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync().where((f) => f.path.contains('CranePro_Backup_')).toList();
      
      if (files.isEmpty) return false;

      // Logic to grab most recent file and parse JSON
      final latestFile = files.last as File;
      final jsonString = await latestFile.readAsString();
      final Map<String, dynamic> data = jsonDecode(jsonString);

      // Trigger state restoration here (e.g. notify listeners/repositories)
      print('Restoring data from ${data['timestamp']}...');
      
      return true;
    } catch (e) {
      print('Restore Error: $e');
      return false;
    }
  }

  Future<void> performAutoBackupTask() async {
    // This is called by WorkManager weekly
    print('Executing Automated Weekly Snapshot...');
    // Simulated backup logic here for background execution
  }
}

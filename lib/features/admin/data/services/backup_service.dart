import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:extend_crane_services/features/admin/data/models/backup_status.dart';

class BackupService {
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

    // 2. Serialize and Compress Simulation
    final jsonString = jsonEncode(backupData);
    final fileName = "CranePro_Backup_${DateTime.now().millisecondsSinceEpoch}.json";
    
    // 3. Local Storage I/O
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(jsonString);

    // 4. Calculate File Size
    final sizeInBytes = jsonString.length;
    final sizeInKB = (sizeInBytes / 1024).toStringAsFixed(2);

    return BackupStatus(
      lastBackupDate: DateTime.now(),
      fileSize: "$sizeInKB KB",
      isSuccess: true,
      backupType: 'Manual',
    );
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

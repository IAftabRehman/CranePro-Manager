import 'package:cloud_firestore/cloud_firestore.dart';

class BackupStatus {
  final DateTime lastBackupDate;
  final String fileSize;
  final bool isSuccess;
  final String backupType; // 'Manual' or 'Auto'

  const BackupStatus({
    required this.lastBackupDate,
    required this.fileSize,
    required this.isSuccess,
    required this.backupType,
  });

  Map<String, dynamic> toMap() {
    return {
      'lastBackupDate': Timestamp.fromDate(lastBackupDate),
      'fileSize': fileSize,
      'isSuccess': isSuccess,
      'backupType': backupType,
    };
  }

  factory BackupStatus.fromMap(Map<String, dynamic> map) {
    return BackupStatus(
      lastBackupDate: (map['lastBackupDate'] as Timestamp).toDate(),
      fileSize: map['fileSize'] ?? '0 KB',
      isSuccess: map['isSuccess'] ?? false,
      backupType: map['backupType'] ?? 'Manual',
    );
  }
}

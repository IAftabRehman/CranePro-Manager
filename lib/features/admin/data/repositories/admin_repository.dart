import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:rxdart/rxdart.dart';

import '../../../auth/data/models/user_model.dart';
import '../models/activity_log_model.dart';
import '../models/backup_status.dart';
import '../models/audit_entry.dart';

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns a real-time stream of all users from the 'users' collection.
  Stream<List<UserModel>> getUsersStream() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .toList();
        });
  }

  /// Approves a user by setting isAdminApproved to true.
  Future<void> approveUser(String userId) async {
    await FirebaseCrashlytics.instance.log(
      "Action: approveUser - UID: $userId",
    );
    await _firestore.collection('users').doc(userId).update({
      'isAdminApproved': true,
      'rejectionReason': FieldValue.delete(),
    });
  }

  /// Rejects a user with a specific reason.
  Future<void> rejectUser(String userId, String reason) async {
    await _firestore.collection('users').doc(userId).update({
      'isAdminApproved': false,
      'rejectionReason': reason,
    });
  }

  /// Toggles the block status of a user.
  Future<void> toggleBlockUser(String uid, bool blockStatus) async {
    await _firestore.collection('users').doc(uid).update({
      'isBlocked': blockStatus,
    });
  }

  /// Updates user status, approval, and role in a single operation.
  Future<void> updateUserStatus(
    String uid,
    bool isApproved,
    String role,
  ) async {
    await FirebaseCrashlytics.instance.log(
      "Action: updateUserStatus - UID: $uid, Approved: $isApproved, Role: $role",
    );
    await _firestore.collection('users').doc(uid).update({
      'isAdminApproved': isApproved,
      'role': role,
      'rejectionReason': isApproved ? FieldValue.delete() : null,
    });

    if (isApproved) {
      await FirebaseAnalytics.instance.logEvent(
        name: 'admin_approved_user',
        parameters: {'user_id': uid, 'assigned_role': role},
      );
    }
  }

  /// Returns a real-time stream of all activity logs.
  Stream<List<ActivityLog>> getActivityLogsStream() {
    return _firestore
        .collection('activity_logs')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ActivityLog.fromMap(doc.data(), docId: doc.id))
          .toList();
    });
  }

  /// Returns a combined stream of User Signups and Quotations for Activity Tracking.
  Stream<List<Map<String, dynamic>>> getCombinedActivityStream() {
    final usersStream = _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .limit(15)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()..['id'] = d.id).toList());

    final quotationsStream = _firestore
        .collection('quotations')
        .orderBy('createdAt', descending: true)
        .limit(15)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()..['id'] = d.id).toList());

    return CombineLatestStream.combine2<List<Map<String, dynamic>>,
        List<Map<String, dynamic>>, List<Map<String, dynamic>>>(
      usersStream,
      quotationsStream,
      (users, quotations) {
        final combined = [...users, ...quotations];
        combined.sort((a, b) {
          final aTime = (a['createdAt'] as Timestamp).toDate();
          final bTime = (b['createdAt'] as Timestamp).toDate();
          return bTime.compareTo(aTime);
        });
        return combined.take(15).toList();
      },
    );
  }

  /// Returns a real-time stream of the latest backup status.
  Stream<BackupStatus?> getBackupStatusStream() {
    return _firestore
        .collection('backups')
        .orderBy('lastBackupDate', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return BackupStatus.fromMap(snapshot.docs.first.data());
    });
  }

  /// Logs a new backup operation to Firestore.
  Future<void> logBackupStatus(BackupStatus status) async {
    await _firestore.collection('backups').add(status.toMap());
  }

  /// Returns a real-time stream of all audit trail entries.
  Stream<List<AuditEntry>> getAuditTrailStream() {
    return _firestore
        .collection('audit_trail')
        .orderBy('timestamp', descending: true)
        .limit(200)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AuditEntry.fromMap(doc.data(), docId: doc.id))
          .toList();
    });
  }

  /// Logs a new audit event to Firestore.
  Future<void> logAudit(AuditEntry entry) async {
    await _firestore.collection('audit_trail').add(entry.toMap());
  }

  /// Fetches ALL users for backup purposes.
  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => doc.data()..['id'] = doc.id).toList();
  }

  /// Fetches ALL quotations for backup purposes.
  Future<List<Map<String, dynamic>>> fetchAllQuotations() async {
    final snapshot = await _firestore.collection('quotations').get();
    return snapshot.docs.map((doc) => doc.data()..['id'] = doc.id).toList();
  }

  /// Fetches ALL audit entries for backup purposes.
  Future<List<Map<String, dynamic>>> fetchAllAuditTrail() async {
    final snapshot = await _firestore.collection('audit_trail').get();
    return snapshot.docs.map((doc) => doc.data()..['id'] = doc.id).toList();
  }

  /// Uploads a complete system snapshot to Firestore.
  Future<void> uploadSnapshot(String snapshotId, Map<String, dynamic> data) async {
    await _firestore.collection('snapshots_archive').doc(snapshotId).set(data);
  }

  /// Fetches a complete system snapshot from Firestore.
  Future<Map<String, dynamic>?> fetchSnapshot(String snapshotId) async {
    final doc = await _firestore.collection('snapshots_archive').doc(snapshotId).get();
    return doc.data();
  }

  /// Performs a full system restore by overwriting active collections in chunks of 400.
  Future<void> performSystemRestore(Map<String, dynamic> snapshotData) async {
    WriteBatch batch = _firestore.batch();
    int opsCount = 0;

    Future<void> commitIfLimit() async {
      opsCount++;
      if (opsCount >= 400) {
        await batch.commit();
        batch = _firestore.batch();
        opsCount = 0;
      }
    }

    // 1. Restore Users
    final users = snapshotData['users'] as List;
    final userDocs = await _firestore.collection('users').get();
    for (var doc in userDocs.docs) {
      batch.delete(doc.reference);
      await commitIfLimit();
    }
    for (var u in users) {
      final data = Map<String, dynamic>.from(u);
      final id = data.remove('id');
      batch.set(_firestore.collection('users').doc(id), data);
      await commitIfLimit();
    }

    // 2. Restore Quotations
    final quotations = snapshotData['quotations'] as List;
    final quotationDocs = await _firestore.collection('quotations').get();
    for (var doc in quotationDocs.docs) {
      batch.delete(doc.reference);
      await commitIfLimit();
    }
    for (var q in quotations) {
      final data = Map<String, dynamic>.from(q);
      final id = data.remove('id');
      batch.set(_firestore.collection('quotations').doc(id), data);
      await commitIfLimit();
    }

    // 3. Restore Audit Trail
    final auditTrail = snapshotData['auditTrail'] as List;
    final auditDocs = await _firestore.collection('audit_trail').get();
    for (var doc in auditDocs.docs) {
      batch.delete(doc.reference);
      await commitIfLimit();
    }
    for (var a in auditTrail) {
      final data = Map<String, dynamic>.from(a);
      final id = data.remove('id');
      batch.set(_firestore.collection('audit_trail').doc(id), data);
      await commitIfLimit();
    }

    // Commit final batch if anything is left
    if (opsCount > 0) {
      await batch.commit();
    }
  }
}

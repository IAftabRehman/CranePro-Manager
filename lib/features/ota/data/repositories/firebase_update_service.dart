import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../models/version_info_model.dart';
import 'dart:developer';

class FirebaseUpdateService {
  final FirebaseFirestore _firestore;

  FirebaseUpdateService([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetches version info document from Firestore.
  /// Path: /app_settings/version_info
  Future<VersionInfoModel?> fetchVersionInfo() async {
    try {
      final doc = await _firestore
          .collection('app_settings')
          .doc('version_info')
          .get()
          .timeout(const Duration(seconds: 5));

      if (doc.exists && doc.data() != null) {
        return VersionInfoModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e, stack) {
      log("Error fetching version info: $e");
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'Failed to fetch OTA version info from Firestore',
      );
      return null;
    }
  }
}

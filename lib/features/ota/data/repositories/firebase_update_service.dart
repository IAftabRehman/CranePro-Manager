import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../models/version_info_model.dart';
import 'dart:developer';
import 'dart:async';

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
      final isNetworkError = e.toString().contains('unavailable') || 
                             e.toString().contains('network') ||
                             e.toString().contains('SocketException');
      
      if (e is FirebaseException && e.code == 'permission-denied') {
        log("WARNING: Permission denied when reading '/app_settings/version_info'. "
            "Please check your Firestore security rules. Since update checks run on startup before login, "
            "the 'app_settings' collection must allow public/unauthenticated reads.");
      } else if (e is TimeoutException || isNetworkError) {
        log("Note: Fetching version info timed out or network is unavailable. App will proceed normally.");
      } else {
        FirebaseCrashlytics.instance.recordError(
          e,
          stack,
          reason: 'Failed to fetch OTA version info from Firestore',
        );
      }
      return null;
    }
  }
}

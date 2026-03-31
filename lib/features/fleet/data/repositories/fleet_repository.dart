import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/crane_model.dart';

class FleetRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Adds a new crane to the fleet.
  /// Validates that the craneNumber is unique.
  Future<void> addCrane(CraneModel crane) async {
    try {
      // Unique check for craneNumber
      final query = await _firestore
          .collection('cranes')
          .where('craneNumber', isEqualTo: crane.craneNumber)
          .get();

      if (query.docs.isNotEmpty) {
        throw Exception('A crane with number ${crane.craneNumber} already exists.');
      }

      await _firestore.collection('cranes').add(crane.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Updates an existing crane's details.
  Future<void> updateCrane(CraneModel crane) async {
    try {
      await _firestore.collection('cranes').doc(crane.id).update(crane.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Streams the entire fleet of cranes.
  Stream<List<CraneModel>> getCranesStream() {
    return _firestore.collection('cranes').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CraneModel.fromMap(doc.data(), docId: doc.id)).toList();
    });
  }
}

final fleetRepositoryProvider = Provider((ref) => FleetRepository());

final cranesStreamProvider = StreamProvider<List<CraneModel>>((ref) {
  return ref.watch(fleetRepositoryProvider).getCranesStream();
});

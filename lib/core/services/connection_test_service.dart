import 'package:cloud_firestore/cloud_firestore.dart';

/// Temporary service used only to verify Firestore connectivity.
/// This class will be deleted once we've confirmed the connection —
/// real Firestore access will live in proper feature-specific
/// repositories (e.g. SubjectsRepository) starting in Step 13.
class ConnectionTestService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> writeTestDocument() async {
    await _firestore.collection('connection_test').doc('ping').set({
      'message': 'StudyFlow connected successfully!',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<String?> readTestDocument() async {
    final doc = await _firestore.collection('connection_test').doc('ping').get();
    if (!doc.exists) return null;
    return doc.data()?['message'] as String?;
  }
}
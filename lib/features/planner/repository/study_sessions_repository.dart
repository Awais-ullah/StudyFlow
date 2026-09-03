import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/study_session.dart';
import '../../../core/constants/firestore_paths.dart';

class StudySessionsRepository {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String userId) =>
      _firestore.collection(FirestorePaths.studySessions(userId));

  Stream<List<StudySession>> watchSessions(String userId) {
    return _collection(userId).orderBy('startTime').snapshots().map(
          (snapshot) => snapshot.docs.map((d) => StudySession.fromMap(d.id, d.data())).toList(),
    );
  }

  Future<void> addSession(String userId, StudySession session) async {
    await _collection(userId).add(session.toMap());
  }

  Future<void> deleteSession(String userId, String sessionId) async {
    await _collection(userId).doc(sessionId).delete();
  }

  Future<void> updateStatus(String userId, String sessionId, SessionStatus status) async {
    await _collection(userId).doc(sessionId).update({'status': status.name});
  }
}
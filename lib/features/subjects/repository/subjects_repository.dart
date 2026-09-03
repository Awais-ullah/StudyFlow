import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/subject.dart';
import '../../../core/constants/firestore_paths.dart';

class SubjectsRepository {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String userId) =>
      _firestore.collection(FirestorePaths.subjects(userId));

  Stream<List<Subject>> watchSubjects(String userId) {
    return _collection(userId).snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => Subject.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }

  Future<void> addSubject(String userId, Subject subject) async {
    await _collection(userId).add({
      ...subject.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateSubject(String userId, Subject subject) async {
    await _collection(userId).doc(subject.id).update(subject.toMap());
  }

  Future<void> deleteSubject(String userId, String subjectId) async {
    await _collection(userId).doc(subjectId).delete();
  }
}
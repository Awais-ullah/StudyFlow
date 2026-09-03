import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/note.dart';
import '../../../core/constants/firestore_paths.dart';

class NotesRepository {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String userId) =>
      _firestore.collection(FirestorePaths.notes(userId));

  Stream<List<Note>> watchNotes(String userId) {
    return _collection(userId).orderBy('updatedAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Note.fromMap(doc.id, doc.data())).toList(),
    );
  }

  Future<void> addNote(String userId, Note note) async {
    await _collection(userId).add({
      ...note.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateNote(String userId, Note note) async {
    await _collection(userId).doc(note.id).update(note.toMap());
  }

  Future<void> deleteNote(String userId, String noteId) async {
    await _collection(userId).doc(noteId).delete();
  }

  Future<void> togglePin(String userId, String noteId, bool isPinned) async {
    await _collection(userId).doc(noteId).update({'isPinned': isPinned});
  }

  Future<void> toggleArchive(String userId, String noteId, bool isArchived) async {
    await _collection(userId).doc(noteId).update({'isArchived': isArchived});
  }
}
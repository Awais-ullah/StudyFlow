import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/task.dart';
import '../../../core/constants/firestore_paths.dart';

class TasksRepository {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String userId) =>
      _firestore.collection(FirestorePaths.tasks(userId));

  Stream<List<Task>> watchTasks(String userId) {
    return _collection(userId).orderBy('dueDate').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Task.fromMap(doc.id, doc.data())).toList(),
    );
  }

  Future<void> addTask(String userId, Task task) async {
    await _collection(userId).add({
      ...task.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTask(String userId, Task task) async {
    await _collection(userId).doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String userId, String taskId) async {
    await _collection(userId).doc(taskId).delete();
  }

  Future<void> toggleComplete(String userId, String taskId, bool isCompleted) async {
    await _collection(userId).doc(taskId).update({'isCompleted': isCompleted});
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskService {
  final CollectionReference _tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  // Create a new task
  Future<void> addTask(Task task) async {
    await _tasksCollection.doc(task.id).set(task.toJson());
  }

  // Update an existing task
  Future<void> updateTask(Task task) async {
    await _tasksCollection.doc(task.id).update(task.toJson());
  }

  // Delete a task
  Future<void> deleteTask(String id) async {
    await _tasksCollection.doc(id).delete();
  }

  // Get a single task by ID
  Future<Task?> getTask(String id) async {
    DocumentSnapshot doc = await _tasksCollection.doc(id).get();
    if (doc.exists) {
      return Task.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Get all tasks (real‑time stream) – for admin view
  Stream<List<Task>> getTasks() {
    return _tasksCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Task.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Get tasks for a specific intern (real‑time stream)
  Stream<List<Task>> getTasksForIntern(String internId) {
    return _tasksCollection
        .where('internId', isEqualTo: internId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Task.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
        });
  }
}

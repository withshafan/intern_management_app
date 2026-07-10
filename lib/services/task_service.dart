import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import 'package:flutter/material.dart';

class TaskService {
  final CollectionReference _tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  // Add a new task
  Future<Task> addTask(Task task) async {
    final docRef = task.id.isEmpty ? _tasksCollection.doc() : _tasksCollection.doc(task.id);
    final taskWithId = Task(
      id: docRef.id,
      internId: task.internId,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      status: task.status,
    );
    await docRef.set(taskWithId.toJson());
    return taskWithId;
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

  // Get all tasks with filters
  Stream<List<Task>> filterTasks({
    String? status,
    String? query,
    DateTimeRange? dueRange,
  }) {
    Query q = _tasksCollection;
    
    if (status != null && status.isNotEmpty) {
      q = q.where('status', isEqualTo: status);
    }
    
    return q.snapshots().map((snapshot) {
      var tasks = snapshot.docs
          .map((doc) => Task.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
          
      if (query != null && query.trim().isNotEmpty) {
        final qStr = query.trim().toLowerCase();
        tasks = tasks.where((t) => t.title.toLowerCase().contains(qStr)).toList();
      }
      
      if (dueRange != null) {
        tasks = tasks.where((t) {
          try {
            final date = DateTime.parse(t.dueDate);
            return date.isAfter(dueRange.start) && date.isBefore(dueRange.end.add(const Duration(days: 1)));
          } catch (e) {
            return false;
          }
        }).toList();
      }
      return tasks;
    });
  }

  // Get overdue tasks
  Stream<List<Task>> overdueTasks() {
    return _tasksCollection.where('status', isNotEqualTo: 'completed').snapshots().map((snapshot) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return snapshot.docs
          .map((doc) => Task.fromJson(doc.data() as Map<String, dynamic>))
          .where((t) {
            try {
              final date = DateTime.parse(t.dueDate);
              return date.isBefore(today);
            } catch (e) {
              return false;
            }
          }).toList();
    });
  }

  // Get due today tasks
  Stream<List<Task>> dueTodayTasks() {
    return _tasksCollection.where('status', isNotEqualTo: 'completed').snapshots().map((snapshot) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return snapshot.docs
          .map((doc) => Task.fromJson(doc.data() as Map<String, dynamic>))
          .where((t) {
            try {
              final date = DateTime.parse(t.dueDate);
              return date.year == today.year && date.month == today.month && date.day == today.day;
            } catch (e) {
              return false;
            }
          }).toList();
    });
  }
}

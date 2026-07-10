import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/intern.dart';

class InternService {
  final CollectionReference _internsCollection =
      FirebaseFirestore.instance.collection('interns');

  // Create a new intern
  Future<void> addIntern(Intern intern) async {
    await _internsCollection.doc(intern.id).set(intern.toJson());
  }

  // Update an existing intern
  Future<void> updateIntern(Intern intern) async {
    await _internsCollection.doc(intern.id).update(intern.toJson());
  }

  // Delete an intern
  Future<void> deleteIntern(String id) async {
    await _internsCollection.doc(id).delete();
  }

  // Get a single intern by ID
  Future<Intern?> getIntern(String id) async {
    DocumentSnapshot doc = await _internsCollection.doc(id).get();
    if (doc.exists) {
      return Intern.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Get all interns (real‑time stream)
  Stream<List<Intern>> getInterns() {
    return _internsCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Intern.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Get interns for a specific user (if needed)
  // Not needed for admin view, but we'll implement later.

  // Get all interns with filters
  Stream<List<Intern>> searchInterns({
    String? query,
    String? department,
    double? minProgress,
    double? maxProgress,
  }) {
    Query q = _internsCollection;
    
    if (department != null && department.isNotEmpty) {
      q = q.where('department', isEqualTo: department);
    }
    
    if (minProgress != null) {
      q = q.where('progress', isGreaterThanOrEqualTo: minProgress);
    }
    if (maxProgress != null) {
      q = q.where('progress', isLessThanOrEqualTo: maxProgress);
    }

    return q.snapshots().map((snapshot) {
      var interns = snapshot.docs
          .map((doc) => Intern.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
          
      if (query != null && query.trim().isNotEmpty) {
        final qStr = query.trim().toLowerCase();
        interns = interns.where((intern) => intern.name.toLowerCase().contains(qStr)).toList();
      }
      return interns;
    });
  }
}

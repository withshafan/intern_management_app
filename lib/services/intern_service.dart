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
}

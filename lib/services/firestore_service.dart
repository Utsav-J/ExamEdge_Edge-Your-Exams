import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/document_summary.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _summariesCollection =>
      _firestore.collection('document_summaries');

  // Get document summary from Firestore
  Future<DocumentSummary?> getDocumentSummary(String uniqueFilename) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final docRef = _summariesCollection
          .doc(user.uid)
          .collection('summaries')
          .doc(uniqueFilename);

      final doc = await docRef.get();
      if (!doc.exists) return null;

      return DocumentSummary.fromFirestore(doc);
    } catch (e) {
      print('Error getting document summary: $e');
      return null;
    }
  }

  // Save document summary to Firestore
  Future<void> saveDocumentSummary(
    String uniqueFilename,
    DocumentSummary summary,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user logged in';

      await _summariesCollection
          .doc(user.uid)
          .collection('summaries')
          .doc(uniqueFilename)
          .set(summary.toJson());
    } catch (e) {
      print('Error saving document summary: $e');
      throw e;
    }
  }

  // Delete document summary from Firestore
  Future<void> deleteDocumentSummary(String uniqueFilename) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _summariesCollection
          .doc(user.uid)
          .collection('summaries')
          .doc(uniqueFilename)
          .delete();
    } catch (e) {
      print('Error deleting document summary: $e');
    }
  }

  // Clear all summaries for current user
  Future<void> clearAllSummaries() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final summaries = await _summariesCollection
          .doc(user.uid)
          .collection('summaries')
          .get();

      final batch = _firestore.batch();
      for (var doc in summaries.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error clearing summaries: $e');
    }
  }
}

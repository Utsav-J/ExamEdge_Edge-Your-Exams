import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/document_summary.dart';
import '../models/mcq.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _summariesCollection =>
      _firestore.collection('document_summaries');

  CollectionReference get _mcqsCollection =>
      _firestore.collection('document_mcqs');

  CollectionReference get _resourcesCollection =>
      _firestore.collection('document_resources');

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

  // Get MCQs from Firestore
  Future<List<MCQ>?> getDocumentMCQs(String uniqueFilename) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final docRef =
          _mcqsCollection.doc(user.uid).collection('mcqs').doc(uniqueFilename);

      final doc = await docRef.get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      final mcqsList = data['mcqs'] as List<dynamic>;

      return mcqsList.map((mcq) => MCQ.fromJson(mcq)).toList();
    } catch (e) {
      print('Error getting MCQs: $e');
      return null;
    }
  }

  // Save MCQs to Firestore
  Future<void> saveMCQs(String uniqueFilename, List<MCQ> mcqs) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user logged in';

      await _mcqsCollection
          .doc(user.uid)
          .collection('mcqs')
          .doc(uniqueFilename)
          .set({
        'mcqs': mcqs
            .map((mcq) => {
                  'question': mcq.question,
                  'options': mcq.options,
                  'answer': mcq.answer,
                })
            .toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'userId': user.uid,
      });
    } catch (e) {
      print('Error saving MCQs: $e');
      throw e;
    }
  }

  // Delete MCQs from Firestore
  Future<void> deleteMCQs(String uniqueFilename) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _mcqsCollection
          .doc(user.uid)
          .collection('mcqs')
          .doc(uniqueFilename)
          .delete();
    } catch (e) {
      print('Error deleting MCQs: $e');
    }
  }

  // Get resources from Firestore
  Future<Map<String, dynamic>?> getDocumentResources(
      String uniqueFilename) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final docRef = _resourcesCollection
          .doc(user.uid)
          .collection('resources')
          .doc(uniqueFilename);

      final doc = await docRef.get();
      if (!doc.exists) return null;

      return doc.data() as Map<String, dynamic>;
    } catch (e) {
      print('Error getting resources: $e');
      return null;
    }
  }

  // Save resources to Firestore
  Future<void> saveDocumentResources(
    String uniqueFilename,
    Map<String, dynamic> videos,
    Map<String, dynamic> books,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user logged in';

      await _resourcesCollection
          .doc(user.uid)
          .collection('resources')
          .doc(uniqueFilename)
          .set({
        'videos': videos,
        'books': books,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': user.uid,
      });
    } catch (e) {
      print('Error saving resources: $e');
      throw e;
    }
  }

  // Delete resources from Firestore
  Future<void> deleteDocumentResources(String uniqueFilename) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _resourcesCollection
          .doc(user.uid)
          .collection('resources')
          .doc(uniqueFilename)
          .delete();
    } catch (e) {
      print('Error deleting resources: $e');
    }
  }
}

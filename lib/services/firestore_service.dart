import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/note.dart';

class FirestoreService {
  CollectionReference get _notesRef =>
      FirebaseFirestore.instance.collection('notes');

  // Real-time stream of all notes
  Stream<List<Note>> getNotesStream() {
    if (Firebase.apps.isEmpty) {
      return Stream.value([]);
    }
    return _notesRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
    });
  }

  // Add a new note to Firestore
  Future<void> addNote(Note note) async {
    if (Firebase.apps.isEmpty) return;
    await _notesRef.add(note.toMap());
  }

  // Update an existing note in Firestore
  Future<void> updateNote(Note note) async {
    if (Firebase.apps.isEmpty || note.id == null) return;
    await _notesRef.doc(note.id).update({
      'title': note.title,
      'body': note.body,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete a note from Firestore
  Future<void> deleteNote(String id) async {
    if (Firebase.apps.isEmpty) return;
    await _notesRef.doc(id).delete();
  }
}

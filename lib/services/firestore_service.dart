import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/note.dart';

class FirestoreService {
  CollectionReference get _notesRef =>
      FirebaseFirestore.instance.collection('notes');

  // 'deleted_notes' is the trash collection
  CollectionReference get _deletedRef =>
      FirebaseFirestore.instance.collection('deleted_notes');

  // ── Active notes ─────────────────────────────────────────────

  Stream<List<Note>> getNotesStream() {
    if (Firebase.apps.isEmpty) return Stream.value([]);
    return _notesRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Note.fromFirestore(d)).toList());
  }

  Future<void> addNote(Note note) async {
    if (Firebase.apps.isEmpty) return;
    await _notesRef.add(note.toMap());
  }

  Future<void> updateNote(Note note) async {
    if (Firebase.apps.isEmpty || note.id == null) return;
    await _notesRef.doc(note.id).update({
      'title': note.title,
      'body': note.body,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Move a note from 'notes' → 'deleted_notes' (soft delete / trash)
  Future<void> moveToTrash(Note note) async {
    if (Firebase.apps.isEmpty || note.id == null) return;
    final db = FirebaseFirestore.instance;
    final batch = db.batch();

    // Copy to deleted_notes with a deletedAt timestamp
    final trashDoc = _deletedRef.doc();
    batch.set(trashDoc, {
      'title': note.title,
      'body': note.body,
      'originalId': note.id,
      'deletedAt': FieldValue.serverTimestamp(),
    });

    // Remove from active notes
    batch.delete(_notesRef.doc(note.id));
    await batch.commit();
  }

  /// Permanently remove a document from 'deleted_notes'
  Future<void> permanentlyDelete(String deletedId) async {
    if (Firebase.apps.isEmpty) return;
    await _deletedRef.doc(deletedId).delete();
  }

  /// Restore a note from 'deleted_notes' back to 'notes'
  Future<void> restoreNote(Note note) async {
    if (Firebase.apps.isEmpty || note.id == null) return;
    final db = FirebaseFirestore.instance;
    final batch = db.batch();

    // Re-add to active notes
    batch.set(_notesRef.doc(), {
      'title': note.title,
      'body': note.body,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Remove from trash
    batch.delete(_deletedRef.doc(note.id));
    await batch.commit();
  }

  // ── Deleted (trash) notes ─────────────────────────────────────

  Stream<List<Note>> getDeletedNotesStream() {
    if (Firebase.apps.isEmpty) return Stream.value([]);
    return _deletedRef
        .orderBy('deletedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Note.fromFirestore(d)).toList());
  }
}

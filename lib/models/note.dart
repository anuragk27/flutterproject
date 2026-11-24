// ============================================================
// lib/models/note.dart
// A "model" is a simple class that describes our data.
// Every note in the app is an object of this class.
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  String? id;
  String title;
  String body;

  // Named parameters in { } with default values.
  Note({this.id, this.title = '', this.body = ''});

  // Convert Note object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Create a Note object from a Firestore DocumentSnapshot
  factory Note.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Note(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
    );
  }
}

// ============================================================
// lib/models/note.dart
// A "model" is a simple class that describes our data.
// Every note in the app is an object of this class.
// ============================================================

class Note {
  String title;
  String body;

  // Named parameters in { } with default values.
  // Note()                      -> empty note
  // Note(title: 'Hi', body: '') -> note with a title
  Note({this.title = '', this.body = ''});
}
// ============================================================
// lib/screens/note_editor_page.dart
// Second screen: create a new note or edit an existing one.
// ============================================================

import 'package:material_ui/material_ui.dart';
import '../models/note.dart';

class NoteEditorPage extends StatefulWidget {
  final Note note;
  final bool isNew; // true = creating, false = editing

  const NoteEditorPage({super.key, required this.note, required this.isNew});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late final TextEditingController titleController;
  late final TextEditingController bodyController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note.title);
    bodyController = TextEditingController(text: widget.note.body);
  }

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  void _save() {
    widget.note.title = titleController.text.trim();
    widget.note.body = bodyController.text.trim();

    // Don't save completely empty new notes
    if (widget.isNew && widget.note.title.isEmpty && widget.note.body.isEmpty) {
      Navigator.pop(context); // just go back
      return;
    }
    // Navigator.pop closes this screen and sends data back to HomePage
    Navigator.pop(context, widget.note);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _save, // saving on back, just like Keep
        ),
        actions: [
          if (!widget.isNew) ...[
            IconButton(
              icon: Icon(
                widget.note.isArchived
                    ? Icons.unarchive_outlined
                    : Icons.archive_outlined,
              ),
              tooltip: widget.note.isArchived ? 'Unarchive' : 'Archive',
              onPressed: () => Navigator.pop(
                context,
                widget.note.isArchived ? 'unarchive' : 'archive',
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => Navigator.pop(context, 'delete'),
            ),
          ],
          IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
            ),
            Expanded(
              child: TextField(
                controller: bodyController,
                maxLines: null, // null = grows with the text
                expands: true, // fills the remaining screen height
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  hintText: 'Note',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

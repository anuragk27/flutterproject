// ============================================================
// lib/widgets/note_card.dart
// A small reusable widget that draws ONE note.
// Splitting UI into small widgets keeps code clean and lets us
// reuse the same card in both grid view and list view.
// ============================================================

// import 'package:flutter/material.dart';
import 'package:material_ui/material_ui.dart';

// '../' means "go up one folder" (from widgets/ to lib/), then into models/
import '../models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap; // function to run when the card is tapped

  const NoteCard({super.key, required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // GestureDetector detects taps, long-press, swipes etc.
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, // take the full width of its column
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)), // thin grey outline
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // left-align text
          // mainAxisSize.min = column is only as tall as its content
          mainAxisSize: MainAxisSize.min,
          children: [
            // "if" inside a list: show the widget only when a title exists
            if (note.title.isNotEmpty) ...[
              Text(
                note.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
            ],
            if (note.body.isNotEmpty)
              Text(
                note.body,
                maxLines: 8, // cut long notes like Keep does
                overflow: TextOverflow.ellipsis, // shows "..." when cut
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
          ],
        ),
      ),
    );
  }
}
// ============================================================
// lib/screens/deleted_notes_page.dart
// Shows notes moved to trash. Supports restore & permanent delete.
// ============================================================

import 'package:material_ui/material_ui.dart';
import '../models/note.dart';
import '../services/firestore_service.dart';

class DeletedNotesPage extends StatefulWidget {
  const DeletedNotesPage({super.key});

  @override
  State<DeletedNotesPage> createState() => _DeletedNotesPageState();
}

class _DeletedNotesPageState extends State<DeletedNotesPage> {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _restore(Note note) async {
    await _firestoreService.restoreNote(note);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note restored to Notes')),
      );
    }
  }

  Future<void> _permanentDelete(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete permanently?'),
        content: const Text(
          'This note will be deleted forever and cannot be recovered.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && note.id != null) {
      await _firestoreService.permanentlyDelete(note.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note permanently deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Deleted Notes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<Note>>(
        stream: _firestoreService.getDeletedNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final deleted = snapshot.data ?? [];

          if (deleted.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No deleted notes',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Notes you delete will appear here.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: deleted.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final note = deleted[index];
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: note.title.isNotEmpty
                      ? Text(
                          note.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : null,
                  subtitle: note.body.isNotEmpty
                      ? Padding(
                          padding: EdgeInsets.only(top: note.title.isNotEmpty ? 4 : 0),
                          child: Text(
                            note.body,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, height: 1.4),
                          ),
                        )
                      : null,
                  // Restore icon
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Restore',
                        icon: const Icon(Icons.restore,
                            color: Color(0xFF1967D2)),
                        onPressed: () => _restore(note),
                      ),
                      IconButton(
                        tooltip: 'Delete permanently',
                        icon: const Icon(Icons.delete_forever,
                            color: Colors.redAccent),
                        onPressed: () => _permanentDelete(note),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';
import '../models/note.dart';
import '../services/firestore_service.dart';
import '../widgets/keep_drawer.dart';
import '../widgets/note_card.dart';
import 'note_editor_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Colors used on this screen
  static const Color bgColor = Colors.white;
  static const Color searchBarColor = Color(0xFFF1F3F4);

  final FirestoreService _firestoreService = FirestoreService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedMenu = 0; // which drawer item is highlighted (0 = Notes)
  bool isGrid = true; // true = 2 column grid, false = single list
  bool isReversed = false; // sort order
  String query = ''; // text typed in the search bar

  void _onMenuSelect(int index) {
    const selectable = [0, 1, 3, 4];
    if (selectable.contains(index)) {
      setState(() => selectedMenu = index);
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Menu item $index tapped')));
  }

  // Opens the editor screen to create or edit a note
  Future<void> _openEditor({Note? note}) async {
    final result = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            NoteEditorPage(note: note ?? Note(), isNew: note == null),
      ),
    );

    if (!mounted || result == null) return;

    if (result == 'delete' && note != null && note.id != null) {
      await _firestoreService.deleteNote(note.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note deleted')),
        );
      }
    } else if (result is Note) {
      if (note == null || note.id == null) {
        await _firestoreService.addNote(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note added to Firestore')),
          );
        }
      } else {
        await _firestoreService.updateNote(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note updated')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgColor,
      drawer: KeepDrawer(selectedIndex: selectedMenu, onSelect: _onMenuSelect),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: StreamBuilder<List<Note>>(
                stream: _firestoreService.getNotesStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'Error connecting to Firestore: ${snapshot.error}\n\n'
                          'Make sure Firestore Database rules in Firebase Console allow read/write.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allNotes = snapshot.data ?? [];
                  var filtered = allNotes.where((n) {
                    final text = '${n.title} ${n.body}'.toLowerCase();
                    return text.contains(query.toLowerCase());
                  }).toList();

                  if (isReversed) {
                    filtered = filtered.reversed.toList();
                  }

                  if (filtered.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          query.isEmpty
                              ? 'No notes yet. Tap + below to add your first note to Firebase!'
                              : 'No matching notes found.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return isGrid ? _buildGrid(filtered) : _buildList(filtered);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        backgroundColor: const Color(0xFF2B50AA),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.add, size: 36),
      ),
    );
  }

  // Search bar at the top
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: searchBarColor,
        borderRadius: BorderRadius.circular(30),
      ),
      height: 56,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => query = value),
              decoration: const InputDecoration(
                hintText: 'Search your notes',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 18),
            ),
          ),
          IconButton(
            icon: Icon(isGrid ? Icons.view_agenda_outlined : Icons.grid_view),
            onPressed: () => setState(() => isGrid = !isGrid),
          ),
          IconButton(
            icon: const Icon(Icons.swap_vert),
            onPressed: () => setState(() => isReversed = !isReversed),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // Two-column grid view
  Widget _buildGrid(List<Note> list) {
    final left = <Widget>[];
    final right = <Widget>[];

    for (int i = 0; i < list.length; i++) {
      final card = Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: NoteCard(
          note: list[i],
          onTap: () => _openEditor(note: list[i]),
        ),
      );
      if (i % 2 == 0) {
        left.add(card);
      } else {
        right.add(card);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Column(children: left)),
          const SizedBox(width: 10),
          Expanded(child: Column(children: right)),
        ],
      ),
    );
  }

  // Single-column list view
  Widget _buildList(List<Note> list) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: NoteCard(
            note: list[index],
            onTap: () => _openEditor(note: list[index]),
          ),
        );
      },
    );
  }
}

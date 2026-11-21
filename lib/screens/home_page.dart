import 'package:material_ui/material_ui.dart';
import '../models/note.dart';
import '../widgets/keep_drawer.dart';
import '../widgets/note_card.dart';
import 'note_editor_page.dart'; // same folder, so no '../' needed

// StatefulWidget = a widget whose data can change (notes list,
// search text, grid/list toggle). When data changes we call
// setState() and Flutter redraws the screen.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// The class starting with "_" is private to this file.
// It holds the changing data (the "state") and the build() method.
class _HomePageState extends State<HomePage> {
  // Colors used on this screen (0xFF + hex code)
  static const Color bgColor = Color(0xFF202124);
  static const Color searchBarColor = Color(0xFF3C4043);

  // Our list of notes (sample data to make the screen look filled)
  final List<Note> notes = [
    Note(
      title: '19/11/26 - Marine Form digital task',
      body:
          'SEC 2,3,5 - Harsh ✅\nSEC 6,7,8 - Subham\nSEC 9,10,11 - Anurag ✅\nSEC 12,14 - Surinder',
    ),
    Note(body: '1. Self Awareness'),
    Note(
      title: '17/11/2026',
      body: '1. Added a new vessel\n2. Updated Contract form\n3.',
    ),
    Note(
      body:
          "I'm working on a Flutter project. I want to add the "
          "`device_preview` package so I can preview the app on "
          "different device sizes, but only when I explicitly turn it on.\n\n"
          "Task: Integrate Device Preview",
    ),
    Note(
      title: 'OLD CONTRACT FORM',
      body: 'Ship Name: ____\nAt: ____\nDate: ____\n...',
    ),
    Note(
      title: 'Contract of Employment Form',
      body:
          "1. Input field size adjustment\n2. Table Positioning\n3. Formula's implementation\n\n# CONTRACT OF EMPLOYMENT\n...",
    ),
    Note(
      title: 'HEADER',
      body:
          '<table border="1">\n  <tbody>\n    <tr>\n      <td style="width:80px;">',
    ),
    Note(body: 'If you are lost,\nthen find what attracts you.'),
  ];

  // A GlobalKey gives us a "remote control" for the Scaffold, so we can
  // open the drawer from our own menu button (which sits inside the body).
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedMenu = 0; // which drawer item is highlighted (0 = Notes)

  // Called when a drawer item is tapped.
  void _onMenuSelect(int index) {
    // Items 0 (Notes), 1 (Reminders), 3 (Archive), 4 (Deleted) are screens.
    // Items 2, 5, 6 are actions, so we don't highlight them.
    const selectable = [0, 1, 3, 4];
    if (selectable.contains(index)) {
      setState(() => selectedMenu = index);
    }
    // For now show a small message; later you can open real screens.
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Menu item $index tapped')));
  }

  bool isGrid = true; // true = 2 column grid, false = single list
  String query = ''; // text typed in the search bar

  // ----------------------------------------------------------
  // Opens the editor screen. If [note] is given we edit it,
  // otherwise we create a new one.
  // "async/await" lets us wait for the editor screen to close
  // and give us back a result.
  // ----------------------------------------------------------
  Future<void> _openEditor({Note? note}) async {
    // Navigator.push opens a new screen on top of the current one.
    final result = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            NoteEditorPage(note: note ?? Note(), isNew: note == null),
      ),
    );

    // Safety check: the screen may have been closed while we waited.
    if (!mounted) return;

    // setState tells Flutter: "data changed, redraw the UI".
    setState(() {
      if (result == 'delete' && note != null) {
        notes.remove(note);
      } else if (result is Note && note == null) {
        notes.insert(0, result); // new notes appear at the top
      }
      // When editing, the Note object is changed directly,
      // so setState alone refreshes the screen.
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter notes using the search text (case-insensitive).
    final filtered = notes.where((n) {
      final text = '${n.title} ${n.body}'.toLowerCase();
      return text.contains(query.toLowerCase());
    }).toList();

    // Scaffold = basic page layout (body, app bar, floating button...)
    return Scaffold(
      key: _scaffoldKey, // attach the remote control
      backgroundColor: bgColor,

      // The slide-in menu. Swiping from the left edge also opens it.
      drawer: KeepDrawer(selectedIndex: selectedMenu, onSelect: _onMenuSelect),

      // SafeArea keeps content away from the phone's notch/status bar.
      body: SafeArea(
        // Column places children vertically, one below another.
        child: Column(
          children: [
            _buildSearchBar(),
            // Expanded makes its child fill all remaining space.
            Expanded(
              child: isGrid ? _buildGrid(filtered) : _buildList(filtered),
            ),
          ],
        ),
      ),

      // The blue "+" button at the bottom right.
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(), // runs when tapped
        backgroundColor: const Color(0xFF2B50AA),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.add, size: 36),
      ),
    );
  }

  // ----------------------------------------------------------
  // SEARCH BAR  (menu icon | text field | view toggle | sort | avatar)
  // ----------------------------------------------------------
  Widget _buildSearchBar() {
    // Container = a box where you can set color, margin, padding, shape.
    return Container(
      margin: const EdgeInsets.fromLTRB(
        12,
        10,
        12,
        10,
      ), // space outside the box
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: searchBarColor,
        borderRadius: BorderRadius.circular(30), // fully rounded ends
      ),
      height: 56,
      // Row places children horizontally.
      child: Row(
        children: [
          // IconButton = a tappable icon
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () =>
                _scaffoldKey.currentState?.openDrawer(), // later: open a Drawer
          ),
          // TextField needs a bounded width inside a Row, so we
          // wrap it in Expanded to take all free horizontal space.
          Expanded(
            child: TextField(
              // onChanged runs on every key press
              onChanged: (value) => setState(() => query = value),
              decoration: const InputDecoration(
                hintText: 'Search Keep',
                border: InputBorder.none, // remove default underline
              ),
              style: const TextStyle(fontSize: 18),
            ),
          ),
          IconButton(
            // Show a different icon depending on the current mode
            icon: Icon(isGrid ? Icons.view_agenda_outlined : Icons.grid_view),
            onPressed: () => setState(() => isGrid = !isGrid),
          ),
          IconButton(
            icon: const Icon(Icons.swap_vert),
            onPressed: () {
              // Simple "sort" - reverse the list order
              setState(() {
                final reversed = notes.reversed.toList();
                notes
                  ..clear()
                  ..addAll(reversed);
              });
            },
          ),
          // CircleAvatar = round profile picture / letter
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFF5B6BD5),
            child: Text(
              'a',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8), // SizedBox = empty spacer
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // GRID VIEW  (Keep's two-column "masonry" layout)
  // We split notes into a left and right column. Each column can
  // have a different height, which gives the staggered look.
  // ----------------------------------------------------------
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
      // even index -> left column, odd index -> right column
      if (i % 2 == 0) {
        left.add(card);
      } else {
        right.add(card);
      }
    }

    // SingleChildScrollView lets the content scroll vertically.
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        12,
        4,
        12,
        100,
      ), // bottom space for the + button
      child: Row(
        // start = align both columns to the top
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Column(children: left)),
          const SizedBox(width: 10), // gap between columns
          Expanded(child: Column(children: right)),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // LIST VIEW  (one note per row)
  // ListView.builder only builds items that are on screen,
  // so it stays fast even with thousands of notes.
  // ----------------------------------------------------------
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

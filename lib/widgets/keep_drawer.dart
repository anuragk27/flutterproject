// ============================================================
// lib/widgets/keep_drawer.dart
// The side menu that slides in from the left (like Google Keep).
// ============================================================

// import 'package:flutter/material.dart';
import 'package:material_ui/material_ui.dart';

// StatelessWidget: the drawer itself stores nothing. The HomePage
// tells it WHICH item is selected and is told back when one is tapped.
class KeepDrawer extends StatelessWidget {
  final int selectedIndex; // which menu item is highlighted
  final ValueChanged<int> onSelect; // called with the tapped item's index

  const KeepDrawer({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    // Drawer = the panel that slides in from the left edge.
    return Drawer(
      backgroundColor: Colors.white,
      // Keep's drawer has a flat right edge, so remove default rounding.
      shape: const RoundedRectangleBorder(),
      // SafeArea keeps content away from the status bar.
      child: SafeArea(
        // ListView so the menu can scroll on small screens.
        child: ListView(
          padding: const EdgeInsets.only(right: 12), // gap on the right side
          children: [
            // ---- Header: "Google Keep" title ----
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Text(
                'To Do',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
            ),

            // ---- Menu items ----
            // Each call builds one row. Index 0..3 can be "selected".
            _item(context, index: 0, icon: Icons.lightbulb_outline, label: 'Notes'),
            // _item(context, index: 1, icon: Icons.notifications_none, label: 'Reminders'),
            // _item(context, index: 2, icon: Icons.add, label: 'Create new label'),
            _item(context, index: 3, icon: Icons.archive_outlined, label: 'Archive'),
            _item(context, index: 4, icon: Icons.delete_outline, label: 'Deleted'),
            // _item(context, index: 5, icon: Icons.settings_outlined, label: 'Settings'),
            // _item(context, index: 6, icon: Icons.help_outline, label: 'Help & feedback'),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // Builds ONE menu row. Writing it once and reusing it avoids
  // repeating the same code 7 times.
  // ----------------------------------------------------------
  Widget _item(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool selected = index == selectedIndex;

    return ListTile(
      // Icon on the left, text next to it
      leading: Icon(
        icon,
        color: selected ? const Color(0xFF1967D2) : const Color(0xFF5F6368),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          color: selected ? const Color(0xFF1967D2) : const Color(0xFF202124),
          fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      // selected + selectedTileColor = the soft blue highlight (Keep light theme)
      selected: selected,
      selectedTileColor: const Color(0xFFE8F0FE),
      // Round only the RIGHT side, so the pill touches the left edge
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      contentPadding: const EdgeInsets.only(left: 20),
      onTap: () {
        Navigator.pop(context); // close the drawer first
        onSelect(index); // then tell HomePage what was tapped
      },
    );
  }
}
import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import 'detail_screen.dart';

class TrashScreen extends StatefulWidget {
  final List<JournalEntry> entries;
  final Function(List<JournalEntry>) onUpdate;

  const TrashScreen({super.key, required this.entries, required this.onUpdate});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  late List<JournalEntry> _trashedEntries;

  @override
  void initState() {
    super.initState();
    _trashedEntries = widget.entries.where((entry) => entry.isDeleted).toList();
  }

  void _restoreEntry(JournalEntry entry) {
    setState(() {
      entry.isDeleted = false;
      _trashedEntries.remove(entry);
    });
    widget.onUpdate(widget.entries);
  }

  void _deletePermanently(JournalEntry entry) {
    setState(() {
      widget.entries.remove(entry);
      _trashedEntries.remove(entry);
    });
    widget.onUpdate(widget.entries);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
      ),
      body: _trashedEntries.isEmpty
          ? const Center(
        child: Text('The trash is empty.', style: TextStyle(color: Colors.grey)),
      )
          : ListView.builder(
        itemCount: _trashedEntries.length,
        itemBuilder: (context, index) {
          final entry = _trashedEntries[index];
          return ListTile(
            title: Text(entry.title),
            subtitle: Text(entry.content, maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(entry: entry))),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.restore_from_trash),
                  tooltip: 'Restore',
                  onPressed: () => _restoreEntry(entry),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever),
                  tooltip: 'Delete Permanently',
                  onPressed: () => _deletePermanently(entry),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
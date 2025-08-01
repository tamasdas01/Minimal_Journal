import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/journal_entry.dart';
import 'add_entry_screen.dart';
import 'settings_screen.dart';
import 'trash_screen.dart';

// Enum to define the available view types
enum ViewType { list, grid }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<JournalEntry> _journalEntries = [];
  List<JournalEntry> _filteredEntries = [];
  final _searchController = TextEditingController();

  bool _isSelectionMode = false;
  final Set<JournalEntry> _selectedEntries = {};
  bool _isLoading = true;

  // State variable to hold the current view type, defaulting to list
  ViewType _viewType = ViewType.list;

  @override
  void initState() {
    super.initState();
    _loadEntries();
    _searchController.addListener(_applyFiltersAndSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/journal_entries.json');
  }

  Future<void> _loadEntries() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        setState(() => _isLoading = false);
        return;
      }
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);

      setState(() {
        _journalEntries =
            jsonList.map((json) => JournalEntry.fromJson(json)).toList();
        _sortEntries();
        _applyFiltersAndSearch();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error loading entries: $e");
    }
  }

  Future<void> _saveEntries() async {
    try {
      final file = await _localFile;
      final jsonList =
      _journalEntries.map((entry) => entry.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      debugPrint("Error saving entries: $e");
    }
  }

  void _sortEntries() {
    _journalEntries.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.date.compareTo(a.date);
    });
  }

  void _applyFiltersAndSearch() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredEntries = _journalEntries.where((entry) {
        final isNotDeleted = !entry.isDeleted;
        if (query.isEmpty) return isNotDeleted;
        final titleMatch = entry.title.toLowerCase().contains(query);
        final contentMatch = entry.content.toLowerCase().contains(query);
        return isNotDeleted && (titleMatch || contentMatch);
      }).toList();
    });
  }

  AppBar _buildAppBar() {
    if (_isSelectionMode) {
      return AppBar(
        leading: IconButton(
            icon: const Icon(Icons.close), onPressed: _exitSelectionMode),
        title: Text('${_selectedEntries.length} selected'),
        actions: [
          IconButton(
              icon: const Icon(Icons.push_pin_outlined),
              tooltip: "Pin",
              onPressed: _togglePinSelectedEntries),
          IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: "Trash",
              onPressed: _trashSelectedEntries),
        ],
      );
    } else {
      return AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Card(
          elevation: 3.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search,
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color
                      ?.withOpacity(0.6)),
              hintText: 'Search...',
              //suffixIcon: IconButton(
                //icon: Icon(Icons.mic,
                   // color: Theme.of(context)
                       // .textTheme
                       // .bodyLarge
                       // ?.color
                     //   ?.withOpacity(0.6)),
                //onPressed: () {},
             // ),
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Switch View',
            icon: Icon(_viewType == ViewType.list
                ? Icons.grid_view_outlined
                : Icons.view_list_outlined),
            onPressed: _toggleViewType,
          ),
        ],
      );
    }
  }

  Widget _buildAppDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.8)),
            child: const Text('Minimal Journal',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.book_outlined),
            title: const Text('Journal'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Trash'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TrashScreen(
                          entries: _journalEntries,
                          onUpdate: (updatedEntries) {
                            setState(() => _journalEntries = updatedEntries);
                            _sortEntries();
                            _applyFiltersAndSearch();
                            _saveEntries();
                          })));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()));
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildAppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildJournalBody(),
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton(
        onPressed: () => _navigateAndAddEntry(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildJournalBody() {
    if (_filteredEntries.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isEmpty
              ? "Your journal is empty."
              : "No entries found.",
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return _viewType == ViewType.list
        ? _buildJournalListView()
        : _buildJournalGridView();
  }

  Widget _buildJournalListView() {
    return ListView.builder(
      itemCount: _filteredEntries.length,
      itemBuilder: (context, index) {
        final entry = _filteredEntries[index];
        final isSelected = _selectedEntries.contains(entry);

        return ListTile(
          leading: _isSelectionMode
              ? Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank)
              : null,
          title: _buildHighlightedText(entry.title, _searchController.text),
          subtitle: _buildHighlightedText(entry.content, _searchController.text,
              maxLines: 2),
          trailing: entry.isPinned
              ? Icon(Icons.push_pin,
              size: 20, color: Theme.of(context).primaryColor)
              : null,
          tileColor:
          isSelected ? Theme.of(context).primaryColor.withOpacity(0.3) : null,
          onTap: () =>
          _isSelectionMode ? _toggleSelection(entry) : _navigateToEditEntry(entry),
          onLongPress: () => _isSelectionMode ? null : _toggleSelection(entry),
        );
      },
    );
  }

  Widget _buildJournalGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.8,
      ),
      itemCount: _filteredEntries.length,
      itemBuilder: (context, index) {
        final entry = _filteredEntries[index];
        final isSelected = _selectedEntries.contains(entry);
        return InkWell(
          onTap: () => _isSelectionMode ? _toggleSelection(entry) : _navigateToEditEntry(entry),
          onLongPress: () => _isSelectionMode ? null : _toggleSelection(entry),
          borderRadius: BorderRadius.circular(12.0),
          child: Card(
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.4)
                : null,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          entry.content,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 4,
                        ),
                      ),
                    ],
                  ),
                  if (entry.isPinned)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Icon(Icons.push_pin,
                          size: 18, color: Theme.of(context).primaryColor),
                    ),
                  if (_isSelectionMode)
                    Positioned(
                      top: -4,
                      left: -4,
                      child: Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHighlightedText(String text, String query, {int? maxLines}) {
    if (query.isEmpty) {
      return Text(text,
          maxLines: maxLines,
          overflow: maxLines != null ? TextOverflow.ellipsis : null);
    }
    final style = Theme.of(context).textTheme.bodyLarge ?? const TextStyle();
    final highlightStyle =
    style.copyWith(backgroundColor: Colors.yellow.withOpacity(0.5));
    final spans = <TextSpan>[];
    int start = 0;
    while (start < text.length) {
      final int matchIndex =
      text.toLowerCase().indexOf(query.toLowerCase(), start);
      if (matchIndex == -1) {
        spans.add(TextSpan(text: text.substring(start), style: style));
        break;
      }
      if (matchIndex > start) {
        spans.add(
            TextSpan(text: text.substring(start, matchIndex), style: style));
      }
      spans.add(TextSpan(
          text: text.substring(matchIndex, matchIndex + query.length),
          style: highlightStyle));
      start = matchIndex + query.length;
    }
    return RichText(
        text: TextSpan(children: spans),
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip);
  }

  void _navigateAndAddEntry(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEntryScreen()),
    );
    if (result != null && result is JournalEntry) {
      setState(() {
        _journalEntries.add(result);
        _sortEntries();
        _applyFiltersAndSearch();
      });
      await _saveEntries();
    }
  }

  void _navigateToEditEntry(JournalEntry entry) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEntryScreen(journalEntry: entry)),
    );

    if (result != null && result is JournalEntry) {
      final index = _journalEntries.indexOf(entry);
      if (index != -1) {
        setState(() {
          _journalEntries[index] = result;
          _sortEntries();
          _applyFiltersAndSearch();
        });
        await _saveEntries();
      }
    }
  }

  void _toggleSelection(JournalEntry entry) {
    setState(() {
      if (!_isSelectionMode) _isSelectionMode = true;
      if (_selectedEntries.contains(entry)) {
        _selectedEntries.remove(entry);
      } else {
        _selectedEntries.add(entry);
      }
      if (_selectedEntries.isEmpty) _isSelectionMode = false;
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectedEntries.clear();
      _isSelectionMode = false;
    });
  }

  void _trashSelectedEntries() {
    setState(() {
      for (var entry in _selectedEntries) {
        entry.isDeleted = true;
        entry.isPinned = false;
      }
      _applyFiltersAndSearch();
      _exitSelectionMode();
    });
    _saveEntries();
  }

  void _togglePinSelectedEntries() {
    setState(() {
      if (_selectedEntries.isNotEmpty) {
        bool shouldPin = !_selectedEntries.first.isPinned;
        for (var entry in _selectedEntries) {
          entry.isPinned = shouldPin;
        }
      }
      _sortEntries();
      _applyFiltersAndSearch();
      _exitSelectionMode();
    });
    _saveEntries();
  }

  void _toggleViewType() {
    setState(() {
      _viewType = _viewType == ViewType.list ? ViewType.grid : ViewType.list;
    });
  }
}
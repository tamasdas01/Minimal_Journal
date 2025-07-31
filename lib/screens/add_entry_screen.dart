import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/journal_entry.dart';

class AddEntryScreen extends StatefulWidget {
  final JournalEntry? journalEntry;

  const AddEntryScreen({super.key, this.journalEntry});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.journalEntry != null) {
      _titleController.text = widget.journalEntry!.title;
      _contentController.text = widget.journalEntry!.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String _formatAsPlainText(String title, String content) {
    return '$title\n\n$content';
  }

  String _formatAsMarkdown(String title, String content) {
    return '# $title\n\n$content';
  }

  String _formatAsHtml(String title, String content) {
    final htmlContent = content.replaceAll('\n', '<br>');
    return '<html><head><title>$title</title></head><body><h1>$title</h1><p>$htmlContent</p></body></html>';
  }

  /// Creates a temporary file with the given content and shares it.
  Future<void> _shareAsFile({
    required String title,
    required String content,
    required String fileExtension,
    required String mimeType,
  }) async {
    try {
      final directory = await getTemporaryDirectory();
      // Sanitize the title to create a valid filename
      final sanitizedTitle = title.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
      final filePath = '${directory.path}/$sanitizedTitle.$fileExtension';

      final file = File(filePath);
      await file.writeAsString(content);

      await Share.shareXFiles(
        [XFile(filePath, mimeType: mimeType)],
        subject: title,
      );
    } catch (e) {
      debugPrint('Error sharing file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Could not share file.')),
        );
      }
    }
  }

  void _shareJournal() {
    final String title = _titleController.text;
    final String content = _contentController.text;

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot share an empty journal.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Share as Plain Text (.txt)'),
              onTap: () {
                Navigator.pop(context);
                _shareAsFile(
                  title: title,
                  content: _formatAsPlainText(title, content),
                  fileExtension: 'txt',
                  mimeType: 'text/plain',
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text('Share as Markdown (.md)'),
              onTap: () {
                Navigator.pop(context);
                _shareAsFile(
                  title: title,
                  content: _formatAsMarkdown(title, content),
                  fileExtension: 'md',
                  mimeType: 'text/markdown',
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.html),
              title: const Text('Share as Rich Text (.html)'),
              onTap: () {
                Navigator.pop(context);
                _shareAsFile(
                  title: title,
                  content: _formatAsHtml(title, content),
                  fileExtension: 'html',
                  mimeType: 'text/html',
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _saveEntry() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      return;
    }
    final JournalEntry resultEntry = JournalEntry(
      title: _titleController.text,
      content: _contentController.text,
      date: widget.journalEntry?.date ?? DateTime.now(),
      isPinned: widget.journalEntry?.isPinned ?? false,
      isDeleted: widget.journalEntry?.isDeleted ?? false,
    );
    Navigator.pop(context, resultEntry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.journalEntry == null ? 'New Entry' : 'Edit Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
            onPressed: _shareJournal,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: _saveEntry,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
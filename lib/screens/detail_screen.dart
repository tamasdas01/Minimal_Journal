import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the new package
import '../models/journal_entry.dart';

class DetailScreen extends StatelessWidget {
  final JournalEntry entry;

  const DetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The title in the app bar will be the entry's title
        title: Text(entry.title),
      ),
      body: SingleChildScrollView(
        // Allows the content to be scrollable if it's long
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the formatted date
              Text(
                DateFormat.yMMMMd().add_jm().format(entry.date), // e.g., July 31, 2025, 10:09 PM
                style: const TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              // Display the full content of the journal
              Text(
                entry.content,
                style: const TextStyle(fontSize: 16, height: 1.5), // Increased line height for readability
              ),
            ],
          ),
        ),
      ),
    );
  }
}
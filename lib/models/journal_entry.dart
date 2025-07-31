import 'package:json_annotation/json_annotation.dart';

part 'journal_entry.g.dart';

@JsonSerializable()
class JournalEntry {
  final String title;
  final String content;
  final DateTime date;
  bool isPinned;
  bool isDeleted;

  JournalEntry({
    required this.title,
    required this.content,
    required this.date,
    this.isPinned = false,
    this.isDeleted = false,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) => _$JournalEntryFromJson(json);

  Map<String, dynamic> toJson() => _$JournalEntryToJson(this);
}
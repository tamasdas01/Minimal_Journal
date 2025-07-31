// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JournalEntry _$JournalEntryFromJson(Map<String, dynamic> json) => JournalEntry(
  title: json['title'] as String,
  content: json['content'] as String,
  date: DateTime.parse(json['date'] as String),
  isPinned: json['isPinned'] as bool? ?? false,
  isDeleted: json['isDeleted'] as bool? ?? false,
);

Map<String, dynamic> _$JournalEntryToJson(JournalEntry instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'date': instance.date.toIso8601String(),
      'isPinned': instance.isPinned,
      'isDeleted': instance.isDeleted,
    };

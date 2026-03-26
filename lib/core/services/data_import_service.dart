import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';

/// Import data from a JSON export file.
class DataImportService {
  DataImportService._();

  static Future<void> import(WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.isEmpty) return;

    final path = result.files.single.path;
    if (path == null) return;

    final content = await File(path).readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;
    final db = ref.read(databaseProvider);

    // Import todos
    final todos = data['todos'] as List? ?? [];
    for (final t in todos) {
      await db.insertTodo(TodoItemsCompanion(
        title: Value(t['title'] as String),
        note: Value(t['note'] as String?),
        isDone: Value(t['isDone'] as bool? ?? false),
        isPinned: Value(t['isPinned'] as bool? ?? false),
        tag: Value(t['tag'] as String?),
        createdAt: Value(DateTime.parse(t['createdAt'] as String)),
        completedAt: Value(t['completedAt'] != null
            ? DateTime.parse(t['completedAt'] as String)
            : null),
        dueDate: Value(t['dueDate'] != null
            ? DateTime.parse(t['dueDate'] as String)
            : null),
      ));
    }

    // Import memos
    final memos = data['memos'] as List? ?? [];
    for (final m in memos) {
      await db.insertMemo(MemoItemsCompanion(
        content: Value(m['content'] as String),
        tag: Value(m['tag'] as String?),
        isPinned: Value(m['isPinned'] as bool? ?? false),
        createdAt: Value(DateTime.parse(m['createdAt'] as String)),
        updatedAt: Value(DateTime.parse(m['updatedAt'] as String)),
      ));
    }

    // Import journals
    final journals = data['journals'] as List? ?? [];
    for (final j in journals) {
      await db.insertJournal(JournalEntriesCompanion(
        title: Value(j['title'] as String? ?? ''),
        contentJson: Value(j['contentJson'] as String? ?? '[]'),
        imagePaths: Value(j['imagePaths'] as String? ?? ''),
        mood: Value(j['mood'] as String?),
        weather: Value(j['weather'] as String?),
        wordCount: Value(j['wordCount'] as int? ?? 0),
        createdAt: Value(DateTime.parse(j['createdAt'] as String)),
        updatedAt: Value(DateTime.parse(j['updatedAt'] as String)),
      ));
    }
  }
}

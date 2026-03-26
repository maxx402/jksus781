import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../database/database_provider.dart';

/// Export all data as JSON, or clear all data.
class DataExportService {
  DataExportService._();

  static Future<String> export(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final todos = await db.getAllTodos();
    final memos = await db.getAllMemos();
    final journals = await db.getAllJournals();

    final data = {
      'exportVersion': '1.0',
      'exportAt': DateTime.now().toIso8601String(),
      'todos': todos.map((t) => {
            'id': t.id,
            'title': t.title,
            'note': t.note,
            'isDone': t.isDone,
            'isPinned': t.isPinned,
            'tag': t.tag,
            'createdAt': t.createdAt.toIso8601String(),
            'completedAt': t.completedAt?.toIso8601String(),
            'dueDate': t.dueDate?.toIso8601String(),
          }).toList(),
      'memos': memos.map((m) => {
            'id': m.id,
            'content': m.content,
            'tag': m.tag,
            'isPinned': m.isPinned,
            'createdAt': m.createdAt.toIso8601String(),
            'updatedAt': m.updatedAt.toIso8601String(),
          }).toList(),
      'journals': journals.map((j) => {
            'id': j.id,
            'title': j.title,
            'contentJson': j.contentJson,
            'imagePaths': j.imagePaths,
            'mood': j.mood,
            'weather': j.weather,
            'wordCount': j.wordCount,
            'createdAt': j.createdAt.toIso8601String(),
            'updatedAt': j.updatedAt.toIso8601String(),
          }).toList(),
    };

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/shuihe_export_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonEncode(data));
    return file.path;
  }

  static Future<void> clearAll(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    await db.delete(db.todoItems).go();
    await db.delete(db.memoItems).go();
    await db.delete(db.journalEntries).go();
  }
}

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Todo items table.
class TodoItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get note => text().nullable()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  TextColumn get tag => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
}

/// Memo items table.
class MemoItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get content => text().withLength(min: 1, max: 2000)();
  TextColumn get tag => text().nullable()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// Journal entries table.
class JournalEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get contentJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get imagePaths =>
      text().withDefault(const Constant(''))(); // comma-separated
  TextColumn get mood => text().nullable()();
  TextColumn get weather => text().nullable()();
  IntColumn get wordCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DriftDatabase(tables: [TodoItems, MemoItems, JournalEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  // ── Todo Queries ──

  Stream<List<TodoItem>> watchAllTodos() {
    return (select(todoItems)
          ..orderBy([
            (t) => OrderingTerm.desc(t.isPinned),
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .watch();
  }

  Future<List<TodoItem>> getAllTodos() {
    return (select(todoItems)
          ..orderBy([
            (t) => OrderingTerm.desc(t.isPinned),
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .get();
  }

  Future<TodoItem?> getTodoById(int id) {
    return (select(todoItems)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertTodo(TodoItemsCompanion entry) {
    return into(todoItems).insert(entry);
  }

  Future<bool> updateTodo(TodoItemsCompanion entry) {
    return update(todoItems).replace(entry);
  }

  Future<int> deleteTodo(int id) {
    return (delete(todoItems)..where((t) => t.id.equals(id))).go();
  }

  // ── Memo Queries ──

  Stream<List<MemoItem>> watchAllMemos() {
    return (select(memoItems)
          ..orderBy([
            (t) => OrderingTerm.desc(t.isPinned),
            (t) => OrderingTerm.desc(t.updatedAt),
          ]))
        .watch();
  }

  Future<List<MemoItem>> getAllMemos() {
    return (select(memoItems)
          ..orderBy([
            (t) => OrderingTerm.desc(t.isPinned),
            (t) => OrderingTerm.desc(t.updatedAt),
          ]))
        .get();
  }

  Stream<List<MemoItem>> watchSearchMemos(String query) {
    return (select(memoItems)
          ..where((t) => t.content.like('%$query%'))
          ..orderBy([
            (t) => OrderingTerm.desc(t.isPinned),
            (t) => OrderingTerm.desc(t.updatedAt),
          ]))
        .watch();
  }

  Future<MemoItem?> getMemoById(int id) {
    return (select(memoItems)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertMemo(MemoItemsCompanion entry) {
    return into(memoItems).insert(entry);
  }

  Future<bool> updateMemo(MemoItemsCompanion entry) {
    return update(memoItems).replace(entry);
  }

  Future<int> deleteMemo(int id) {
    return (delete(memoItems)..where((t) => t.id.equals(id))).go();
  }

  // ── Journal Queries ──

  Stream<List<JournalEntry>> watchAllJournals() {
    return (select(journalEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<List<JournalEntry>> getAllJournals() {
    return (select(journalEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Stream<List<JournalEntry>> watchJournalsByMonth(int year, int month) {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1);
    return (select(journalEntries)
          ..where(
              (t) => t.createdAt.isBiggerOrEqualValue(start) & t.createdAt.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<JournalEntry?> getJournalById(int id) {
    return (select(journalEntries)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertJournal(JournalEntriesCompanion entry) {
    return into(journalEntries).insert(entry);
  }

  Future<bool> updateJournal(JournalEntriesCompanion entry) {
    return update(journalEntries).replace(entry);
  }

  Future<int> deleteJournal(int id) {
    return (delete(journalEntries)..where((t) => t.id.equals(id))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'shuihe.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

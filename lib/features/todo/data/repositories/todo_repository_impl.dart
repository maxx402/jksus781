import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/todo_item.dart';
import '../../domain/repositories/todo_repository.dart';
import '../mappers/todo_mapper.dart';

/// Drift implementation of [TodoRepository].
class TodoRepositoryImpl implements TodoRepository {
  TodoRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<TodoEntity>> watchAll() {
    return _db.watchAllTodos().map(
          (rows) => rows.map(TodoMapper.fromRow).toList(),
        );
  }

  @override
  Future<List<TodoEntity>> getAll() async {
    final rows = await _db.getAllTodos();
    return rows.map(TodoMapper.fromRow).toList();
  }

  @override
  Future<TodoEntity?> getById(int id) async {
    final row = await _db.getTodoById(id);
    return row != null ? TodoMapper.fromRow(row) : null;
  }

  @override
  Future<int> save(TodoEntity item) {
    return _db.insertTodo(TodoMapper.toCompanion(item));
  }

  @override
  Future<void> update(TodoEntity item) async {
    await _db.updateTodo(TodoMapper.toCompanion(item));
  }

  @override
  Future<void> delete(int id) async {
    await _db.deleteTodo(id);
  }

  @override
  Future<void> markDone(int id) async {
    final row = await _db.getTodoById(id);
    if (row == null) return;
    await _db.updateTodo(
      TodoItemsCompanion(
        id: Value(row.id),
        title: Value(row.title),
        note: Value(row.note),
        isDone: const Value(true),
        isPinned: Value(row.isPinned),
        tag: Value(row.tag),
        createdAt: Value(row.createdAt),
        completedAt: Value(DateTime.now()),
        dueDate: Value(row.dueDate),
      ),
    );
  }

  @override
  Future<void> togglePin(int id) async {
    final row = await _db.getTodoById(id);
    if (row == null) return;
    await _db.updateTodo(
      TodoItemsCompanion(
        id: Value(row.id),
        title: Value(row.title),
        note: Value(row.note),
        isDone: Value(row.isDone),
        isPinned: Value(!row.isPinned),
        tag: Value(row.tag),
        createdAt: Value(row.createdAt),
        completedAt: Value(row.completedAt),
        dueDate: Value(row.dueDate),
      ),
    );
  }
}

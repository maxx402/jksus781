import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/todo_item.dart';

/// Maps between Drift row objects and domain entities.
class TodoMapper {
  TodoMapper._();

  static TodoEntity fromRow(TodoItem row) {
    return TodoEntity(
      id: row.id,
      title: row.title,
      note: row.note,
      isDone: row.isDone,
      isPinned: row.isPinned,
      tag: row.tag,
      createdAt: row.createdAt,
      completedAt: row.completedAt,
      dueDate: row.dueDate,
    );
  }

  static TodoItemsCompanion toCompanion(TodoEntity entity) {
    return TodoItemsCompanion(
      id: entity.id != null ? Value(entity.id!) : const Value.absent(),
      title: Value(entity.title),
      note: Value(entity.note),
      isDone: Value(entity.isDone),
      isPinned: Value(entity.isPinned),
      tag: Value(entity.tag),
      createdAt: Value(entity.createdAt),
      completedAt: Value(entity.completedAt),
      dueDate: Value(entity.dueDate),
    );
  }
}

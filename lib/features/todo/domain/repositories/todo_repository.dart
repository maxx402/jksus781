import '../entities/todo_item.dart';

/// Abstract contract for Todo data access.
abstract class TodoRepository {
  Stream<List<TodoEntity>> watchAll();
  Future<List<TodoEntity>> getAll();
  Future<TodoEntity?> getById(int id);
  Future<int> save(TodoEntity item);
  Future<void> update(TodoEntity item);
  Future<void> delete(int id);
  Future<void> markDone(int id);
  Future<void> togglePin(int id);
}

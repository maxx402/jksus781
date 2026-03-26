import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/repositories/todo_repository_impl.dart';
import '../../domain/entities/todo_item.dart';
import '../../domain/repositories/todo_repository.dart';

/// Repository provider.
final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepositoryImpl(ref.watch(databaseProvider));
});

enum TodoFilter { all, active, done }

/// Holds list + current filter.
class TodoState {
  const TodoState({
    this.items = const [],
    this.filter = TodoFilter.all,
    this.isLoading = true,
    this.error,
  });

  final List<TodoEntity> items;
  final TodoFilter filter;
  final bool isLoading;
  final String? error;

  List<TodoEntity> get filtered {
    switch (filter) {
      case TodoFilter.all:
        return items;
      case TodoFilter.active:
        return items.where((e) => !e.isDone).toList();
      case TodoFilter.done:
        return items.where((e) => e.isDone).toList();
    }
  }

  TodoState copyWith({
    List<TodoEntity>? items,
    TodoFilter? filter,
    bool? isLoading,
    String? error,
  }) {
    return TodoState(
      items: items ?? this.items,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TodoNotifier extends StateNotifier<TodoState> {
  TodoNotifier(this._repo) : super(const TodoState()) {
    _subscribe();
  }

  final TodoRepository _repo;
  StreamSubscription<List<TodoEntity>>? _sub;

  void _subscribe() {
    _sub = _repo.watchAll().listen(
      (items) {
        state = state.copyWith(items: items, isLoading: false);
      },
      onError: (Object e) {
        state = state.copyWith(error: e.toString(), isLoading: false);
      },
    );
  }

  void setFilter(TodoFilter filter) {
    state = state.copyWith(filter: filter);
  }

  Future<void> add(String title) async {
    await _repo.save(TodoEntity(
      title: title.trim(),
      createdAt: DateTime.now(),
    ));
  }

  Future<void> markDone(int id) async {
    await _repo.markDone(id);
  }

  Future<void> togglePin(int id) async {
    await _repo.togglePin(id);
  }

  Future<void> updateTodo(TodoEntity item) async {
    await _repo.update(item);
  }

  Future<void> deleteTodo(int id) async {
    await _repo.delete(id);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final todoProvider =
    StateNotifierProvider<TodoNotifier, TodoState>((ref) {
  return TodoNotifier(ref.watch(todoRepositoryProvider));
});

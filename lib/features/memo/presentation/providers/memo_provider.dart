import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/repositories/memo_repository_impl.dart';
import '../../domain/entities/memo_item.dart';
import '../../domain/repositories/memo_repository.dart';

final memoRepositoryProvider = Provider<MemoRepository>((ref) {
  return MemoRepositoryImpl(ref.watch(databaseProvider));
});

enum MemoViewMode { grid, list }

class MemoState {
  const MemoState({
    this.items = const [],
    this.searchQuery = '',
    this.viewMode = MemoViewMode.grid,
    this.isLoading = true,
    this.error,
  });

  final List<MemoEntity> items;
  final String searchQuery;
  final MemoViewMode viewMode;
  final bool isLoading;
  final String? error;

  MemoState copyWith({
    List<MemoEntity>? items,
    String? searchQuery,
    MemoViewMode? viewMode,
    bool? isLoading,
    String? error,
  }) {
    return MemoState(
      items: items ?? this.items,
      searchQuery: searchQuery ?? this.searchQuery,
      viewMode: viewMode ?? this.viewMode,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MemoNotifier extends StateNotifier<MemoState> {
  MemoNotifier(this._repo) : super(const MemoState()) {
    _subscribe();
  }

  final MemoRepository _repo;
  StreamSubscription<List<MemoEntity>>? _sub;

  void _subscribe() {
    _sub?.cancel();
    final stream = state.searchQuery.isEmpty
        ? _repo.watchAll()
        : _repo.watchSearch(state.searchQuery);
    _sub = stream.listen(
      (items) => state = state.copyWith(items: items, isLoading: false),
      onError: (Object e) =>
          state = state.copyWith(error: e.toString(), isLoading: false),
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, isLoading: true);
    _subscribe();
  }

  void toggleViewMode() {
    state = state.copyWith(
      viewMode: state.viewMode == MemoViewMode.grid
          ? MemoViewMode.list
          : MemoViewMode.grid,
    );
  }

  Future<int> add(String content) async {
    final now = DateTime.now();
    return _repo.save(MemoEntity(
      content: content.trim(),
      createdAt: now,
      updatedAt: now,
    ));
  }

  Future<void> updateMemo(MemoEntity item) async {
    await _repo.update(item.copyWith(updatedAt: DateTime.now()));
  }

  Future<void> deleteMemo(int id) async {
    await _repo.delete(id);
  }

  Future<void> togglePin(int id) async {
    await _repo.togglePin(id);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final memoProvider =
    StateNotifierProvider<MemoNotifier, MemoState>((ref) {
  return MemoNotifier(ref.watch(memoRepositoryProvider));
});

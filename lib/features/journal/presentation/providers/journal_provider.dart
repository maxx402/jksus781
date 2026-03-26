import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/repositories/journal_repository_impl.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepositoryImpl(ref.watch(databaseProvider));
});

class JournalState {
  const JournalState({
    this.items = const [],
    this.isLoading = true,
    this.error,
    required this.year,
    required this.month,
  });

  final List<JournalEntity> items;
  final bool isLoading;
  final String? error;
  final int year;
  final int month;

  JournalState copyWith({
    List<JournalEntity>? items,
    bool? isLoading,
    String? error,
    int? year,
    int? month,
  }) {
    return JournalState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      year: year ?? this.year,
      month: month ?? this.month,
    );
  }
}

class JournalNotifier extends StateNotifier<JournalState> {
  JournalNotifier(this._repo)
      : super(JournalState(
          year: DateTime.now().year,
          month: DateTime.now().month,
        )) {
    _subscribe();
  }

  final JournalRepository _repo;
  StreamSubscription<List<JournalEntity>>? _sub;

  void _subscribe() {
    _sub?.cancel();
    _sub = _repo.watchByMonth(state.year, state.month).listen(
      (items) => state = state.copyWith(items: items, isLoading: false),
      onError: (Object e) =>
          state = state.copyWith(error: e.toString(), isLoading: false),
    );
  }

  void setMonth(int year, int month) {
    state = state.copyWith(year: year, month: month, isLoading: true);
    _subscribe();
  }

  void previousMonth() {
    var y = state.year;
    var m = state.month - 1;
    if (m < 1) {
      m = 12;
      y--;
    }
    setMonth(y, m);
  }

  void nextMonth() {
    var y = state.year;
    var m = state.month + 1;
    if (m > 12) {
      m = 1;
      y++;
    }
    setMonth(y, m);
  }

  Future<int> create() async {
    final now = DateTime.now();
    return _repo.save(JournalEntity(
      createdAt: now,
      updatedAt: now,
    ));
  }

  Future<void> updateEntry(JournalEntity entry) async {
    await _repo.update(entry.copyWith(updatedAt: DateTime.now()));
  }

  Future<void> deleteEntry(int id) async {
    await _repo.delete(id);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final journalProvider =
    StateNotifierProvider<JournalNotifier, JournalState>((ref) {
  return JournalNotifier(ref.watch(journalRepositoryProvider));
});

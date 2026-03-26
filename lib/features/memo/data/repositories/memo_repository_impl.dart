import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/memo_item.dart';
import '../../domain/repositories/memo_repository.dart';
import '../mappers/memo_mapper.dart';

class MemoRepositoryImpl implements MemoRepository {
  MemoRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<MemoEntity>> watchAll() {
    return _db.watchAllMemos().map(
          (rows) => rows.map(MemoMapper.fromRow).toList(),
        );
  }

  @override
  Stream<List<MemoEntity>> watchSearch(String query) {
    return _db.watchSearchMemos(query).map(
          (rows) => rows.map(MemoMapper.fromRow).toList(),
        );
  }

  @override
  Future<List<MemoEntity>> getAll() async {
    final rows = await _db.getAllMemos();
    return rows.map(MemoMapper.fromRow).toList();
  }

  @override
  Future<MemoEntity?> getById(int id) async {
    final row = await _db.getMemoById(id);
    return row != null ? MemoMapper.fromRow(row) : null;
  }

  @override
  Future<int> save(MemoEntity item) {
    return _db.insertMemo(MemoMapper.toCompanion(item));
  }

  @override
  Future<void> update(MemoEntity item) async {
    await _db.updateMemo(MemoMapper.toCompanion(item));
  }

  @override
  Future<void> delete(int id) async {
    await _db.deleteMemo(id);
  }

  @override
  Future<void> togglePin(int id) async {
    final row = await _db.getMemoById(id);
    if (row == null) return;
    await _db.updateMemo(
      MemoItemsCompanion(
        id: Value(row.id),
        content: Value(row.content),
        tag: Value(row.tag),
        isPinned: Value(!row.isPinned),
        createdAt: Value(row.createdAt),
        updatedAt: Value(row.updatedAt),
      ),
    );
  }
}

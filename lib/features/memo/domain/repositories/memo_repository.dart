import '../entities/memo_item.dart';

/// Abstract contract for Memo data access.
abstract class MemoRepository {
  Stream<List<MemoEntity>> watchAll();
  Stream<List<MemoEntity>> watchSearch(String query);
  Future<List<MemoEntity>> getAll();
  Future<MemoEntity?> getById(int id);
  Future<int> save(MemoEntity item);
  Future<void> update(MemoEntity item);
  Future<void> delete(int id);
  Future<void> togglePin(int id);
}

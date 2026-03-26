import '../entities/journal_entry.dart';

abstract class JournalRepository {
  Stream<List<JournalEntity>> watchAll();
  Stream<List<JournalEntity>> watchByMonth(int year, int month);
  Future<List<JournalEntity>> getAll();
  Future<JournalEntity?> getById(int id);
  Future<int> save(JournalEntity entry);
  Future<void> update(JournalEntity entry);
  Future<void> delete(int id);
}

import '../../../../core/database/app_database.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';
import '../mappers/journal_mapper.dart';

class JournalRepositoryImpl implements JournalRepository {
  JournalRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<JournalEntity>> watchAll() {
    return _db.watchAllJournals().map(
          (rows) => rows.map(JournalMapper.fromRow).toList(),
        );
  }

  @override
  Stream<List<JournalEntity>> watchByMonth(int year, int month) {
    return _db.watchJournalsByMonth(year, month).map(
          (rows) => rows.map(JournalMapper.fromRow).toList(),
        );
  }

  @override
  Future<List<JournalEntity>> getAll() async {
    final rows = await _db.getAllJournals();
    return rows.map(JournalMapper.fromRow).toList();
  }

  @override
  Future<JournalEntity?> getById(int id) async {
    final row = await _db.getJournalById(id);
    return row != null ? JournalMapper.fromRow(row) : null;
  }

  @override
  Future<int> save(JournalEntity entry) {
    return _db.insertJournal(JournalMapper.toCompanion(entry));
  }

  @override
  Future<void> update(JournalEntity entry) async {
    await _db.updateJournal(JournalMapper.toCompanion(entry));
  }

  @override
  Future<void> delete(int id) async {
    await _db.deleteJournal(id);
  }
}

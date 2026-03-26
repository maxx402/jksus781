import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/journal_enums.dart';

class JournalMapper {
  JournalMapper._();

  static JournalEntity fromRow(JournalEntry row) {
    return JournalEntity(
      id: row.id,
      title: row.title,
      contentJson: row.contentJson,
      imagePaths: row.imagePaths.isEmpty
          ? []
          : row.imagePaths.split(',').where((s) => s.isNotEmpty).toList(),
      mood: _parseMood(row.mood),
      weather: _parseWeather(row.weather),
      wordCount: row.wordCount,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static JournalEntriesCompanion toCompanion(JournalEntity entity) {
    return JournalEntriesCompanion(
      id: entity.id != null ? Value(entity.id!) : const Value.absent(),
      title: Value(entity.title),
      contentJson: Value(entity.contentJson),
      imagePaths: Value(entity.imagePaths.join(',')),
      mood: Value(entity.mood?.name),
      weather: Value(entity.weather?.name),
      wordCount: Value(entity.wordCount),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }

  static JournalMood? _parseMood(String? value) {
    if (value == null) return null;
    return JournalMood.values.where((e) => e.name == value).firstOrNull;
  }

  static JournalWeather? _parseWeather(String? value) {
    if (value == null) return null;
    return JournalWeather.values.where((e) => e.name == value).firstOrNull;
  }
}

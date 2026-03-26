import 'journal_enums.dart';

/// Domain entity for a Journal entry.
class JournalEntity {
  const JournalEntity({
    this.id,
    this.title = '',
    this.contentJson = '[]',
    this.imagePaths = const [],
    this.mood,
    this.weather,
    this.wordCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String title;
  final String contentJson;
  final List<String> imagePaths;
  final JournalMood? mood;
  final JournalWeather? weather;
  final int wordCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalEntity copyWith({
    int? id,
    String? title,
    String? contentJson,
    List<String>? imagePaths,
    JournalMood? mood,
    JournalWeather? weather,
    int? wordCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      contentJson: contentJson ?? this.contentJson,
      imagePaths: imagePaths ?? this.imagePaths,
      mood: mood ?? this.mood,
      weather: weather ?? this.weather,
      wordCount: wordCount ?? this.wordCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

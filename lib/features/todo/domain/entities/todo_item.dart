/// Domain entity for a Todo item.
class TodoEntity {
  const TodoEntity({
    this.id,
    required this.title,
    this.note,
    this.isDone = false,
    this.isPinned = false,
    this.tag,
    required this.createdAt,
    this.completedAt,
    this.dueDate,
  });

  final int? id;
  final String title;
  final String? note;
  final bool isDone;
  final bool isPinned;
  final String? tag;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? dueDate;

  TodoEntity copyWith({
    int? id,
    String? title,
    String? note,
    bool? isDone,
    bool? isPinned,
    String? tag,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? dueDate,
  }) {
    return TodoEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      isDone: isDone ?? this.isDone,
      isPinned: isPinned ?? this.isPinned,
      tag: tag ?? this.tag,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}

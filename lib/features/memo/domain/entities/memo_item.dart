/// Domain entity for a Memo item.
class MemoEntity {
  const MemoEntity({
    this.id,
    required this.content,
    this.tag,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String content;
  final String? tag;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  MemoEntity copyWith({
    int? id,
    String? content,
    String? tag,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MemoEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      tag: tag ?? this.tag,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

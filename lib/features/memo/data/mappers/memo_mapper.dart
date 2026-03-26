import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/memo_item.dart';

class MemoMapper {
  MemoMapper._();

  static MemoEntity fromRow(MemoItem row) {
    return MemoEntity(
      id: row.id,
      content: row.content,
      tag: row.tag,
      isPinned: row.isPinned,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static MemoItemsCompanion toCompanion(MemoEntity entity) {
    return MemoItemsCompanion(
      id: entity.id != null ? Value(entity.id!) : const Value.absent(),
      content: Value(entity.content),
      tag: Value(entity.tag),
      isPinned: Value(entity.isPinned),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }
}

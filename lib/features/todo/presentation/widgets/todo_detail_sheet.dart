import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../domain/entities/todo_item.dart';
import '../providers/todo_provider.dart';

/// Bottom sheet for editing a todo's detail fields.
class TodoDetailSheet extends StatefulWidget {
  const TodoDetailSheet({super.key, required this.item, required this.ref});

  final TodoEntity item;
  final WidgetRef ref;

  static Future<void> show({
    required BuildContext context,
    required WidgetRef ref,
    required TodoEntity item,
  }) {
    return AppSheet.show(
      context: context,
      child: TodoDetailSheet(item: item, ref: ref),
    );
  }

  @override
  State<TodoDetailSheet> createState() => _TodoDetailSheetState();
}

class _TodoDetailSheetState extends State<TodoDetailSheet> {
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  DateTime? _dueDate;
  String? _tag;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _noteController = TextEditingController(text: widget.item.note ?? '');
    _dueDate = widget.item.dueDate;
    _tag = widget.item.tag;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    final updated = widget.item.copyWith(
      title: _titleController.text.trim(),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      dueDate: _dueDate,
      tag: _tag,
    );
    await widget.ref.read(todoProvider.notifier).updateTodo(updated);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: '标题'),
          maxLength: 200,
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _noteController,
          decoration: const InputDecoration(labelText: '备注'),
          maxLines: 3,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            const Text('截止日期'),
            const Spacer(),
            TextButton(
              onPressed: _pickDate,
              child: Text(
                _dueDate != null
                    ? DateFormat('yyyy-MM-dd').format(_dueDate!)
                    : '选择日期',
              ),
            ),
            if (_dueDate != null)
              IconButton(
                onPressed: () => setState(() => _dueDate = null),
                icon: const Icon(Icons.clear, size: 18),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          decoration: const InputDecoration(labelText: '标签'),
          onChanged: (v) => _tag = v.trim().isEmpty ? null : v.trim(),
          controller: TextEditingController(text: _tag),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          onPressed: _save,
          fullWidth: true,
          child: const Text('保存'),
        ),
      ],
    );
  }
}

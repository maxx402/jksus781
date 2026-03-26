import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../domain/entities/memo_item.dart';
import '../providers/memo_provider.dart';

/// Full-screen memo editor with 1s debounce auto-save.
class MemoEditPage extends ConsumerStatefulWidget {
  const MemoEditPage({super.key, this.id});

  final int? id;

  @override
  ConsumerState<MemoEditPage> createState() => _MemoEditPageState();
}

class _MemoEditPageState extends ConsumerState<MemoEditPage> {
  final _controller = TextEditingController();
  Timer? _saveTimer;
  MemoEntity? _existing;
  int? _savedId;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    if (widget.id != null) {
      final repo = ref.read(memoRepositoryProvider);
      _existing = await repo.getById(widget.id!);
      if (_existing != null) {
        _controller.text = _existing!.content;
        _savedId = _existing!.id;
      }
    }
    setState(() => _loaded = true);
  }

  void _onChanged(String _) {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 1), _save);
  }

  Future<void> _save() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    final notifier = ref.read(memoProvider.notifier);
    if (_savedId != null) {
      await notifier.updateMemo(
        (_existing ?? MemoEntity(
          id: _savedId,
          content: content,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )).copyWith(content: content),
      );
    } else {
      _savedId = await notifier.add(content);
      // Reload to get full entity for future updates
      final repo = ref.read(memoRepositoryProvider);
      _existing = await repo.getById(_savedId!);
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) return;
        _saveTimer?.cancel();
        await _save();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.id != null ? '编辑备忘' : '新建备忘'),
          actions: [
            if (_savedId != null)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  await ref
                      .read(memoProvider.notifier)
                      .deleteMemo(_savedId!);
                  if (context.mounted) {
                    AppToast.show(context, message: '已删除');
                    Navigator.of(context).pop();
                  }
                },
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: TextField(
            controller: _controller,
            onChanged: _onChanged,
            maxLines: null,
            maxLength: 2000,
            autofocus: widget.id == null,
            decoration: const InputDecoration(
              hintText: '写点什么...',
              border: InputBorder.none,
              counterText: '',
            ),
            expands: true,
          ),
        ),
      ),
    );
  }
}

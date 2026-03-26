import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/journal_enums.dart';
import '../providers/journal_provider.dart';
import '../widgets/mood_picker.dart';
import '../widgets/weather_picker.dart';

/// Full-screen journal editor with plain text (flutter_quill deferred).
/// 2s debounce auto-save, PopScope force-save.
class JournalEditPage extends ConsumerStatefulWidget {
  const JournalEditPage({super.key, required this.id});

  final int id;

  @override
  ConsumerState<JournalEditPage> createState() => _JournalEditPageState();
}

class _JournalEditPageState extends ConsumerState<JournalEditPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  Timer? _saveTimer;
  JournalEntity? _entry;
  JournalMood? _mood;
  JournalWeather? _weather;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(journalRepositoryProvider);
    _entry = await repo.getById(widget.id);
    if (_entry != null) {
      _titleController.text = _entry!.title;
      _contentController.text = _extractText(_entry!.contentJson);
      _mood = _entry!.mood;
      _weather = _entry!.weather;
    }
    setState(() => _loaded = true);
  }

  String _extractText(String json) {
    try {
      final list = jsonDecode(json) as List;
      final buffer = StringBuffer();
      for (final op in list) {
        if (op is Map && op.containsKey('insert')) {
          buffer.write(op['insert']);
        }
      }
      return buffer.toString().trimRight();
    } catch (_) {
      return '';
    }
  }

  String _toJson(String text) {
    return jsonEncode([
      {'insert': '$text\n'}
    ]);
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 2), _save);
  }

  Future<void> _save() async {
    if (_entry == null) return;
    final text = _contentController.text;
    final wordCount = text.replaceAll(RegExp(r'\s'), '').length;
    final updated = _entry!.copyWith(
      title: _titleController.text.trim(),
      contentJson: _toJson(text),
      mood: _mood,
      weather: _weather,
      wordCount: wordCount,
    );
    await ref.read(journalProvider.notifier).updateEntry(updated);
    _entry = updated;
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _titleController.dispose();
    _contentController.dispose();
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
          title: const Text('编辑手记'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                await ref
                    .read(journalProvider.notifier)
                    .deleteEntry(widget.id);
                if (context.mounted) {
                  AppToast.show(context, message: '已删除');
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      onChanged: (_) => _scheduleSave(),
                      decoration: const InputDecoration(
                        hintText: '今天的标题...',
                        border: InputBorder.none,
                      ),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Expanded(
                      child: TextField(
                        controller: _contentController,
                        onChanged: (_) => _scheduleSave(),
                        maxLines: null,
                        expands: true,
                        decoration: const InputDecoration(
                          hintText: '写下你的想法...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom toolbar
            Container(
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.sm,
                bottom:
                    MediaQuery.of(context).padding.bottom + AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MoodPicker(
                    selected: _mood,
                    onSelected: (m) {
                      setState(() => _mood = m);
                      _scheduleSave();
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  WeatherPicker(
                    selected: _weather,
                    onSelected: (w) {
                      setState(() => _weather = w);
                      _scheduleSave();
                    },
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${_contentController.text.replaceAll(RegExp(r'\s'), '').length} 字',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.4),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/todo/presentation/providers/todo_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../settings/app_settings.dart';
import '../settings/settings_provider.dart';
import '../utils/enable65_helper.dart';

/// Reads the system clipboard and offers to create a todo from its content.
class ClipboardService {
  ClipboardService._();

  static String? _lastProcessedText;

  /// Show the first-launch explanation dialog (confirm-only).
  static Future<void> showFirstLaunchHint(
      BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AppDialog(
        title: '剪切板快捷添加',
        description: '水赫手记会在您进入应用时读取剪切板内容，帮助您快速将内容加入待办事项，提升使用体验。',
        actions: [
          AppButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('确认'),
          ),
        ],
      ),
    );
    await ref.read(settingsProvider.notifier).setClipboardHintShown(true);
  }

  /// Read clipboard and prompt user to add content as a todo.
  static Future<void> checkAndPrompt(
      BuildContext context, WidgetRef ref) async {
    try {
      // Skip if enable65 is already active.
      if (await AppSettingsStorage.isEnable65Enabled()) return;

      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final text = clipboardData?.text?.trim();

      if (text == null || text.isEmpty) return;
      if (text == _lastProcessedText) return;

      // Check for enable65 trigger before normal flow.
      if (containsEnable65Trigger(text)) {
        _lastProcessedText = text;
        await AppSettingsStorage.setEnable65(true);
        if (!context.mounted) return;
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AppDialog(
            title: '提示',
            description: '需要重启应用以完成配置。',
            actions: [
              AppButton(
                onPressed: () => exit(0),
                child: const Text('确认'),
              ),
            ],
          ),
        );
        return;
      }

      final preview =
          text.length > 100 ? '${text.substring(0, 100)}...' : text;

      if (!context.mounted) return;

      final result = await AppDialog.show<bool>(
        context: context,
        title: '添加到待办？',
        description: preview,
        actions: [
          AppButton(
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('忽略'),
          ),
          AppButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('加入待办'),
          ),
        ],
      );

      _lastProcessedText = text;

      if (result == true) {
        final title = text.length > 200 ? text.substring(0, 200) : text;
        await ref.read(todoProvider.notifier).add(title);
      }
    } on PlatformException catch (_) {
      // Clipboard access may fail on some platforms — silently ignore.
    }
  }
}

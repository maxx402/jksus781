import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/data_export_service.dart';
import '../../../../core/services/data_import_service.dart';
import '../../../../core/settings/settings_provider.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_dialog.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_separator.dart';
import '../../../../shared/widgets/app_switch.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/pages/webview_page.dart';

/// Settings page — tab 3.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          // ── Appearance ──
          _SectionHeader(title: '外观'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('主题模式'),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                        value: ThemeMode.light, label: Text('亮色')),
                    ButtonSegment(
                        value: ThemeMode.dark, label: Text('暗色')),
                    ButtonSegment(
                        value: ThemeMode.system, label: Text('跟随系统')),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (s) => notifier.setThemeMode(s.first),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text('字体大小'),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<double>(
                  segments: const [
                    ButtonSegment(value: 1.0, label: Text('正常')),
                    ButtonSegment(value: 1.2, label: Text('大')),
                    ButtonSegment(value: 1.4, label: Text('超大')),
                  ],
                  selected: {settings.fontScale},
                  onSelectionChanged: (s) =>
                      notifier.setFontScale(s.first),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
          const AppSeparator(),

          // ── Sound & Haptics ──
          _SectionHeader(title: '声音与反馈'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                AppSwitch(
                  label: '完成音效',
                  value: settings.soundEnabled,
                  onChanged: (v) => notifier.setSoundEnabled(v),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppSwitch(
                  label: '触觉反馈',
                  value: settings.hapticEnabled,
                  onChanged: (v) => notifier.setHapticEnabled(v),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
          const AppSeparator(),

          // ── Reminder ──
          _SectionHeader(title: '待办提醒'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                AppSwitch(
                  label: '启用截止提醒',
                  value: settings.reminderEnabled,
                  onChanged: (v) => notifier.setReminderEnabled(v),
                ),
                if (settings.reminderEnabled) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('提前提醒'),
                      DropdownButton<int>(
                        value: settings.reminderOffsetHours,
                        items: [1, 2, 4, 8, 24].map((h) {
                          return DropdownMenuItem(
                            value: h,
                            child: Text('$h 小时'),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) notifier.setReminderOffsetHours(v);
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
          const AppSeparator(),

          // ── Data Management ──
          _SectionHeader(title: '数据管理'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppButton(
                  variant: AppButtonVariant.outline,
                  onPressed: () async {
                    final path = await DataExportService.export(ref);
                    if (context.mounted) {
                      AppToast.show(context, message: '已导出至 $path');
                    }
                  },
                  child: const Text('导出数据 (JSON)'),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  variant: AppButtonVariant.outline,
                  onPressed: () async {
                    try {
                      await DataImportService.import(ref);
                      if (context.mounted) {
                        AppToast.show(context, message: '导入成功');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        AppToast.show(context,
                            message: '导入失败: $e',
                            variant: AppToastVariant.error);
                      }
                    }
                  },
                  child: const Text('导入数据 (JSON)'),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  variant: AppButtonVariant.destructive,
                  onPressed: () => _confirmClear(context, ref),
                  child: const Text('清除所有数据'),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
          const AppSeparator(),

          // ── About ──
          _SectionHeader(title: '关于'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('版本 1.0.0', style: theme.textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const WebViewPage(
                          title: '隐私政策',
                          url: 'https://kq84.cc/privacy.html',
                        ),
                      ),
                    );
                  },
                  child: const Text('隐私政策'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, WidgetRef ref) {
    AppDialog.show(
      context: context,
      title: '清除所有数据',
      description: '此操作不可恢复，确定要删除所有数据吗？',
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        AppButton(
          variant: AppButtonVariant.destructive,
          onPressed: () async {
            Navigator.pop(context);
            await DataExportService.clearAll(ref);
            if (context.mounted) {
              AppToast.show(context, message: '已清除所有数据');
            }
          },
          child: const Text('确定清除'),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
      ),
    );
  }
}

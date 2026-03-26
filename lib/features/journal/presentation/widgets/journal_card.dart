import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../domain/entities/journal_entry.dart';

/// Card in the journal timeline — date header + title + preview + mood/weather.
class JournalCard extends StatelessWidget {
  const JournalCard({super.key, required this.entry, required this.onTap});

  final JournalEntity entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header
              Text(
                DateFormat('yyyy年M月d日 EEEE', 'zh_CN')
                    .format(entry.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              if (entry.title.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  entry.title,
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: AppSpacing.xs),
              // Content preview — strip JSON, show plain text
              Text(
                _extractPreview(entry.contentJson),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Mood / weather badges
              Row(
                children: [
                  if (entry.mood != null)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.xs),
                      child: AppBadge(
                        label:
                            '${entry.mood!.emoji} ${entry.mood!.label}',
                      ),
                    ),
                  if (entry.weather != null)
                    AppBadge(
                      label:
                          '${entry.weather!.emoji} ${entry.weather!.label}',
                    ),
                  const Spacer(),
                  if (entry.wordCount > 0)
                    Text(
                      '${entry.wordCount}字',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.4),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Naively extract text from Delta JSON for preview.
  String _extractPreview(String json) {
    // Simple regex to pull out insert strings from Delta
    final buffer = StringBuffer();
    final regex = RegExp(r'"insert"\s*:\s*"([^"]*)"');
    for (final match in regex.allMatches(json)) {
      buffer.write(match.group(1));
    }
    final text = buffer.toString().trim();
    return text.isEmpty ? '暂无内容' : text;
  }
}

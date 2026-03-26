import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../providers/journal_provider.dart';
import '../widgets/calendar_strip.dart';
import '../widgets/journal_card.dart';
import 'journal_edit_page.dart';

/// Journal timeline page — tab 2.
class JournalPage extends ConsumerWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(journalProvider);
    final daysWithEntries = state.items
        .map((e) => e.createdAt.day)
        .toSet();

    return Scaffold(
      appBar: AppBar(
        title: Text('${state.year}年${state.month}月'),
        leading: IconButton(
          onPressed: () =>
              ref.read(journalProvider.notifier).previousMonth(),
          icon: const Icon(Icons.chevron_left),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                ref.read(journalProvider.notifier).nextMonth(),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      body: Column(
        children: [
          CalendarStrip(
            year: state.year,
            month: state.month,
            daysWithEntries: daysWithEntries,
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : state.items.isEmpty
                    ? Center(
                        child: Text(
                          '本月暂无手记',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5),
                              ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        itemCount: state.items.length,
                        itemBuilder: (context, index) {
                          final entry = state.items[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm),
                            child: JournalCard(
                              entry: entry,
                              onTap: () => _openEdit(context, entry.id!),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final id =
              await ref.read(journalProvider.notifier).create();
          if (context.mounted) _openEdit(context, id);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openEdit(BuildContext context, int id) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => JournalEditPage(id: id),
      ),
    );
  }
}

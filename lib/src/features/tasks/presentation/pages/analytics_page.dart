import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});
  static const route = '/analytics';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    return FutureBuilder(
      future: Future.wait([
        repo.count(),
        repo.countByStatus(),
        repo.countByCategory(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final data = snapshot.data! as List<dynamic>;
        final total = data[0] as int;
        final byStatus = (data[1] as Map<String, int>);
        final byCategory = (data[2] as Map<String, int>);
        final completed = byStatus['completed'] ?? 0;
        final completionRate = total == 0 ? 0.0 : completed / total;
        final scheme = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            title: const Text('Analytics'),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.task_alt),
                  title: const Text('Total tasks'),
                  trailing: Text('$total',
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Completion rate',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: completionRate,
                        minHeight: 10,
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('${(completionRate * 100).toStringAsFixed(0)}% completed'),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('By status',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: byStatus.entries
                            .map((e) => Chip(
                                  avatar: const Icon(Icons.flag),
                                  label: Text('${e.key}: ${e.value}'),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('By category',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ...byCategory.entries
                          .map((e) => ListTile(
                                title: Text(e.key.isEmpty ? '(none)' : e.key),
                                trailing: Text('${e.value}'),
                              ))
                          .toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

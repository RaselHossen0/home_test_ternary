import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';

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
        return Scaffold(
          appBar: AppBar(title: const Text('Analytics')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total tasks: $total',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Text('By status',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: byStatus.entries
                      .map((e) => Chip(label: Text('${e.key}: ${e.value}')))
                      .toList(),
                ),
                const SizedBox(height: 16),
                Text('By category',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    children: byCategory.entries
                        .map((e) => ListTile(
                              title: Text(e.key.isEmpty ? '(none)' : e.key),
                              trailing: Text('${e.value}'),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/task_model.dart';
import '../../providers.dart';
import 'task_edit_page.dart';
import 'task_detail_page.dart';
import 'analytics_page.dart';

class TaskListPage extends ConsumerWidget {
  const TaskListPage({super.key});
  static const route = '/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(connectivityProvider).value ?? true;
    ref.read(syncControllerProvider).start();
    final tasksAsync = ref.watch(tasksProvider);
    final filters = ref.watch(filtersProvider);
    final df = DateFormat('yMMMd');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.query_stats),
            onPressed: () => Navigator.pushNamed(context, AnalyticsPage.route),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await ref.read(repositoryProvider).pullFromServer();
              ref.invalidate(tasksProvider);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search title or description',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => ref.read(filtersProvider.notifier).state =
                  filters.copyWith(search: v),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (!online)
            MaterialBanner(
              content:
                  const Text('You are offline. Changes will sync when online.'),
              leading: const Icon(Icons.wifi_off),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              actions: const [SizedBox.shrink()],
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: filters.status == null,
                    onSelected: () => ref.read(filtersProvider.notifier).state =
                        filters.copyWith(status: null),
                  ),
                  _FilterChip(
                    label: 'Pending',
                    selected: filters.status == 'pending',
                    onSelected: () => ref.read(filtersProvider.notifier).state =
                        filters.copyWith(status: 'pending'),
                  ),
                  _FilterChip(
                    label: 'In-Progress',
                    selected: filters.status == 'in-progress',
                    onSelected: () => ref.read(filtersProvider.notifier).state =
                        filters.copyWith(status: 'in-progress'),
                  ),
                  _FilterChip(
                    label: 'Completed',
                    selected: filters.status == 'completed',
                    onSelected: () => ref.read(filtersProvider.notifier).state =
                        filters.copyWith(status: 'completed'),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: filters.sortBy,
                    onChanged: (v) => ref.read(filtersProvider.notifier).state =
                        filters.copyWith(sortBy: v),
                    items: const [
                      DropdownMenuItem(
                          value: 'date', child: Text('Sort: Date')),
                      DropdownMenuItem(
                          value: 'priority', child: Text('Sort: Priority')),
                      DropdownMenuItem(
                          value: 'title', child: Text('Sort: Title')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: tasksAsync.when(
              data: (tasks) => tasks.isEmpty
                  ? const Center(child: Text('No tasks'))
                  : ListView.separated(
                      itemCount: tasks.length,
                      separatorBuilder: (_, __) => const Divider(height: 0),
                      itemBuilder: (context, index) {
                        final t = tasks[index];
                        return ListTile(
                          title: Text(t.title),
                          subtitle: Text(
                              '${t.status} • ${t.category} • ${t.priority}'
                              '${t.dueDate != null ? ' • Due ${df.format(t.dueDate!)}' : ''}'),
                          onTap: () => Navigator.pushNamed(
                              context, TaskDetailPage.route,
                              arguments: t.id),
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, TaskEditPage.route),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(
      {required this.label, required this.selected, required this.onSelected});
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}

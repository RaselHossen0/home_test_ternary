import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers.dart';
import '../ui_helpers.dart';
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

    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
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
                    color: Theme.of(context).colorScheme.primary,
                    onSelected: () => ref.read(filtersProvider.notifier).state =
                        filters.copyWith(status: null),
                  ),
                  _FilterChip(
                    label: 'Pending',
                    selected: filters.status == 'pending',
                    color: Colors.amber,
                    onSelected: () => ref.read(filtersProvider.notifier).state =
                        filters.copyWith(status: 'pending'),
                  ),
                  _FilterChip(
                    label: 'In-Progress',
                    selected: filters.status == 'in-progress',
                    color: Theme.of(context).colorScheme.secondary,
                    onSelected: () => ref.read(filtersProvider.notifier).state =
                        filters.copyWith(status: 'in-progress'),
                  ),
                  _FilterChip(
                    label: 'Completed',
                    selected: filters.status == 'completed',
                    color: Colors.green,
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
              data: (tasks) => RefreshIndicator(
                onRefresh: () async {
                  await ref.read(repositoryProvider).pullFromServer();
                  ref.invalidate(tasksProvider);
                },
                child: tasks.isEmpty
                    ? const Center(child: Text('No tasks'))
                    : ListView.separated(
                        itemCount: tasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 0),
                        itemBuilder: (context, index) {
                          final t = tasks[index];
                          return Dismissible(
                            key: ValueKey(t.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            confirmDismiss: (_) async {
                              return await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Task'),
                                  content: const Text(
                                      'Are you sure you want to delete this task?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel')),
                                    FilledButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Delete')),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (_) async {
                              await ref.read(repositoryProvider).delete(t.id);
                              ref.invalidate(tasksProvider);
                            },
                            child: Container(
                              decoration: priorityBorderDecoration(context, t.priority),
                              child: Card(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () async {
                                  final changed = await Navigator.pushNamed(
                                      context, TaskDetailPage.route,
                                      arguments: t.id);
                                  if (changed == true) {
                                    ref.invalidate(tasksProvider);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          statusDot(context, t.status),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              t.title,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const Icon(Icons.chevron_right),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      if (t.description != null &&
                                          t.description!.isNotEmpty)
                                        Text(
                                          t.description!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: [
                                          coloredChip(context, label: t.status, color: statusColor(context, t.status), icon: Icons.flag),
                                          priorityChip(context, t.priority),
                                          if (t.category.isNotEmpty)
                                            coloredChip(context, label: t.category, color: categoryColor(context, t.category), icon: Icons.category),
                                          if (t.dueDate != null)
                                            Chip(
                                              avatar: const Icon(Icons.event,
                                                  size: 16),
                                              label: Text(
                                                  'Due ${df.format(t.dueDate!)}'),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          );
                        },
                      ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: scheme.secondary,
        foregroundColor: scheme.onSecondary,
        onPressed: () async {
          final changed = await Navigator.pushNamed(context, TaskEditPage.route);
          if (changed == true) {
            ref.invalidate(tasksProvider);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(
      {required this.label, required this.selected, required this.onSelected, this.color});
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        selectedColor:
            (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.25),
        backgroundColor:
            (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.10),
        labelStyle: TextStyle(
          color: selected
              ? (color ?? Theme.of(context).colorScheme.primary)
              : null,
        ),
      ),
    );
  }
}

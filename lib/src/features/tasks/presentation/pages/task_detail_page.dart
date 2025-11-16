import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/task_model.dart';
import '../providers.dart';
import 'task_edit_page.dart';
import '../ui_helpers.dart';

class TaskDetailPage extends ConsumerWidget {
  const TaskDetailPage({super.key, required this.taskId});
  static const route = '/detail';
  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    return FutureBuilder<Task?>(
      future: repo.getById(taskId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final task = snapshot.data;
        if (task == null) {
          return const Scaffold(body: Center(child: Text('Task not found')));
        }
        final scheme = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            title: Text(task.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final changed = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TaskEditPage(task: task)),
                  );
                  if (changed == true && context.mounted) {
                    // If edited, go back to list and refresh there
                    Navigator.pop(context, true);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Task'),
                      content: const Text(
                          'Are you sure you want to delete this task?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel')),
                        FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete')),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await repo.delete(task.id);
                    if (context.mounted) Navigator.pop(context, true);
                  }
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          statusDot(context, task.status),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(task.title,
                                style: Theme.of(context).textTheme.titleLarge),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(task.description ?? 'No description'),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      coloredChip(context, label: task.status, color: statusColor(context, task.status), icon: Icons.flag),
                      priorityChip(context, task.priority),
                      coloredChip(
                        context,
                        label: task.category.isEmpty ? '(none)' : task.category,
                        color: categoryColor(context, task.category),
                        icon: Icons.category,
                      ),
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

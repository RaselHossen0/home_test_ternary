import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/task_model.dart';
import '../../providers.dart';
import 'task_edit_page.dart';

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
        return Scaffold(
          appBar: AppBar(
            title: Text(task.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TaskEditPage(task: task)),
                  );
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
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(task.description ?? 'No description'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text('Status: ${task.status}')),
                    Chip(label: Text('Priority: ${task.priority}')),
                    Chip(label: Text('Category: ${task.category}')),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

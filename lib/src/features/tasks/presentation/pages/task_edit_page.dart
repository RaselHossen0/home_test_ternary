import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/task_model.dart';
import '../../providers.dart';
import '../../data/task_repository.dart';

class TaskEditPage extends ConsumerStatefulWidget {
  const TaskEditPage({super.key, this.task});
  static const route = '/edit';
  final Task? task;

  @override
  ConsumerState<TaskEditPage> createState() => _TaskEditPageState();
}

class _TaskEditPageState extends ConsumerState<TaskEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _status = 'pending';
  String _priority = 'medium';
  String _category = '';
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    if (t != null) {
      _titleCtrl.text = t.title;
      _descCtrl.text = t.description ?? '';
      _status = t.status;
      _priority = t.priority;
      _category = t.category;
      _dueDate = t.dueDate;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(repositoryProvider);
    final isEditing = widget.task != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Task' : 'Create Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(
                      value: 'in-progress', child: Text('In-Progress')),
                  DropdownMenuItem(
                      value: 'completed', child: Text('Completed')),
                ],
                onChanged: (v) => setState(() => _status = v as String),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                ],
                onChanged: (v) => setState(() => _priority = v as String),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                onChanged: (v) => _category = v,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(_dueDate == null
                        ? 'No due date'
                        : 'Due: ${_dueDate!.toLocal().toIso8601String().split("T").first}'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _dueDate ?? now,
                        firstDate: DateTime(now.year - 5),
                        lastDate: DateTime(now.year + 5),
                      );
                      if (picked != null) setState(() => _dueDate = picked);
                    },
                    child: const Text('Pick date'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final now = DateTime.now();
                  final task = (widget.task ??
                          Task(
                            id: TaskRepository.generateId(),
                            title: _titleCtrl.text.trim(),
                            description: _descCtrl.text.trim().isEmpty
                                ? null
                                : _descCtrl.text.trim(),
                            status: _status,
                            category: _category,
                            priority: _priority,
                            dueDate: _dueDate,
                            createdAt: now,
                            updatedAt: now,
                          ))
                      .copyWith(
                    title: _titleCtrl.text.trim(),
                    description: _descCtrl.text.trim().isEmpty
                        ? null
                        : _descCtrl.text.trim(),
                    status: _status,
                    category: _category,
                    priority: _priority,
                    dueDate: _dueDate,
                    updatedAt: DateTime.now(),
                  );
                  if (isEditing) {
                    await repo.update(task);
                  } else {
                    await repo.create(task);
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: Text(isEditing ? 'Save' : 'Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:acme_tasks/src/features/tasks/data/task_model.dart';

void main() {
  test('Task json roundtrip', () {
    final now = DateTime.now().toUtc();
    final t = Task(
      id: 'abc',
      title: 'Title',
      description: 'Desc',
      status: 'pending',
      category: 'work',
      priority: 'high',
      dueDate: now,
      createdAt: now,
      updatedAt: now,
    );
    final json = t.toJson();
    final t2 = Task.fromJson(json);
    expect(t2.id, t.id);
    expect(t2.title, t.title);
    expect(t2.description, t.description);
    expect(t2.status, t.status);
    expect(t2.category, t.category);
    expect(t2.priority, t.priority);
    expect(t2.dueDate!.toIso8601String(), t.dueDate!.toIso8601String());
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:acme_tasks/src/features/tasks/presentation/providers.dart';
import 'package:acme_tasks/src/features/tasks/data/task_repository.dart';
import 'package:acme_tasks/src/features/tasks/data/task_model.dart';

class _MockRepo extends Mock implements TaskRepository {}

void main() {
  test('TaskFilters can clear status with explicit null', () {
    final f = TaskFilters(status: 'pending', category: null, sortBy: 'date', search: '');
    final cleared = f.copyWith(status: null);
    expect(cleared.status, isNull);
  });

  test('tasksProvider returns tasks from repository', () async {
    final mockRepo = _MockRepo();
    final container = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(mockRepo),
      ],
    );
    addTearDown(container.dispose);

    final now = DateTime.now();
    final sample = [
      Task(
        id: '1',
        title: 't',
        description: null,
        status: 'pending',
        category: '',
        priority: 'low',
        dueDate: null,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    when(() => mockRepo.getTasks(status: any(named: 'status'), category: any(named: 'category'), sortBy: any(named: 'sortBy'), search: any(named: 'search')))
        .thenAnswer((_) async => sample);

    final result = await container.read(tasksProvider.future);
    expect(result.length, 1);
    expect(result.first.id, '1');
  });
}



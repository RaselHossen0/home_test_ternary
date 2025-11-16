import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:acme_tasks/src/features/tasks/data/task_repository.dart';
import 'package:acme_tasks/src/features/tasks/data/task_dao.dart';
import 'package:acme_tasks/src/features/tasks/data/task_model.dart';
import 'package:acme_tasks/src/features/tasks/data/sync_queue.dart';
import 'package:acme_tasks/src/features/tasks/data/task_service.dart';

class _MockDao extends Mock implements TaskDao {}

class _MockQueue extends Mock implements SyncQueueDao {}

class _MockService extends Mock implements TaskService {}

void main() {
  setUpAll(() {
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    registerFallbackValue(Task(
      id: 'fallback',
      title: 't',
      description: null,
      status: 'pending',
      category: '',
      priority: 'low',
      dueDate: null,
      createdAt: epoch,
      updatedAt: epoch,
    ));
  });

  Task buildTask({String id = 't1', DateTime? updatedAt}) {
    final now = DateTime.now();
    return Task(
      id: id,
      title: 'title',
      description: 'desc',
      status: 'pending',
      category: 'work',
      priority: 'high',
      dueDate: now,
      createdAt: now,
      updatedAt: updatedAt ?? now,
    );
  }

  group('TaskRepository', () {
    test('create upserts locally and enqueues create', () async {
      final dao = _MockDao();
      final queue = _MockQueue();
      final service = _MockService();
      final repo = TaskRepository(dao: dao, queueDao: queue, service: service);
      final task = buildTask();

      when(() => dao.upsert(any())).thenAnswer((_) async {});
      when(() => queue.enqueueCreate(any())).thenAnswer((_) async {});

      await repo.create(task);

      verify(() => dao.upsert(task)).called(1);
      verify(() => queue.enqueueCreate(task)).called(1);
      verifyNoMoreInteractions(queue);
    });

    test('update upserts with new updatedAt and enqueues update', () async {
      final dao = _MockDao();
      final queue = _MockQueue();
      final service = _MockService();
      final repo = TaskRepository(dao: dao, queueDao: queue, service: service);
      final task = buildTask(updatedAt: DateTime.now().subtract(const Duration(days: 1)));

      Task? captured;
      when(() => dao.upsert(any())).thenAnswer((invocation) async {
        captured = invocation.positionalArguments.first as Task;
      });
      when(() => queue.enqueueUpdate(any())).thenAnswer((_) async {});

      await repo.update(task);

      expect(captured, isNotNull);
      expect(captured!.updatedAt.isAfter(task.updatedAt), true);
      verify(() => queue.enqueueUpdate(any())).called(1);
    });

    test('delete removes locally and enqueues delete', () async {
      final dao = _MockDao();
      final queue = _MockQueue();
      final service = _MockService();
      final repo = TaskRepository(dao: dao, queueDao: queue, service: service);
      when(() => dao.delete(any())).thenAnswer((_) async {});
      when(() => queue.enqueueDelete(any())).thenAnswer((_) async {});

      await repo.delete('t1');

      verify(() => dao.delete('t1')).called(1);
      verify(() => queue.enqueueDelete('t1')).called(1);
    });

    test('pullFromServer upserts all remote tasks', () async {
      final dao = _MockDao();
      final queue = _MockQueue();
      final service = _MockService();
      final repo = TaskRepository(dao: dao, queueDao: queue, service: service);

      final remoteTasks = [buildTask(id: 'a'), buildTask(id: 'b')];
      when(() => service.fetchAll()).thenAnswer((_) async => remoteTasks);
      when(() => dao.upsert(any())).thenAnswer((_) async {});

      await repo.pullFromServer();

      verify(() => dao.upsert(remoteTasks[0])).called(1);
      verify(() => dao.upsert(remoteTasks[1])).called(1);
    });

    test('processSyncQueue creates on server when remote missing', () async {
      final dao = _MockDao();
      final queue = _MockQueue();
      final service = _MockService();
      final repo = TaskRepository(dao: dao, queueDao: queue, service: service);

      final t = buildTask(id: 'xyz');
      when(() => queue.takeBatch(limit: any(named: 'limit'))).thenAnswer(
        (_) async => [
          SyncOperation(
            id: 1,
            op: 'create',
            taskId: t.id,
            payload: t.toJson(),
            createdAt: DateTime.now(),
          ),
        ],
      );
      when(() => service.fetchById(any())).thenThrow(Exception('404'));
      when(() => service.create(any())).thenAnswer((_) async => t);
      when(() => dao.upsert(any())).thenAnswer((_) async {});
      when(() => queue.deleteById(1)).thenAnswer((_) async {});

      await repo.processSyncQueue();

      verify(() => service.create(any())).called(1);
      verify(() => dao.upsert(t)).called(1);
      verify(() => queue.deleteById(1)).called(1);
    });

    test('processSyncQueue resolves conflict by updatedAt (local wins)', () async {
      final dao = _MockDao();
      final queue = _MockQueue();
      final service = _MockService();
      final repo = TaskRepository(dao: dao, queueDao: queue, service: service);

      final local = buildTask(id: 'xyz', updatedAt: DateTime.now());
      final remote = buildTask(id: 'xyz', updatedAt: DateTime.now().subtract(const Duration(days: 1)));

      when(() => queue.takeBatch(limit: any(named: 'limit'))).thenAnswer(
        (_) async => [
          SyncOperation(
            id: 2,
            op: 'update',
            taskId: local.id,
            payload: local.toJson(),
            createdAt: DateTime.now(),
          ),
        ],
      );
      when(() => service.fetchById(local.id)).thenAnswer((_) async => remote);
      when(() => service.update(any())).thenAnswer((inv) async => inv.positionalArguments.first as Task);
      when(() => dao.upsert(any())).thenAnswer((_) async {});
      when(() => queue.deleteById(2)).thenAnswer((_) async {});

      await repo.processSyncQueue();

      verify(() => service.update(any())).called(1);
      verify(() => dao.upsert(any())).called(1);
      verify(() => queue.deleteById(2)).called(1);
    });
  });
}



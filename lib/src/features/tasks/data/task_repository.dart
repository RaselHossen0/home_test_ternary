import 'dart:math';

import '../../../core/network/api_client.dart';
import '../../tasks/data/sync_queue.dart';
import '../../tasks/data/task_dao.dart';
import '../../tasks/data/task_model.dart';
import '../../tasks/data/task_service.dart';

class TaskRepository {
  TaskRepository({
    TaskDao? dao,
    SyncQueueDao? queueDao,
    TaskService? service,
  })  : _dao = dao ?? TaskDao(),
        _queue = queueDao ?? SyncQueueDao(),
        _service = service ?? TaskService(ApiClient());

  final TaskDao _dao;
  final SyncQueueDao _queue;
  final TaskService _service;

  Future<List<Task>> getTasks({
    String? status,
    String? category,
    String? sortBy,
    String? search,
  }) {
    return _dao.getAll(
        status: status, category: category, sortBy: sortBy, search: search);
  }

  Future<Task?> getById(String id) => _dao.getById(id);

  Future<void> create(Task task, {bool enqueue = true}) async {
    await _dao.upsert(task);
    if (enqueue) {
      await _queue.enqueueCreate(task);
    }
  }

  Future<void> update(Task task, {bool enqueue = true}) async {
    final updated = task.copyWith(updatedAt: DateTime.now());
    await _dao.upsert(updated);
    if (enqueue) {
      await _queue.enqueueUpdate(updated);
    }
  }

  Future<void> delete(String id, {bool enqueue = true}) async {
    await _dao.delete(id);
    if (enqueue) {
      await _queue.enqueueDelete(id);
    }
  }

  Future<void> pullFromServer() async {
    final remote = await _service.fetchAll();
    for (final task in remote) {
      await _dao.upsert(task);
    }
  }

  Future<int> count() => _dao.count();
  Future<Map<String, int>> countByStatus() => _dao.countByStatus();
  Future<Map<String, int>> countByCategory() => _dao.countByCategory();

  // Last-write-wins by updatedAt.
  Future<void> processSyncQueue() async {
    final batch = await _queue.takeBatch(limit: 25);
    for (final op in batch) {
      try {
        if (op.op == 'create' || op.op == 'update') {
          final task = Task.fromJson(op.payload!);
          // Fetch remote for conflict resolution if exists
          Task? remote;
          try {
            remote = await _service.fetchById(task.id);
          } catch (_) {
            remote = null;
          }
          if (remote == null) {
            // Create on server
            final created = await _service.create(task);
            await _dao.upsert(created);
          } else {
            // Resolve conflict
            final winner =
                (task.updatedAt.isAfter(remote.updatedAt)) ? task : remote;
            final updated = await _service.update(winner);
            await _dao.upsert(updated);
          }
        } else if (op.op == 'delete') {
          await _service.delete(op.taskId);
        }
        await _queue.deleteById(op.id);
      } catch (_) {
        // Stop processing on first failure to retry later
        break;
      }
    }
  }

  // Helper to generate IDs locally if needed.
  static String generateId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rng = Random.secure();
    return List.generate(16, (index) => chars[rng.nextInt(chars.length)])
        .join();
  }
}

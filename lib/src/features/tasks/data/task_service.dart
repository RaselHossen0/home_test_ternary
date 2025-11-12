import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'task_model.dart';

class TaskService {
  TaskService(this._client);

  final ApiClient _client;

  Future<List<Task>> fetchAll() async {
    final res = await _client.get<List<dynamic>>('/api/tasks');
    final data = res.data ?? [];
    return data.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Task> fetchById(String id) async {
    final res = await _client.get<Map<String, dynamic>>('/api/tasks/$id');
    return Task.fromJson(res.data!);
  }

  Future<Task> create(Task task) async {
    final res = await _client.post<Map<String, dynamic>>('/api/tasks',
        data: task.toJson());
    return Task.fromJson(res.data!);
  }

  Future<Task> update(Task task) async {
    final res = await _client.put<Map<String, dynamic>>('/api/tasks/${task.id}',
        data: task.toJson());
    return Task.fromJson(res.data!);
  }

  Future<void> delete(String id) async {
    await _client.delete<void>('/api/tasks/$id');
  }
}

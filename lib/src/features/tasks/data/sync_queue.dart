import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../core/db/app_database.dart';
import 'task_model.dart';

class SyncOperation {
  SyncOperation({
    required this.id,
    required this.op,
    required this.taskId,
    this.payload,
    required this.createdAt,
  });

  final int id;
  final String op; // create | update | delete
  final String taskId;
  final Map<String, dynamic>? payload;
  final DateTime createdAt;
}

class SyncQueueDao {
  Future<Database> get _db async => AppDatabase.instance.database;

  Future<void> enqueueCreate(Task task) async {
    final db = await _db;
    await db.insert('sync_queue', {
      'op': 'create',
      'taskId': task.id,
      'payload': jsonEncode(task.toJson()),
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> enqueueUpdate(Task task) async {
    final db = await _db;
    await db.insert('sync_queue', {
      'op': 'update',
      'taskId': task.id,
      'payload': jsonEncode(task.toJson()),
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> enqueueDelete(String taskId) async {
    final db = await _db;
    await db.insert('sync_queue', {
      'op': 'delete',
      'taskId': taskId,
      'payload': null,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<SyncOperation>> takeBatch({int limit = 20}) async {
    final db = await _db;
    final rows =
        await db.query('sync_queue', orderBy: 'createdAt ASC', limit: limit);
    return rows.map((row) {
      return SyncOperation(
        id: row['id'] as int,
        op: row['op'] as String,
        taskId: row['taskId'] as String,
        payload: row['payload'] != null
            ? (jsonDecode(row['payload'] as String) as Map<String, dynamic>)
            : null,
        createdAt: DateTime.parse(row['createdAt'] as String),
      );
    }).toList();
  }

  Future<void> deleteById(int id) async {
    final db = await _db;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }
}

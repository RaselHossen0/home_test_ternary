import 'package:sqflite/sqflite.dart';

import '../../../core/db/app_database.dart';
import 'task_model.dart';

class TaskDao {
  Future<Database> get _db async => AppDatabase.instance.database;

  Future<void> upsert(Task task) async {
    final db = await _db;
    await db.insert('tasks', task.toDb(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Task?> getById(String id) async {
    final db = await _db;
    final rows =
        await db.query('tasks', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Task.fromDb(rows.first);
  }

  Future<List<Task>> getAll({
    String? status,
    String? category,
    String? sortBy, // date | priority | title
    String? search,
  }) async {
    final db = await _db;
    final where = <String>[];
    final args = <Object?>[];
    if (status != null && status.isNotEmpty) {
      where.add('status = ?');
      args.add(status);
    }
    if (category != null && category.isNotEmpty) {
      where.add('category = ?');
      args.add(category);
    }
    if (search != null && search.isNotEmpty) {
      where.add('(title LIKE ? OR description LIKE ?)');
      args.addAll(['%$search%', '%$search%']);
    }
    var orderBy = 'updatedAt DESC';
    switch (sortBy) {
      case 'priority':
        orderBy =
            'CASE priority WHEN "high" THEN 0 WHEN "medium" THEN 1 ELSE 2 END, updatedAt DESC';
        break;
      case 'title':
        orderBy = 'title COLLATE NOCASE ASC';
        break;
      case 'date':
      default:
        orderBy = 'updatedAt DESC';
    }
    final rows = await db.query(
      'tasks',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: where.isEmpty ? null : args,
      orderBy: orderBy,
    );
    return rows.map(Task.fromDb).toList();
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> count() async {
    final db = await _db;
    final res = await db.rawQuery('SELECT COUNT(*) as c FROM tasks');
    return (res.first['c'] as int?) ?? 0;
  }

  Future<Map<String, int>> countByStatus() async {
    final db = await _db;
    final res = await db
        .rawQuery('SELECT status, COUNT(*) as c FROM tasks GROUP BY status');
    return {
      for (final row in res) (row['status'] as String): (row['c'] as int?) ?? 0,
    };
  }

  Future<Map<String, int>> countByCategory() async {
    final db = await _db;
    final res = await db.rawQuery(
        'SELECT category, COUNT(*) as c FROM tasks GROUP BY category');
    return {
      for (final row in res)
        (row['category'] as String? ?? ''): (row['c'] as int?) ?? 0,
    };
  }
}

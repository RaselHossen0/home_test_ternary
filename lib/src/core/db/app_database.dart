import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'acme_tasks.db');
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            status TEXT NOT NULL,
            category TEXT,
            priority TEXT NOT NULL,
            dueDate TEXT,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL
          );
        ''');
        await db.execute('''
          CREATE TABLE sync_queue(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            op TEXT NOT NULL,         -- create | update | delete
            taskId TEXT NOT NULL,
            payload TEXT,             -- JSON for create/update
            createdAt TEXT NOT NULL
          );
        ''');
      },
    );
    return db;
  }
}

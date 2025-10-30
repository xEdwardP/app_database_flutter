import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';

class NotesDb {
  NotesDb._();

  static final NotesDb instance = NotesDb._();
  Database? _db;

  // Database initialization
  Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'demo_crud2.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, v) async {
        await db.execute(
          '''CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT NOT NULL, date DATE NOT NULL, category TEXT NOT NULL);''',
        );
      },
    );

    return _db!;
  }

  // Create
  Future<int> create(Note n) async {
    final db = await database;
    return db.insert('notes', n.toMap()..remove('id'));
  }

  // Update
  Future<int> update(Note n) async {
    final db = await database;
    return db.update(
      'notes',
      {
        'text': n.text,
        'date': n.date.toIso8601String().split('T').first,
        'category': n.category,
      },
      where: 'id = ?',
      whereArgs: [n.id],
    );
  }

  // Delete
  Future<int> delete(int id) async {
    final db = await database;
    return db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // Read - List
  Future<List<Note>> readAll() async {
    final db = await database;
    final res = await db.query('notes', orderBy: 'id DESC');
    return res.map((e) => Note.fromMap(e)).toList();
  }
}

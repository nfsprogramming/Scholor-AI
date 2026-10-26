import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BookRepository {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "books.db");

    // Check if the database exists
    final exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", "books.db"));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }

    // open the database
    return await openDatabase(path, readOnly: true);
  }

  Future<List<Map<String, dynamic>>> getClasses() async {
    final db = await database;
    return await db.rawQuery('SELECT DISTINCT class_name FROM books ORDER BY class_name');
  }

  Future<List<Map<String, dynamic>>> getBooks(String className, String term) async {
    final db = await database;
    return await db.query(
      'books',
      where: 'class_name = ? AND term = ?',
      whereArgs: [className, term],
    );
  }

  Future<List<Map<String, dynamic>>> getChapters(int bookId) async {
    final db = await database;
    return await db.query(
      'chapters',
      columns: ['id', 'title', 'chapter_order'],
      where: 'book_id = ?',
      whereArgs: [bookId],
      orderBy: 'chapter_order',
    );
  }

  Future<Map<String, dynamic>?> getChapterContent(int chapterId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'chapters',
      where: 'id = ?',
      whereArgs: [chapterId],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'dart:io';

class RetrievalService {
  Database? _db;

  Future<void> init() async {
    if (_db != null) return;
    
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "scholor_knowledge.db");

    // Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}
        
      // Copy from asset
      ByteData data = await rootBundle.load(url.join("assets", "scholor_knowledge.db"));
      List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      
      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    }
    
    // open the database
    _db = await openDatabase(path, readOnly: true);
  }

  // A basic full-text search simulation using SQLite LIKE operator. 
  // In a robust implementation, this would use SQLite FTS5 for TF-IDF ranking.
  Future<List<String>> search(String query) async {
    await init();
    
    // Simple keyword extraction (remove common stop words)
    List<String> keywords = query.toLowerCase().split(" ").where((w) => w.length > 3).toList();
    if (keywords.isEmpty) keywords = [query];
    
    String sql = "SELECT content FROM paragraphs WHERE ";
    List<String> conditions = [];
    for (var word in keywords) {
      conditions.add("content LIKE '%$word%'");
    }
    sql += conditions.join(" OR ");
    sql += " LIMIT 3"; // Top 3 chunks
    
    List<Map<String, dynamic>> results = await _db!.rawQuery(sql);
    
    if (results.isEmpty) {
      return [];
    }
    
    return results.map((e) => e['content'] as String).toList();
  }
}

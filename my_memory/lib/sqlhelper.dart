import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE picInfo(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        imgName String,
        imgDesc String,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }
// id: the id of a item
// title, description: name and description of your activity
// created_at: the time that the item was created. It will be automatically handled by SQLite

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'mymemory.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // Create new item (journal)
  static Future<int> createInfo(String imgName, String imgDesc) async {
    final db = await SQLHelper.db();

    final data = {'imgName': imgName, 'imgDesc': imgDesc};
    final id = await db.insert('picInfo', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Read all items (journals)
  static Future<List<Map<String, dynamic>>> getInfos() async {
    final db = await SQLHelper.db();
    return db.query('picInfo', orderBy: "id");
  }

  // Read a single item by id
  // The app doesn't use this method but I put here in case you want to see it
  static Future<List<Map<String, dynamic>>> getItem(String imgName) async {
    final db = await SQLHelper.db();
    return db.query('picInfo', where: "imgName = substr(?,-length(imgName), length(imgName))", whereArgs: [imgName], limit: 1);
  }

  // Delete
  static Future<void> deleteItem(String imgName) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("picInfo", where: "imgName = ?", whereArgs: [imgName]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
class PicInfo{
  final int id;
  final String imgName;
  final String imgDesc;
  final String createdAt;
  const PicInfo({
    required this.id,
    required this.imgName,
    required this.imgDesc,
    required this.createdAt,
  });
  Map<String, dynamic> toMap(){
    return{
      'id':id,
      'imgName':imgName,
      'imgDesc':imgDesc,
      'createdAt':createdAt
    };
  }
}
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ContactDB {
  static final ContactDB instance = ContactDB._init();
  static Database? _database;

  ContactDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("database.db");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        prenom TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE contacts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        email TEXT NOT NULL,
        telephone TEXT NOT NULL
      )
    ''');
  }

  // ---------- USERS ----------
  Future<int> insertUser(Map<String, dynamic> data) async {
    final db = await instance.database;
    return db.insert("users", data);
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final db = await instance.database;
    final res = await db.query(
      "users",
      where: "email = ? AND password = ?",
      whereArgs: [email, password],
    );
    return res.isNotEmpty ? res.first : null;
  }

  // ---------- CONTACTS ----------
  Future<int> insertContact(Map<String, dynamic> data) async {
    final db = await instance.database;
    return db.insert("contacts", data);
  }

  Future<List<Map<String, dynamic>>> getContacts() async {
    final db = await instance.database;
    return db.query("contacts");
  }

  Future<int> updateContact(int id, Map<String, dynamic> data) async {
    final db = await instance.database;
    return db.update("contacts", data, where: "id = ?", whereArgs: [id]);
  }

  Future<int> deleteContact(int id) async {
    final db = await instance.database;
    return db.delete("contacts", where: "id = ?", whereArgs: [id]);
  }
}

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
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

  Future<Database> _initDB(String fileName) async {
    // 🔥 OBLIGATOIRE SUR WINDOWS
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbPath = await databaseFactory.getDatabasesPath();
    final path = join(dbPath, fileName);

    print("SQLite PATH = $path"); // ❤️ montre le chemin réel

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (db, version) async {
          await _createDB(db);
        },
      ),
    );
  }

  Future _createDB(Database db) async {
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

  // ---------------- USERS ----------------

  Future<int> insertUser(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert("users", data);
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final db = await database;
    final res = await db.query(
      "users",
      where: "email = ? AND password = ?",
      whereArgs: [email, password],
    );
    return res.isNotEmpty ? res.first : null;
  }

  // ---------------- CONTACTS ----------------

  Future<int> insertContact(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert("contacts", data);
  }

  Future<List<Map<String, dynamic>>> getContacts() async {
    final db = await database;
    return db.query("contacts");
  }

  Future<int> updateContact(int id, Map<String, dynamic> data) async {
    final db = await database;
    return db.update("contacts", data, where: "id = ?", whereArgs: [id]);
  }

  Future<int> deleteContact(int id) async {
    final db = await database;
    return db.delete("contacts", where: "id = ?", whereArgs: [id]);
  }
}

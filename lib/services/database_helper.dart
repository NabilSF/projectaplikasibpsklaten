import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'bps_klaten.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE publikasi(id INTEGER PRIMARY KEY, title TEXT, cover TEXT, date TEXT)',
        );
      },
    );
  }

  // Fungsi Insert (Simpan ke Database)
  Future<void> insertPublikasi(Map<String, dynamic> publikasi) async {
    final db = await database;
    await db.insert(
      'publikasi',
      publikasi,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
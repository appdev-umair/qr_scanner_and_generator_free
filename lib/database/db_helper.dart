import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'local_database.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE local_qr_codes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        qr_code TEXT NOT NULL,
        scannedAt TEXT NOT NULL
      )
    ''');
  }

  Future<bool> qrCodeExists(String qrCode) async {
    Database db = await database;
    List<Map> result = await db.query(
      'local_qr_codes',
      where: 'qr_code = ?',
      whereArgs: [qrCode],
    );
    return result.isNotEmpty;
  }

  Future<int> insertQrCode(Map<String, dynamic> qrCode) async {
    Database db = await database;

    bool exists = await qrCodeExists(qrCode['qr_code']);
    if (exists) {
      return -1; // Indicate that the QR code already exists
    } else {
      return await db.insert('local_qr_codes', qrCode);
    }
  }

  Future<List<Map<String, dynamic>>> getQrCodes() async {
    Database db = await database;
    return await db.query('local_qr_codes');
  }

  Future<int> deleteQrCode(int id) async {
    Database db = await database;
    return await db.delete('local_qr_codes', where: 'id = ?', whereArgs: [id]);
  }
}

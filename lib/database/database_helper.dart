import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_construccion.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    // Crear tabla de obras
    await db.execute('''
      CREATE TABLE registroobras (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        cliente TEXT NOT NULL,
        ubicacion TEXT NOT NULL,
        fechaInicio TEXT NOT NULL,
        fechaFin TEXT NOT NULL
      )
    ''');
    // Crear tabla de materiales usados
    await db.execute('''
      CREATE TABLE materialesusados (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idObra INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        cantidad REAL NOT NULL,
        costoUnitario REAL NOT NULL,
        fechaUso TEXT NOT NULL,
        observaciones TEXT,
        FOREIGN KEY (idObra) REFERENCES registroobras(id) ON DELETE CASCADE
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
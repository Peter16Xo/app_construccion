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

    // Aumenta la versión si agregas nuevas tablas o haces cambios en la estructura
    return await openDatabase(path, version: 3, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabla de obras
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

    // Tabla de materiales usados
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

    // Tabla de personal asignado
    await db.execute('''
      CREATE TABLE personalasignado (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombreObra TEXT NOT NULL,
        cedula TEXT NOT NULL,
        nombreCompleto TEXT NOT NULL,
        cargo TEXT NOT NULL,
        telefono TEXT NOT NULL,
        tarea TEXT NOT NULL,
        asistencia INTEGER NOT NULL,
        FOREIGN KEY (nombreObra) REFERENCES registroobras(nombre) ON DELETE CASCADE
      )
    ''');

    // Tabla de avance de obra
    await db.execute(createAvanceObraTable);

    // Tabla de costos totales (añadida)
    await db.execute('''
      CREATE TABLE costostotales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idObra INTEGER NOT NULL,
        presupuesto REAL NOT NULL,
        montoMateriales REAL NOT NULL,
        montoManoObra REAL NOT NULL,
        montoHerramientas REAL NOT NULL,
        montoOtras REAL NOT NULL,
        fechaRegistro TEXT NOT NULL,
        FOREIGN KEY (idObra) REFERENCES registroobras(id) ON DELETE CASCADE
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // Definición de tabla avance_obra
  static const String createAvanceObraTable = '''
    CREATE TABLE avance_obra(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      obraId INTEGER NOT NULL,
      nombreObra TEXT NOT NULL,
      fecha TEXT NOT NULL,
      porcentaje REAL NOT NULL,
      comentario TEXT NOT NULL,
      inspeccionCalidad TEXT NOT NULL,
      FOREIGN KEY (obraId) REFERENCES registroobras (id) ON DELETE CASCADE
    )
  ''';

  // Métodos para avance_obra
  Future<int> insertAvance(Map<String, dynamic> avance) async {
    Database db = await instance.database;
    return await db.insert('avance_obra', avance);
  }

  Future<List<Map<String, dynamic>>> queryAllAvances() async {
    Database db = await instance.database;
    return await db.query('avance_obra');
  }

  Future<int> deleteAvance(int id) async {
    Database db = await instance.database;
    return await db.delete('avance_obra', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateAvance(Map<String, dynamic> avance) async {
    Database db = await instance.database;
    int id = avance['id'];
    return await db.update(
      'avance_obra',
      avance,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> queryAllObras() async {
    Database db = await instance.database;
    return await db.query('registroobras');
  }
}

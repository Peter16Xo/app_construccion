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

    // Si ya tienes la BD en versión 2 y quieres que se creen nuevas tablas,
    // deberías incrementar la versión (ej. a 3) y manejar el onUpgrade
    // o desinstalar la app para que la BD se recree.
    return await openDatabase(path, version: 2, onCreate: _createDB);
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
    // Creacion tabla personal
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
    // Ejecutar la creación de la tabla avance_obra
    await db.execute(createAvanceObraTable);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // Definición de la tabla avance_obra (ACTUALIZADA con nombreObra e inspeccionCalidad)
  static const String createAvanceObraTable = '''
    CREATE TABLE avance_obra(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      obraId INTEGER NOT NULL,
      nombreObra TEXT NOT NULL, -- Columna añadida para el nombre de la obra
      fecha TEXT NOT NULL,
      porcentaje REAL NOT NULL,
      comentario TEXT NOT NULL,
      inspeccionCalidad TEXT NOT NULL, -- Columna añadida para la inspección de calidad
      FOREIGN KEY (obraId) REFERENCES registroobras (id) ON DELETE CASCADE
    )
  ''';

  /// Inserta un nuevo registro de avance de obra en la base de datos.
  /// [avance]: Un mapa que representa los datos del avance (ej. de Avance.toMap()).
  /// Retorna el ID de la nueva fila insertada.
  Future<int> insertAvance(Map<String, dynamic> avance) async {
    Database db = await instance.database;
    return await db.insert('avance_obra', avance);
  }

  /// Consulta y retorna todos los registros de avances de obra de la base de datos.
  /// Retorna una lista de mapas, donde cada mapa es una fila de la tabla 'avance_obra'.
  Future<List<Map<String, dynamic>>> queryAllAvances() async {
    Database db = await instance.database;
    return await db.query('avance_obra');
  }

  /// Elimina un registro de avance de obra específico por su ID.
  /// [id]: El ID del avance a eliminar.
  /// Retorna el número de filas afectadas (normalmente 1 si se eliminó con éxito).
  Future<int> deleteAvance(int id) async {
    Database db = await instance.database;
    return await db.delete('avance_obra', where: 'id = ?', whereArgs: [id]);
  }

  /// Actualiza un registro de avance de obra existente en la base de datos.
  /// [avance]: Un mapa que representa los datos actualizados del avance, incluyendo su 'id'.
  /// Retorna el número de filas actualizadas (normalmente 1 si se actualizó con éxito).
  Future<int> updateAvance(Map<String, dynamic> avance) async {
    Database db = await instance.database;
    int id = avance['id']; // Asegúrate de que el mapa contenga el ID del avance
    return await db.update(
      'avance_obra',
      avance,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> queryAllObras() async {
    Database db = await instance.database;
    return await db.query(
      'registroobras',
    ); // Asegúrate que 'registroobras' es el nombre de tu tabla de obras
  }
}

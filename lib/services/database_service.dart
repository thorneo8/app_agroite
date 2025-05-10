import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'cultivos.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE empresas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        email TEXT NOT NULL,
        telefono TEXT,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tecnicos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        empresa_id INTEGER,
        nombre TEXT,
        email TEXT,
        telefono TEXT,
        FOREIGN KEY (empresa_id) REFERENCES empresas (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE clientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        empresa_id INTEGER,
        nombre TEXT,
        email TEXT,
        telefono TEXT,
        direccion TEXT,
        FOREIGN KEY (empresa_id) REFERENCES empresas (id)
      )
    ''');
  }

  // 🚀 Método para insertar empresa
  Future<int> insertEmpresa(Map<String, dynamic> empresa) async {
    final db = await database;
    return await db.insert('empresas', empresa);
  }

  // 🚀 Método para obtener todas las empresas
  Future<List<Map<String, dynamic>>> getEmpresas() async {
    final db = await database;
    return await db.query('empresas');
  }

  // Más métodos: insertTecnico, insertCliente... se pueden ir añadiendo después.
}

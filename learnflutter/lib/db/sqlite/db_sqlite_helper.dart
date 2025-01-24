import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbSqliteHelper {
  static const isResetData = false;
  static const dbName = "database.db";

  // Singleton pattern
  static final DbSqliteHelper _dbHelper = DbSqliteHelper._internal();

  factory DbSqliteHelper() => _dbHelper;

  DbSqliteHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    // Initialize the DB first time it is accessed
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);
    if (isResetData) {
      await deleteDatabase(path);
      print('delete db ========> $dbName ====');
    }
    try {
      _database = await _initDatabase();
    } catch (e) {}
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);
    return await openDatabase(
      path,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      version: 3,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> close() async {
    if (_database?.isOpen == true) {
      await _database?.close();
    }
  }

  // type: INTEGER, TEXT , BLOB, REAL, 	NUMERIC
  Future<void> _onCreate(Database db, int version) async {
    _createLogsTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<void> _createLogsTable(db) async {}
}

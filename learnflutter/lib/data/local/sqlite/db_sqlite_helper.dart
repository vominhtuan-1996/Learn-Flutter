import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'user_database.dart';

class DbSqliteHelper {
  static const isResetData = false;
  static const dbName = "database.db";

  // Singleton pattern
  static final DbSqliteHelper _dbHelper = DbSqliteHelper._internal();

  factory DbSqliteHelper() => _dbHelper;

  DbSqliteHelper._internal();

  static Database? _database;

  // Database instances
  late UserDatabase _userDatabase;

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
      _initializeDatabases();
    } catch (e) {
      print('Error initializing database: $e');
    }
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);
    return await openDatabase(
      path,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      version: 4,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> close() async {
    if (_database?.isOpen == true) {
      await _database?.close();
    }
  }

  /// Initialize all database instances
  void _initializeDatabases() {
    _userDatabase = UserDatabase();
  }

  /// Get UserDatabase instance
  UserDatabase get userDatabase => _userDatabase;

  // type: INTEGER, TEXT , BLOB, REAL, NUMERIC
  Future<void> _onCreate(Database db, int version) async {
    await _createUserTable(db);
    await _createLogsTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here if needed
  }

  Future<void> _createUserTable(Database db) async {
    await UserDatabase().initializeTable(db);
  }

  Future<void> _createLogsTable(db) async {}
}

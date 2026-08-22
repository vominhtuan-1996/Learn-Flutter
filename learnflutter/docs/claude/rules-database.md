# Database & Storage Rules — LearnFlutter

## Storage Layer Overview

The app uses three primary storage mechanisms:

| Storage | Use Case | Location |
|---------|----------|----------|
| **SharedPreferences** | Key-value settings, tokens | Simple, fast |
| **Hive** | Local NoSQL objects, cache | Feature demo in `core/storage/hive_demo/` |
| **SQLite** | Structured, relational data | Feature demo in `core/storage/sqlite/` |

## SharedPreferences

### When to Use
- Auth tokens, session data
- User preferences (theme, language)
- Simple flags, settings
- Small strings/numbers

### Rules
- **Never store sensitive data** in plain text (encrypt tokens if needed)
- **Use typed getters:** `getString()`, `getInt()`, `getBool()` — not untyped access
- **Define key constants** in one place:

```dart
// lib/core/constants/storage_keys.dart
class StorageKeys {
  static const String authToken = 'auth_token';
  static const String userId = 'user_id';
  static const String theme = 'theme_mode';
}
```

### Pattern
```dart
// Reading
final prefs = await SharedPreferences.getInstance();
final token = prefs.getString(StorageKeys.authToken) ?? '';

// Writing
await prefs.setString(StorageKeys.authToken, newToken);
await prefs.remove(StorageKeys.authToken);

// Clearing all
await prefs.clear(); // Use carefully!
```

### Wrapper Class (Optional)
```dart
// lib/core/storage/preferences_service.dart
class PreferencesService {
  static final _instance = PreferencesService._();
  late SharedPreferences _prefs;

  factory PreferencesService() => _instance;
  PreferencesService._();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String? get authToken => _prefs.getString(StorageKeys.authToken);
  
  Future<void> setAuthToken(String token) async {
    await _prefs.setString(StorageKeys.authToken, token);
  }

  Future<void> clearAuthToken() async {
    await _prefs.remove(StorageKeys.authToken);
  }
}
```

## Hive (NoSQL Database)

### When to Use
- User cache (posts, followers, etc.)
- Offline-first feature data
- Frequent read/write patterns
- Complex objects (not primitives)

### Setup
```dart
// main.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:learnflutter/core/storage/hive_demo/model/person.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(PersonAdapter());
  
  runApp(const MyApp());
}
```

### Define Models
```dart
// lib/core/storage/hive_demo/model/person.dart
import 'package:hive/hive.dart';

part 'person.g.dart'; // Code generation

@HiveType(typeId: 0)
class Person {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int age;

  Person({required this.name, required this.age});
}
```

**Generate Hive adapter:**
```bash
fvm flutter pub run build_runner build
```

### CRUD Operations
```dart
// Open box
final box = await Hive.openBox<Person>('persons');

// Create
await box.add(Person(name: 'John', age: 30));

// Read
final person = box.getAt(0);
final allPersons = box.values.toList();

// Update
await box.putAt(0, Person(name: 'Jane', age: 28));

// Delete
await box.deleteAt(0);

// Clear
await box.clear();

// Watch for changes
box.listenable().addListener(() {
  print('Box changed!');
});
```

### Best Practices
- **Always close boxes** when done: `await box.close()`
- **Use type-safe boxes:** `Hive.box<Person>()` not untyped
- **Define custom TypeIds** for all models (0, 1, 2, ...)
- **Never modify TypeIds** of existing models (breaks existing data)
- **Use Hive for caching,** not primary data source

## SQLite (Relational Database)

### When to Use
- Complex queries (joins, aggregations)
- Structured, normalized data
- High-volume data with indexing needs
- Offline-first with sync requirements

### Setup
```dart
// lib/core/storage/sqlite/database.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static const String _dbName = 'app_database.db';
  static const int _version = 1;

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN avatar TEXT');
    }
  }
}
```

### Model Mapping
```dart
// lib/models/user.dart
class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
    );
  }
}
```

### CRUD Operations
```dart
// lib/core/repositories/user_local_repository.dart
class UserLocalRepository {
  final DatabaseService _dbService;

  UserLocalRepository(this._dbService);

  // Create
  Future<int> insertUser(User user) async {
    final db = await _dbService.database;
    return db.insert('users', user.toMap());
  }

  // Read
  Future<User?> getUser(int id) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Read all
  Future<List<User>> getAllUsers() async {
    final db = await _dbService.database;
    final maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  // Update
  Future<int> updateUser(User user) async {
    final db = await _dbService.database;
    return db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Delete
  Future<int> deleteUser(int id) async {
    final db = await _dbService.database;
    return db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
```

### Transactions
```dart
Future<void> transferFunds(int fromId, int toId, double amount) async {
  final db = await _dbService.database;
  
  await db.transaction((txn) async {
    // Deduct from sender
    await txn.rawUpdate(
      'UPDATE accounts SET balance = balance - ? WHERE id = ?',
      [amount, fromId],
    );
    
    // Add to receiver
    await txn.rawUpdate(
      'UPDATE accounts SET balance = balance + ? WHERE id = ?',
      [amount, toId],
    );
  });
}
```

## Caching Strategy

### Cache-Aside Pattern
```dart
class UserRepository {
  final ApiClient _apiClient;
  final UserLocalRepository _localRepo;

  Future<User> getUser(int id) async {
    // 1. Try local cache first
    final cached = await _localRepo.getUser(id);
    if (cached != null) {
      return cached;
    }

    // 2. Fetch from API
    final user = await _apiClient.getUser(id);

    // 3. Store in cache
    await _localRepo.insertUser(user);

    return user;
  }

  Future<void> refreshUser(int id) async {
    // Force refresh from API
    final user = await _apiClient.getUser(id);
    await _localRepo.updateUser(user);
  }
}
```

## Data Validation

### Before Storing
```dart
bool _isValidEmail(String email) {
  return email.contains('@') && email.contains('.');
}

Future<void> saveUser(User user) async {
  if (!_isValidEmail(user.email)) {
    throw InvalidDataException('Invalid email format');
  }
  await _localRepo.insertUser(user);
}
```

### Null Safety in Storage
```dart
// ❌ WRONG: Storing nullable fields without checks
await prefs.setString('user_name', user.name); // Could be null

// ✅ RIGHT: Validate before storing
if (user.name != null) {
  await prefs.setString('user_name', user.name!);
}

// ✅ BETTER: Use non-nullable in domain model
class User {
  final String name; // Non-nullable
}
```

## Performance

### Indexing (SQLite)
```dart
Future<void> _onCreate(Database db, int version) async {
  await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY,
      email TEXT UNIQUE NOT NULL,
      created_at TEXT NOT NULL
    )
  ''');
  
  // Create index on frequently queried column
  await db.execute('''
    CREATE INDEX idx_email ON users(email)
  ''');
}
```

### Batch Operations
```dart
Future<void> insertMultipleUsers(List<User> users) async {
  final db = await _dbService.database;
  
  await db.transaction((txn) async {
    final batch = txn.batch();
    for (final user in users) {
      batch.insert('users', user.toMap());
    }
    await batch.commit();
  });
}
```

### Pagination
```dart
Future<List<User>> getUsers({required int limit, required int offset}) async {
  final db = await _dbService.database;
  return db.query(
    'users',
    limit: limit,
    offset: offset,
    orderBy: 'created_at DESC',
  ).then((maps) => maps.map((m) => User.fromMap(m)).toList());
}
```

## Migration & Schema Changes

### Version Control
```dart
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  // v1 → v2: Add avatar column
  if (oldVersion < 2) {
    await db.execute('ALTER TABLE users ADD COLUMN avatar TEXT');
  }
  
  // v2 → v3: Add phone column
  if (oldVersion < 3) {
    await db.execute('ALTER TABLE users ADD COLUMN phone TEXT');
  }
}
```

### Data Cleanup
```dart
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    // Remove outdated data
    await db.delete('cache');
    
    // Then add new schema
    await db.execute('ALTER TABLE users ADD COLUMN last_login TEXT');
  }
}
```

## Testing

### Mock Storage
```dart
class MockPreferencesService implements PreferencesService {
  final Map<String, dynamic> _data = {};

  @override
  String? get authToken => _data['auth_token'];

  @override
  Future<void> setAuthToken(String token) async {
    _data['auth_token'] = token;
  }
}
```

### In-Memory Database for Tests
```dart
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

setUp(() {
  databaseFactory = databaseFactoryFfi;
});

test('insert user', () async {
  final db = await openDatabase(inMemoryDatabasePath);
  // Test operations
  await db.close();
});
```

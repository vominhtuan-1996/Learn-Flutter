import 'package:sqflite/sqflite.dart';
import 'package:learnflutter/db/sqlite/db_sqlite_helper.dart';
import 'package:learnflutter/db/models/user_model.dart';

/// UserDatabase - Tầng Data Access cho dữ liệu user
///
/// Lớp này đóng vai trò Repository Pattern, trung gian giữa Business Logic
/// và SQLite database. Nó cung cấp các phương thức CRUD (Create, Read, Update, Delete).
/// Tất cả truy vấn database đều đi qua lớp này.
///
/// Tính năng:
/// - Quản lý schema users table
/// - CRUD operations với error handling
/// - Search và filter users
/// - Query statistics
///
/// Data flow: Business Logic → UserDatabase → SQLite → UserModel
class UserDatabase {
  static const String tableName = 'users';

  /// SQL schema cho bảng users
  ///
  /// Bảng này lưu trữ thông tin user với các field:
  /// - id: Primary key auto-increment
  /// - email: UNIQUE, để prevent duplicate accounts
  /// - password: Nên hash trước khi lưu (hiện tại plain text - cần fix)
  /// - isActive: Default 1, user có thể bị deactivate
  /// - Timestamps: createdAt (required), updatedAt, lastLogin (optional)
  static const String createTableSql = '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      fullName TEXT,
      phone TEXT,
      avatar TEXT,
      token TEXT,
      isActive INTEGER DEFAULT 1,
      createdAt TEXT NOT NULL,
      updatedAt TEXT,
      lastLogin TEXT
    )
  ''';

  final DbSqliteHelper _dbHelper = DbSqliteHelper();

  /// initializeTable - Tạo users table trong database.
  ///
  /// Phương thức này được gọi lần đầu khi database được khởi tạo.
  /// Nó execute SQL command để tạo bảng users nếu chưa tồn tại.
  Future<void> initializeTable(Database db) async {
    await db.execute(createTableSql);
  }

  /// insertUser - Thêm user mới vào database.
  ///
  /// Phương thức này được sử dụng khi user register account mới.
  /// Nó insert UserModel vào database và trả về ID của user mới.
  /// Nếu email đã tồn tại (UNIQUE constraint), nó sẽ throw exception.
  ///
  /// Exception: 'Error inserting user' nếu insert thất bại
  Future<int> insertUser(UserModel user) async {
    try {
      final db = await _dbHelper.database;
      return await db.insert(
        tableName,
        user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Error inserting user: $e');
    }
  }

  /// getUserByEmail - Lấy user từ database bằng email.
  ///
  /// Phương thức này được dùng khi login để tìm user bằng email.
  /// Query trả về null nếu email không tồn tại.
  ///
  /// Exception: 'Error getting user by email' nếu query thất bại
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        tableName,
        where: 'email = ?',
        whereArgs: [email],
      );
      if (result.isNotEmpty) {
        return UserModel.fromJson(result.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting user by email: $e');
    }
  }

  /// getUserById - Lấy user từ database bằng ID.
  ///
  /// Phương thức này dùng khi cần lấy thông tin user từ ID.
  /// Query trả về null nếu ID không tồn tại.
  ///
  /// Exception: 'Error getting user by id' nếu query thất bại
  Future<UserModel?> getUserById(int id) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        return UserModel.fromJson(result.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting user by id: $e');
    }
  }

  /// getAllUsers - Lấy tất cả users từ database.
  ///
  /// Trả về List<UserModel> bao gồm tất cả users (active và inactive).
  /// Dùng cho admin dashboard hoặc analytics.
  ///
  /// Exception: 'Error getting all users' nếu query thất bại
  Future<List<UserModel>> getAllUsers() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(tableName);
      return result.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error getting all users: $e');
    }
  }

  /// Get active users
  Future<List<UserModel>> getActiveUsers() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        tableName,
        where: 'isActive = ?',
        whereArgs: [1],
      );
      return result.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error getting active users: $e');
    }
  }

  /// updateUser - Cập nhật thông tin user.
  ///
  /// Phương thức này update tất cả fields của user (except id).
  /// Nó tự động set updatedAt timestamp.
  /// Trả về số rows bị ảnh hưởng (thường là 1).
  ///
  /// Exception: 'Error updating user' nếu update thất bại
  Future<int> updateUser(UserModel user) async {
    try {
      final db = await _dbHelper.database;
      final updatedUser = user.copyWith(
        updatedAt: DateTime.now(),
      );
      return await db.update(
        tableName,
        updatedUser.toJson(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  /// updateLastLogin - Cập nhật thời gian login cuối cùng.
  ///
  /// Phương thức này được gọi sau khi user login thành công.
  /// Nó update lastLogin và updatedAt timestamp.
  ///
  /// Exception: 'Error updating last login' nếu update thất bại
  Future<int> updateLastLogin(int userId) async {
    try {
      final db = await _dbHelper.database;
      return await db.update(
        tableName,
        {
          'lastLogin': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      throw Exception('Error updating last login: $e');
    }
  }

  /// Update token
  Future<int> updateToken(int userId, String token) async {
    try {
      final db = await _dbHelper.database;
      return await db.update(
        tableName,
        {
          'token': token,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      throw Exception('Error updating token: $e');
    }
  }

  /// Delete user
  Future<int> deleteUser(int id) async {
    try {
      final db = await _dbHelper.database;
      return await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  /// Deactivate user
  Future<int> deactivateUser(int id) async {
    try {
      final db = await _dbHelper.database;
      return await db.update(
        tableName,
        {
          'isActive': 0,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Error deactivating user: $e');
    }
  }

  /// Activate user
  Future<int> activateUser(int id) async {
    try {
      final db = await _dbHelper.database;
      return await db.update(
        tableName,
        {
          'isActive': 1,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Error activating user: $e');
    }
  }

  /// Check user exists
  Future<bool> userExists(String email) async {
    try {
      final user = await getUserByEmail(email);
      return user != null;
    } catch (e) {
      return false;
    }
  }

  /// Get total user count
  Future<int> getUserCount() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('Error getting user count: $e');
    }
  }

  /// Clear all users
  Future<int> clearAllUsers() async {
    try {
      final db = await _dbHelper.database;
      return await db.delete(tableName);
    } catch (e) {
      throw Exception('Error clearing users: $e');
    }
  }

  /// Search users by keyword
  Future<List<UserModel>> searchUsers(String keyword) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        tableName,
        where: 'email LIKE ? OR fullName LIKE ?',
        whereArgs: ['%$keyword%', '%$keyword%'],
      );
      return result.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error searching users: $e');
    }
  }
}

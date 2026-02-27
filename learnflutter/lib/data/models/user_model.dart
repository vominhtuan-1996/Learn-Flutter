import 'package:equatable/equatable.dart';

/// UserModel - Entity của Data Layer
///
/// Model này đại diện cho một user trong hệ thống. Nó được sử dụng để:
/// 1. Lưu trữ dữ liệu user từ database vào memory
/// 2. Serialize/deserialize dữ liệu khi ghi vào hoặc đọc từ database
/// 3. Truyền dữ liệu giữa các layer (Data → Business Logic → Presentation)
///
/// Extends Equatable để so sánh hai UserModel bằng giá trị thay vì reference.
class UserModel extends Equatable {
  final int? id;
  final String email;
  final String password;
  final String? fullName;
  final String? phone;
  final String? avatar;
  final String? token;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLogin;

  const UserModel({
    this.id,
    required this.email,
    required this.password,
    this.fullName,
    this.phone,
    this.avatar,
    this.token,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.lastLogin,
  });

  /// toJson - Chuyển đổi UserModel thành Map để lưu vào database.
  ///
  /// Phương thức này được gọi khi cần lưu user vào SQLite.
  /// Nó chuyển đổi tất cả các field thành format mà database có thể lưu trữ.
  /// DateTime được chuyển thành ISO 8601 string, boolean được chuyển thành 0/1.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'fullName': fullName,
      'phone': phone,
      'avatar': avatar,
      'token': token,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  /// fromJson - Tạo UserModel từ dữ liệu Map lấy từ database
  ///
  /// Factory constructor này được sử dụng khi đọc user từ SQLite.
  /// Nó chuyển đổi dữ liệu từ format database (Map) thành UserModel object.
  /// DateTime được parse từ ISO 8601 string, boolean được convert từ 0/1.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      password: json['password'],
      fullName: json['fullName'],
      phone: json['phone'],
      avatar: json['avatar'],
      token: json['token'],
      isActive: json['isActive'] == 1,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
    );
  }

  /// copyWith - Tạo bản copy của UserModel với một số field được cập nhật.
  ///
  /// Phương thức này cung cấp immutability cho UserModel. Thay vì thay đổi
  /// object hiện tại, nó tạo một object mới với các thay đổi cần thiết.
  /// Nếu field không được cung cấp, giá trị cũ sẽ được sử dụng.
  UserModel copyWith({
    int? id,
    String? email,
    String? password,
    String? fullName,
    String? phone,
    String? avatar,
    String? token,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      token: token ?? this.token,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        password,
        fullName,
        phone,
        avatar,
        token,
        isActive,
        createdAt,
        updatedAt,
        lastLogin,
      ];
}

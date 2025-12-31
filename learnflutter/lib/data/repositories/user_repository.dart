import 'package:learnflutter/core/network/api_client.dart';
import 'package:learnflutter/db/models/user_model.dart';

/// UserRepository - Wrapper repository to interact with user-related API endpoints
///
/// Responsibilities:
/// - Provide high-level methods for authentication and user profile
/// - Map API responses to `UserModel`
/// - Manage auth token via `ApiClient`
class UserRepository {
  UserRepository._internal();

  static final UserRepository instance = UserRepository._internal();

  final ApiClient _api = ApiClient.instance;

  /// Login with email + password. On success sets auth token in ApiClient.
  Future<UserModel> login({required String email, required String password}) async {
    final resp = await _api.post('/auth/login', data: {'email': email, 'password': password});

    // resp expected format: { user: {...}, token: '...', accessToken: '...' }
    final token = resp['token'] ?? resp['accessToken'];
    if (token != null && token is String && token.isNotEmpty) {
      _api.setAuthToken(token);
    }

    final userJson = resp['user'] ?? resp;
    return UserModel.fromJson(Map<String, dynamic>.from(userJson));
  }

  /// Register a new user. Returns created UserModel and sets token if provided.
  Future<UserModel> register(Map<String, dynamic> payload) async {
    final resp = await _api.post('/auth/register', data: payload);
    final token = resp['token'] ?? resp['accessToken'];
    if (token != null && token is String && token.isNotEmpty) {
      _api.setAuthToken(token);
    }
    final userJson = resp['user'] ?? resp;
    return UserModel.fromJson(Map<String, dynamic>.from(userJson));
  }

  /// Fetch user profile by id
  Future<UserModel> getProfile(int id) async {
    final resp = await _api.get('/users/$id');
    return UserModel.fromJson(Map<String, dynamic>.from(resp));
  }

  /// Update user profile
  Future<UserModel> updateProfile(int id, Map<String, dynamic> payload) async {
    final resp = await _api.put('/users/$id', data: payload);
    return UserModel.fromJson(Map<String, dynamic>.from(resp));
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {}
    _api.clearAuthToken();
  }
}

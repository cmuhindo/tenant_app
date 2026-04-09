import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/user.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final _storage = const FlutterSecureStorage();
  final _dio = Dio(BaseOptions(baseUrl: 'https://rentcom.net/api'));

  AuthNotifier() : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
        'device_name': 'flutter_app',
      });

      final token = response.data['token'];
      final userData = User.fromJson(response.data['user']);

      await _storage.write(key: 'auth_token', value: token);
      state = state.copyWith(
        isLoading: false,
        user: userData,
        isAuthenticated: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    state = AuthState();
  }
}

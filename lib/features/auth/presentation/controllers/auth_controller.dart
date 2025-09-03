import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/network/dio_client.dart';

class AuthState {
  final String name;
  final String email;
  final String password;
  final bool isLoading;
  final String? error;
  final bool loginSuccess;
  final bool registerSuccess;

  AuthState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.error,
    this.loginSuccess = false,
    this.registerSuccess = false,
  });

  AuthState copyWith({
    String? name,
    String? email,
    String? password,
    bool? isLoading,
    String? error,
    bool? loginSuccess,
    bool? registerSuccess,
  }) {
    return AuthState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      loginSuccess: loginSuccess ?? this.loginSuccess,
      registerSuccess: registerSuccess ?? this.registerSuccess,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final AuthStorage authStorage;
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onRegisterSuccess;

  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.authStorage,
    this.onLoginSuccess,
    this.onRegisterSuccess,
  }) : super(AuthState());

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setEmail(String email) {
    state = state.copyWith(email: email);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password);
  }

  Future<void> login() async {
    if (state.email.isEmpty || state.password.isEmpty) {
      state = state.copyWith(error: 'Please fill in all fields');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await loginUseCase.execute(state.email, state.password);
      await authStorage.saveTokens(response.accessToken, response.refreshToken);
      state = state.copyWith(isLoading: false, loginSuccess: true);
      onLoginSuccess?.call();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register() async {
    if (state.name.isEmpty || state.email.isEmpty || state.password.isEmpty) {
      state = state.copyWith(error: 'Please fill in all fields');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await registerUseCase.execute(
        state.name,
        state.email,
        state.password,
      );
      // After successful registration, auto-login with same credentials
      final loginResponse = await loginUseCase.execute(
        state.email,
        state.password,
      );
      await authStorage.saveTokens(
        loginResponse.accessToken,
        loginResponse.refreshToken,
      );
      state = state.copyWith(isLoading: false, loginSuccess: true);
      print('Registration and auto-login successful: ${response.message}');
      onLoginSuccess?.call();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void loginWithSocial(String provider) {
    // Implement OAuth login
    print('Iniciando sesión con $provider');
  }

  void registerWithSocial(String provider) {
    // Implement OAuth register
    print('Registrándose con $provider');
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSuccess() {
    state = state.copyWith(loginSuccess: false, registerSuccess: false);
  }
}

// Providers
final dioClientProvider = Provider((ref) => DioClient());

final authRemoteDataSourceProvider = Provider(
  (ref) => AuthRemoteDataSource(ref.watch(dioClientProvider)),
);

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(ref.watch(authRemoteDataSourceProvider)),
);

final loginUseCaseProvider = Provider(
  (ref) => LoginUseCase(ref.watch(authRepositoryProvider)),
);

final registerUseCaseProvider = Provider(
  (ref) => RegisterUseCase(ref.watch(authRepositoryProvider)),
);

final authStorageProvider = Provider((ref) => AuthStorage());

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(
    loginUseCase: ref.watch(loginUseCaseProvider),
    registerUseCase: ref.watch(registerUseCaseProvider),
    authStorage: ref.watch(authStorageProvider),
  ),
);

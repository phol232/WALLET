import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/auth_models.dart';

class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepository(this.remoteDataSource);

  Future<LoginResponse> login(String email, String password) async {
    final request = LoginRequest(email: email, password: password);
    return await remoteDataSource.login(request);
  }

  Future<RegisterResponse> register(
    String fullname,
    String email,
    String password,
  ) async {
    final request = RegisterRequest(
      fullname: fullname,
      email: email,
      password: password,
    );
    return await remoteDataSource.register(request);
  }
}

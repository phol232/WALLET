import '../repositories/auth_repository.dart';
import '../../data/models/auth_models.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<LoginResponse> execute(String email, String password) async {
    return await repository.login(email, password);
  }
}

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<RegisterResponse> execute(
    String fullname,
    String email,
    String password,
  ) async {
    return await repository.register(fullname, email, password);
  }
}

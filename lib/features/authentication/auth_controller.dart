import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple/repositories/auth_repository.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

final authControllerProvider =
StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(ref.read(authRepositoryProvider));
});

class AuthController extends StateNotifier<bool> {
  AuthController(this._repository) : super(false);

  final AuthRepository _repository;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = true;

    try {
      await _repository.login(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('User not found');

        case 'wrong-password':
          throw Exception('Incorrect password');

        case 'invalid-credential':
          throw Exception('Invalid email or password');

        default:
          throw Exception(e.message ?? 'Login failed');
      }
    } finally {
      state = false;
    }
  }

  Future<void> logout() {
    return _repository.logout();
  }
}
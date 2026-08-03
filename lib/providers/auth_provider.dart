import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});
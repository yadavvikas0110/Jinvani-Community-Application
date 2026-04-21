import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../models/auth_user.dart';

class AuthState {
  final bool initializing;
  final AuthUser? user;
  const AuthState({this.initializing = true, this.user});

  bool get isAuthenticated => user != null;

  AuthState copyWith({bool? initializing, AuthUser? user, bool clearUser = false}) =>
      AuthState(
        initializing: initializing ?? this.initializing,
        user: clearUser ? null : (user ?? this.user),
      );
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    _bootstrap();
    return const AuthState();
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> _bootstrap() async {
    try {
      final user = await _repo.me();
      state = AuthState(initializing: false, user: user);
    } catch (_) {
      state = const AuthState(initializing: false);
    }
  }

  void setUser(AuthUser user) {
    state = state.copyWith(initializing: false, user: user);
  }

  Future<void> logout() async {
    await _repo.logout();
    state = state.copyWith(clearUser: true, initializing: false);
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

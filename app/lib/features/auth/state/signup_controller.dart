import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupDraft {
  final String name;
  final String email;
  final String phone;
  final String? signupToken;
  final List<String> roles;

  const SignupDraft({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.signupToken,
    this.roles = const [],
  });

  SignupDraft copyWith({
    String? name,
    String? email,
    String? phone,
    String? signupToken,
    List<String>? roles,
  }) =>
      SignupDraft(
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        signupToken: signupToken ?? this.signupToken,
        roles: roles ?? this.roles,
      );
}

class SignupDraftController extends Notifier<SignupDraft> {
  @override
  SignupDraft build() => const SignupDraft();

  void setDetails({required String name, required String email, required String phone}) {
    state = state.copyWith(name: name, email: email, phone: phone);
  }

  void setSignupToken(String token) => state = state.copyWith(signupToken: token);
  void setRoles(List<String> roles) => state = state.copyWith(roles: roles);
  void reset() => state = const SignupDraft();
}

final signupDraftProvider =
    NotifierProvider<SignupDraftController, SignupDraft>(SignupDraftController.new);

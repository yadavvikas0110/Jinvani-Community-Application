import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordDraft {
  final String identifier;
  final String phone;
  final String? resetToken;

  const ForgotPasswordDraft({
    this.identifier = '',
    this.phone = '',
    this.resetToken,
  });

  ForgotPasswordDraft copyWith({
    String? identifier,
    String? phone,
    String? resetToken,
  }) =>
      ForgotPasswordDraft(
        identifier: identifier ?? this.identifier,
        phone: phone ?? this.phone,
        resetToken: resetToken ?? this.resetToken,
      );
}

class ForgotPasswordDraftController extends Notifier<ForgotPasswordDraft> {
  @override
  ForgotPasswordDraft build() => const ForgotPasswordDraft();

  void setIdentifier({required String identifier, required String phone}) {
    state = state.copyWith(identifier: identifier, phone: phone);
  }

  void setResetToken(String token) => state = state.copyWith(resetToken: token);
  void reset() => state = const ForgotPasswordDraft();
}

final forgotPasswordDraftProvider =
    NotifierProvider<ForgotPasswordDraftController, ForgotPasswordDraft>(
        ForgotPasswordDraftController.new);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/support_repository.dart';
import '../models/support_models.dart';

class SupportSubmitState {
  final bool submitting;
  final String? error;
  final SupportTicket? lastTicket;
  final FeedbackSubmission? lastFeedback;

  const SupportSubmitState({
    this.submitting = false,
    this.error,
    this.lastTicket,
    this.lastFeedback,
  });

  SupportSubmitState copyWith({
    bool? submitting,
    String? error,
    SupportTicket? lastTicket,
    FeedbackSubmission? lastFeedback,
    bool clearError = false,
  }) {
    return SupportSubmitState(
      submitting: submitting ?? this.submitting,
      error: clearError ? null : (error ?? this.error),
      lastTicket: lastTicket ?? this.lastTicket,
      lastFeedback: lastFeedback ?? this.lastFeedback,
    );
  }
}

class SupportController extends Notifier<SupportSubmitState> {
  @override
  SupportSubmitState build() => const SupportSubmitState();

  Future<SupportTicket?> submitTicket({
    required String subject,
    required String description,
  }) async {
    state = state.copyWith(submitting: true, clearError: true);
    try {
      final ticket = await ref.read(supportRepositoryProvider).createTicket(
            subject: subject,
            description: description,
          );
      state = state.copyWith(submitting: false, lastTicket: ticket);
      return ticket;
    } catch (e) {
      state = state.copyWith(submitting: false, error: e.toString());
      return null;
    }
  }

  Future<FeedbackSubmission?> submitFeedback({
    required String subject,
    required String description,
  }) async {
    state = state.copyWith(submitting: true, clearError: true);
    try {
      final fb = await ref.read(supportRepositoryProvider).submitFeedback(
            subject: subject,
            description: description,
          );
      state = state.copyWith(submitting: false, lastFeedback: fb);
      return fb;
    } catch (e) {
      state = state.copyWith(submitting: false, error: e.toString());
      return null;
    }
  }
}

final supportControllerProvider =
    NotifierProvider<SupportController, SupportSubmitState>(
        SupportController.new);

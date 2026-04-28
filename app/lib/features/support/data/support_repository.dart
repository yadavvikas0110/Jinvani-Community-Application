import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../models/support_models.dart';

class SupportRepository {
  SupportRepository(this._dio);
  final Dio _dio;

  static const _base = '/support';

  Future<SupportTicket> createTicket({
    required String subject,
    required String description,
  }) async {
    final r = await _dio.post(
      '$_base/tickets',
      data: {'subject': subject, 'description': description},
    );
    return SupportTicket.fromJson(r.data['ticket'] as Map<String, dynamic>);
  }

  Future<List<SupportTicket>> listMyTickets() async {
    final r = await _dio.get('$_base/tickets');
    final raw = (r.data['tickets'] as List?) ?? const [];
    return raw
        .map((t) => SupportTicket.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  Future<FeedbackSubmission> submitFeedback({
    required String subject,
    required String description,
  }) async {
    final r = await _dio.post(
      '$_base/feedback',
      data: {'subject': subject, 'description': description},
    );
    return FeedbackSubmission.fromJson(
        r.data['feedback'] as Map<String, dynamic>);
  }
}

final supportRepositoryProvider = Provider<SupportRepository>(
  (ref) => SupportRepository(ref.watch(apiClientProvider)),
);

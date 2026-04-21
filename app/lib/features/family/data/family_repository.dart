import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../models/family.dart';

class FamilyRepository {
  FamilyRepository(this._dio);
  final Dio _dio;

  static const _base = '/users/me/family';

  Future<FamilySnapshot> getFamily() async {
    final r = await _dio.get(_base);
    return FamilySnapshot.fromJson(r.data as Map<String, dynamic>);
  }

  Future<InviteResult> invite({
    required String name,
    required String relation,
    String? phone,
    String? email,
  }) async {
    final r = await _dio.post('$_base/invite', data: {
      'name': name,
      'relation': relation,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (email != null && email.isNotEmpty) 'email': email,
    });
    return InviteResult.fromJson(r.data as Map<String, dynamic>);
  }

  Future<InviteResult> sendExternalInvite({
    required String name,
    required String relation,
    String? phone,
    String? email,
  }) async {
    final r = await _dio.post('$_base/invite/external', data: {
      'name': name,
      'relation': relation,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (email != null && email.isNotEmpty) 'email': email,
    });
    return InviteResult.fromJson(r.data as Map<String, dynamic>);
  }

  Future<void> accept(String invitationId) =>
      _dio.post('$_base/requests/$invitationId/accept');

  Future<void> reject(String invitationId) =>
      _dio.post('$_base/requests/$invitationId/reject');

  Future<void> cancel(String invitationId) =>
      _dio.post('$_base/requests/$invitationId/cancel');

  Future<void> removeMember(String memberId) =>
      _dio.delete('$_base/members/$memberId');
}

final familyRepositoryProvider =
    Provider<FamilyRepository>((ref) => FamilyRepository(ref.watch(apiClientProvider)));

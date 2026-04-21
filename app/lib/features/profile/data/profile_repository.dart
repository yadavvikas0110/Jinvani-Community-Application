import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../models/profile.dart';

class ProfileRepository {
  ProfileRepository(this._dio);
  final Dio _dio;

  static const _base = '/users/me/profile';

  Future<Profile> getProfile() async {
    final r = await _dio.get(_base);
    return Profile.fromJson(r.data['profile'] as Map<String, dynamic>);
  }

  Future<Profile> updatePersonal(Map<String, dynamic> data) async {
    final r = await _dio.put('$_base/personal', data: data);
    return Profile.fromJson(r.data['profile'] as Map<String, dynamic>);
  }

  Future<Profile> addEducation(Map<String, dynamic> data) async {
    final r = await _dio.post('$_base/education', data: data);
    return Profile.fromJson(r.data['profile'] as Map<String, dynamic>);
  }

  Future<Profile> updateEducation(String id, Map<String, dynamic> data) async {
    final r = await _dio.put('$_base/education/$id', data: data);
    return Profile.fromJson(r.data['profile'] as Map<String, dynamic>);
  }

  Future<Profile> deleteEducation(String id) async {
    final r = await _dio.delete('$_base/education/$id');
    return Profile.fromJson(r.data['profile'] as Map<String, dynamic>);
  }

  Future<Profile> updateWork(Map<String, dynamic> data) async {
    final r = await _dio.put('$_base/work', data: data);
    return Profile.fromJson(r.data['profile'] as Map<String, dynamic>);
  }

  Future<Profile> updateEconomic(Map<String, dynamic> data) async {
    final r = await _dio.put('$_base/economic', data: data);
    return Profile.fromJson(r.data['profile'] as Map<String, dynamic>);
  }

  Future<Profile> updateBio(Map<String, dynamic> data) async {
    final r = await _dio.put('$_base/bio', data: data);
    return Profile.fromJson(r.data['profile'] as Map<String, dynamic>);
  }

  Future<Profile> updateGoals(List<String> goals) async {
    final r = await _dio.put('$_base/goals', data: {'goals': goals});
    return Profile.fromJson(r.data['profile'] as Map<String, dynamic>);
  }

  Future<String> uploadFile(String filePath, String filename) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: filename),
    });
    final r = await _dio.post('$_base/upload', data: form);
    return r.data['url'] as String;
  }
}

final profileRepositoryProvider =
    Provider<ProfileRepository>((ref) => ProfileRepository(ref.watch(apiClientProvider)));

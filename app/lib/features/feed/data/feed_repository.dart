import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../models/feed.dart';

class FeedRepository {
  FeedRepository(this._dio);
  final Dio _dio;

  static const _base = '/feed';

  Future<FeedPage> list({required String type, String? cursor, int limit = 20}) async {
    final r = await _dio.get(_base, queryParameters: {
      'type': type,
      'limit': limit,
      if (cursor != null) 'cursor': cursor,
    });
    return FeedPage.fromJson(r.data as Map<String, dynamic>);
  }

  Future<FeedPost> getPost(String id) async {
    final r = await _dio.get('$_base/$id');
    return FeedPost.fromJson(r.data as Map<String, dynamic>);
  }

  Future<FeedPost> createPost({
    required String type,
    String? title,
    required String body,
    String? imageUrl,
  }) async {
    final r = await _dio.post(_base, data: {
      'type': type,
      if (title != null && title.isNotEmpty) 'title': title,
      'body': body,
      if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
    });
    return FeedPost.fromJson(r.data as Map<String, dynamic>);
  }

  Future<void> deletePost(String id) => _dio.delete('$_base/$id');

  Future<(bool liked, int count)> toggleLike(String id) async {
    final r = await _dio.post('$_base/$id/like');
    final data = r.data as Map<String, dynamic>;
    return (data['liked'] == true, (data['likesCount'] as num?)?.toInt() ?? 0);
  }

  Future<bool> toggleSave(String id) async {
    final r = await _dio.post('$_base/$id/save');
    return (r.data as Map<String, dynamic>)['saved'] == true;
  }

  Future<List<FeedComment>> listComments(String postId) async {
    final r = await _dio.get('$_base/$postId/comments');
    final items = (r.data['items'] as List? ?? const []);
    return items
        .whereType<Map>()
        .map((e) => FeedComment.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<FeedComment> addComment(String postId, String text) async {
    final r = await _dio.post('$_base/$postId/comments', data: {'text': text});
    return FeedComment.fromJson(r.data as Map<String, dynamic>);
  }

  Future<void> deleteComment(String postId, String commentId) =>
      _dio.delete('$_base/$postId/comments/$commentId');

  Future<String> uploadImage(String path) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(path),
    });
    final r = await _dio.post('$_base/upload', data: form);
    return (r.data as Map<String, dynamic>)['url'] as String;
  }
}

final feedRepositoryProvider =
    Provider<FeedRepository>((ref) => FeedRepository(ref.watch(apiClientProvider)));

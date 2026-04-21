import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/feed_repository.dart';
import '../models/feed.dart';
import 'feed_controller.dart';

class PostDetailState {
  final bool loading;
  final FeedPost? post;
  final List<FeedComment> comments;
  final bool commentsLoading;
  final bool submitting;
  final String? error;

  const PostDetailState({
    this.loading = true,
    this.post,
    this.comments = const [],
    this.commentsLoading = false,
    this.submitting = false,
    this.error,
  });

  PostDetailState copyWith({
    bool? loading,
    FeedPost? post,
    List<FeedComment>? comments,
    bool? commentsLoading,
    bool? submitting,
    String? error,
    bool clearError = false,
  }) =>
      PostDetailState(
        loading: loading ?? this.loading,
        post: post ?? this.post,
        comments: comments ?? this.comments,
        commentsLoading: commentsLoading ?? this.commentsLoading,
        submitting: submitting ?? this.submitting,
        error: clearError ? null : error ?? this.error,
      );
}

class PostDetailController extends Notifier<PostDetailState> {
  PostDetailController(this.postId);
  final String postId;

  late final FeedRepository _repo = ref.read(feedRepositoryProvider);

  @override
  PostDetailState build() {
    _load();
    return const PostDetailState();
  }

  Future<void> _load() async {
    try {
      final post = await _repo.getPost(postId);
      state = state.copyWith(
          loading: false, post: post, commentsLoading: true, clearError: true);
      final comments = await _repo.listComments(postId);
      state = state.copyWith(comments: comments, commentsLoading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, clearError: true);
    await _load();
  }

  void _syncToList(FeedPost post) {
    final notifier = post.isBlog
        ? ref.read(feedBlogsControllerProvider.notifier)
        : ref.read(feedPostsControllerProvider.notifier);
    notifier.updatePost(post);
  }

  Future<void> toggleLike() async {
    final p = state.post;
    if (p == null) return;
    final optimistic = p.copyWith(
      liked: !p.liked,
      likesCount: p.likesCount + (p.liked ? -1 : 1),
    );
    state = state.copyWith(post: optimistic);
    _syncToList(optimistic);
    try {
      final (liked, count) = await _repo.toggleLike(p.id);
      final updated = optimistic.copyWith(liked: liked, likesCount: count);
      state = state.copyWith(post: updated);
      _syncToList(updated);
    } catch (_) {
      state = state.copyWith(post: p);
      _syncToList(p);
    }
  }

  Future<void> toggleSave() async {
    final p = state.post;
    if (p == null) return;
    final optimistic = p.copyWith(saved: !p.saved);
    state = state.copyWith(post: optimistic);
    _syncToList(optimistic);
    try {
      final saved = await _repo.toggleSave(p.id);
      final updated = optimistic.copyWith(saved: saved);
      state = state.copyWith(post: updated);
      _syncToList(updated);
    } catch (_) {
      state = state.copyWith(post: p);
      _syncToList(p);
    }
  }

  Future<void> addComment(String text) async {
    final p = state.post;
    if (p == null || text.trim().isEmpty) return;
    state = state.copyWith(submitting: true);
    try {
      final c = await _repo.addComment(p.id, text.trim());
      final updated = p.copyWith(commentsCount: p.commentsCount + 1);
      state = state.copyWith(
        post: updated,
        comments: [c, ...state.comments],
        submitting: false,
      );
      _syncToList(updated);
    } catch (e) {
      state = state.copyWith(submitting: false, error: e.toString());
    }
  }

  Future<void> deleteComment(String commentId) async {
    final p = state.post;
    if (p == null) return;
    final removed = state.comments.where((c) => c.id != commentId).toList();
    final updated = p.copyWith(
      commentsCount:
          (p.commentsCount - 1).clamp(0, 1 << 30),
    );
    state = state.copyWith(post: updated, comments: removed);
    _syncToList(updated);
    try {
      await _repo.deleteComment(p.id, commentId);
    } catch (_) {
      // rollback
      state = state.copyWith(post: p);
      _syncToList(p);
    }
  }
}

final postDetailControllerProvider =
    NotifierProvider.family<PostDetailController, PostDetailState, String>(
  PostDetailController.new,
);

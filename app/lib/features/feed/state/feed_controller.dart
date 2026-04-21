import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/feed_repository.dart';
import '../models/feed.dart';

class FeedTabState {
  final bool loading;
  final bool loadingMore;
  final List<FeedPost> items;
  final String? nextCursor;
  final String? error;
  const FeedTabState({
    this.loading = false,
    this.loadingMore = false,
    this.items = const [],
    this.nextCursor,
    this.error,
  });

  bool get hasMore => nextCursor != null;

  FeedTabState copyWith({
    bool? loading,
    bool? loadingMore,
    List<FeedPost>? items,
    String? nextCursor,
    String? error,
    bool clearCursor = false,
    bool clearError = false,
  }) =>
      FeedTabState(
        loading: loading ?? this.loading,
        loadingMore: loadingMore ?? this.loadingMore,
        items: items ?? this.items,
        nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
        error: clearError ? null : error ?? this.error,
      );
}

abstract class FeedTabController extends Notifier<FeedTabState> {
  String get type;
  late final FeedRepository _repo = ref.read(feedRepositoryProvider);

  @override
  FeedTabState build() {
    _initialLoad();
    return const FeedTabState(loading: true);
  }

  Future<void> _initialLoad() async {
    try {
      final page = await _repo.list(type: type);
      state = FeedTabState(items: page.items, nextCursor: page.nextCursor);
    } catch (e) {
      state = FeedTabState(error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final page = await _repo.list(type: type);
      state = FeedTabState(items: page.items, nextCursor: page.nextCursor);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.loadingMore || state.nextCursor == null) return;
    state = state.copyWith(loadingMore: true);
    try {
      final page = await _repo.list(type: type, cursor: state.nextCursor);
      state = state.copyWith(
        loadingMore: false,
        items: [...state.items, ...page.items],
        nextCursor: page.nextCursor,
        clearCursor: page.nextCursor == null,
      );
    } catch (e) {
      state = state.copyWith(loadingMore: false, error: e.toString());
    }
  }

  void prependPost(FeedPost post) {
    if (post.type != type) return;
    state = state.copyWith(items: [post, ...state.items]);
  }

  void updatePost(FeedPost post) {
    final idx = state.items.indexWhere((p) => p.id == post.id);
    if (idx == -1) return;
    final next = [...state.items];
    next[idx] = post;
    state = state.copyWith(items: next);
  }

  void removePost(String id) {
    state = state.copyWith(items: state.items.where((p) => p.id != id).toList());
  }

  Future<void> toggleLike(FeedPost post) async {
    final optimistic = post.copyWith(
      liked: !post.liked,
      likesCount: post.likesCount + (post.liked ? -1 : 1),
    );
    updatePost(optimistic);
    try {
      final (liked, count) = await _repo.toggleLike(post.id);
      updatePost(optimistic.copyWith(liked: liked, likesCount: count));
    } catch (_) {
      updatePost(post);
    }
  }

  Future<void> toggleSave(FeedPost post) async {
    final optimistic = post.copyWith(saved: !post.saved);
    updatePost(optimistic);
    try {
      final saved = await _repo.toggleSave(post.id);
      updatePost(optimistic.copyWith(saved: saved));
    } catch (_) {
      updatePost(post);
    }
  }

  Future<void> delete(FeedPost post) async {
    removePost(post.id);
    try {
      await _repo.deletePost(post.id);
    } catch (_) {
      state = state.copyWith(items: [post, ...state.items]);
    }
  }
}

class FeedPostsController extends FeedTabController {
  @override
  String get type => 'post';
}

class FeedBlogsController extends FeedTabController {
  @override
  String get type => 'blog';
}

final feedPostsControllerProvider =
    NotifierProvider<FeedPostsController, FeedTabState>(FeedPostsController.new);

final feedBlogsControllerProvider =
    NotifierProvider<FeedBlogsController, FeedTabState>(FeedBlogsController.new);

class CreatePostController extends Notifier<bool> {
  late final FeedRepository _repo = ref.read(feedRepositoryProvider);

  @override
  bool build() => false;

  Future<FeedPost> submit({
    required String type,
    String? title,
    required String body,
    String? imageUrl,
  }) async {
    state = true;
    try {
      final post = await _repo.createPost(
        type: type,
        title: title,
        body: body,
        imageUrl: imageUrl,
      );
      final notifier = type == 'blog'
          ? ref.read(feedBlogsControllerProvider.notifier)
          : ref.read(feedPostsControllerProvider.notifier);
      notifier.prependPost(post);
      return post;
    } finally {
      state = false;
    }
  }

  Future<String> uploadImage(String path) => _repo.uploadImage(path);
}

final createPostControllerProvider =
    NotifierProvider<CreatePostController, bool>(CreatePostController.new);

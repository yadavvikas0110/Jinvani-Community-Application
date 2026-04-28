import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/state/auth_controller.dart';
import '../../profile/state/profile_controller.dart';
import '../models/feed.dart';
import '../state/post_detail_controller.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _comment = TextEditingController();
  final _commentFocus = FocusNode();

  @override
  void dispose() {
    _comment.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _comment.text.trim();
    if (text.isEmpty) return;
    _comment.clear();
    _commentFocus.unfocus();
    await ref
        .read(postDetailControllerProvider(widget.postId).notifier)
        .addComment(text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postDetailControllerProvider(widget.postId));
    final controller =
        ref.read(postDetailControllerProvider(widget.postId).notifier);
    final myId = ref.watch(authControllerProvider).user?.id;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(state.post?.isBlog == true ? 'Blog' : 'Post',
            style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : state.post == null
              ? Center(
                  child: Text(state.error ?? 'Post not found',
                      style: const TextStyle(color: AppColors.textSecondary)))
              : Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: controller.refresh,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          children: [
                            _PostBody(post: state.post!),
                            const SizedBox(height: 12),
                            _ReactionsBar(
                              post: state.post!,
                              onLike: controller.toggleLike,
                              onSave: controller.toggleSave,
                              onComment: () => _commentFocus.requestFocus(),
                            ),
                            const SizedBox(height: 16),
                            const Text('Comments',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            const SizedBox(height: 8),
                            if (state.commentsLoading)
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                    child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2))),
                              )
                            else if (state.comments.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Text('Be the first to comment',
                                      style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 13)),
                                ),
                              )
                            else
                              ...state.comments.map(
                                (c) => _CommentTile(
                                  comment: c,
                                  canDelete: c.author.id == myId,
                                  onDelete: () => controller.deleteComment(c.id),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    _CommentComposer(
                      controller: _comment,
                      focusNode: _commentFocus,
                      submitting: state.submitting,
                      onSubmit: _submitComment,
                    ),
                  ],
                ),
    );
  }
}

class _PostBody extends StatelessWidget {
  final FeedPost post;
  const _PostBody({required this.post});

  @override
  Widget build(BuildContext context) {
    final a = post.author;
    final subParts = <String>[
      if ((a.role ?? '').isNotEmpty) a.role!,
      if ((a.city ?? '').isNotEmpty) a.city!,
      relativeTime(post.createdAt),
    ];
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE1E3E6)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFEEF0F4),
                  backgroundImage: (a.avatarUrl ?? '').isNotEmpty
                      ? NetworkImage(a.avatarUrl!)
                      : null,
                  child: (a.avatarUrl ?? '').isEmpty
                      ? const Icon(Icons.person,
                          color: AppColors.textMuted, size: 22)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.name,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(subParts.join(' • '),
                          style: const TextStyle(
                              color: Color(0xFFABAFB9), fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
            if (post.title != null && post.title!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(post.title!,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3)),
            ],
            if (post.imageUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(post.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                        height: 180, color: const Color(0xFFEEF0F4))),
              ),
            ],
            const SizedBox(height: 12),
            Text(post.body,
                style: const TextStyle(
                    color: Color(0xFF4C4A53), fontSize: 14, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

class _ReactionsBar extends StatelessWidget {
  final FeedPost post;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback onComment;

  const _ReactionsBar({
    required this.post,
    required this.onLike,
    required this.onSave,
    required this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE1E3E6)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            _action(
              icon: post.liked ? Icons.favorite : Icons.favorite_border,
              color: post.liked
                  ? const Color(0xFFE5484D)
                  : const Color(0xFF5C5965),
              label: '${post.likesCount}',
              onTap: onLike,
            ),
            const SizedBox(width: 16),
            _action(
              icon: Icons.chat_bubble_outline,
              color: const Color(0xFF908D99),
              label: '${post.commentsCount}',
              onTap: onComment,
            ),
            const Spacer(),
            InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: onSave,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  post.saved ? Icons.bookmark : Icons.bookmark_border,
                  size: 20,
                  color: post.saved
                      ? AppColors.accent
                      : const Color(0xFF908D99),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _action({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final FeedComment comment;
  final bool canDelete;
  final VoidCallback onDelete;
  const _CommentTile({
    required this.comment,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final a = comment.author;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFFEEF0F4),
            backgroundImage: (a.avatarUrl ?? '').isNotEmpty
                ? NetworkImage(a.avatarUrl!)
                : null,
            child: (a.avatarUrl ?? '').isEmpty
                ? const Icon(Icons.person,
                    color: AppColors.textMuted, size: 16)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE7E5E5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(a.name,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                      ),
                      Text(relativeTime(comment.createdAt),
                          style: const TextStyle(
                              color: Color(0xFFABAFB9), fontSize: 10)),
                      if (canDelete)
                        InkWell(
                          borderRadius: BorderRadius.circular(4),
                          onTap: onDelete,
                          child: const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(Icons.delete_outline,
                                size: 16, color: AppColors.textMuted),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(comment.text,
                      style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF4C4A53),
                          height: 1.4)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentComposer extends ConsumerWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool submitting;
  final VoidCallback onSubmit;

  const _CommentComposer({
    required this.controller,
    required this.focusNode,
    required this.submitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarUrl = ref.watch(profileControllerProvider).profile?.bio.avatarUrl;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE7E5E5))),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFEEF0F4),
              backgroundImage: (avatarUrl ?? '').isNotEmpty
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: (avatarUrl ?? '').isEmpty
                  ? const Icon(Icons.person,
                      color: AppColors.textMuted, size: 16)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                minLines: 1,
                maxLines: 4,
                maxLength: 1000,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSubmit(),
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFFF4F4F8),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
            IconButton(
              onPressed: submitting ? null : onSubmit,
              icon: submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send, color: AppColors.buttonStart),
            ),
          ],
        ),
      ),
    );
  }
}

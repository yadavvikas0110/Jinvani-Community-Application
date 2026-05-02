import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/feed.dart';

class PostCard extends StatelessWidget {
  final FeedPost post;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onSave;
  final VoidCallback? onDelete;
  final bool isOwn;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onSave,
    this.onDelete,
    this.isOwn = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = post.author;
    final subParts = <String>[
      if ((a.role ?? '').isNotEmpty) a.role!,
      if ((a.city ?? '').isNotEmpty) a.city!,
      relativeTime(post.createdAt),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE1E3E6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFFEEF0F4),
                            backgroundImage: (a.avatarUrl ?? '').isNotEmpty
                                ? NetworkImage(a.avatarUrl!)
                                : null,
                            child: (a.avatarUrl ?? '').isEmpty
                                ? const Icon(Icons.person,
                                    color: AppColors.textMuted, size: 20)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.name,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary)),
                                const SizedBox(height: 2),
                                Text(subParts.join(' • '),
                                    style: const TextStyle(
                                        color: Color(0xFFABAFB9),
                                        fontSize: 10)),
                              ],
                            ),
                          ),
                          if (isOwn && onDelete != null)
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert,
                                  color: AppColors.textMuted, size: 20),
                              onSelected: (v) {
                                if (v == 'delete') onDelete!();
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete',
                                      style:
                                          TextStyle(color: AppColors.danger)),
                                ),
                              ],
                            )
                          else
                            const Icon(Icons.more_vert,
                                color: AppColors.textMuted, size: 20),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (post.imageUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.network(post.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                    color: const Color(0xFFEEF0F4))),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(post.body,
                          style: const TextStyle(
                              color: Color(0xFF4C4A53), fontSize: 12, height: 1.4)),
                    ],
                  ),
                ),
                Container(height: 1, color: const Color(0xFFE7E5E5)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      _PostAction(
                        icon: post.liked ? Icons.favorite : Icons.favorite_border,
                        color: post.liked ? const Color(0xFFE5484D) : const Color(0xFF5C5965),
                        label: '${post.likesCount}',
                        onTap: onLike,
                      ),
                      const SizedBox(width: 16),
                      _PostAction(
                        icon: Icons.chat_bubble_outline,
                        color: const Color(0xFF908D99),
                        label: '${post.commentsCount}',
                        onTap: onComment,
                      ),
                      const SizedBox(width: 16),
                      _PostAction(
                        icon: Icons.share_outlined,
                        color: const Color(0xFF908D99),
                        label: 'Share',
                        onTap: onShare,
                      ),
                      const Spacer(),
                      InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: onSave,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            post.saved ? Icons.bookmark : Icons.bookmark_border,
                            size: 18,
                            color: post.saved
                                ? AppColors.accent
                                : const Color(0xFF908D99),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PostAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _PostAction({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 10, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

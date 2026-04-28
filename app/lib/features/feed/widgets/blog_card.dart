import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/feed.dart';

class BlogCard extends StatelessWidget {
  final FeedPost post;
  final VoidCallback onTap;
  final VoidCallback onSave;

  const BlogCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final a = post.author;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        shadowColor: const Color(0x1410281C),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.imageUrl != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(post.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                                color: const Color(0xFFEEF0F4),
                                child: const Icon(Icons.image_outlined,
                                    color: AppColors.textMuted, size: 48))),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              post.title ?? 'Untitled',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  height: 1.25),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_outward,
                              size: 18, color: AppColors.textPrimary),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        post.body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0xFF667085),
                            fontSize: 14,
                            height: 1.4),
                      ),
                    ],
                  ),
                ),
                Container(height: 1, color: const Color(0xFFE7E5E5)),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
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
                            Text(relativeTime(post.createdAt),
                                style: const TextStyle(
                                    color: Color(0xFF9A9DA3), fontSize: 10)),
                          ],
                        ),
                      ),
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

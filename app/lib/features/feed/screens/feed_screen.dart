import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/state/auth_controller.dart';
import '../../profile/state/profile_controller.dart';
import '../models/feed.dart';
import '../state/feed_controller.dart';
import '../widgets/blog_card.dart';
import '../widgets/composer_pill.dart';
import '../widgets/post_card.dart';
import 'create_post_screen.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _openComposer() async {
    final isBlog = _tabs.index == 1;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreatePostScreen(type: isBlog ? 'blog' : 'post'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileControllerProvider).profile;
    final avatarUrl = profile?.bio.avatarUrl;
    final isBlog = _tabs.index == 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16,
        title: const Text('Jinvani',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline,
                color: AppColors.textPrimary),
            onPressed: () {},
            tooltip: 'Saved',
          ),
          _LogoutButton(),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabs,
            labelColor: const Color(0xFF3D629A),
            unselectedLabelColor: const Color(0xFF6B7280),
            indicatorColor: const Color(0xFF3D629A),
            indicatorWeight: 2,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            tabs: const [
              Tab(text: 'Community Feed'),
              Tab(text: 'Blogs & Articles'),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: ComposerPill(
              avatarUrl: avatarUrl,
              hint: isBlog ? 'Write a blog or article...' : 'Share your thoughts',
              onTap: _openComposer,
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text('Quick View',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                ),
                _LatestChip(),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: const [
                _FeedList(type: 'post'),
                _FeedList(type: 'blog'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.logout, color: AppColors.textPrimary),
      onPressed: () async {
        await ref.read(authControllerProvider.notifier).logout();
        if (context.mounted) context.go('/login');
      },
    );
  }
}

class _LatestChip extends StatelessWidget {
  const _LatestChip();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFAB110),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('Latest',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w500)),
          SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.black),
        ],
      ),
    );
  }
}

class _FeedList extends ConsumerStatefulWidget {
  final String type;
  const _FeedList({required this.type});

  @override
  ConsumerState<_FeedList> createState() => _FeedListState();
}

class _FeedListState extends ConsumerState<_FeedList>
    with AutomaticKeepAliveClientMixin {
  final _scroll = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 300) {
        _notifier().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  FeedTabController _notifier() {
    return widget.type == 'blog'
        ? ref.read(feedBlogsControllerProvider.notifier)
        : ref.read(feedPostsControllerProvider.notifier);
  }

  FeedTabState _watch() {
    return widget.type == 'blog'
        ? ref.watch(feedBlogsControllerProvider)
        : ref.watch(feedPostsControllerProvider);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = _watch();
    final myId = ref.watch(authControllerProvider).user?.id;

    if (state.loading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _notifier().refresh,
      child: state.items.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Icon(Icons.forum_outlined, size: 64, color: AppColors.textMuted),
                SizedBox(height: 12),
                Center(
                  child: Text('Nothing here yet',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              ],
            )
          : ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: state.items.length + (state.hasMore ? 1 : 0),
              itemBuilder: (_, i) {
                if (i >= state.items.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                        child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))),
                  );
                }
                final p = state.items[i];
                final isOwn = p.author.id == myId;
                if (p.isBlog) {
                  return BlogCard(
                    post: p,
                    onTap: () => context.push('/feed/${p.id}'),
                    onSave: () => _notifier().toggleSave(p),
                  );
                }
                return PostCard(
                  post: p,
                  isOwn: isOwn,
                  onTap: () => context.push('/feed/${p.id}'),
                  onLike: () => _notifier().toggleLike(p),
                  onComment: () => context.push('/feed/${p.id}'),
                  onShare: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share coming soon')),
                    );
                  },
                  onSave: () => _notifier().toggleSave(p),
                  onDelete: () => _confirmDelete(p),
                );
              },
            ),
    );
  }

  Future<void> _confirmDelete(FeedPost post) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete post?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (ok == true) await _notifier().delete(post);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../feed/models/feed.dart';
import '../feed/state/feed_controller.dart';
import '../profile/state/profile_controller.dart';

const _bg = Color(0xFFF7F7F6);
const _cardBorder = Color(0xFFE1E3E6);
const _cardDivider = Color(0xFFE7E5E5);
const _textDark = Color(0xFF121A2C);
const _textBody = Color(0xFF4C4A53);
const _textMuted = Color(0xFF888E9B);
const _textSubtle = Color(0xFFABAFB9);
const _linkBlue = Color(0xFF395A91);
const _applyBlue = Color(0xFF2E5187);
const _pillBg = Color(0xFFE9EAF2);
const _pillText = Color(0xFF3F4890);
const _likeCountColor = Color(0xFF5C5965);
const _counterMuted = Color(0xFF908D99);
const _searchBg = Color(0xFFF4F4F8);
const _searchHint = Color(0xFF494949);
const _profileGradStart = Color(0xFF1C427D);
const _profileGradMid = Color(0xFF1B449C);
const _profileGradEnd = Color(0xFF6361E2);
const _amber = Color(0xFFFDB913);
const _amberDeep = Color(0xFFF59E0B);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider).profile;
    final completion = profile?.completion ?? 0;
    final posts = ref.watch(feedPostsControllerProvider).items.take(2).toList();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const _TopSearchBar(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _ProfileCompletionCard(
                completion: completion,
                onTap: () => context.push('/profile'),
              ),
            ),
            const SizedBox(height: 24),
            const _QuickViewTiles(),
            const SizedBox(height: 24),
            _QuickViewPosts(
              posts: posts,
              onViewAll: () => context.push('/feed'),
              onOpen: (id) => context.push('/feed/$id'),
            ),
            const SizedBox(height: 24),
            _RecommendedJobsSection(
              onViewAll: () => context.push('/jobs'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _TopSearchBar extends StatelessWidget {
  const _TopSearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: _searchBg,
          borderRadius: BorderRadius.circular(100),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/common/search.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(_searchHint, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Search here',
                style: TextStyle(
                  color: _searchHint,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCompletionCard extends StatelessWidget {
  final int completion;
  final VoidCallback onTap;
  const _ProfileCompletionCard({required this.completion, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            begin: Alignment(-1, -0.02),
            end: Alignment(1, 0.02),
            colors: [_profileGradStart, _profileGradMid, _profileGradEnd],
            stops: [0.0, 0.49, 1.0],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Profile Completion',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$completion%',
                        style: const TextStyle(
                          color: _amber,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 11),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 6,
                      color: Colors.white.withValues(alpha: 0.2),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (completion / 100).clamp(0.0, 1.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [_amber, _amberDeep],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 11),
                  const Text(
                    'Complete your profile to unlock all features',
                    style: TextStyle(
                      color: _amber,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 13),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/icons/common/arrow_right.svg',
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickViewTiles extends StatelessWidget {
  const _QuickViewTiles();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick View',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _QuickTile(
                icon: 'assets/icons/quickview/job.svg',
                label: 'Job',
                onTap: () => context.push('/jobs'),
              ),
              _QuickTile(
                icon: 'assets/icons/quickview/booking.svg',
                label: 'Booking',
                onTap: () => context.push('/booking'),
              ),
              _QuickTile(
                icon: 'assets/icons/quickview/directory_b.svg',
                label: 'Directory',
                onTap: () {},
              ),
              _QuickTile(
                icon: 'assets/icons/quickview/family.svg',
                label: 'Family',
                onTap: () => context.push('/family'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  const _QuickTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(icon, width: 32, height: 32, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _QuickViewPosts extends StatelessWidget {
  final List<FeedPost> posts;
  final VoidCallback onViewAll;
  final ValueChanged<String> onOpen;
  const _QuickViewPosts({
    required this.posts,
    required this.onViewAll,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Quick View', onViewAll: onViewAll),
          const SizedBox(height: 16),
          if (posts.isEmpty)
            _PreviewPostCard(
              name: 'Priya Shah',
              subtitle: 'Jain Social Worker Mumbai 10 min ago',
              body:
                  'Proud to announce that our community food bank served 500+ families this month! 🙏 Jai Jinendra to all volunteers who made this possible. Together we grow stronger.',
              avatarAsset: 'assets/avatars/avatar1.png',
              likes: 143,
              comments: 143,
              shares: 143,
              liked: true,
              onTap: onViewAll,
            )
          else
            ...posts.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PreviewPostCard(
                  name: p.author.name,
                  subtitle: _formatAuthor(p.author, p.createdAt),
                  body: p.body,
                  avatarAsset: 'assets/avatars/avatar1.png',
                  likes: p.likesCount,
                  comments: p.commentsCount,
                  shares: 0,
                  liked: p.liked,
                  onTap: () => onOpen(p.id),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatAuthor(FeedAuthor a, DateTime createdAt) {
    final parts = <String>[];
    if (a.role != null && a.role!.isNotEmpty) parts.add(a.role!);
    if (a.city != null && a.city!.isNotEmpty) parts.add(a.city!);
    parts.add(_ago(createdAt));
    return parts.join(' ');
  }

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 60) return '${d.inMinutes} min ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;
  const _SectionHeader({required this.title, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        GestureDetector(
          onTap: onViewAll,
          child: const Text(
            'View All',
            style: TextStyle(
              color: _linkBlue,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewPostCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String body;
  final String avatarAsset;
  final int likes;
  final int comments;
  final int shares;
  final bool liked;
  final VoidCallback onTap;
  const _PreviewPostCard({
    required this.name,
    required this.subtitle,
    required this.body,
    required this.avatarAsset,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.liked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: _cardDivider,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _cardBorder),
        ),
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipOval(
                        child: Image.asset(avatarAsset, width: 40, height: 40, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: _textDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: _textSubtle,
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RotatedBox(
                        quarterTurns: 1,
                        child: SvgPicture.asset(
                          'assets/icons/post/more.svg',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    body,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _textBody,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 15),
              child: Row(
                children: [
                  _ReactionPair(
                    iconAsset: liked ? 'assets/icons/post/like_clicked.svg' : 'assets/icons/post/like.svg',
                    count: likes,
                    countColor: _likeCountColor,
                    width: 12.73,
                    height: 12,
                  ),
                  const SizedBox(width: 10),
                  _ReactionPair(
                    iconAsset: 'assets/icons/post/comment.svg',
                    count: comments,
                    countColor: _counterMuted,
                    width: 12.63,
                    height: 12,
                  ),
                  const SizedBox(width: 10),
                  _ReactionPair(
                    iconAsset: 'assets/icons/post/share.svg',
                    count: shares,
                    countColor: _counterMuted,
                    width: 14.34,
                    height: 12,
                  ),
                  const Spacer(),
                  SvgPicture.asset(
                    'assets/icons/post/save.svg',
                    width: 8.99,
                    height: 12,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReactionPair extends StatelessWidget {
  final String iconAsset;
  final int count;
  final Color countColor;
  final double width;
  final double height;
  const _ReactionPair({
    required this.iconAsset,
    required this.count,
    required this.countColor,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(iconAsset, width: width, height: height),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: TextStyle(
            color: countColor,
            fontSize: 10,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _RecommendedJobsSection extends StatelessWidget {
  final VoidCallback onViewAll;
  const _RecommendedJobsSection({required this.onViewAll});

  static const _jobs = <_JobEntry>[
    _JobEntry(
      title: 'Marketing Executive',
      company: 'Jain Jewellears Mumbai 10 min ago',
      location: 'Mumbai, Maharashtra',
      salary: '\$10,00,000',
      postedAgo: '4days ago',
    ),
    _JobEntry(
      title: 'Senior Accountant',
      company: 'Mehta & Associates CA Firm',
      location: 'Mumbai, Maharashtra',
      salary: '\$10,00,000',
      postedAgo: '4days ago',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Recommended Jobs', onViewAll: onViewAll),
          const SizedBox(height: 16),
          for (final j in _jobs) ...[
            _JobCard(entry: j),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _JobEntry {
  final String title;
  final String company;
  final String location;
  final String salary;
  final String postedAgo;
  const _JobEntry({
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.postedAgo,
  });
}

class _JobCard extends StatelessWidget {
  final _JobEntry entry;
  const _JobCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardDivider,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.title,
                            style: const TextStyle(
                              color: _textDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.company,
                            style: const TextStyle(
                              color: Color(0xFF99A0B0),
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SvgPicture.asset(
                      'assets/icons/post/save.svg',
                      width: 13.48,
                      height: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    _JobPill(text: 'Full Time'),
                    SizedBox(width: 8),
                    _JobPill(text: '2-4 years'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/common/location_pin.svg',
                      width: 10.55,
                      height: 15,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entry.location,
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      entry.salary,
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 15),
            child: Row(
              children: [
                Text(
                  entry.postedAgo,
                  style: const TextStyle(
                    color: _likeCountColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: _applyBlue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                  child: const Text(
                    'Apply Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JobPill extends StatelessWidget {
  final String text;
  const _JobPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _pillBg,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: _pillText,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}


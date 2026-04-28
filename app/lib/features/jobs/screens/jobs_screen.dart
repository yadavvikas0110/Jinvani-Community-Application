import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../state/jobs_controller.dart';
import '../state/seeker_setup_controller.dart';
import '../widgets/job_card.dart';

class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key});
  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          _SheetOption(
            icon: Icons.description_outlined,
            label: 'Application status',
            onTap: () {
              Navigator.pop(context);
              context.push('/jobs/applied');
            },
          ),
          _SheetOption(
            icon: Icons.bookmark_outline,
            label: 'Saved jobs',
            onTap: () {
              Navigator.pop(context);
              context.push('/jobs/saved');
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final setupDone = ref.watch(seekerSetupDoneProvider);

    return setupDone.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const Scaffold(body: Center(child: Text('Error'))),
      data: (done) {
        if (!done) {
          return _SetupPromptScreen(
            onStart: () => context.push('/jobs/setup/role'),
          );
        }
        return _JobsListingScreen(
          searchController: _searchController,
          onShowOptions: () => _showOptionsSheet(context),
        );
      },
    );
  }
}

// ── Setup prompt screen ───────────────────────────────────────────────────────

class _SetupPromptScreen extends StatelessWidget {
  final VoidCallback onStart;
  const _SetupPromptScreen({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Jobs',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Illustration ────────────────────────────────────────────
            _SetupIllustration(),
            const SizedBox(height: 32),
            const Text(
              'Find your next opportunity',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Set up your job seeker profile to get\npersonalized job recommendations.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryButtonGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ElevatedButton(
                  onPressed: onStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEEF1FF), Color(0xFFE8F0FD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryButtonGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5970AF).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.work_outline,
                    color: Colors.white, size: 38),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search,
                        size: 14, color: Color(0xFF5970AF)),
                    SizedBox(width: 5),
                    Text(
                      'Find jobs',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5970AF),
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Jobs listing screen ───────────────────────────────────────────────────────

class _JobsListingScreen extends ConsumerWidget {
  final TextEditingController searchController;
  final VoidCallback onShowOptions;

  const _JobsListingScreen({
    required this.searchController,
    required this.onShowOptions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(jobsControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F6),
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          SliverAppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.black12,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: AppColors.textPrimary, size: 22),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: const Text(
              'Jobs',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert,
                    color: AppColors.textPrimary, size: 22),
                onPressed: onShowOptions,
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F4F8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: searchController,
                          onChanged: (v) => ref
                              .read(jobsControllerProvider.notifier)
                              .search(v),
                          decoration: const InputDecoration(
                            hintText: 'Search jobs, companies...',
                            hintStyle: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(Icons.search,
                                size: 20, color: AppColors.textMuted),
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 13),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.tune_outlined,
                          size: 20, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: state.loading
            ? const Center(child: CircularProgressIndicator())
            : state.error != null
                ? Center(child: Text(state.error!))
                : ListView(
                    padding:
                        const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      // Category filter row
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Recommended Jobs',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'View All',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF395A91),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: jobCategories
                              .map((cat) => Padding(
                                    padding:
                                        const EdgeInsets.only(right: 8),
                                    child: JobCategoryPill(
                                      label: cat,
                                      selected:
                                          state.selectedCategory == cat,
                                      onTap: () => ref
                                          .read(jobsControllerProvider
                                              .notifier)
                                          .selectCategory(cat),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...state.jobs.map((job) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: JobCard(
                              job: job,
                              onTap: () =>
                                  context.push('/jobs/${job.id}'),
                              onSave: () => ref
                                  .read(
                                      jobsControllerProvider.notifier)
                                  .toggleSave(job.id),
                            ),
                          )),
                      if (state.jobs.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Text('No jobs found',
                                style: TextStyle(
                                    color: AppColors.textMuted)),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }
}

// ── Sheet option ──────────────────────────────────────────────────────────────

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SheetOption(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Icon(icon, size: 24, color: AppColors.textPrimary),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }
}

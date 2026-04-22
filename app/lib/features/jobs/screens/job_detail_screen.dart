import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../models/job.dart';
import '../state/jobs_controller.dart';

class JobDetailScreen extends ConsumerStatefulWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _applyNow(Job job) {
    if (job.isApplied) return;
    context.push('/jobs/${widget.jobId}/apply');
  }

  @override
  Widget build(BuildContext context) {
    final jobAsync = ref.watch(jobDetailProvider(widget.jobId));

    return jobAsync.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
          body: Center(child: Text('Error: $e'))),
      data: (job) => Scaffold(
        backgroundColor: Colors.white,
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
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
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(120),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CompanyHeader(job: job),
                      const SizedBox(height: 8),
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        labelColor: const Color(0xFF395A91),
                        unselectedLabelColor: AppColors.textMuted,
                        labelStyle: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                        indicatorColor: const Color(0xFF395A91),
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: const [
                          Tab(text: 'Job Description'),
                          Tab(text: 'About company'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _JobDescriptionTab(job: job),
              _AboutCompanyTab(job: job),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: job.isApplied
                ? Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline,
                              color: AppColors.success, size: 18),
                          SizedBox(width: 8),
                          Text('Applied',
                              style: TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16)),
                        ],
                      ),
                    ),
                  )
                : GradientButton(
                    label: 'Apply now',
                    onPressed: () => _applyNow(job),
                  ),
          ),
        ),
      ),
    );
  }
}

class _CompanyHeader extends StatelessWidget {
  final Job job;
  const _CompanyHeader({required this.job});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
          ),
          child: job.companyLogoUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(job.companyLogoUrl!, fit: BoxFit.cover),
                )
              : const Icon(Icons.business, size: 20, color: AppColors.textMuted),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(job.title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      letterSpacing: 0.3)),
              const SizedBox(height: 2),
              Text(job.company,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF111827))),
              const SizedBox(height: 4),
              Text('Posted ${job.postedAt}',
                  style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                      letterSpacing: 0.3)),
            ],
          ),
        ),
      ],
    );
  }
}

class _JobDescriptionTab extends StatelessWidget {
  final Job job;
  const _JobDescriptionTab({required this.job});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Row(
          children: [
            _InfoChip(icon: Icons.work_outline, label: 'Job Type', value: job.jobType),
            const SizedBox(width: 16),
            _InfoChip(icon: Icons.currency_rupee, label: 'Salaries', value: job.payscale),
          ],
        ),
        const SizedBox(height: 20),
        if (job.description != null) ...[
          const _SectionTitle('Job Description'),
          const SizedBox(height: 8),
          Text(job.description!,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF555252), height: 1.5)),
          const SizedBox(height: 16),
        ],
        if (job.skills.isNotEmpty) ...[
          const _SectionTitle('A Must Have Skill'),
          const SizedBox(height: 8),
          ...job.skills.map((s) => _BulletItem(text: s)),
          const SizedBox(height: 16),
        ],
        if (job.requirements.isNotEmpty) ...[
          const _SectionTitle('Candidate Recruitment'),
          const SizedBox(height: 8),
          ...job.requirements.map((r) => _BulletItem(text: r)),
        ],
      ],
    );
  }
}

class _AboutCompanyTab extends StatelessWidget {
  final Job job;
  const _AboutCompanyTab({required this.job});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const _SectionTitle('About company'),
        const SizedBox(height: 8),
        Text(
          job.aboutCompany ?? 'No company information available.',
          style: const TextStyle(
              fontSize: 12, color: Color(0xFF555252), height: 1.5),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoChip(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFDEE0E8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textMuted, height: 1.5)),
            Text(value,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                    height: 1.5)),
          ],
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: -0.2),
      );
}

class _BulletItem extends StatelessWidget {
  final String text;
  const _BulletItem({required this.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• ',
                style: TextStyle(fontSize: 12, color: Color(0xFF555252))),
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF555252), height: 1.5)),
            ),
          ],
        ),
      );
}

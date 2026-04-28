import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../state/profile_controller.dart';
import '../widgets/profile_app_bar.dart';
import '../widgets/profile_sticky_actions.dart';
import '../widgets/section_card.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});
  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  final _selected = <String>{};
  bool _saving = false;

  static const _goals = [
    ('business_support', 'Business Support',
        'Connect with investors, mentors and resources to grow your business',
        Icons.trending_up),
    ('matchmaking', 'Matchmaking',
        'Find compatible matches within the Jain community for marriage',
        Icons.favorite_border),
    ('job_assistance', 'Job Assistance',
        'Get matched with job opportunities, career guidance and placement support',
        Icons.work_outline),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final saved = ref.read(profileControllerProvider).profile?.goals ?? const [];
      setState(() => _selected.addAll(saved));
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(profileControllerProvider.notifier).saveGoals(_selected.toList());
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: const ProfileAppBar(title: 'Profile'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const SectionHeader(
            title: 'What are your goals?',
            subtitle: "Select all that apply — we'll personalise your experience",
          ),
          const SizedBox(height: 16),
          ..._goals.map((g) {
            final selected = _selected.contains(g.$1);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  setState(() {
                    if (selected) {
                      _selected.remove(g.$1);
                    } else {
                      _selected.add(g.$1);
                    }
                  });
                },
                child: SectionCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.accent.withValues(alpha: 0.12)
                              : const Color(0xFFEEF0F4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(g.$4,
                            color: selected ? AppColors.accent : AppColors.textPrimary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(g.$2,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text(g.$3,
                                style: const TextStyle(
                                    color: AppColors.textSecondary, fontSize: 13)),
                          ],
                        ),
                      ),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected ? AppColors.accent : Colors.transparent,
                          border: Border.all(
                            color: selected ? AppColors.accent : AppColors.inputBorder,
                            width: 2,
                          ),
                        ),
                        child: selected
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      bottomNavigationBar: ProfileStickyActions(
        primaryLabel: 'Finish Profile Setup',
        onPrimary: _saving ? null : _save,
        loading: _saving,
      ),
    );
  }
}

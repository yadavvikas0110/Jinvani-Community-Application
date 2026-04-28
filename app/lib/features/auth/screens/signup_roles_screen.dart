import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../data/auth_repository.dart';
import '../state/auth_controller.dart';
import '../state/signup_controller.dart';

class SignupRolesScreen extends ConsumerStatefulWidget {
  const SignupRolesScreen({super.key});
  @override
  ConsumerState<SignupRolesScreen> createState() => _SignupRolesScreenState();
}

class _Goal {
  final String value;
  final String title;
  final String description;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const _Goal({
    required this.value,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });
}

class _SignupRolesScreenState extends ConsumerState<SignupRolesScreen> {
  static const _goals = <_Goal>[
    _Goal(
      value: 'Business Support',
      title: 'Business Support',
      description:
          'Connect with investors, mentors and resources to grow your business',
      icon: Icons.business_center_outlined,
      iconBg: Color(0xFFE6F0FF),
      iconColor: Color(0xFF2C4E84),
    ),
    _Goal(
      value: 'Matchmaking',
      title: 'Matchmaking',
      description:
          'Find compatible matches within the Jain community for marriage',
      icon: Icons.favorite_outline,
      iconBg: Color(0xFFFFE6E6),
      iconColor: Color(0xFFE5484D),
    ),
    _Goal(
      value: 'Job Assistance',
      title: 'Job Assistance',
      description:
          'Get matched with job opportunities, career guidance and placement support',
      icon: Icons.work_outline,
      iconBg: Color(0xFFEAF7E6),
      iconColor: Color(0xFF2DBE64),
    ),
  ];

  final _selected = <String>{};
  bool _loading = false;

  Future<void> _submit() async {
    if (_selected.isEmpty) return;
    setState(() => _loading = true);
    try {
      final user =
          await ref.read(authRepositoryProvider).updateRoles(_selected.toList());
      ref.read(authControllerProvider.notifier).setUser(user);
      ref.read(signupDraftProvider.notifier).reset();
      if (mounted) context.go('/home');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF181818), size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: const Text(
          'Goal Selection',
          style: TextStyle(
            color: Color(0xFF181818),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What are your goals?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF101828),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Select all that apply — we'll personalise your experience",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888C96),
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (final goal in _goals) ...[
                      _GoalCard(
                        goal: goal,
                        selected: _selected.contains(goal.value),
                        onTap: () => setState(() {
                          if (_selected.contains(goal.value)) {
                            _selected.remove(goal.value);
                          } else {
                            _selected.add(goal.value);
                          }
                        }),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: GradientButton(
                label: 'Finish Profile Setup',
                loading: _loading,
                onPressed: _selected.isEmpty || _loading ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final _Goal goal;
  final bool selected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.goal,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF2C4E84) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: goal.iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(goal.icon, color: goal.iconColor, size: 28),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF101828),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    goal.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF676D7A),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_circle,
                  color: Color(0xFF2C4E84), size: 22),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class SupportMenuScreen extends StatelessWidget {
  const SupportMenuScreen({super.key});

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
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Support & Feedback',
          style: TextStyle(
            color: Color(0xFF181818),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How can we help you?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF101828),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose an option below to get started',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFA0A2A9),
                ),
              ),
              const SizedBox(height: 16),
              _SupportOptionCard(
                items: [
                  _SupportOption(
                    iconBg: const Color(0xFFFFF4E5),
                    icon: Icons.headset_mic_outlined,
                    iconColor: const Color(0xFFE87B19),
                    title: 'Customer Support',
                    subtitle:
                        "Raise a ticket or email us — we're here to help with any issue.",
                    onTap: () => context.push('/support/customer'),
                  ),
                  _SupportOption(
                    iconBg: const Color(0xFFF6E7FF),
                    icon: Icons.rate_review_outlined,
                    iconColor: const Color(0xFF9439D5),
                    title: 'Feedback',
                    subtitle:
                        'Share suggestions or ideas to help us improve your experience.',
                    onTap: () => context.push('/support/feedback'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportOption {
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SupportOption({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class _SupportOptionCard extends StatelessWidget {
  final List<_SupportOption> items;
  const _SupportOptionCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDEDAE5), width: 0.5),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _SupportOptionRow(
              option: items[i],
              showDivider: i < items.length - 1,
            ),
          ],
        ],
      ),
    );
  }
}

class _SupportOptionRow extends StatelessWidget {
  final _SupportOption option;
  final bool showDivider;

  const _SupportOptionRow({required this.option, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: option.onTap,
      child: Container(
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(
                  bottom: BorderSide(color: Color(0xFFDEDAE5), width: 0.5),
                )
              : null,
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: option.iconBg,
                borderRadius: BorderRadius.circular(5),
              ),
              alignment: Alignment.center,
              child: Icon(option.icon, color: option.iconColor, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D1D1F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF949AA2),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class CustomerSupportScreen extends StatelessWidget {
  const CustomerSupportScreen({super.key});

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
          'Customer Support',
          style: TextStyle(
            color: Color(0xFF181818),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How would you like to reach us?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF101828),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pick the option that works best for you',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFA0A2A9),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ChannelCard(
                      items: [
                        _ChannelOption(
                          icon: Icons.confirmation_number_outlined,
                          title: 'Raise a Ticket',
                          subtitle:
                              'Submit your query or issue and our team will respond promptly.',
                          onTap: () => context.push('/support/customer/ticket'),
                        ),
                        _ChannelOption(
                          icon: Icons.mail_outline,
                          title: 'Email Support',
                          subtitle:
                              'Send your issue details directly to our support team via email.',
                          onTap: () => context.push('/support/customer/email'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFF0F0F0)),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => context.pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF2F3F5),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

class _ChannelOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ChannelOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class _ChannelCard extends StatelessWidget {
  final List<_ChannelOption> items;
  const _ChannelCard({required this.items});

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
          for (var i = 0; i < items.length; i++)
            InkWell(
              onTap: items[i].onTap,
              child: Container(
                decoration: BoxDecoration(
                  border: i < items.length - 1
                      ? const Border(
                          bottom: BorderSide(
                              color: Color(0xFFDEDAE5), width: 0.5),
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
                        color: const Color(0xFFFFF4E5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      alignment: Alignment.center,
                      child: Icon(items[i].icon,
                          color: const Color(0xFFE87B19), size: 24),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            items[i].title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1D1D1F),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            items[i].subtitle,
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
            ),
        ],
      ),
    );
  }
}

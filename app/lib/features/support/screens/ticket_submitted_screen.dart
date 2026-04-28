import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/gradient_button.dart';

class TicketSubmittedScreen extends StatelessWidget {
  final String? ticketRef;
  const TicketSubmittedScreen({super.key, this.ticketRef});

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
          onPressed: () => context.go('/home'),
        ),
        centerTitle: true,
        title: const Text(
          'Ticket Submitted',
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2DBE64),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Ticket Successfully',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF121A2C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your support request has been submitted successfully. Our team will get back to you shortly.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4B5563),
                        height: 1.5,
                      ),
                    ),
                    if (ticketRef != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Ref: $ticketRef',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1D1D1F),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFDEDAE5), width: 0.5),
                      ),
                      child: Column(
                        children: const [
                          _InfoRow(
                            icon: Icons.access_time,
                            iconBg: Color(0xFFEFF1FF),
                            iconColor: Color(0xFF2C4E84),
                            label: 'Estimated Response',
                            value: '2-5 business hours',
                            showDivider: true,
                          ),
                          _InfoRow(
                            icon: Icons.mail_outline,
                            iconBg: Color(0xFFFFF4E5),
                            iconColor: Color(0xFFE87B19),
                            label: 'Confirmation sent to',
                            value: 'Your registered email',
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
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
                label: 'Go to Home',
                onPressed: () => context.go('/home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;
  final bool showDivider;

  const _InfoRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF949AA2),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D1D1F),
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

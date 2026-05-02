import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../state/booking_controller.dart';

const _purple = AppColors.accent;

const _paymentMethods = [
  {
    'id': 'UPI',
    'label': 'UPI',
    'sub': 'GPay, PhonePe, Paytm & more',
    'icon': Icons.account_balance_wallet_outlined,
    'bg': Color(0xFFECFDF5),
    'iconColor': Color(0xFF059669),
  },
  {
    'id': 'Card',
    'label': 'Credit / Debit Card',
    'sub': 'Visa, Mastercard, RuPay',
    'icon': Icons.credit_card_outlined,
    'bg': Color(0xFFEFF6FF),
    'iconColor': Color(0xFF2563EB),
  },
  {
    'id': 'NetBanking',
    'label': 'Net Banking',
    'sub': 'All major banks supported',
    'icon': Icons.account_balance_outlined,
    'bg': Color(0xFFFFF7ED),
    'iconColor': Color(0xFFD97706),
  },
  {
    'id': 'Wallets',
    'label': 'Wallets',
    'sub': 'Mobikwik, Amazon Pay & more',
    'icon': Icons.wallet_outlined,
    'bg': Color(0xFFF5F3FF),
    'iconColor': AppColors.accent,
  },
];

class BookingPaymentScreen extends ConsumerWidget {
  final String propertyId;
  const BookingPaymentScreen({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkout = ref.watch(checkoutControllerProvider);
    final ctrl = ref.read(checkoutControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black12,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color(0xFF121A2C), size: 22),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/booking');
            }
          },
        ),
        title: const Text(
          'Payment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF121A2C),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          // ── Amount summary card ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accent, AppColors.accent.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₹${checkout.total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${checkout.nights} night${checkout.nights > 1 ? 's' : ''} · '
                  '${checkout.guests} guest${checkout.guests > 1 ? 's' : ''} · '
                  '${checkout.roomCount} room${checkout.roomCount > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Select payment method ────────────────────────────────────────
          const Text(
            'Select Payment Method',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),

          ..._paymentMethods.map((method) {
            final id = method['id'] as String;
            final selected = checkout.paymentMethod == id;
            return GestureDetector(
              onTap: () => ctrl.setPaymentMethod(id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFF5F3FF) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? _purple
                        : const Color(0xFFE5E7EB),
                    width: selected ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFEDE9FF)
                            : method['bg'] as Color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        method['icon'] as IconData,
                        size: 22,
                        color: selected
                            ? _purple
                            : method['iconColor'] as Color,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            method['label'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? _purple
                                  : const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            method['sub'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? _purple
                              : const Color(0xFFD1D5DB),
                          width: 2,
                        ),
                      ),
                      child: selected
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _purple,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // ── Secure payment notice ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD1FAE5)),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_user_outlined,
                    size: 18, color: Color(0xFF059669)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '100% secure payment. Your data is encrypted and protected.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF065F46),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ── Bottom pay button ───────────────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.accent, AppColors.accent.withValues(alpha: 0.8)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton(
                    onPressed: checkout.submitting
                        ? null
                        : () async {
                            final booking =
                                await ctrl.confirmBooking(propertyId);
                            if (!context.mounted) return;
                            if (booking != null) {
                              context.pushReplacement(
                                  '/booking/confirmed/${booking.id}');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Payment failed. Try again.')),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: checkout.submitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                        : Text(
                            'Pay ₹${checkout.total.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'By proceeding, you agree to our Terms and Conditions',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

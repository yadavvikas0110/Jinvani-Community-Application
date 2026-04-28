import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../state/support_controller.dart';

class RaiseTicketScreen extends ConsumerStatefulWidget {
  const RaiseTicketScreen({super.key});

  @override
  ConsumerState<RaiseTicketScreen> createState() => _RaiseTicketScreenState();
}

class _RaiseTicketScreenState extends ConsumerState<RaiseTicketScreen> {
  final _form = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _description = TextEditingController();
  int _descLength = 0;

  static const int _maxDescription = 500;

  @override
  void initState() {
    super.initState();
    _description.addListener(() {
      if (_descLength != _description.text.length) {
        setState(() => _descLength = _description.text.length);
      }
    });
  }

  @override
  void dispose() {
    _subject.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final ticket = await ref
        .read(supportControllerProvider.notifier)
        .submitTicket(
          subject: _subject.text.trim(),
          description: _description.text.trim(),
        );
    if (!mounted) return;
    if (ticket != null) {
      context.pushReplacement('/support/customer/ticket/submitted',
          extra: ticket.ref);
    } else {
      final err = ref.read(supportControllerProvider).error ??
          'Could not submit ticket. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitting = ref.watch(supportControllerProvider).submitting;
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
          'Raise a Ticket',
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
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Submit a Support Ticket',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF101828),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "We'll get back to you within 2–4 hours",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFA0A2A9),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: const Color(0xFFDEDAE5), width: 0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel('Subject*'),
                            const SizedBox(height: 4),
                            _BorderedField(
                              controller: _subject,
                              hint: 'Brief summary of your issue',
                              maxLength: 120,
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Subject is required'
                                      : null,
                            ),
                            const SizedBox(height: 16),
                            const _FieldLabel('Description*'),
                            const SizedBox(height: 4),
                            _BorderedField(
                              controller: _description,
                              hint:
                                  'Describe your issue in detail so we can help you faster...',
                              maxLines: 6,
                              minLines: 5,
                              maxLength: _maxDescription,
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Description is required'
                                      : null,
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '$_descLength/$_maxDescription',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9EA1A8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                label: 'Submit Ticket',
                loading: submitting,
                onPressed: submitting ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF121A2C),
        ),
      );
}

class _BorderedField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final String? Function(String?)? validator;

  const _BorderedField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: Color(0xFF121A2C)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 12,
          color: Color(0xFF9EA1A8),
        ),
        counterText: '',
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E2E5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5970AF)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5484D)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5484D)),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../profile/widgets/labeled_field.dart';
import '../../profile/widgets/profile_app_bar.dart';
import '../models/family.dart';
import '../state/family_controller.dart';

class AddFamilyMemberScreen extends ConsumerStatefulWidget {
  const AddFamilyMemberScreen({super.key});

  @override
  ConsumerState<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends ConsumerState<AddFamilyMemberScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  String? _relation;
  bool _sending = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  String? _phoneOrEmail() {
    if (_phone.text.trim().isEmpty && _email.text.trim().isEmpty) {
      return 'Enter a phone or an email';
    }
    return null;
  }

  String _normalizedPhone() {
    final p = _phone.text.trim();
    if (p.isEmpty) return '';
    return p.startsWith('+') ? p : '+91${p.replaceAll(RegExp(r'\D'), '')}';
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_relation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a relation')),
      );
      return;
    }
    final err = _phoneOrEmail();
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    setState(() => _sending = true);
    try {
      final res = await ref.read(familyControllerProvider.notifier).invite(
            name: _name.text.trim(),
            relation: _relation!,
            phone: _phone.text.trim().isEmpty ? null : _normalizedPhone(),
            email: _email.text.trim().isEmpty ? null : _email.text.trim(),
          );
      if (!mounted) return;
      if (res.status == 'sent') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent')),
        );
        context.pop();
      } else if (res.status == 'user_not_registered') {
        await _showNotRegisteredDialog();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not send request')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _showNotRegisteredDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _NotRegisteredDialog(
        name: _name.text.trim(),
        initialPhone: _phone.text.trim().isEmpty ? null : _normalizedPhone(),
        initialEmail: _email.text.trim().isEmpty ? null : _email.text.trim(),
        onConfirm: (phone, email) async {
          final res = await ref
              .read(familyControllerProvider.notifier)
              .sendExternalInvite(
                name: _name.text.trim(),
                relation: _relation!,
                phone: phone,
                email: email,
              );
          return res.status == 'sent';
        },
      ),
    );
    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invite sent')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: const ProfileAppBar(title: 'Add Members'),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE6E9F7), Color(0xFFF1E7F6)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.handshake_outlined,
                    size: 72, color: AppColors.accent),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Connect a Family Member',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            const Text('Enter their details to send a connection request',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            LabeledField(
              label: 'Enter Name',
              child: TextFormField(
                controller: _name,
                decoration: const InputDecoration(hintText: 'e.g. Vikas Jain'),
                validator: (v) =>
                    (v == null || v.trim().length < 2) ? 'Enter a name' : null,
              ),
            ),
            const SizedBox(height: 14),
            LabeledField(
              label: 'Relation',
              child: DropdownButtonFormField<String>(
                initialValue: _relation,
                hint: const Text('Select'),
                items: kRelations.entries
                    .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _relation = v),
              ),
            ),
            const SizedBox(height: 14),
            LabeledField(
              label: 'Mobile Number',
              child: TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: 'e.g. 9986378383'),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                    child: Divider(color: Color(0xFFCBD0DC), thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFCBD0DC)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('AND/OR',
                        style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                            fontSize: 11)),
                  ),
                ),
                const Expanded(
                    child: Divider(color: Color(0xFFCBD0DC), thickness: 1)),
              ],
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: 'Email Address',
              child: TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'e.g. priya@example.com'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
                    return 'Invalid email';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8ECFA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 18, color: AppColors.accent),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Adding both mobile and email lets us reach them via multiple channels for a higher chance of delivery.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: GradientButton(
            label: 'Continue',
            trailingIcon: Icons.arrow_forward,
            loading: _sending,
            onPressed: _sending ? null : _submit,
          ),
        ),
      ),
    );
  }
}

class _NotRegisteredDialog extends StatefulWidget {
  final String name;
  final String? initialPhone;
  final String? initialEmail;
  final Future<bool> Function(String? phone, String? email) onConfirm;

  const _NotRegisteredDialog({
    required this.name,
    required this.onConfirm,
    this.initialPhone,
    this.initialEmail,
  });

  @override
  State<_NotRegisteredDialog> createState() => _NotRegisteredDialogState();
}

class _NotRegisteredDialogState extends State<_NotRegisteredDialog> {
  late final TextEditingController _phone =
      TextEditingController(text: widget.initialPhone ?? '');
  late final TextEditingController _email =
      TextEditingController(text: widget.initialEmail ?? '');
  bool _sending = false;

  @override
  void dispose() {
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryButtonGradient,
                ),
                child: const Icon(Icons.person_add_alt_1,
                    color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text('User Not Registered',
                  style: TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w700,
                      fontSize: 18)),
            ),
            const SizedBox(height: 6),
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                  children: [
                    TextSpan(
                      text: widget.name,
                      style: const TextStyle(
                          color: AppColors.accent, fontWeight: FontWeight.w600),
                    ),
                    const TextSpan(
                        text:
                            ' is not registered on Jinvani. Send an invite to connect with them.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFEAECF0)),
            const SizedBox(height: 10),
            LabeledField(
              label: 'Mobile Number',
              child: TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: 'e.g. 9986378383'),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text('AND/OR',
                  style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 12)),
            ),
            const SizedBox(height: 10),
            LabeledField(
              label: 'Email Address',
              child: TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'e.g. priya@example.com'),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _sending ? null : () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFEEF0F4),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      foregroundColor: AppColors.textPrimary,
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: GradientButton(
                      label: 'Send Invite',
                      loading: _sending,
                      onPressed: _sending
                          ? null
                          : () async {
                              final phone = _phone.text.trim();
                              final email = _email.text.trim();
                              if (phone.isEmpty && email.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Enter phone or email')),
                                );
                                return;
                              }
                              setState(() => _sending = true);
                              try {
                                final ok = await widget.onConfirm(
                                  phone.isEmpty
                                      ? null
                                      : (phone.startsWith('+')
                                          ? phone
                                          : '+91${phone.replaceAll(RegExp(r'\D'), '')}'),
                                  email.isEmpty ? null : email,
                                );
                                if (context.mounted) Navigator.pop(context, ok);
                              } catch (_) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Failed to send invite')),
                                  );
                                }
                              } finally {
                                if (context.mounted) setState(() => _sending = false);
                              }
                            },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

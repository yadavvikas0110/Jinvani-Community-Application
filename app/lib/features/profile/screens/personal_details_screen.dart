import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../state/profile_controller.dart';
import '../widgets/labeled_field.dart';
import '../widgets/profile_app_bar.dart';
import '../widgets/profile_sticky_actions.dart';
import '../widgets/section_card.dart';

class PersonalDetailsScreen extends ConsumerStatefulWidget {
  const PersonalDetailsScreen({super.key});
  @override
  ConsumerState<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends ConsumerState<PersonalDetailsScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _birth = TextEditingController();
  final _current = TextEditingController();
  final _pref = TextEditingController();
  String? _gender;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  void _hydrate() {
    final p = ref.read(profileControllerProvider).profile;
    if (p == null) return;
    final pd = p.personalDetails;
    _name.text = pd.fullName ?? '';
    _age.text = pd.age?.toString() ?? '';
    _gender = pd.gender;
    _birth.text = pd.birthLocation ?? '';
    _current.text = pd.currentLocation ?? '';
    _pref.text = pd.preference ?? '';
    setState(() {});
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _birth.dispose();
    _current.dispose();
    _pref.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(profileControllerProvider.notifier).savePersonal({
        if (_name.text.trim().isNotEmpty) 'fullName': _name.text.trim(),
        if (_age.text.trim().isNotEmpty) 'age': int.tryParse(_age.text.trim()),
        if (_gender != null) 'gender': _gender,
        if (_birth.text.trim().isNotEmpty) 'birthLocation': _birth.text.trim(),
        if (_current.text.trim().isNotEmpty) 'currentLocation': _current.text.trim(),
        if (_pref.text.trim().isNotEmpty) 'preference': _pref.text.trim(),
      });
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save. Try again.')),
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
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const SectionHeader(
              title: 'Personal Details',
              subtitle: 'Tell us a bit about you — required fields.',
            ),
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LabeledField(
                    label: 'Full Name',
                    child: TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(hintText: 'Priya Jain'),
                      validator: (v) =>
                          (v == null || v.trim().length < 2) ? 'Enter your full name' : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  LabeledField(
                    label: 'Age',
                    child: TextFormField(
                      controller: _age,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '25'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final n = int.tryParse(v.trim());
                        if (n == null || n < 1 || n > 120) return 'Invalid age';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  LabeledField(
                    label: 'Gender',
                    child: DropdownButtonFormField<String>(
                      initialValue: _gender,
                      decoration: const InputDecoration(hintText: 'Select'),
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('Male')),
                        DropdownMenuItem(value: 'female', child: Text('Female')),
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                      ],
                      onChanged: (v) => setState(() => _gender = v),
                    ),
                  ),
                  const SizedBox(height: 14),
                  LabeledField(
                    label: 'Birth Location',
                    child: TextFormField(
                      controller: _birth,
                      decoration: const InputDecoration(hintText: 'Jaipur, India'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  LabeledField(
                    label: 'Current Location',
                    child: TextFormField(
                      controller: _current,
                      decoration: const InputDecoration(hintText: 'Bengaluru, India'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  LabeledField(
                    label: 'Preference',
                    child: TextFormField(
                      controller: _pref,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Open to relocate, Remote preferred',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              '• Marked as Required — needed to use community features.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ProfileStickyActions(
        onPrimary: _saving ? null : _save,
        loading: _saving,
      ),
    );
  }
}

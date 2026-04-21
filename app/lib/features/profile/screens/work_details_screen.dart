import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/profile_controller.dart';
import '../widgets/labeled_field.dart';
import '../widgets/profile_app_bar.dart';
import '../widgets/profile_sticky_actions.dart';
import '../widgets/section_card.dart';

class WorkDetailsScreen extends ConsumerStatefulWidget {
  const WorkDetailsScreen({super.key});
  @override
  ConsumerState<WorkDetailsScreen> createState() => _WorkDetailsScreenState();
}

class _WorkDetailsScreenState extends ConsumerState<WorkDetailsScreen> {
  final _form = GlobalKey<FormState>();
  final _type = TextEditingController();
  final _company = TextEditingController();
  final _companyType = TextEditingController();
  final _role = TextEditingController();
  final _years = TextEditingController();
  final _location = TextEditingController();
  final _desc = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  void _hydrate() {
    final w = ref.read(profileControllerProvider).profile?.workDetails;
    if (w == null) return;
    _type.text = w.jobType ?? '';
    _company.text = w.companyName ?? '';
    _companyType.text = w.companyType ?? '';
    _role.text = w.jobRole ?? '';
    _years.text = w.yearsOfExperience?.toString() ?? '';
    _location.text = w.jobLocation ?? '';
    _desc.text = w.roleDescription ?? '';
  }

  @override
  void dispose() {
    _type.dispose();
    _company.dispose();
    _companyType.dispose();
    _role.dispose();
    _years.dispose();
    _location.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(profileControllerProvider.notifier).saveWork({
        if (_type.text.trim().isNotEmpty) 'jobType': _type.text.trim(),
        if (_company.text.trim().isNotEmpty) 'companyName': _company.text.trim(),
        if (_companyType.text.trim().isNotEmpty) 'companyType': _companyType.text.trim(),
        if (_role.text.trim().isNotEmpty) 'jobRole': _role.text.trim(),
        if (_years.text.trim().isNotEmpty)
          'yearsOfExperience': int.tryParse(_years.text.trim()),
        if (_location.text.trim().isNotEmpty) 'jobLocation': _location.text.trim(),
        if (_desc.text.trim().isNotEmpty) 'roleDescription': _desc.text.trim(),
      });
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
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const SectionHeader(
              title: 'Work Details',
              subtitle: 'Share what you do — helps connect you with opportunities.',
            ),
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LabeledField(
                    label: 'Job Type',
                    child: TextFormField(
                      controller: _type,
                      decoration: const InputDecoration(hintText: 'Full-time, Contract...'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  LabeledField(
                    label: 'Company Name',
                    child: TextFormField(
                      controller: _company,
                      decoration: const InputDecoration(hintText: 'Acme Corp'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  LabeledField(
                    label: 'Company Type',
                    child: TextFormField(
                      controller: _companyType,
                      decoration: const InputDecoration(hintText: 'Startup, MNC, Family business'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  LabeledField(
                    label: 'Job Role',
                    child: TextFormField(
                      controller: _role,
                      decoration: const InputDecoration(hintText: 'Product Manager'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  LabeledField(
                    label: 'Years of Experience',
                    child: TextFormField(
                      controller: _years,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '5'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  LabeledField(
                    label: 'Job Location',
                    child: TextFormField(
                      controller: _location,
                      decoration: const InputDecoration(hintText: 'Bengaluru, India'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  LabeledField(
                    label: 'Role Description',
                    child: TextFormField(
                      controller: _desc,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'What you do day-to-day',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ProfileStickyActions(
        onPrimary: _saving ? null : _save,
        loading: _saving,
        onSkip: () => context.pop(),
      ),
    );
  }
}

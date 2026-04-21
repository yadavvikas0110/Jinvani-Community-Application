import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../state/profile_controller.dart';
import '../widgets/labeled_field.dart';
import '../widgets/profile_app_bar.dart';
import '../widgets/profile_sticky_actions.dart';
import '../widgets/section_card.dart';

class EconomicDataScreen extends ConsumerStatefulWidget {
  const EconomicDataScreen({super.key});
  @override
  ConsumerState<EconomicDataScreen> createState() => _EconomicDataScreenState();
}

class _EconomicDataScreenState extends ConsumerState<EconomicDataScreen> {
  final _form = GlobalKey<FormState>();
  final _source = TextEditingController();
  final _jobStatus = TextEditingController();
  final _savings = TextEditingController();
  final _goal = TextEditingController();
  final _goalDesc = TextEditingController();
  final _invType = TextEditingController();
  final _invValue = TextEditingController();
  final _invNotes = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  void _hydrate() {
    final e = ref.read(profileControllerProvider).profile?.economicData;
    if (e == null) return;
    _source.text = e.financialInfo.sourceOfIncome ?? '';
    _jobStatus.text = e.financialInfo.jobStatus ?? '';
    _savings.text = e.financialInfo.currentSavings?.toString() ?? '';
    _goal.text = e.futureGoals.goal ?? '';
    _goalDesc.text = e.futureGoals.description ?? '';
    _invType.text = e.investmentPortfolio.type ?? '';
    _invValue.text = e.investmentPortfolio.currentValue?.toString() ?? '';
    _invNotes.text = e.investmentPortfolio.notes ?? '';
  }

  @override
  void dispose() {
    for (final c in [_source, _jobStatus, _savings, _goal, _goalDesc, _invType, _invValue, _invNotes]) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic>? _buildFinancial() {
    final m = <String, dynamic>{
      if (_source.text.trim().isNotEmpty) 'sourceOfIncome': _source.text.trim(),
      if (_jobStatus.text.trim().isNotEmpty) 'jobStatus': _jobStatus.text.trim(),
      if (_savings.text.trim().isNotEmpty)
        'currentSavings': double.tryParse(_savings.text.trim()),
    };
    return m.isEmpty ? null : m;
  }

  Map<String, dynamic>? _buildGoal() {
    final m = <String, dynamic>{
      if (_goal.text.trim().isNotEmpty) 'goal': _goal.text.trim(),
      if (_goalDesc.text.trim().isNotEmpty) 'description': _goalDesc.text.trim(),
    };
    return m.isEmpty ? null : m;
  }

  Map<String, dynamic>? _buildInv() {
    final m = <String, dynamic>{
      if (_invType.text.trim().isNotEmpty) 'type': _invType.text.trim(),
      if (_invValue.text.trim().isNotEmpty)
        'currentValue': double.tryParse(_invValue.text.trim()),
      if (_invNotes.text.trim().isNotEmpty) 'notes': _invNotes.text.trim(),
    };
    return m.isEmpty ? null : m;
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final payload = <String, dynamic>{};
      final fi = _buildFinancial();
      final fg = _buildGoal();
      final ip = _buildInv();
      if (fi != null) payload['financialInfo'] = fi;
      if (fg != null) payload['futureGoals'] = fg;
      if (ip != null) payload['investmentPortfolio'] = ip;
      await ref.read(profileControllerProvider.notifier).saveEconomic(payload);
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
              title: 'Economic Data',
              subtitle: 'Your financial footprint — kept confidential to you.',
            ),
            const SizedBox(height: 16),
            _GroupTitle('Financial Info'),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LabeledField(
                    label: 'Source of Income',
                    child: TextFormField(
                      controller: _source,
                      decoration:
                          const InputDecoration(hintText: 'Salary, Business, Investments...'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  LabeledField(
                    label: 'Job Status',
                    child: TextFormField(
                      controller: _jobStatus,
                      decoration:
                          const InputDecoration(hintText: 'Employed, Self-employed, Student'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  LabeledField(
                    label: 'Current Savings (₹)',
                    child: TextFormField(
                      controller: _savings,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '500000'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _GroupTitle('Future Goals'),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LabeledField(
                    label: 'Goal',
                    child: TextFormField(
                      controller: _goal,
                      decoration: const InputDecoration(hintText: 'Buy a house, Start business'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  LabeledField(
                    label: 'Description',
                    child: TextFormField(
                      controller: _goalDesc,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Short summary of your target',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _GroupTitle('Investment Portfolio'),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LabeledField(
                    label: 'Type',
                    child: TextFormField(
                      controller: _invType,
                      decoration:
                          const InputDecoration(hintText: 'Stocks, Mutual Funds, Real Estate'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  LabeledField(
                    label: 'Current Value (₹)',
                    child: TextFormField(
                      controller: _invValue,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '250000'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  LabeledField(
                    label: 'Notes',
                    child: TextFormField(
                      controller: _invNotes,
                      maxLines: 3,
                      decoration:
                          const InputDecoration(hintText: 'Any context on the portfolio'),
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

class _GroupTitle extends StatelessWidget {
  final String text;
  const _GroupTitle(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontSize: 15)),
      );
}

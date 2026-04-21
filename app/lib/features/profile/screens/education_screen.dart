import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../models/profile.dart';
import '../state/profile_controller.dart';
import '../widgets/labeled_field.dart';
import '../widgets/profile_app_bar.dart';
import '../widgets/profile_sticky_actions.dart';
import '../widgets/section_card.dart';

class EducationScreen extends ConsumerStatefulWidget {
  const EducationScreen({super.key});
  @override
  ConsumerState<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends ConsumerState<EducationScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this)
      ..addListener(() {
        if (!_tabs.indexIsChanging) setState(() => _tab = _tabs.index);
      });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(profileControllerProvider).profile?.education ?? const [];
    final currentType = ['degree', 'schooling', 'certification'][_tab];
    final filtered = entries.where((e) => e.type == currentType).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: const ProfileAppBar(title: 'Profile'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const SectionHeader(
            title: 'Educational Details',
            subtitle: 'Add your academic background — optional but helps match opportunities.',
          ),
          const SizedBox(height: 16),
          _TabBar(controller: _tabs),
          const SizedBox(height: 16),
          if (filtered.isNotEmpty) ...[
            ...filtered.map((e) => _EducationListItem(entry: e)),
            const SizedBox(height: 12),
          ],
          SectionCard(
            child: _FormForType(type: currentType),
          ),
          const SizedBox(height: 16),
        ],
      ),
      bottomNavigationBar: ProfileStickyActions(
        onPrimary: () => context.pop(),
        onSkip: () => context.pop(),
        primaryLabel: 'Done',
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final TabController controller;
  const _TabBar({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEF0F4),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.accent,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        tabs: const [
          Tab(text: 'Degree'),
          Tab(text: 'Schooling'),
          Tab(text: 'Certification'),
        ],
      ),
    );
  }
}

class _EducationListItem extends ConsumerWidget {
  final EducationEntry entry;
  const _EducationListItem({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SectionCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.displayTitle,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  if (entry.displaySubtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(entry.displaySubtitle,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete entry?'),
                    content: const Text('This cannot be undone.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete',
                              style: TextStyle(color: AppColors.danger))),
                    ],
                  ),
                );
                if (ok == true) {
                  await ref.read(profileControllerProvider.notifier).deleteEducation(entry.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FormForType extends ConsumerStatefulWidget {
  final String type;
  const _FormForType({required this.type});
  @override
  ConsumerState<_FormForType> createState() => _FormForTypeState();
}

class _FormForTypeState extends ConsumerState<_FormForType> {
  final _form = GlobalKey<FormState>();
  final _c = <String, TextEditingController>{};
  String? _certUrl;
  String? _certFilename;
  bool _uploading = false;
  bool _saving = false;

  TextEditingController _ctrl(String k) => _c.putIfAbsent(k, () => TextEditingController());

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickCertificate() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.single.path == null) return;
    setState(() => _uploading = true);
    try {
      final url = await ref.read(profileControllerProvider.notifier).uploadFile(
            result.files.single.path!,
            result.files.single.name,
          );
      setState(() {
        _certUrl = url;
        _certFilename = result.files.single.name;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload failed')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _add() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final data = <String, dynamic>{'type': widget.type};
      switch (widget.type) {
        case 'degree':
          _putIfPresent(data, 'degreeName');
          _putIfPresent(data, 'specialization');
          _putIfPresent(data, 'collegeName');
          _putIfPresent(data, 'percentage');
          break;
        case 'schooling':
          _putIfPresent(data, 'schoolName');
          _putIfPresent(data, 'stream');
          _putIfPresent(data, 'boardName');
          _putIfPresent(data, 'location');
          _putIfPresent(data, 'percentage');
          _putIfPresent(data, 'achievements');
          break;
        case 'certification':
          _putIfPresent(data, 'certificateName');
          _putIfPresent(data, 'certificateDescription');
          if (_certUrl != null) {
            // Prepend backend host for client display persistence.
            data['certificateUrl'] = _absoluteUrl(_certUrl!);
          }
          break;
      }
      await ref.read(profileControllerProvider.notifier).addEducation(data);
      for (final c in _c.values) {
        c.clear();
      }
      setState(() {
        _certUrl = null;
        _certFilename = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry added')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add entry')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _putIfPresent(Map<String, dynamic> data, String key) {
    final v = _c[key]?.text.trim();
    if (v != null && v.isNotEmpty) data[key] = v;
  }

  String _absoluteUrl(String path) {
    if (path.startsWith('http')) return path;
    // API_BASE_URL defaults to host:4000/api/v1; static served at host:4000/static/uploads.
    const base = String.fromEnvironment('API_BASE_URL',
        defaultValue: 'http://10.0.2.2:4000/api/v1');
    final host = base.replaceAll('/api/v1', '');
    return '$host$path';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.type == 'degree') ..._degreeFields(),
          if (widget.type == 'schooling') ..._schoolingFields(),
          if (widget.type == 'certification') ..._certificationFields(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _saving ? null : _add,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add, color: AppColors.accent),
              label: Text(
                widget.type == 'certification' ? 'Add Certificate' : 'Add ${_label(widget.type)}',
                style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.accent),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _label(String t) => t[0].toUpperCase() + t.substring(1);

  List<Widget> _degreeFields() => [
        LabeledField(
          label: 'Degree Name',
          child: TextFormField(
            controller: _ctrl('degreeName'),
            decoration: const InputDecoration(hintText: 'B.Tech, B.Com, MBA...'),
          ),
        ),
        const SizedBox(height: 14),
        LabeledField(
          label: 'Specialization',
          child: TextFormField(
            controller: _ctrl('specialization'),
            decoration: const InputDecoration(hintText: 'Computer Science'),
          ),
        ),
        const SizedBox(height: 14),
        LabeledField(
          label: 'College Name',
          child: TextFormField(
            controller: _ctrl('collegeName'),
            decoration: const InputDecoration(hintText: 'IIT Delhi'),
          ),
        ),
        const SizedBox(height: 14),
        LabeledField(
          label: 'Percentage / CGPA',
          child: TextFormField(
            controller: _ctrl('percentage'),
            decoration: const InputDecoration(hintText: '8.6 CGPA'),
          ),
        ),
      ];

  List<Widget> _schoolingFields() => [
        LabeledField(
          label: 'School Name',
          child: TextFormField(
            controller: _ctrl('schoolName'),
            decoration: const InputDecoration(hintText: 'Delhi Public School'),
          ),
        ),
        const SizedBox(height: 14),
        LabeledField(
          label: 'Stream',
          child: TextFormField(
            controller: _ctrl('stream'),
            decoration: const InputDecoration(hintText: 'Science / Commerce'),
          ),
        ),
        const SizedBox(height: 14),
        LabeledField(
          label: 'Board',
          child: TextFormField(
            controller: _ctrl('boardName'),
            decoration: const InputDecoration(hintText: 'CBSE'),
          ),
        ),
        const SizedBox(height: 14),
        LabeledField(
          label: 'Location',
          child: TextFormField(
            controller: _ctrl('location'),
            decoration: const InputDecoration(hintText: 'New Delhi'),
          ),
        ),
        const SizedBox(height: 14),
        LabeledField(
          label: 'Percentage',
          child: TextFormField(
            controller: _ctrl('percentage'),
            decoration: const InputDecoration(hintText: '92%'),
          ),
        ),
        const SizedBox(height: 14),
        LabeledField(
          label: 'Achievements',
          child: TextFormField(
            controller: _ctrl('achievements'),
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Gold medal, olympiads, sports...',
            ),
          ),
        ),
      ];

  List<Widget> _certificationFields() => [
        LabeledField(
          label: 'Certificate',
          child: InkWell(
            onTap: _uploading ? null : _pickCertificate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.inputBorder, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFFAFAFC),
              ),
              child: Row(
                children: [
                  Icon(
                    _uploading
                        ? Icons.hourglass_empty
                        : _certUrl != null
                            ? Icons.check_circle
                            : Icons.upload_file_outlined,
                    color: _certUrl != null ? AppColors.success : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _uploading
                          ? 'Uploading...'
                          : _certFilename ?? 'Upload PDF / JPG / PNG (up to 5MB)',
                      style: TextStyle(
                        color: _certUrl != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        LabeledField(
          label: 'Name',
          child: TextFormField(
            controller: _ctrl('certificateName'),
            decoration: const InputDecoration(hintText: 'AWS Certified Developer'),
          ),
        ),
        const SizedBox(height: 14),
        LabeledField(
          label: 'Description',
          child: TextFormField(
            controller: _ctrl('certificateDescription'),
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Brief summary of what this covers',
            ),
          ),
        ),
      ];
}

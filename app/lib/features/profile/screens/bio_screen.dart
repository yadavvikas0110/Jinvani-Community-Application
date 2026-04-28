import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../state/profile_controller.dart';
import '../widgets/profile_app_bar.dart';
import '../widgets/profile_sticky_actions.dart';
import '../widgets/section_card.dart';

class BioScreen extends ConsumerStatefulWidget {
  const BioScreen({super.key});
  @override
  ConsumerState<BioScreen> createState() => _BioScreenState();
}

class _BioScreenState extends ConsumerState<BioScreen> {
  final _form = GlobalKey<FormState>();
  final _bio = TextEditingController();
  String? _avatarUrl;
  bool _uploading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  void _hydrate() {
    final b = ref.read(profileControllerProvider).profile?.bio;
    if (b == null) return;
    _bio.text = b.briefIntroduction ?? '';
    _avatarUrl = b.avatarUrl;
    setState(() {});
  }

  @override
  void dispose() {
    _bio.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (picked == null) return;
    setState(() => _uploading = true);
    try {
      final url = await ref.read(profileControllerProvider.notifier).uploadFile(
            picked.path,
            picked.name,
          );
      setState(() => _avatarUrl = _absoluteUrl(url));
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

  String _absoluteUrl(String path) {
    if (path.startsWith('http')) return path;
    const base = String.fromEnvironment('API_BASE_URL',
        defaultValue: 'https://teal-tapioca-5eaaaa.netlify.app/api/v1');
    final host = base.replaceAll('/api/v1', '');
    return '$host$path';
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(profileControllerProvider.notifier).saveBio({
        if (_avatarUrl != null) 'avatarUrl': _avatarUrl,
        if (_bio.text.trim().isNotEmpty) 'briefIntroduction': _bio.text.trim(),
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
              title: 'Profile Picture & Bio',
              subtitle: 'Add a photo and introduction — this is required',
            ),
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 54,
                          backgroundColor: const Color(0xFFEEF0F4),
                          backgroundImage: _avatarUrl != null
                              ? NetworkImage(_avatarUrl!)
                              : null,
                          child: _uploading
                              ? const CircularProgressIndicator()
                              : _avatarUrl == null
                                  ? const Icon(Icons.person,
                                      size: 48, color: AppColors.textMuted)
                                  : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Material(
                            color: AppColors.accent,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: _uploading ? null : _pickImage,
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.camera_alt,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap the icon to upload. 400×400 recommended, up to 5MB.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Brief Introduction',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE8E9),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Text(
                          'Required',
                          style: TextStyle(
                            color: Color(0xFFD83E3E),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _bio,
                    maxLines: 5,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      hintText:
                          'Write a short bio summarizing your skills, experience, or goals',
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
      ),
    );
  }
}

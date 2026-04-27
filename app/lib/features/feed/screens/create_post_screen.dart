import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/state/auth_controller.dart';
import '../../profile/state/profile_controller.dart';
import '../state/feed_controller.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  final String type; // 'post' | 'blog'
  const CreatePostScreen({super.key, required this.type});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  String? _imageUrl;
  bool _uploading = false;
  bool _submitting = false;

  bool get _isBlog => widget.type == 'blog';

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {}));
    _body.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  bool get _canPost {
    if (_body.text.trim().isEmpty) return false;
    if (_isBlog) {
      if (_title.text.trim().length < 3) return false;
      if (_imageUrl == null) return false;
    }
    return !_submitting && !_uploading;
  }

  String _absoluteUrl(String path) {
    if (path.startsWith('http')) return path;
    const base = String.fromEnvironment('API_BASE_URL',
        defaultValue: 'https://teal-tapioca-5eaaaa.netlify.app/api/v1');
    final host = base.replaceAll('/api/v1', '');
    return '$host$path';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (picked == null) return;
    setState(() => _uploading = true);
    try {
      final url = await ref
          .read(createPostControllerProvider.notifier)
          .uploadImage(picked.path);
      setState(() => _imageUrl = _absoluteUrl(url));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image upload failed')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _submit() async {
    if (!_canPost) return;
    setState(() => _submitting = true);
    try {
      await ref.read(createPostControllerProvider.notifier).submit(
            type: widget.type,
            title: _isBlog ? _title.text.trim() : null,
            body: _body.text.trim(),
            imageUrl: _imageUrl,
          );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to publish ${widget.type}')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileControllerProvider).profile;
    final user = ref.watch(authControllerProvider).user;
    final name = user?.name ?? profile?.personalDetails.fullName ?? 'You';
    final avatarUrl = profile?.bio.avatarUrl;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Header(
                title: _isBlog ? 'Create Blog' : 'Create Post',
                onClose: _submitting ? null : () => Navigator.pop(context),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFFEEF0F4),
                            backgroundImage: (avatarUrl ?? '').isNotEmpty
                                ? NetworkImage(avatarUrl!)
                                : null,
                            child: (avatarUrl ?? '').isEmpty
                                ? const Icon(Icons.person,
                                    color: AppColors.textMuted, size: 20)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary)),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF0F4),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('Posting Publicly',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondary)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_isBlog) ...[
                        TextField(
                          controller: _title,
                          maxLength: 200,
                          decoration: InputDecoration(
                            hintText: 'Title',
                            counterText: '',
                            filled: true,
                            fillColor: const Color(0xFFF4F4F8),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextField(
                        controller: _body,
                        minLines: _isBlog ? 6 : 4,
                        maxLines: 10,
                        maxLength: 5000,
                        decoration: InputDecoration(
                          hintText: _isBlog
                              ? 'Share your article...'
                              : "What's on your mind?",
                          counterText: '',
                          filled: true,
                          fillColor: const Color(0xFFF4F4F8),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      if (_imageUrl != null)
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Image.network(_imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                        color: const Color(0xFFEEF0F4))),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Material(
                                color: Colors.black54,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () => setState(() => _imageUrl = null),
                                  child: const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Icon(Icons.close,
                                        color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: _uploading ? null : _pickImage,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFFE1E3E6)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                if (_uploading)
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                else
                                  const Icon(Icons.image_outlined,
                                      color: AppColors.textSecondary, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  _uploading
                                      ? 'Uploading...'
                                      : _isBlog
                                          ? 'Add cover image (required)'
                                          : 'Add image (optional)',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _canPost ? _submit : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.buttonStart,
                            disabledBackgroundColor: const Color(0xFFD5D7DB),
                            disabledForegroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _submitting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : Text(_isBlog ? 'Publish' : 'Post',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback? onClose;
  const _Header({required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE7E5E5), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

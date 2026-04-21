import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ComposerPill extends StatelessWidget {
  final String? avatarUrl;
  final String hint;
  final VoidCallback onTap;

  const ComposerPill({
    super.key,
    required this.hint,
    required this.onTap,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF446BA5),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                backgroundImage: (avatarUrl ?? '').isNotEmpty
                    ? NetworkImage(avatarUrl!)
                    : null,
                child: (avatarUrl ?? '').isEmpty
                    ? const Icon(Icons.person,
                        color: AppColors.textMuted, size: 20)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F8),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(hint,
                      style: const TextStyle(
                          color: Color(0xFF494949), fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0x33FFFFFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

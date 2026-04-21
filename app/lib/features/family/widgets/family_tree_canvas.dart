import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/family.dart';

/// Dark navy card that renders the user in the center with their family
/// members arranged in a circle around them. Up to 6 avatars for readability;
/// beyond that, extras show as a "+N more" chip at bottom-right.
class FamilyTreeCanvas extends StatelessWidget {
  final String selfName;
  final String? selfAvatar;
  final List<FamilyMember> members;
  final double height;

  const FamilyTreeCanvas({
    super.key,
    required this.selfName,
    this.selfAvatar,
    this.members = const [],
    this.height = 320,
  });

  @override
  Widget build(BuildContext context) {
    final visible = members.take(6).toList();
    final overflow = members.length - visible.length;

    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F1236), Color(0xFF1A1149)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final centerX = c.maxWidth / 2;
          final centerY = c.maxHeight / 2;
          final radius = math.min(c.maxWidth, c.maxHeight) * 0.35;
          final children = <Widget>[
            Positioned(
              left: centerX - 44,
              top: centerY - 44,
              child: _Avatar(
                name: selfName,
                subtitle: 'You',
                url: selfAvatar,
                size: 88,
                selected: true,
              ),
            ),
          ];

          for (var i = 0; i < visible.length; i++) {
            final angle = (2 * math.pi / math.max(visible.length, 1)) * i - math.pi / 2;
            final dx = centerX + math.cos(angle) * radius - 36;
            final dy = centerY + math.sin(angle) * radius - 36;
            children.add(Positioned(
              left: dx,
              top: dy,
              child: _Avatar(
                name: visible[i].displayName,
                subtitle: relationLabel(visible[i].relation),
                url: visible[i].displayAvatar,
                size: 72,
              ),
            ));
          }

          if (overflow > 0) {
            children.add(Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('+$overflow more',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ));
          }

          return Stack(children: children);
        },
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final String subtitle;
  final String? url;
  final double size;
  final bool selected;

  const _Avatar({
    required this.name,
    required this.subtitle,
    this.url,
    this.size = 64,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? Colors.white : Colors.white.withValues(alpha: 0.5),
              width: selected ? 2.5 : 1.5,
            ),
          ),
          child: ClipOval(
            child: url != null
                ? Image.network(
                    url!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _initialsBg(initials, size),
                  )
                : _initialsBg(initials, size),
          ),
        ),
        const SizedBox(height: 6),
        Text(name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            )),
        Text(subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 10,
            )),
      ],
    );
  }

  Widget _initialsBg(String initials, double size) {
    return Container(
      color: const Color(0xFF4D2063),
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.35,
        ),
      ),
    );
  }
}

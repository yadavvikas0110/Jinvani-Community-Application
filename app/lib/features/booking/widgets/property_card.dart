import 'package:flutter/material.dart';
import '../models/property.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;
  final VoidCallback onSave;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    property.primaryImage,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 180,
                      color: const Color(0xFFF0F0F0),
                      child: const Icon(Icons.image_outlined,
                          size: 48, color: Color(0xFFBBBBBB)),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: onSave,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        property.isSaved
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        size: 18,
                        color: property.isSaved
                            ? const Color(0xFF7C3AED)
                            : const Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 12, color: Color(0xFFFFC107)),
                        const SizedBox(width: 3),
                        Text(
                          property.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          ' (${property.reviewCount})',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: Color(0xFF9EA1A8)),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          property.location,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF9EA1A8)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '₹${property.startingPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF7C3AED),
                              ),
                            ),
                            const TextSpan(
                              text: '/night',
                              style: TextStyle(
                                  fontSize: 11, color: Color(0xFF9EA1A8)),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _InfoPill(
                              icon: Icons.meeting_room_outlined,
                              label: '${property.rooms.length} Rooms'),
                          const SizedBox(width: 6),
                          if (property.rooms.isNotEmpty)
                            _InfoPill(
                                icon: Icons.people_outline,
                                label: 'Up to ${property.rooms.first.maxGuests}'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F0FF),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: const Color(0xFF7C3AED)),
            const SizedBox(width: 3),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7C3AED),
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
}

class CityCategoryPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const CityCategoryPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF7C3AED) : const Color(0xFFEDE9FF),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : const Color(0xFF7C3AED),
            ),
          ),
        ),
      );
}

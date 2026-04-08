import 'package:flutter/material.dart';

class DisponibiliteBadge extends StatelessWidget {
  final String disponibilite;
  const DisponibiliteBadge({super.key, required this.disponibilite});

  @override
  Widget build(BuildContext context) {
    final cfg = _config();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: cfg.dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            cfg.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: cfg.text,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeConfig _config() {
    switch (disponibilite) {
      case 'visite_en_cours':
        return _BadgeConfig(
          bg: const Color(0xFFFFF3E0),
          dot: const Color(0xFFE65100),
          text: const Color(0xFFE65100),
          label: 'Visite en cours',
        );
      case 'loue':
        return _BadgeConfig(
          bg: const Color(0xFFFFEBEE),
          dot: const Color(0xFFC62828),
          text: const Color(0xFFC62828),
          label: 'Loué',
        );
      case 'vendu':
        return _BadgeConfig(
          bg: const Color(0xFFFFEBEE),
          dot: const Color(0xFFC62828),
          text: const Color(0xFFC62828),
          label: 'Vendu',
        );
      default: // disponible
        return _BadgeConfig(
          bg: const Color(0xFFE8F5E9),
          dot: const Color(0xFF2E7D32),
          text: const Color(0xFF2E7D32),
          label: 'Disponible',
        );
    }
  }
}

class _BadgeConfig {
  final Color bg, dot, text;
  final String label;
  const _BadgeConfig({
    required this.bg,
    required this.dot,
    required this.text,
    required this.label,
  });
}

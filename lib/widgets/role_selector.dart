import 'package:flutter/material.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_font.dart';

enum UserRole { acheteur, courtier }

class RoleSelector extends StatelessWidget {
  final UserRole? selected;
  final void Function(UserRole) onSelect;

  const RoleSelector({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RoleCard(
            role: UserRole.acheteur,
            icon: Icons.home_outlined,
            title: 'Acheteur / Locataire',
            subtitle: 'Je cherche un bien',
            isSelected: selected == UserRole.acheteur,
            onTap: () => onSelect(UserRole.acheteur),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _RoleCard(
            role: UserRole.courtier,
            icon: Icons.handshake_outlined,
            title: 'Courtier',
            subtitle: 'Je publie des biens',
            isSelected: selected == UserRole.courtier,
            onTap: () => onSelect(UserRole.courtier),
          ),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final UserRole role;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCourtier = role == UserRole.courtier;
    final borderColor = isSelected
        ? (isCourtier ? DiwaneColors.navy : DiwaneColors.orange)
        : DiwaneColors.cardBorder;
    final bgColor = isSelected
        ? (isCourtier ? DiwaneColors.navyLight : DiwaneColors.orangeLight)
        : DiwaneColors.surface;
    final iconColor = isSelected
        ? (isCourtier ? DiwaneColors.navy : DiwaneColors.orange)
        : DiwaneColors.textMuted;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontFamily: AppFont.interSemiBold,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? iconColor : DiwaneColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: AppFont.interRegular,
                fontSize: 12,
                color: DiwaneColors.textMuted,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.check_circle_rounded, color: iconColor, size: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

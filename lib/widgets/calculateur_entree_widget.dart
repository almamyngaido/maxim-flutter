import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/bien_diwane_model.dart';

/// Calculateur "Total à payer à l'entrée" — uniquement pour les locations.
class CalculateurEntreeWidget extends StatefulWidget {
  final BienDiwane bien;
  const CalculateurEntreeWidget({super.key, required this.bien});

  @override
  State<CalculateurEntreeWidget> createState() =>
      _CalculateurEntreeWidgetState();
}

class _CalculateurEntreeWidgetState extends State<CalculateurEntreeWidget> {
  late int _cautionMois;
  late int _avanceMois;

  @override
  void initState() {
    super.initState();
    _cautionMois = widget.bien.cautionMois ?? 2;
    _avanceMois = widget.bien.avanceMois ?? 1;
  }

  int get _loyer => widget.bien.loyer?.toInt() ?? 0;
  int get _total => _loyer * (_cautionMois + _avanceMois);

  @override
  Widget build(BuildContext context) {
    if (_loyer == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DiwaneColors.navyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DiwaneColors.cardBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calculate_outlined,
                  color: DiwaneColors.navy, size: 18),
              SizedBox(width: 8),
              Text(
                'Calculateur d\'entrée',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: DiwaneColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Loyer mensuel (fixe)
          _LigneFixe(label: 'Loyer mensuel', montant: _loyer),

          // Caution (ajustable)
          _LigneAvecStepper(
            label: 'Caution',
            mois: _cautionMois,
            montantParMois: _loyer,
            onChanged: (v) => setState(() => _cautionMois = v),
            min: 1,
            max: 6,
          ),

          // Avance (ajustable)
          _LigneAvecStepper(
            label: 'Avance loyer',
            mois: _avanceMois,
            montantParMois: _loyer,
            onChanged: (v) => setState(() => _avanceMois = v),
            min: 1,
            max: 3,
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: DiwaneColors.cardBorder),
          ),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total à avoir le jour J',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              Text(
                _fcfa(_total),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: DiwaneColors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          const Text(
            'Caution récupérable en fin de bail · Ajustez selon votre accord avec le courtier',
            style: TextStyle(
                fontSize: 10, color: DiwaneColors.textMuted, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ── Ligne montant fixe ────────────────────────────────────────────────────────

class _LigneFixe extends StatelessWidget {
  final String label;
  final int montant;
  const _LigneFixe({required this.label, required this.montant});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: DiwaneColors.textPrimary)),
          Text(_fcfa(montant),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DiwaneColors.textPrimary)),
        ],
      ),
    );
  }
}

// ── Ligne avec stepper -/+ ────────────────────────────────────────────────────

class _LigneAvecStepper extends StatelessWidget {
  final String label;
  final int mois;
  final int montantParMois;
  final void Function(int) onChanged;
  final int min;
  final int max;

  const _LigneAvecStepper({
    required this.label,
    required this.mois,
    required this.montantParMois,
    required this.onChanged,
    required this.min,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text('$label ($mois mois)',
                style: const TextStyle(fontSize: 12)),
          ),
          Row(
            children: [
              _StepBtn(
                icon: Icons.remove,
                enabled: mois > min,
                onTap: () => onChanged(mois - 1),
              ),
              const SizedBox(width: 8),
              Text(
                _fcfa(mois * montantParMois),
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              _StepBtn(
                icon: Icons.add,
                enabled: mois < max,
                onTap: () => onChanged(mois + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepBtn(
      {required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: enabled ? DiwaneColors.navyLight : Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon,
            size: 14,
            color: enabled ? DiwaneColors.navy : Colors.grey[400]),
      ),
    );
  }
}

String _fcfa(int montant) =>
    '${NumberFormat('#,###', 'fr_FR').format(montant)} FCFA';

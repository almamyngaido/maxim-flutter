import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/publier_bien_controller.dart';

class Step5Prix extends StatelessWidget {
  const Step5Prix({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PublierBienController>();

    return Obx(() => c.typeTransaction.value == 'location'
        ? _PrixLocation(c: c)
        : _PrixVente(c: c));
  }
}

// ─── Location ─────────────────────────────────────────────────────────────────

class _PrixLocation extends StatelessWidget {
  final PublierBienController c;
  const _PrixLocation({required this.c});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Loyer mensuel
          const _Label('Loyer mensuel (FCFA) *'),
          const SizedBox(height: 8),
          _MontantField(
            hintText: 'Ex: 350000',
            initialValue: c.loyer.value,
            onChanged: (v) => c.loyer.value = v,
          ),
          const SizedBox(height: 16),

          // Caution
          const _Label('Caution (nb de mois)'),
          const SizedBox(height: 8),
          Obx(() => _MoisStepper(value: c.cautionMois.value, onChanged: (v) => c.cautionMois.value = v)),
          const SizedBox(height: 16),

          // Avance
          const _Label('Avance (nb de mois)'),
          const SizedBox(height: 8),
          Obx(() => _MoisStepper(value: c.avanceMois.value, onChanged: (v) => c.avanceMois.value = v)),
          const SizedBox(height: 16),

          // Charges séparées
          Obx(() => SwitchListTile(
            value: c.chargesSep.value,
            onChanged: (v) => c.chargesSep.value = v,
            title: const Text('Charges séparées ?', style: TextStyle(fontSize: 14, color: DiwaneColors.textPrimary)),
            activeColor: DiwaneColors.navy,
            contentPadding: EdgeInsets.zero,
          )),
          Obx(() => c.chargesSep.value
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const _Label('Montant des charges (FCFA/mois)'),
                    const SizedBox(height: 8),
                    _MontantField(hintText: 'Ex: 20000', initialValue: c.charges.value, onChanged: (v) => c.charges.value = v),
                  ]),
                )
              : const SizedBox.shrink()),

          // Prix négociable
          Obx(() => SwitchListTile(
            value: c.prixNegociable.value,
            onChanged: (v) => c.prixNegociable.value = v,
            title: const Text('Prix négociable ?', style: TextStyle(fontSize: 14, color: DiwaneColors.textPrimary)),
            activeColor: DiwaneColors.navy,
            contentPadding: EdgeInsets.zero,
          )),

          // Total calculé
          const SizedBox(height: 8),
          Obx(() {
            final total = c.totalEntree;
            if (total == 0) return const SizedBox.shrink();
            final fmt = NumberFormat('#,###', 'fr_FR').format(total.round());
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DiwaneColors.orangeLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DiwaneColors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total à l'entrée", style: TextStyle(fontWeight: FontWeight.bold, color: DiwaneColors.textPrimary)),
                  Text('$fmt FCFA', style: const TextStyle(fontWeight: FontWeight.bold, color: DiwaneColors.orange, fontSize: 16)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Vente ────────────────────────────────────────────────────────────────────

class _PrixVente extends StatelessWidget {
  final PublierBienController c;
  const _PrixVente({required this.c});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prix de vente
          const _Label('Prix de vente (FCFA) *'),
          const SizedBox(height: 8),
          _MontantField(
            hintText: 'Ex: 85000000',
            initialValue: c.prix.value,
            onChanged: (v) => c.prix.value = v,
          ),
          const SizedBox(height: 16),

          // Prix négociable
          Obx(() => SwitchListTile(
            value: c.prixNegociable.value,
            onChanged: (v) => c.prixNegociable.value = v,
            title: const Text('Prix négociable ?', style: TextStyle(fontSize: 14, color: DiwaneColors.textPrimary)),
            activeColor: DiwaneColors.navy,
            contentPadding: EdgeInsets.zero,
          )),

          // Commission
          const SizedBox(height: 8),
          const _Label('Commission agent (%)'),
          const SizedBox(height: 8),
          Obx(() => _MoisStepper(
            value: c.commissionPct.value,
            min: 1,
            max: 15,
            onChanged: (v) => c.commissionPct.value = v,
            suffix: '%',
          )),
        ],
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DiwaneColors.textPrimary));
  }
}

class _MontantField extends StatefulWidget {
  final String hintText;
  final String initialValue;
  final ValueChanged<String> onChanged;
  const _MontantField({required this.hintText, required this.initialValue, required this.onChanged});

  @override
  State<_MontantField> createState() => _MontantFieldState();
}
class _MontantFieldState extends State<_MontantField> {
  late final TextEditingController _ctrl;
  @override void initState() { super.initState(); _ctrl = TextEditingController(text: widget.initialValue); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _ctrl,
      onChanged: widget.onChanged,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(fontSize: 15, color: DiwaneColors.textPrimary),
      decoration: InputDecoration(
        hintText: widget.hintText, hintStyle: const TextStyle(color: DiwaneColors.textMuted),
        suffixText: 'FCFA', suffixStyle: const TextStyle(color: DiwaneColors.textMuted),
        filled: true, fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: DiwaneColors.cardBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: DiwaneColors.cardBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: DiwaneColors.navy, width: 1.5)),
      ),
    );
  }
}

class _MoisStepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final String suffix;

  const _MoisStepper({required this.value, this.min = 0, this.max = 12, required this.onChanged, this.suffix = 'mois'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Btn(icon: Icons.remove, active: value > min, onTap: () => onChanged(value - 1)),
        const SizedBox(width: 16),
        Text('$value $suffix', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DiwaneColors.navy)),
        const SizedBox(width: 16),
        _Btn(icon: Icons.add, active: value < max, onTap: () => onChanged(value + 1)),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _Btn({required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: active ? onTap : null,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: active ? DiwaneColors.navyLight : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: DiwaneColors.cardBorder),
        ),
        child: Icon(icon, size: 18, color: active ? DiwaneColors.navy : Colors.grey[400]),
      ),
    );
  }
}

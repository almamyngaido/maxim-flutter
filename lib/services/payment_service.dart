import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/diwane_auth_controller.dart';

class PaymentService extends GetxService {
  static const _devMode = true; // ← passer à false quand Wave est activé

  static String get _base => '${ApiConfig.baseUrl}/api';
  final _client = http.Client();

  Map<String, String> _headers() {
    final token = DiwaneAuthController.to.token.value;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _handle(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    String message = 'Erreur ${response.statusCode}';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      message = body['message']?.toString() ?? message;
    } catch (_) {}
    throw Exception(message);
  }

  // ── Initier un abonnement ───────────────────────────────────────────────────
  Future<PaymentSession> initierAbonnement(String plan) async {
    if (_devMode) {
      await Future.delayed(const Duration(milliseconds: 800));
      final fakeId = 'dev_abo_${plan}_${DateTime.now().millisecondsSinceEpoch}';
      return PaymentSession(checkoutUrl: '', transactionId: fakeId, reference: 'REF-$fakeId');
    }
    final response = await _client.post(
      Uri.parse('$_base/payments/abonnement/initier'),
      headers: _headers(),
      body: jsonEncode({'plan': plan}),
    );
    return PaymentSession.fromJson(_handle(response));
  }

  // ── Initier un boost annonce ────────────────────────────────────────────────
  Future<PaymentSession> initierBoost(String bienId, int dureeJours) async {
    if (_devMode) {
      await Future.delayed(const Duration(milliseconds: 800));
      final fakeId = 'dev_boost_${DateTime.now().millisecondsSinceEpoch}';
      return PaymentSession(checkoutUrl: '', transactionId: fakeId, reference: 'REF-$fakeId');
    }
    final response = await _client.post(
      Uri.parse('$_base/payments/boost/initier'),
      headers: _headers(),
      body: jsonEncode({'bien_id': bienId, 'duree_jours': dureeJours}),
    );
    return PaymentSession.fromJson(_handle(response));
  }

  // ── Ouvrir l'URL Wave Checkout ──────────────────────────────────────────────
  Future<void> ouvrirWaveCheckout(String checkoutUrl) async {
    if (_devMode) return; // En dev, on saute l'ouverture de Wave
    final uri = Uri.parse(checkoutUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Impossible d\'ouvrir Wave. Vérifiez que Wave est installé.');
    }
  }

  // ── Vérifier le statut d'un paiement ───────────────────────────────────────
  Future<String> verifierStatut(String transactionId) async {
    if (_devMode && transactionId.startsWith('dev_')) {
      // Appelle le backend pour confirmer manuellement la transaction de test
      final response = await _client.post(
        Uri.parse('$_base/payments/test/confirmer/$transactionId'),
        headers: _headers(),
      );
      if (response.statusCode == 200) return 'succes';
      return 'initiee';
    }
    final response = await _client.get(
      Uri.parse('$_base/payments/statut/$transactionId'),
      headers: _headers(),
    );
    final data = _handle(response);
    return data['statut'] as String? ?? 'initiee';
  }

  // ── Polling jusqu'à confirmation (max 5 min) ────────────────────────────────
  Future<bool> attendreConfirmation(String transactionId) async {
    if (_devMode && transactionId.startsWith('dev_')) {
      // En dev : confirme immédiatement après 2s
      await Future.delayed(const Duration(seconds: 2));
      final statut = await verifierStatut(transactionId);
      return statut == 'succes';
    }
    const maxTentatives = 100; // 100 × 3s = 5 min
    for (int i = 0; i < maxTentatives; i++) {
      await Future.delayed(const Duration(seconds: 3));
      try {
        final statut = await verifierStatut(transactionId);
        if (statut == 'succes') return true;
        if (statut == 'echec') return false;
      } catch (_) {
        // Continuer le polling même en cas d'erreur réseau temporaire
      }
    }
    return false; // Timeout
  }

  @override
  void onClose() {
    _client.close();
    super.onClose();
  }
}

class PaymentSession {
  final String checkoutUrl;
  final String transactionId;
  final String reference;

  PaymentSession({
    required this.checkoutUrl,
    required this.transactionId,
    required this.reference,
  });

  factory PaymentSession.fromJson(Map<String, dynamic> json) => PaymentSession(
        checkoutUrl:   json['checkout_url']   as String,
        transactionId: json['transaction_id'] as String,
        reference:     json['reference']      as String,
      );
}

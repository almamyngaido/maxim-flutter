import 'package:luxury_real_estate_flutter_ui_kit/model/bien_immo_model.dart';

class ParticipantUser {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String? phoneNumber;

  ParticipantUser({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.phoneNumber,
  });

  factory ParticipantUser.fromJson(Map<String, dynamic> json) {
    return ParticipantUser(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'] ?? '',
      email: json['email'],
      phoneNumber: json['phoneNumber'],
    );
  }

  String get fullName => '$prenom $nom'.trim();
}

class Conversation {
  final String id;
  final String bienImmoId;
  final List<String> participantIds;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final int unreadCountBuyer;
  final int unreadCountSeller;
  final String? lastMessagePreview;
  final BienImmo? bienImmo;
  final ParticipantUser? otherParticipant;

  Conversation({
    required this.id,
    required this.bienImmoId,
    required this.participantIds,
    required this.createdAt,
    required this.lastMessageAt,
    required this.unreadCountBuyer,
    required this.unreadCountSeller,
    this.lastMessagePreview,
    this.bienImmo,
    this.otherParticipant,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      bienImmoId: json['bienImmoId'],
      participantIds: List<String>.from(json['participantIds']),
      createdAt: DateTime.parse(json['createdAt']),
      lastMessageAt: DateTime.parse(json['lastMessageAt']),
      unreadCountBuyer: json['unreadCountBuyer'] ?? 0,
      unreadCountSeller: json['unreadCountSeller'] ?? 0,
      lastMessagePreview: json['lastMessagePreview'],
      bienImmo: json['bienImmo'] != null
          ? BienImmo.fromJson(json['bienImmo'])
          : null,
      otherParticipant: json['otherParticipant'] != null
          ? ParticipantUser.fromJson(json['otherParticipant'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bienImmoId': bienImmoId,
      'participantIds': participantIds,
      'createdAt': createdAt.toIso8601String(),
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'unreadCountBuyer': unreadCountBuyer,
      'unreadCountSeller': unreadCountSeller,
      'lastMessagePreview': lastMessagePreview,
    };
  }
}

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final DateTime? readAt;
  final UserSender? sender;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.isRead,
    this.readAt,
    this.sender,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      conversationId: json['conversationId'],
      senderId: json['senderId'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      sender: json['sender'] != null
          ? UserSender.fromJson(json['sender'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
    };
  }
}

class UserSender {
  final String id;
  final String nom;
  final String prenom;
  final String email;

  UserSender({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
  });

  factory UserSender.fromJson(Map<String, dynamic> json) {
    return UserSender(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'] ?? '',
      email: json['email'],
    );
  }

  String get fullName => '$prenom $nom'.trim();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
    };
  }
}

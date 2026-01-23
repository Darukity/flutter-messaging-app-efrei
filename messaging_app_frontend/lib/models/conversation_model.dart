import 'message_model.dart';

/// 💭 Model pour représenter une conversation
class Conversation {
  final String id;
  final String user1Id;
  final String user2Id;
  final List<Message> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Créer une Conversation depuis une Map (réponse API)
  factory Conversation.fromJson(Map<String, dynamic> json) {
    // 📅 Helper pour parser le timestamp (peut être String ou DateTime)
    DateTime parseTimestamp(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }
    
    final messagesList = (json['messages'] as List?)
        ?.map((msg) => Message.fromJson(msg as Map<String, dynamic>))
        .toList() ??
        [];

    return Conversation(
      id: json['_id'] ?? '',
      user1Id: json['user1_id'] ?? '',
      user2Id: json['user2_id'] ?? '',
      messages: messagesList,
      createdAt: parseTimestamp(json['createdAt']),
      updatedAt: parseTimestamp(json['updatedAt']),
    );
  }

  /// Convertir en Map pour les requêtes API
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user1_id': user1Id,
      'user2_id': user2Id,
      'messages': messages.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Obtenir le dernier message
  Message? get lastMessage =>
      messages.isNotEmpty ? messages.last : null;

  /// Vérifier si une conversation est avec un utilisateur spécifique
  bool isWithUser(String userId) =>
      user1Id == userId || user2Id == userId;

  /// Obtenir l'ID de l'autre utilisateur
  String getOtherUserId(String currentUserId) =>
      user1Id == currentUserId ? user2Id : user1Id;

  /// Créer une copie avec messages modifiés
  Conversation copyWith({List<Message>? messages}) {
    return Conversation(
      id: id,
      user1Id: user1Id,
      user2Id: user2Id,
      messages: messages ?? this.messages,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() =>
      'Conversation(id: $id, user1: $user1Id, user2: $user2Id, messages: ${messages.length})';
}

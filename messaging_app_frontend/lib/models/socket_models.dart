import 'message_model.dart';

/// 🎁 Model pour les événements Socket.io

/// 📤 Requête pour envoyer un message via socket (événement socket)
class SocketSendMessageRequest {
  final Map<String, dynamic> addedMessage;
  final Map<String, dynamic> receiver;
  final Map<String, dynamic> conversation;

  SocketSendMessageRequest({
    required this.addedMessage,
    required this.receiver,
    required this.conversation,
  });

  Map<String, dynamic> toJson() {
    return {
      'addedMessage': addedMessage,
      'receiver': receiver,
      'conversation': conversation,
    };
  }
}

/// 📨 Événement reçu quand un message arrive via socket
class MessageReceivedEvent {
  final Map<String, dynamic> addedMessage;
  final Map<String, dynamic> conversation;

  MessageReceivedEvent({
    required this.addedMessage,
    required this.conversation,
  });

  factory MessageReceivedEvent.fromJson(Map<String, dynamic> json) {
    return MessageReceivedEvent(
      addedMessage: json['addedMessage'] ?? {},
      conversation: json['conversation'] ?? {},
    );
  }

  /// Obtenir le dernier message de l'événement
  Message? get lastMessage {
    final messages = addedMessage['messages'] as List?;
    if (messages != null && messages.isNotEmpty) {
      return Message.fromJson(messages.last as Map<String, dynamic>);
    }
    return null;
  }

  @override
  String toString() =>
      'MessageReceivedEvent(conversation: ${conversation['_id']})';
}

/// 👥 Model pour les utilisateurs en ligne
class OnlineUser {
  final String userId;
  final String socketId;

  OnlineUser({
    required this.userId,
    required this.socketId,
  });

  factory OnlineUser.fromJson(Map<String, dynamic> json) {
    return OnlineUser(
      userId: json['userId'] ?? '',
      socketId: json['socketId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'socketId': socketId,
    };
  }

  @override
  String toString() => 'OnlineUser(userId: $userId, socketId: $socketId)';
}

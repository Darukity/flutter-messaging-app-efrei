import 'package:flutter/material.dart';

class Message {
  final String id;
  final String authorId;
  final String author;
  final String content;
  final String authorImage;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.authorId,
    required this.author,
    required this.content,
    required this.authorImage,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? '',
      authorId: json['author_id'] ?? '',
      author: json['author'] ?? '',
      content: json['content'] ?? '',
      authorImage: json['authorImage'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'author_id': authorId,
        'author': author,
        'content': content,
        'authorImage': authorImage,
        'timestamp': timestamp.toIso8601String(),
      };
}

class MessageProvider extends ChangeNotifier {
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Charger les messages depuis le backend
  void setMessages(List<dynamic> messagesList) {
    _messages = messagesList
        .map((msg) => Message.fromJson(msg as Map<String, dynamic>))
        .toList();
    _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    notifyListeners();
  }

  // Ajouter un message (envoyé localement)
  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  // Ajouter un message reçu en temps réel
  void addReceivedMessage(Map<String, dynamic> messageData) {
    final message = Message.fromJson(messageData);
    _messages.add(message);
    notifyListeners();
  }

  // Effacer tous les messages
  void clearMessages() {
    _messages = [];
    notifyListeners();
  }

  // Initialiser les messages avec le statut de chargement
  void startLoading() {
    _isLoading = true;
    _error = null;
    notifyListeners();
  }

  void setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void stopLoading() {
    _isLoading = false;
    notifyListeners();
  }
}

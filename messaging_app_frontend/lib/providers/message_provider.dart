import 'package:flutter/material.dart';

/// 📨 Model pour les messages (utilisé par le Provider)
/// 
/// Ce model est spécifique au Provider et pourrait être fusionné avec
/// Message du dossier models/ pour éviter la duplication
class ProviderMessage {
  final String id;
  final String authorId;
  final String author;
  final String content;
  final String authorImage;
  final DateTime timestamp;

  ProviderMessage({
    required this.id,
    required this.authorId,
    required this.author,
    required this.content,
    required this.authorImage,
    required this.timestamp,
  });

  factory ProviderMessage.fromJson(Map<String, dynamic> json) {
    return ProviderMessage(
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

/// 💬 MessageProvider - Gestion d'état des messages d'une conversation
/// 
/// 🆚 Comparaison Angular : Équivalent à un Service avec un BehaviorSubject
/// 
/// Responsabilités :
/// - Stocker la liste des messages de la conversation active
/// - Ajouter des messages (envoyés ou reçus)
/// - Gérer l'état de chargement
/// - Notifier les widgets des changements (notifyListeners)
/// 
/// 📖 Utilisation :
/// Dans un widget, utilisez `Consumer<MessageProvider>` pour s'abonner
/// aux changements et re-render automatiquement
class MessageProvider extends ChangeNotifier {
  List<ProviderMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  // Getters - Lecture seule pour l'extérieur
  List<ProviderMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 📥 Charger les messages depuis le backend
  /// 
  /// Convertit la liste JSON en objets ProviderMessage typés
  /// et trie par ordre chronologique
  void setMessages(List<dynamic> messagesList) {
    _messages = messagesList
        .map((msg) => ProviderMessage.fromJson(msg as Map<String, dynamic>))
        .toList();
    _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    notifyListeners(); // 🔔 DING DONG ! Tous les widgets qui écoutent vont se mettre à jour
  }

  /// ➕ Ajouter un message (envoyé localement)
  /// 
  /// Utilisé quand l'utilisateur envoie un message
  void addMessage(ProviderMessage message) {
    _messages.add(message);
    notifyListeners(); // 🔔 Notifier les widgets
  }

  /// 📩 Ajouter un message reçu en temps réel
  /// 
  /// Appelé quand un message arrive via Socket.IO
  void addReceivedMessage(ProviderMessage message) {
    _messages.add(message);
    notifyListeners(); // 🔔 Notifier les widgets
  }

  /// 🗑️ Effacer tous les messages
  /// 
  /// Utilisé lors du changement de conversation
  void clearMessages() {
    _messages = [];
    notifyListeners(); // 🔔 Notifier les widgets
  }

  /// ⏳ Initialiser le chargement
  /// 
  /// Affiche un spinner pendant le fetch des données
  void startLoading() {
    _isLoading = true;
    _error = null;
    notifyListeners(); // 🔔 Notifier les widgets
  }

  /// ❌ Définir une erreur
  /// 
  /// Affiche un message d'erreur à l'utilisateur
  void setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners(); // 🔔 Notifier les widgets
  }

  /// ✅ Arrêter le chargement
  /// 
  /// Cache le spinner une fois les données chargées
  void stopLoading() {
    _isLoading = false;
    notifyListeners(); // 🔔 Notifier les widgets
  }
}

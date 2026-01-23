/// 💬 Model pour représenter un message
class Message {
  final String id;
  final String authorId;
  final String author;
  final String content;
  final String? authorImage;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.authorId,
    required this.author,
    required this.content,
    this.authorImage,
    required this.timestamp,
  });

  /// Créer un Message depuis une Map (réponse API)
  factory Message.fromJson(Map<String, dynamic> json) {
    // 📅 Helper pour parser le timestamp (peut être String ou DateTime)
    DateTime parseTimestamp(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }
    
    return Message(
      id: json['_id'] ?? '',
      authorId: json['author_id'] ?? '',
      author: json['author'] ?? 'Utilisateur inconnu',
      content: json['content'] ?? '',
      authorImage: json['authorImage'],
      timestamp: parseTimestamp(json['createdAt'] ?? json['timestamp']),
    );
  }

  /// Convertir en Map pour les requêtes API
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'author_id': authorId,
      'author': author,
      'content': content,
      'authorImage': authorImage,
      'createdAt': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() => 'Message(id: $id, author: $author, content: $content)';
}

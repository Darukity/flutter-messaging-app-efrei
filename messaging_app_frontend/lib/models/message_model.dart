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
    return Message(
      id: json['_id'] ?? '',
      authorId: json['author_id'] ?? '',
      author: json['author'] ?? 'Utilisateur inconnu',
      content: json['content'] ?? '',
      authorImage: json['authorImage'],
      timestamp: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
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

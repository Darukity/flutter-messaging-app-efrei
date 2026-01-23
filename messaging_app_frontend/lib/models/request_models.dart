/// 📊 Model pour la requête d'envoi de message
class SendMessageRequest {
  final String user2Id;
  final String author;
  final String content;
  final String authorImage;

  SendMessageRequest({
    required this.user2Id,
    required this.author,
    required this.content,
    required this.authorImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'user2_id': user2Id,
      'author': author,
      'content': content,
      'authorImage': authorImage,
    };
  }
}

/// ✏️ Model pour la mise à jour du profil
class UpdateProfileRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String? profession;
  final String? employer;
  final String? location;
  final List<String>? skills;

  UpdateProfileRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profession,
    this.employer,
    this.location,
    this.skills,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };
    if (profession != null) json['profession'] = profession;
    if (employer != null) json['employer'] = employer;
    if (location != null) json['location'] = location;
    if (skills != null) json['skills'] = skills;
    return json;
  }
}

/// 📝 Model pour la mise à jour de la bio
class UpdateAboutRequest {
  final String aboutUser;

  UpdateAboutRequest({
    required this.aboutUser,
  });

  Map<String, dynamic> toJson() {
    return {
      'aboutUser': aboutUser,
    };
  }
}

/// 🖼️ Model pour la mise à jour de l'image de profil
class UpdateProfileImageRequest {
  final String image;

  UpdateProfileImageRequest({
    required this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'profileImg': image,
    };
  }
}

/// 🎨 Model pour la mise à jour de l'image de couverture
class UpdateCoverImageRequest {
  final String image;

  UpdateCoverImageRequest({
    required this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'coverImg': image,
    };
  }
}

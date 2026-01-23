/// 👤 Model pour représenter un utilisateur
class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? profession;
  final String? employer;
  final String? location;
  final String? aboutUser;
  final List<String>? skills;
  final String? profileImg;
  final String? coverImg;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profession,
    this.employer,
    this.location,
    this.aboutUser,
    this.skills,
    this.profileImg,
    this.coverImg,
  });

  /// Créer un User depuis une Map (réponse API)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      profession: json['profession'],
      employer: json['employer'],
      location: json['location'],
      aboutUser: json['aboutUser'],
      skills: json['skills'] != null ? List<String>.from(json['skills']) : null,
      profileImg: json['profileImg'],
      coverImg: json['coverImg'],
    );
  }

  /// Convertir en Map pour les requêtes API
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'profession': profession,
      'employer': employer,
      'location': location,
      'aboutUser': aboutUser,
      'skills': skills,
      'profileImg': profileImg,
      'coverImg': coverImg,
    };
  }

  /// Créer une copie avec certains champs modifiés
  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? profession,
    String? employer,
    String? location,
    String? aboutUser,
    List<String>? skills,
    String? profileImg,
    String? coverImg,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      profession: profession ?? this.profession,
      employer: employer ?? this.employer,
      location: location ?? this.location,
      aboutUser: aboutUser ?? this.aboutUser,
      skills: skills ?? this.skills,
      profileImg: profileImg ?? this.profileImg,
      coverImg: coverImg ?? this.coverImg,
    );
  }

  /// Obtenir le nom complet
  String get fullName => '$firstName $lastName';

  @override
  String toString() => 'User(id: $id, name: $fullName, email: $email)';
}

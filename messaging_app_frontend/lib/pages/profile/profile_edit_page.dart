import 'package:flutter/material.dart';
import 'package:messaging_app_frontend/services/user_profile_service.dart';
import 'package:messaging_app_frontend/services/auth_storage.dart';

class ProfileEditPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const ProfileEditPage({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _professionController;
  late TextEditingController _employerController;
  late TextEditingController _locationController;
  late TextEditingController _aboutController;
  late TextEditingController _skillsController;

  bool _isLoading = false;
  List<String> _skills = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController(text: widget.user['firstName'] ?? '');
    _lastNameController = TextEditingController(text: widget.user['lastName'] ?? '');
    _emailController = TextEditingController(text: widget.user['email'] ?? '');
    _professionController = TextEditingController(text: widget.user['profession'] ?? '');
    _employerController = TextEditingController(text: widget.user['employer'] ?? '');
    _locationController = TextEditingController(text: widget.user['location'] ?? '');
    _aboutController = TextEditingController(text: widget.user['aboutUser'] ?? '');
    _skillsController = TextEditingController();

    // Initialiser les compétences
    if (widget.user['skills'] != null && widget.user['skills'] is List) {
      _skills = List<String>.from(widget.user['skills'] as List);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _professionController.dispose();
    _employerController.dispose();
    _locationController.dispose();
    _aboutController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final skill = _skillsController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillsController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  Future<void> _saveProfile() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedData = await UserProfileService.updateProfileData(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        profession: _professionController.text.trim(),
        employer: _employerController.text.trim(),
        location: _locationController.text.trim(),
        skills: _skills,
      );

      // Mettre à jour la bio si fournie
      if (_aboutController.text.isNotEmpty) {
        await UserProfileService.updateAbout(_aboutController.text.trim());
      }

      // 🔄 IMPORTANT: Mettre à jour les données locales du user dans AuthStorage
      final updatedUser = {
        ...updatedData,
        'aboutUser': _aboutController.text.trim(),
      };
      await AuthStorage.saveUserData(updatedUser);
      print('✅ AuthStorage mis à jour avec les nouvelles données');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('❌ Erreur lors de la sauvegarde: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier mon profil'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Informations personnelles
              const Text(
                'Informations personnelles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Prénom
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'Prénom *',
                  hintText: 'Entrez votre prénom',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Nom
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Nom *',
                  hintText: 'Entrez votre nom',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email *',
                  hintText: 'Entrez votre email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),

              // Section Informations professionnelles
              const Text(
                'Informations professionnelles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Profession
              TextField(
                controller: _professionController,
                decoration: InputDecoration(
                  labelText: 'Profession',
                  hintText: 'ex: Développeur Flutter',
                  prefixIcon: const Icon(Icons.work),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Employeur
              TextField(
                controller: _employerController,
                decoration: InputDecoration(
                  labelText: 'Employeur',
                  hintText: 'ex: Google',
                  prefixIcon: const Icon(Icons.business),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Lieu
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Lieu',
                  hintText: 'ex: Paris, France',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Section À propos
              const Text(
                'À propos de vous',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _aboutController,
                decoration: InputDecoration(
                  labelText: 'Biographie',
                  hintText: 'Parlez un peu de vous...',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // Section Compétences
              const Text(
                'Compétences',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Ajouter une compétence
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _skillsController,
                      decoration: InputDecoration(
                        labelText: 'Ajouter une compétence',
                        hintText: 'ex: Flutter',
                        prefixIcon: const Icon(Icons.star),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _addSkill(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: ElevatedButton(
                      onPressed: _addSkill,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Liste des compétences
              if (_skills.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var skill in _skills)
                      Chip(
                        label: Text(skill),
                        onDeleted: () => _removeSkill(skill),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        backgroundColor: Colors.blue.shade50,
                        labelStyle: TextStyle(
                          color: Colors.blue.shade700,
                        ),
                      ),
                  ],
                ),

              const SizedBox(height: 32),

              // Boutons d'action
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Enregistrer les modifications',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

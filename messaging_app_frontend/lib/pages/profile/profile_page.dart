import 'package:flutter/material.dart';
import 'package:messaging_app_frontend/services/auth_storage.dart';
import 'package:messaging_app_frontend/models/models.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _currentUser;
  bool _isLoading = true;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _protectPage();
    await _loadProfile();
  }

  Future<void> _protectPage() async {
    final token = await AuthStorage.getToken();
    if (token == null && mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _loadProfile() async {
    try {
      // Charger les données locales d'abord (rapide)
      final userData = await AuthStorage.getUserData();
      debugPrint('👤 [ProfilePage] Chargement profil...');
      debugPrint('   Données: $userData');
      
      if (userData != null) {
        setState(() {
          _currentUser = User.fromJson(userData);
          _isLoading = false;
        });
        debugPrint('   ✅ Profil chargé: ${_currentUser!.firstName} ${_currentUser!.lastName}');
      } else {
        debugPrint('   ❌ Aucune donnée utilisateur trouvée en stockage');
        setState(() {
          _isLoading = false;
        });
      }

      // Puis faire un refresh depuis le backend pour avoir les dernières données
      // Note: Vous pouvez utiliser UserProfileService.getCurrentProfile() si vous avez un endpoint backend
    } catch (e) {
      debugPrint('❌ Erreur chargement profil: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/users');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/conversations');
        break;
      case 2:
        // Rester sur la page profile
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Impossible de charger le profil',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadProfile,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header avec image de couverture
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade300, Colors.blue.shade700],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Cercle de profil
                            Positioned(
                              bottom: -40,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 58,
                                  backgroundColor: Colors.blue.shade300,
                                  child: Text(
                                    '${_currentUser!.firstName.isNotEmpty ? _currentUser!.firstName[0] : '?'}${_currentUser!.lastName.isNotEmpty ? _currentUser!.lastName[0] : '?'}'
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 60),

                      // Informations utilisateur
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            // Nom
                            Text(
                              '${_currentUser!.firstName} ${_currentUser!.lastName}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),

                            // Email
                            Text(
                              _currentUser!.email,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Profession
                            if (_currentUser!.profession != null &&
                                _currentUser!.profession!.isNotEmpty)
                              Text(
                                _currentUser!.profession!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                            const SizedBox(height: 16),

                            // Bouton modifier profil
                            SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.pushNamed(
                                    context,
                                    '/profile-edit',
                                    arguments: _currentUser,
                                  );
                                  if (result == true && mounted) {
                                    _loadProfile();
                                  }
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text('Modifier le profil'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade500,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // KPIs Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Statistiques',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              children: [
                                _buildKPICard(
                                  'Inscrit depuis',
                                  _getJoinedDaysAgo(),
                                  Icons.calendar_today,
                                  Colors.blue,
                                ),
                                _buildKPICard(
                                  'Lieu',
                                  _currentUser!.location ?? 'Non défini',
                                  Icons.location_on,
                                  Colors.green,
                                ),
                                _buildKPICard(
                                  'Employeur',
                                  _currentUser!.employer ?? 'Non défini',
                                  Icons.business,
                                  Colors.orange,
                                ),
                                _buildKPICard(
                                  'Compétences',
                                  '${_currentUser!.skills?.length ?? 0}',
                                  Icons.star,
                                  Colors.purple,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // À propos
                      if (_currentUser!.aboutUser != null &&
                          _currentUser!.aboutUser!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'À propos',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _currentUser!.aboutUser ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),

                      // Compétences
                      if (_currentUser!.skills != null &&
                          _currentUser!.skills!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Compétences',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (_currentUser!.skills != null)
                                    for (var skill in _currentUser!.skills!)
                                      Chip(
                                        label: Text(skill),
                                        backgroundColor: Colors.blue.shade50,
                                        labelStyle: TextStyle(
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                ],
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),

                      // Bouton déconnexion
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await AuthStorage.clearToken();
                              if (mounted) {
                                Navigator.pushReplacementNamed(context, '/login');
                              }
                            },
                            icon: const Icon(Icons.logout),
                            label: const Text('Se déconnecter'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade500,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Utilisateurs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Conversations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getJoinedDaysAgo() {
    // Note: createdAt n'est pas dans le modèle User, donc retourner une valeur par défaut
    return 'Non défini';
  }
}

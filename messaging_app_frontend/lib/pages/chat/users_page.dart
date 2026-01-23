import 'package:flutter/material.dart';
import 'package:messaging_app_frontend/services/auth_storage.dart';
import 'package:messaging_app_frontend/services/conversation_service.dart';
import 'package:messaging_app_frontend/models/models.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<User> _users = [];
  User? _currentUser;
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _protectPage();
    await _loadCurrentUser();
    await _loadUsers();
  }

  Future<void> _protectPage() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<void> _loadCurrentUser() async {
    final userData = await AuthStorage.getUserData();
    if (userData != null) {
      setState(() {
        _currentUser = User.fromJson(userData);
      });
    }
  }

  Future<void> _loadUsers() async {
    try {
      final users = await ConversationService.getAllUsers();
      setState(() {
        _users = users.where((user) => user.id != _currentUser?.id).toList();
        _isLoading = false;
      });
    } catch (e) {
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
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  Future<void> _logout() async {
    await AuthStorage.clearToken();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _openChat(User user) {
    Navigator.pushNamed(
      context,
      '/chat-detail',
      arguments: user,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tous les utilisateurs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_currentUser != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue.shade50,
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            _currentUser!.firstName.isNotEmpty
                                ? _currentUser!.firstName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_currentUser!.firstName} ${_currentUser!.lastName}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                _currentUser!.email,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Cliquez sur un utilisateur pour démarrer une conversation',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  child: _users.isEmpty
                      ? const Center(
                          child: Text('Aucun utilisateur disponible'),
                        )
                      : ListView.builder(
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final user = _users[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade300,
                                  child: Text(
                                    user.firstName.isNotEmpty
                                        ? user.firstName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  '${user.firstName} ${user.lastName}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  user.email,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: const Icon(
                                  Icons.chat_bubble_outline,
                                  color: Colors.blue,
                                ),
                                onTap: () => _openChat(user),
                              ),
                            );
                          },
                        ),
                ),
              ],
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
}

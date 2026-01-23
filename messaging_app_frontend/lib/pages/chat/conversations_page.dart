import 'package:flutter/material.dart';
import 'package:messaging_app_frontend/services/auth_storage.dart';
import 'package:messaging_app_frontend/services/conversation_service.dart';
import 'package:messaging_app_frontend/models/models.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({Key? key}) : super(key: key);

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  List<Conversation> _conversations = [];
  User? _currentUser;
  bool _isLoading = true;
  int _selectedIndex = 1;
  final Map<String, User> _userCache = {}; // Cache for user details

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _protectPage();
    await _loadCurrentUser();
    await _loadConversations();
  }

  Future<void> _protectPage() async {
    final token = await AuthStorage.getToken();
    debugPrint('🔐 Protection page - Token: ${token != null ? "présent" : "absent"}');
    if (token == null) {
      if (mounted) {
        debugPrint('❌ Pas de token, redirection vers login');
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<void> _loadCurrentUser() async {
    final userData = await AuthStorage.getUserData();
    debugPrint('👤 Chargement utilisateur actuel...');
    debugPrint('   Données: $userData');
    
    if (userData != null) {
      setState(() {
        _currentUser = User.fromJson(userData);
      });
      debugPrint('   ✅ Utilisateur chargé: ${_currentUser!.firstName} ${_currentUser!.lastName}');
    } else {
      debugPrint('   ❌ Aucune donnée utilisateur trouvée en stockage');
    }
  }

  Future<void> _loadConversations() async {
    try {
      debugPrint('🔍 Chargement des conversations...');
      final conversations = await ConversationService.getConversations();
      debugPrint('   ✅ ${conversations.length} conversations récupérées');
      
      // Filter conversations where current user is involved
      final myConversations = conversations.where((conv) {
        return conv.user1Id == _currentUser?.id || 
               conv.user2Id == _currentUser?.id;
      }).toList();
      
      debugPrint('   → ${myConversations.length} conversations pour l\'utilisateur actuel');
      
      // 🔄 Rafraîchir les détails de l'utilisateur pour chaque conversation
      // Cela assure que les noms modifiés sont affichés correctement
      for (var conv in myConversations) {
        final otherUserId = conv.user1Id == _currentUser?.id
            ? conv.user2Id
            : conv.user1Id;
        
        try {
          final userDetails = await ConversationService.getUserById(otherUserId);
          _userCache[otherUserId] = userDetails;
          debugPrint('   ✅ Cache mis à jour pour: ${userDetails.fullName}');
        } catch (e) {
          debugPrint('❌ Erreur lors du chargement des détails pour $otherUserId: $e');
          // Le cache reste avec les anciennes données en cas d'erreur
        }
      }

      setState(() {
        _conversations = myConversations;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Erreur chargement conversations: $e');
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

  Future<void> _logout() async {
    await AuthStorage.clearToken();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  User _getOtherUserInfo(Conversation conversation) {
    final otherUserId = conversation.user1Id == _currentUser?.id
        ? conversation.user2Id
        : conversation.user1Id;

    // ✅ Priorité 1: Vérifier le cache (qui est rafraîchi à chaque chargement)
    if (_userCache.containsKey(otherUserId)) {
      final cachedUser = _userCache[otherUserId]!;
      if (cachedUser.firstName.isNotEmpty) {
        return cachedUser;
      }
    }

    // ✅ Priorité 2: Extraire du dernier message (fallback)
    if (conversation.messages.isNotEmpty) {
      try {
        final otherUserMessage = conversation.messages.firstWhere(
          (msg) => msg.authorId == otherUserId,
        );

        return User(
          id: otherUserId,
          firstName: otherUserMessage.author.split(' ')[0],
          lastName: otherUserMessage.author.split(' ').skip(1).join(' '),
          email: '',
          profession: null,
          employer: null,
          location: null,
          aboutUser: null,
          skills: null,
          profileImg: null,
          coverImg: null,
        );
      } catch (e) {
        // Aucun message de cet utilisateur
      }
    }

    // ✅ Priorité 3: Données par défaut
    return User(
      id: otherUserId,
      firstName: 'Utilisateur',
      lastName: '',
      email: '',
      profession: null,
      employer: null,
      location: null,
      aboutUser: null,
      skills: null,
      profileImg: null,
      coverImg: null,
    );
  }

  String _getLastMessage(Conversation conversation) {
    if (conversation.messages.isEmpty) return 'Pas de messages';
    return conversation.messages.last.content;
  }

  String _getLastMessageTime(Conversation conversation) {
    if (conversation.messages.isEmpty) return '';
    return _formatTime(conversation.messages.last.timestamp);
  }

  void _openChat(User otherUser) {
    Navigator.pushNamed(
      context,
      '/chat-detail',
      arguments: otherUser,
    ).then((_) {
      // Refresh conversations when coming back
      _loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
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
                Expanded(
                  child: _conversations.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Pas encore de conversations',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, '/users');
                                },
                                icon: const Icon(Icons.people),
                                label: const Text('Voir tous les utilisateurs'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _conversations.length,
                          itemBuilder: (context, index) {
                            final conversation = _conversations[index];
                            final otherUser = _getOtherUserInfo(conversation);
                            final lastMessage = _getLastMessage(conversation);
                            final lastTime = _getLastMessageTime(conversation);

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade300,
                                  child: Text(
                                    otherUser.firstName.isNotEmpty
                                        ? otherUser.firstName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  '${otherUser.firstName} ${otherUser.lastName}'.trim(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  lastMessage,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                trailing: Text(
                                  lastTime,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                onTap: () => _openChat(otherUser),
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/users');
        break;
      case 1:
        // Rester sur conversations
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Maintenant';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}j';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:messaging_app_frontend/services/auth_storage.dart';
import 'package:messaging_app_frontend/services/conversation_service.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({Key? key}) : super(key: key);

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  List<dynamic> _conversations = [];
  Map<String, dynamic>? _currentUser;
  bool _isLoading = true;
  int _selectedIndex = 1;
  Map<String, Map<String, dynamic>> _userCache = {}; // Cache for user details

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
        _currentUser = userData;
      });
    }
  }

  Future<void> _loadConversations() async {
    try {
      final conversations = await ConversationService.getConversations();
      // Filter conversations where current user is involved
      final myConversations = conversations.where((conv) {
        return conv['user1_id'] == _currentUser?['_id'] || 
               conv['user2_id'] == _currentUser?['_id'];
      }).toList();
// Fetch user details for conversations that need them
      for (var conv in myConversations) {
        final otherUserId = conv['user1_id'] == _currentUser?['_id']
            ? conv['user2_id']
            : conv['user1_id'];
        
        // Check if we need to fetch user details (no messages from other user yet)
        final messages = conv['messages'] as List;
        final hasOtherUserMessage = messages.any((msg) => msg['author_id'] == otherUserId);
        
        if (!hasOtherUserMessage && !_userCache.containsKey(otherUserId)) {
          try {
            final userDetails = await ConversationService.getUserById(otherUserId);
            _userCache[otherUserId] = userDetails;
          } catch (e) {
            print('Failed to fetch user details for $otherUserId: $e');
          }
        }
      }

      
      setState(() {
        _conversations = myConversations;
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

  Future<void> _logout() async {
    await AuthStorage.clearToken();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Map<String, dynamic> _getOtherUserInfo(Map<String, dynamic> conversation) {
    final otherUserId = conversation['user1_id'] == _currentUser?['_id']
        ? conversation['user2_id']
        : conversation['user1_id'];

    // Check if we have cached user details
    if (_userCache.containsKey(otherUserId)) {
      return _userCache[otherUserId]!;
    }

    // Get the last message to extract user info
    final messages = conversation['messages'] as List;
    if (messages.isNotEmpty) {
      // Try to find a message from the other user (not from current user)
      try {
        final otherUserMessage = messages.firstWhere(
          (msg) => msg['author_id'] == otherUserId,
        );

        return {
          '_id': otherUserId,
          'firstName': otherUserMessage['author']?.split(' ')[0] ?? 'Utilisateur',
          'lastName': otherUserMessage['author']?.split(' ').skip(1).join(' ') ?? '',
          'email': '',
        };
      } catch (e) {
        // No messages from other user yet, return basic info with ID
        return {
          '_id': otherUserId,
          'firstName': 'Utilisateur',
          'lastName': '',
          'email': '',
        };
      }
    }

    return {
      '_id': otherUserId,
      'firstName': 'Utilisateur',
      'lastName': '',
      'email': '',
    };
  }

  String _getLastMessage(Map<String, dynamic> conversation) {
    final messages = conversation['messages'] as List;
    if (messages.isEmpty) return 'Pas de messages';
    
    final lastMsg = messages.last;
    return lastMsg['content'] ?? '';
  }

  String _getLastMessageTime(Map<String, dynamic> conversation) {
    final messages = conversation['messages'] as List;
    if (messages.isEmpty) return '';
    
    final lastMsg = messages.last;
    return _formatTime(lastMsg['createdAt']);
  }

  void _openChat(Map<String, dynamic> otherUser) {
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
                            _currentUser!['firstName'][0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_currentUser!['firstName']} ${_currentUser!['lastName']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                _currentUser!['email'],
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
                                    otherUser['firstName'][0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  '${otherUser['firstName']} ${otherUser['lastName']}'.trim(),
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

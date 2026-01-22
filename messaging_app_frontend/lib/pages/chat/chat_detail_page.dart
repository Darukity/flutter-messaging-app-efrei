import 'package:flutter/material.dart';
import 'package:messaging_app_frontend/services/auth_storage.dart';
import 'package:messaging_app_frontend/services/conversation_service.dart';
import 'package:messaging_app_frontend/socket_service.dart';

class ChatDetailPage extends StatefulWidget {
  final Map<String, dynamic> otherUser;

  const ChatDetailPage({Key? key, required this.otherUser}) : super(key: key);

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final SocketService _socketService = SocketService();
  Map<String, dynamic>? _currentUser;
  List<dynamic> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _loadCurrentUser();
    await _loadConversation();
    _initSocket();
  }

  Future<void> _loadCurrentUser() async {
    final userData = await AuthStorage.getUserData();
    if (userData != null) {
      setState(() {
        _currentUser = userData;
      });
    }
  }

  Future<void> _loadConversation() async {
    try {
      final conversation = await ConversationService.getConversation(widget.otherUser['_id']);
      setState(() {
        if (conversation != null && conversation['messages'] != null) {
          _messages = List.from(conversation['messages']);
        }
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initSocket() {
    _socketService.initSocket();

    // Connect user to socket
    if (_currentUser != null) {
      _socketService.socket.emit('addUser', _currentUser!['_id']);
    }

    // Listen for incoming messages
    _socketService.socket.on('getMessage', (data) {
      if (mounted) {
        final message = data['addedMessage'];
        final lastMessage = message['messages'].last;

        // Only add if message is from the other user in this conversation
        if (lastMessage['author_id'] == widget.otherUser['_id']) {
          setState(() {
            _messages.add(lastMessage);
          });
          _scrollToBottom();
        }
      }
    });

    // Listen for online users
    _socketService.socket.on('getUsers', (users) {
      print('Online users: $users');
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentUser == null) {
      return;
    }

    final messageContent = _messageController.text.trim();
    _messageController.clear();

    try {
      final response = await ConversationService.sendMessage(
        user2Id: widget.otherUser['_id'],
        author: '${_currentUser!['firstName']} ${_currentUser!['lastName']}',
        content: messageContent,
        authorImage: _currentUser!['profileImage'] ?? '',
      );

      // Add message to local state
      final addedMessage = response;
      final lastMessage = addedMessage['messages'].last;

      setState(() {
        _messages.add(lastMessage);
      });

      _scrollToBottom();

      // Emit socket event
      _socketService.socket.emit('sendMessage', {
        'addedMessage': addedMessage,
        'receiver': widget.otherUser,
        'conversation': addedMessage,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'envoi: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _socketService.socket.disconnect();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.shade300,
              radius: 18,
              child: Text(
                widget.otherUser['firstName'][0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.otherUser['firstName']} ${widget.otherUser['lastName']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    widget.otherUser['email'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
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
                              'Pas encore de messages',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Envoyez le premier message !',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe = message['author_id'] == _currentUser?['_id'];

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.7,
                              ),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.blue.shade500 : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message['content'],
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black87,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTime(message['createdAt']),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isMe ? Colors.white70 : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Écrivez un message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'À l\'instant';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
    }
  }
}

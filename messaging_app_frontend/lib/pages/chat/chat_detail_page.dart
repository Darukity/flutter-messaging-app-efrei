import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:messaging_app_frontend/providers/message_provider.dart';
import 'package:messaging_app_frontend/providers/chat_provider.dart';
import 'package:messaging_app_frontend/services/auth_storage.dart';
import 'package:messaging_app_frontend/services/conversation_service.dart';
import 'package:messaging_app_frontend/config/api_config.dart';

class ChatDetailPage extends StatefulWidget {
  final Map<String, dynamic> otherUser;

  const ChatDetailPage({Key? key, required this.otherUser}) : super(key: key);

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  Map<String, dynamic>? _currentUser;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    // Charger l'utilisateur actuel
    final userData = await AuthStorage.getUserData();
    setState(() {
      _currentUser = userData;
    });

    // Initialiser le ChatProvider (singleton, une seule fois)
    final chatProvider = context.read<ChatProvider>();
    if (userData != null) {
      // Initialiser le socket si pas déjà fait
      if (!chatProvider.isConnected) {
        chatProvider.initSocket();
      }
      // Connecter l'utilisateur
      chatProvider.connectUser(userData);
      chatProvider.setOtherUser(widget.otherUser);
    }

    // Charger les messages
    if (mounted) {
      final messageProvider = context.read<MessageProvider>();
      messageProvider.startLoading();
      try {
        final conversation = await ConversationService.getConversation(widget.otherUser['_id']);
        if (conversation != null && conversation['messages'] != null) {
          messageProvider.setMessages(conversation['messages']);
        }
        messageProvider.stopLoading();
      } catch (e) {
        print('Erreur chargement messages: $e');
        messageProvider.setError(e.toString());
      }
    }

    // Écouter les messages reçus en temps réel
    if (mounted) {
      chatProvider.onMessageReceived((data) {
        if (mounted) {
          print('📨 Données reçues du socket: $data');
          final addedMessage = data['addedMessage'];
          
          if (addedMessage != null) {
            final messages = addedMessage['messages'];
            if (messages != null && messages is List && messages.isNotEmpty) {
              final lastMessage = messages.last;
              print('📌 Dernier message: author_id=${lastMessage['author_id']}, otherUserId=${widget.otherUser['_id']}');

              // Ajouter uniquement si c'est de l'autre utilisateur
              if (lastMessage['author_id'] == widget.otherUser['_id']) {
                print('✅ Ajout du message reçu de ${widget.otherUser['firstName']}');
                context.read<MessageProvider>().addReceivedMessage(lastMessage);
                _scrollToBottom();
              } else {
                print('⏭️ Ignoré: message de soi-même');
              }
            }
          }
        }
      });
    }
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
      print('📤 Envoi du message: "$messageContent" à ${widget.otherUser['firstName']}');
      
      final response = await ConversationService.sendMessage(
        user2Id: widget.otherUser['_id'],
        author: '${_currentUser!['firstName']} ${_currentUser!['lastName']}',
        content: messageContent,
        authorImage: _currentUser!['profileImage'] ?? '',
      );

      print('✅ Réponse serveur reçue: ${response.keys}');

      // Ajouter le message au provider
      final addedMessage = response;
      final lastMessage = addedMessage['messages']?.last;

      if (lastMessage != null && mounted) {
        context.read<MessageProvider>().addMessage(
          Message.fromJson(lastMessage),
        );
        print('📝 Message ajouté localement');
      }

      _scrollToBottom();

      // Émettre via socket pour notifier l'autre personne
      if (mounted) {
        print('🔔 Émission du socket pour notifier ${widget.otherUser['firstName']}');
        context.read<ChatProvider>().sendSocketMessage(
          addedMessage: addedMessage,
          conversation: addedMessage,
        );
      }
    } catch (e) {
      print('❌ Erreur envoi message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'envoi: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
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
                  // Afficher le statut en ligne
                  Consumer<ChatProvider>(
                    builder: (context, chatProvider, _) {
                      return Text(
                        chatProvider.isOnline ? 'En ligne' : 'Hors ligne',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: chatProvider.isOnline ? Colors.green : Colors.grey,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list avec Consumer
          Expanded(
            child: Consumer<MessageProvider>(
              builder: (context, messageProvider, _) {
                if (messageProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (messageProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erreur: ${messageProvider.error}',
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (messageProvider.messages.isEmpty) {
                  return Center(
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
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messageProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = messageProvider.messages[index];
                    final isMe = message.authorId == _currentUser?['_id'];

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
                              message.content,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(message.timestamp),
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

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

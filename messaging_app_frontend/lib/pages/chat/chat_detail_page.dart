import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:messaging_app_frontend/providers/message_provider.dart';
import 'package:messaging_app_frontend/providers/chat_provider.dart';
import 'package:messaging_app_frontend/services/auth_storage.dart';
import 'package:messaging_app_frontend/services/conversation_service.dart';
import 'package:messaging_app_frontend/models/models.dart' as models;

class ChatDetailPage extends StatefulWidget {
  final models.User otherUser;

  const ChatDetailPage({Key? key, required this.otherUser}) : super(key: key);

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  models.User? _currentUser;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late double _previousBottomInset = 0;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    // Charger l'utilisateur actuel
    final userData = await AuthStorage.getUserData();
    if (userData != null) {
      setState(() {
        _currentUser = models.User.fromJson(userData);
      });
    }

    // Initialiser le ChatProvider (singleton, une seule fois)
    final chatProvider = context.read<ChatProvider>();
    if (_currentUser != null) {
      // Initialiser le socket si pas déjà fait
      if (!chatProvider.isConnected) {
        chatProvider.initSocket();
      }
      // Connecter l'utilisateur
      chatProvider.connectUser(_currentUser!);
      chatProvider.setOtherUser(widget.otherUser);
    }

    // Charger les messages
    if (mounted) {
      final messageProvider = context.read<MessageProvider>();
      messageProvider.startLoading();
      try {
        final conversation = await ConversationService.getConversation(widget.otherUser.id);
        if (conversation != null && conversation.messages.isNotEmpty) {
          // Convertir les messages du modèle Conversation vers des Maps
          // setMessages() attend List<dynamic> (raw maps), pas des objets ProviderMessage
          final messageMaps = conversation.messages.map((m) {
            return {
              '_id': m.id,
              'author_id': m.authorId,
              'author': m.author,
              'content': m.content,
              'authorImage': m.authorImage,
              'timestamp': m.timestamp.toIso8601String(), // ✅ Convertir DateTime en String
            };
          }).toList();
          messageProvider.setMessages(messageMaps); // ✅ Passer les maps, pas les objets
        }
        messageProvider.stopLoading();
        // 📌 Scroller vers le bas après le chargement
        _scrollToBottom();
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
          
          if (addedMessage != null && addedMessage is Map) {
            final messages = addedMessage['messages'];
            if (messages != null && messages is List && messages.isNotEmpty) {
              // Récupérer le dernier message et le convertir en Message provider
              try {
                final lastMsgData = messages.last as Map<String, dynamic>;
                final lastMessage = ProviderMessage.fromJson(lastMsgData);
                print('📌 Dernier message: author_id=${lastMessage.authorId}, otherUserId=${widget.otherUser.id}');

                // Ajouter uniquement si c'est de l'autre utilisateur
                if (lastMessage.authorId == widget.otherUser.id) {
                  print('✅ Ajout du message reçu de ${widget.otherUser.firstName}');
                  context.read<MessageProvider>().addReceivedMessage(lastMessage);
                  _scrollToBottom();
                } else {
                  print('⏭️ Ignoré: message de soi-même');
                }
              } catch (e) {
                print('❌ Erreur conversion message: $e');
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
      print('📤 Envoi du message: "$messageContent" à ${widget.otherUser.firstName}');
      
      final response = await ConversationService.sendMessage(
        user2Id: widget.otherUser.id,
        author: '${_currentUser!.firstName} ${_currentUser!.lastName}',
        content: messageContent,
        authorImage: _currentUser!.profileImg ?? '',
      );

      print('✅ Réponse serveur reçue: id=${response.id}');

      // Ajouter le message au provider
      if (response.messages.isNotEmpty && mounted) {
        final lastModelMessage = response.messages.last;
        final lastMessageMap = {
          '_id': lastModelMessage.id,
          'author_id': lastModelMessage.authorId,
          'author': lastModelMessage.author,
          'content': lastModelMessage.content,
          'authorImage': lastModelMessage.authorImage,
          'timestamp': lastModelMessage.timestamp.toIso8601String(), // ✅ Convertir DateTime en String
        };
        final lastMessage = ProviderMessage.fromJson(lastMessageMap);
        context.read<MessageProvider>().addMessage(lastMessage);
        print('📝 Message ajouté localement');
      }

      _scrollToBottom();

      // Émettre via socket pour notifier l'autre personne
      if (mounted) {
        print('🔔 Émission du socket pour notifier ${widget.otherUser.firstName}');
        context.read<ChatProvider>().sendSocketMessage(
          addedMessage: response.toJson(),
          conversation: response.toJson(),
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
    // 📱 Détecter l'ouverture du clavier
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    // Si le clavier s'ouvre, scroller vers le bas
    if (bottomInset > _previousBottomInset) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
    _previousBottomInset = bottomInset;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.shade300,
              radius: 18,
              child: Text(
                widget.otherUser.firstName.isNotEmpty
                    ? widget.otherUser.firstName[0].toUpperCase()
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
                    '${widget.otherUser.firstName} ${widget.otherUser.lastName}',
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
                    final isMe = message.authorId == _currentUser?.id;

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

          // Message input avec gestion du clavier
          Padding(
            padding: EdgeInsets.only(
              left: 0,
              right: 0,
              top: 16,
              bottom: 0 ,
            ),
            child: Container(
              padding: EdgeInsets.only(
              left: 5,
              right: 5,
              top: 10,
              bottom: 10 ,
            ),
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
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    // ⏱️ Messages de moins d'1 jour: afficher temps relatif
    if (difference.inDays == 0) {
      if (difference.inMinutes < 1) {
        return 'À l\'instant';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m';
      } else {
        return '${difference.inHours}h';
      }
    }
    
    // 📅 Messages d'après 1 jour: afficher la date + heure exacte
    final day = timestamp.day.toString().padLeft(2, '0');
    final month = timestamp.month.toString().padLeft(2, '0');
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$day/$month/${timestamp.year} $hour:$minute';
  }
}

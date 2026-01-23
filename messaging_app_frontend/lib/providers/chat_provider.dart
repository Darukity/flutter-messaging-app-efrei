import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/api_config.dart';

class ChatProvider extends ChangeNotifier {
  static final ChatProvider _instance = ChatProvider._internal();
  late IO.Socket _socket;
  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? _otherUser;
  bool _isConnected = false;
  bool _isOnline = false;
  bool _socketInitialized = false;
  List<dynamic> _onlineUsers = []; // 📋 Stocker la liste des utilisateurs en ligne

  factory ChatProvider() {
    return _instance;
  }

  ChatProvider._internal();

  IO.Socket get socket => _socket;
  Map<String, dynamic>? get currentUser => _currentUser;
  Map<String, dynamic>? get otherUser => _otherUser;
  bool get isConnected => _isConnected;
  bool get isOnline => _isOnline;
  List<dynamic> get onlineUsers => _onlineUsers;

  // Initialiser le socket une seule fois
  void initSocket() {
    if (_socketInitialized) {
      print('Socket déjà initialisé');
      return;
    }

    _socket = IO.io(ApiConfig.socketUrl, <String, dynamic>{
      'transports': ['websocket', 'polling'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionDelay': 1000,
      'reconnectionDelayMax': 5000,
      'reconnectionAttempts': 10,
      'reconnectionDecayMultiplier': 1.5,
      'query': {
        // Passer le token si nécessaire
      },
    });

    _socketInitialized = true;
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _socket.on('connect', (_) {
      _isConnected = true;
      print('✅ Socket connecté avec ID: ${_socket.id}');
      notifyListeners();
      
      // Réémettre addUser si on a déjà un utilisateur
      if (_currentUser != null) {
        _socket.emit('addUser', _currentUser!['_id']);
      }
    });

    _socket.on('disconnect', (_) {
      _isConnected = false;
      _isOnline = false;
      print('❌ Socket déconnecté');
      notifyListeners();
    });

    _socket.on('connect_error', (error) {
      print('⚠️ Erreur connexion socket: $error');
    });

    _socket.on('getUsers', (users) {
      print('👥 Utilisateurs en ligne reçus: $users');
      _onlineUsers = users is List ? users : [];
      
      // Vérifier si l'autre utilisateur est en ligne
      if (_otherUser != null) {
        final wasOnline = _isOnline;
        _isOnline = _onlineUsers.any((user) {
          if (user is! Map) return false;
          final userId = user['userId'];
          final otherUserId = _otherUser!['_id'];
          print('   🔍 Vérification: socket userId=$userId vs otherUserId=$otherUserId');
          return userId == otherUserId;
        });
        
        if (wasOnline != _isOnline) {
          print('${_isOnline ? '✅ EN LIGNE' : '⏱️ HORS LIGNE'} ${_otherUser!['firstName']}');
          notifyListeners();
        } else {
          print('   → Statut inchangé (${_isOnline ? 'EN LIGNE' : 'HORS LIGNE'})');
        }
      } else {
        print('   → Pas d\'autre utilisateur défini');
      }
    });

    _socket.on('getMessage', (data) {
      print('📨 Nouveau message reçu: $data');
    });

    _socket.on('error', (error) {
      print('❌ Erreur socket: $error');
    });
  }

  // Connecter l'utilisateur au socket
  void connectUser(Map<String, dynamic> user) {
    _currentUser = user;
    if (!_socketInitialized) {
      initSocket();
    }
    
    print('🔗 Connexion utilisateur: ${user['_id']}');
    _socket.emit('addUser', user['_id']);
  }

  // Définir l'autre utilisateur de la conversation
  void setOtherUser(Map<String, dynamic> user) {
    _otherUser = user;
    
    // 🔍 Vérifier immédiatement le statut en ligne contre la liste stockée
    if (_onlineUsers.isNotEmpty) {
      final wasOnline = _isOnline;
      _isOnline = _onlineUsers.any((u) {
        if (u is! Map) return false;
        return u['userId'] == user['_id'];
      });
      
      if (wasOnline != _isOnline) {
        print('🔄 Statut immédiat: ${_isOnline ? '✅ EN LIGNE' : '⏱️ HORS LIGNE'} ${user['firstName']}');
      }
    } else {
      print('⚠️ Liste utilisateurs vide, en attente de getUsers');
      _isOnline = false;
    }
    
    notifyListeners();
  }

  // Émettre un message
  void sendSocketMessage({
    required Map<String, dynamic> addedMessage,
    required Map<String, dynamic> conversation,
  }) {
    // 🔍 Vérifier si le socket est vraiment connecté
    if (!_socket.connected) {
      print('⚠️ Socket non connecté (_socket.connected = ${_socket.connected}), tentative de reconnexion...');
      // Attendre un peu et réessayer
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_socket.connected) {
          _sendMessageNow(addedMessage, conversation);
        } else {
          print('❌ Socket toujours non connecté après délai');
        }
      });
      return;
    }

    _sendMessageNow(addedMessage, conversation);
  }

  // Envoyer le message maintenant (socket connecté)
  void _sendMessageNow(
    Map<String, dynamic> addedMessage,
    Map<String, dynamic> conversation,
  ) {
    print('📤 Envoi du message via socket à: ${_otherUser!['_id']}');
    _socket.emit('sendMessage', {
      'addedMessage': addedMessage,
      'receiver': _otherUser,
      'conversation': conversation,
    });
  }

  // Écouter les messages reçus (une seule fois)
  void onMessageReceived(Function(Map<String, dynamic>) callback) {
    // Supprimer les anciens listeners pour éviter les doublons
    _socket.off('getMessage');
    
    // Ajouter le nouveau listener
    _socket.on('getMessage', (data) {
      print('📩 Callback message reçu: $data');
      callback(data);
    });
  }

  // Déconnecter le socket
  void disconnect() {
    if (_socketInitialized && _socket.connected) {
      _socket.disconnect();
    }
    _isConnected = false;
    _isOnline = false;
    _currentUser = null;
    _otherUser = null;
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}

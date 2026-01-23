import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/api_config.dart';
import '../models/models.dart';

/// 🔌 ChatProvider - Le "Cerveau" de la connexion Socket.IO
/// 
/// 🆚 Comparaison Angular : C'est l'équivalent d'un Service qui gère WebSocket
/// 
/// Responsabilités :
/// - Gérer la connexion Socket.IO avec le backend
/// - Maintenir la liste des utilisateurs en ligne
/// - Écouter les événements temps réel (messages, statuts)
/// - Notifier les widgets quand quelque chose change (notifyListeners)
/// 
/// 📖 Philosophie Provider :
/// Les widgets s'abonnent avec `Consumer<ChatProvider>` et sont automatiquement
/// re-rendered quand `notifyListeners()` est appelé
class ChatProvider extends ChangeNotifier {
  // Singleton pattern pour garantir une seule instance dans toute l'app
  static final ChatProvider _instance = ChatProvider._internal();
  late IO.Socket _socket;
  User? _currentUser;
  User? _otherUser;
  bool _isConnected = false;
  bool _isOnline = false;
  bool _socketInitialized = false;
  List<OnlineUser> _onlineUsers = []; // ✅ Models typés

  factory ChatProvider() {
    return _instance;
  }

  ChatProvider._internal();

  // Getters - Lecture seule pour l'extérieur
  IO.Socket get socket => _socket;
  User? get currentUser => _currentUser;
  User? get otherUser => _otherUser;
  bool get isConnected => _isConnected;
  bool get isOnline => _isOnline;
  List<OnlineUser> get onlineUsers => _onlineUsers;

  /// 🚀 Initialiser le socket une seule fois
  /// 
  /// Cette méthode configure la connexion Socket.IO avec le backend.
  /// Elle ne doit être appelée qu'une seule fois au démarrage.
  void initSocket() {
    if (_socketInitialized) {
      debugPrint('⚠️ Socket déjà initialisé, état connecté: ${_socket.connected}');
      return;
    }

    debugPrint('🚀 Initialisation du socket...');
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
    debugPrint('   Socket objet créé, autoConnect: true');
    _setupSocketListeners();
  }

  /// 📡 Configurer les écouteurs Socket.IO
  /// 
  /// Ces listeners réagissent aux événements envoyés par le backend
  void _setupSocketListeners() {
    _socket.on('connect', (_) {
      _isConnected = true;
      debugPrint('✅ Socket connecté avec ID: ${_socket.id}');
      notifyListeners(); // 🔔 Notifier les widgets
      
      // Réémettre addUser si on a déjà un utilisateur
      if (_currentUser != null) {
        debugPrint('   📤 Rééémission addUser pour ${_currentUser!.id}');
        _socket.emit('addUser', _currentUser!.id);
      }
    });

    _socket.on('disconnect', (_) {
      _isConnected = false;
      _isOnline = false;
      debugPrint('❌ Socket déconnecté');
      notifyListeners(); // 🔔 Notifier les widgets
    });

    _socket.on('connect_error', (error) {
      debugPrint('⚠️ Erreur connexion socket: $error');
      _isConnected = false;
    });

    _socket.on('getUsers', (users) {
      debugPrint('👥 Utilisateurs en ligne reçus: $users');
      
      // ✅ Convertir en models OnlineUser
      _onlineUsers = (users as List)
          .map((item) => OnlineUser.fromJson(item as Map<String, dynamic>))
          .toList();
      
      // Vérifier si l'autre utilisateur est en ligne
      if (_otherUser != null) {
        final wasOnline = _isOnline;
        _isOnline = _onlineUsers.any((u) => u.userId == _otherUser!.id);
        
        if (wasOnline != _isOnline) {
          debugPrint('${_isOnline ? '✅ EN LIGNE' : '⏱️ HORS LIGNE'} ${_otherUser!.fullName}');
          notifyListeners(); // 🔔 Notifier les widgets
        } else {
          debugPrint('   → Statut inchangé (${_isOnline ? 'EN LIGNE' : 'HORS LIGNE'})');
        }
      } else {
        debugPrint('   → Pas d\'autre utilisateur défini');
      }
    });

    _socket.on('getMessage', (data) {
      debugPrint('📨 Nouveau message reçu: $data');
    });

    _socket.on('error', (error) {
      debugPrint('❌ Erreur socket: $error');
    });
  }

  /// 🔗 Connecter l'utilisateur au socket
  /// 
  /// Cette méthode enregistre l'utilisateur actuel dans le système Socket.IO
  /// pour qu'il soit visible comme "en ligne" par les autres utilisateurs
  void connectUser(User user) {
    _currentUser = user;
    if (!_socketInitialized) {
      initSocket();
    }
    
    debugPrint('🔗 Connexion utilisateur: ${user.id}');
    
    // 🔍 Vérifier si le socket est déjà connecté
    if (_socket.connected) {
      debugPrint('   ✅ Socket déjà connecté, émission addUser immédiate');
      _socket.emit('addUser', user.id);
    } else {
      debugPrint('   ⏳ Socket pas encore connecté, attente de la connexion...');
      // Attendre que le socket se connecte, puis émettre addUser
      _socket.onConnect((_) {
        debugPrint('   ✅ Socket connecté maintenant, émission addUser');
        _socket.emit('addUser', user.id);
      });
    }
  }

  /// 👤 Définir l'autre utilisateur de la conversation
  /// 
  /// Permet de suivre le statut en ligne de l'autre personne
  void setOtherUser(User user) {
    _otherUser = user;
    
    // 🔍 Vérifier immédiatement le statut en ligne contre la liste stockée
    if (_onlineUsers.isNotEmpty) {
      final wasOnline = _isOnline;
      _isOnline = _onlineUsers.any((u) => u.userId == user.id);
      
      if (wasOnline != _isOnline) {
        debugPrint('🔄 Statut immédiat: ${_isOnline ? '✅ EN LIGNE' : '⏱️ HORS LIGNE'} ${user.fullName}');
      }
    } else {
      debugPrint('⚠️ Liste utilisateurs vide, en attente de getUsers');
      _isOnline = false;
    }
    
    notifyListeners(); // 🔔 Notifier les widgets
  }

  /// 📤 Émettre un message via Socket.IO
  /// 
  /// Envoie un message en temps réel à l'autre utilisateur
  void sendSocketMessage({
    required Map<String, dynamic> addedMessage,
    required Map<String, dynamic> conversation,
  }) {
    // 🔍 Vérifier si le socket est vraiment connecté
    if (!_socket.connected) {
      debugPrint('⚠️ Socket non connecté (_socket.connected = ${_socket.connected}), tentative de reconnexion...');
      // Attendre un peu et réessayer
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_socket.connected) {
          _sendMessageNow(addedMessage, conversation);
        } else {
          debugPrint('❌ Socket toujours non connecté après délai');
        }
      });
      return;
    }

    _sendMessageNow(addedMessage, conversation);
  }

  /// Envoyer le message maintenant (socket connecté)
  void _sendMessageNow(
    Map<String, dynamic> addedMessage,
    Map<String, dynamic> conversation,
  ) {
    debugPrint('📤 Envoi du message via socket à: ${_otherUser!.id}');
    _socket.emit('sendMessage', {
      'addedMessage': addedMessage,
      'receiver': _otherUser,
      'conversation': conversation,
    });
  }

  /// 📩 Écouter les messages reçus (une seule fois)
  /// 
  /// Configure un callback qui sera appelé à chaque réception de message
  void onMessageReceived(Function(Map<String, dynamic>) callback) {
    // Supprimer les anciens listeners pour éviter les doublons
    _socket.off('getMessage');
    
    // Ajouter le nouveau listener
    _socket.on('getMessage', (data) {
      debugPrint('📩 Callback message reçu: $data');
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

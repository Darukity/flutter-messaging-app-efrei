import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/api_config.dart';

class ChatProvider extends ChangeNotifier {
  late IO.Socket _socket;
  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? _otherUser;
  bool _isConnected = false;
  bool _isOnline = false;

  IO.Socket get socket => _socket;
  Map<String, dynamic>? get currentUser => _currentUser;
  Map<String, dynamic>? get otherUser => _otherUser;
  bool get isConnected => _isConnected;
  bool get isOnline => _isOnline;

  // Initialiser le socket
  void initSocket(String baseUrl) {
    _socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': true,
      'reconnectionDelay': 1000,
      'reconnectionDelayMax': 5000,
      'reconnectionAttempts': 5,
    });

    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _socket.on('connect', (_) {
      _isConnected = true;
      notifyListeners();
      print('Socket connecté');
    });

    _socket.on('disconnect', (_) {
      _isConnected = false;
      _isOnline = false;
      notifyListeners();
      print('Socket déconnecté');
    });

    _socket.on('getUsers', (users) {
      // Vérifier si l'autre utilisateur est en ligne
      if (_otherUser != null) {
        _isOnline = users.any((user) => user['userId'] == _otherUser!['_id']);
        notifyListeners();
      }
    });
  }

  // Connecter l'utilisateur au socket
  void connectUser(Map<String, dynamic> user) {
    _currentUser = user;
    if (!_isConnected) {
      _socket.connect();
    }
    _socket.emit('addUser', user['_id']);
  }

  // Définir l'autre utilisateur de la conversation
  void setOtherUser(Map<String, dynamic> user) {
    _otherUser = user;
    notifyListeners();
  }

  // Émettre un message
  void sendSocketMessage({
    required Map<String, dynamic> addedMessage,
    required Map<String, dynamic> conversation,
  }) {
    _socket.emit('sendMessage', {
      'addedMessage': addedMessage,
      'receiver': _otherUser,
      'conversation': conversation,
    });
  }

  // Écouter les messages reçus
  void onMessageReceived(Function(Map<String, dynamic>) callback) {
    _socket.on('getMessage', (data) {
      callback(data);
    });
  }

  // Déconnecter le socket
  void disconnect() {
    _socket.disconnect();
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

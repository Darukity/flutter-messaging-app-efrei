# 📱 Architecture de l'Application Flutter - Messaging App

## 🎯 Vue d'Ensemble

Cette application de messagerie instantanée est construite avec Flutter et suit les meilleures pratiques recommandées par Google. Elle communique avec un backend Node.js/Express via des APIs REST et Socket.IO pour le temps réel.

## 🏗️ Structure du Projet

```
lib/
├── main.dart                 # Point d'entrée de l'application
├── routes.dart               # Configuration des routes centralisées
│
├── 📂 models/               # 📋 MODELS - La structure des données
│   ├── user_model.dart      # Modèle User (id, firstName, lastName, email...)
│   ├── conversation_model.dart  # Modèle Conversation
│   ├── message_model.dart   # Modèle Message
│   └── models.dart          # Export centralisé de tous les modèles
│
├── 📂 services/             # 🌐 SERVICES - Communication avec l'extérieur
│   ├── dio_client.dart      # Client HTTP configuré avec intercepteurs
│   ├── auth_service.dart    # Login, Register, Refresh token
│   ├── auth_storage.dart    # Stockage sécurisé du token JWT
│   ├── conversation_service.dart  # API conversations et messages
│   └── user_profile_service.dart  # API profil utilisateur
│
├── 📂 providers/            # 🔄 PROVIDERS - Gestion d'état (ChangeNotifier)
│   ├── chat_provider.dart   # État global du chat (Socket.IO, utilisateurs en ligne)
│   └── message_provider.dart # État des messages d'une conversation
│
├── 📂 pages/                # 📄 PAGES/SCREENS - Les écrans de l'app
│   ├── auth/
│   │   ├── login_page.dart
│   │   └── register_page.dart
│   ├── chat/
│   │   ├── conversations_page.dart  # Liste des conversations
│   │   ├── users_page.dart          # Liste de tous les utilisateurs
│   │   └── chat_detail_page.dart    # Fenêtre de conversation
│   └── profile/
│       ├── profile_page.dart        # Affichage du profil
│       └── profile_edit_page.dart   # Édition du profil
│
├── 📂 widgets/              # 🧩 WIDGETS - Composants réutilisables
│   └── (à créer si besoin de widgets custom)
│
└── 📂 config/               # ⚙️ CONFIG - Configuration globale
    └── api_config.dart      # URL du backend, ports Socket.IO
```

---

## 🧠 Philosophie Flutter : **Tout est Widget**

### 🆚 Comparaison avec Angular

| **Concept** | **Angular** | **Flutter (Dart)** |
|-------------|-------------|-------------------|
| **Composant** | `@Component` (HTML + CSS + TS) | `Widget` (tout en Dart) |
| **Service** | `@Injectable()` avec HttpClient | `Service` (classe avec Dio) |
| **State Management** | RxJS + Signals | `Provider` + `ChangeNotifier` |
| **Routing** | Angular Router | Navigator + Routes |
| **HTTP** | HttpClient (Observables) | Dio (Future/async-await) |
| **Injection** | DI avec constructeur | Provider.of() ou Consumer |

---

## 🔄 Architecture Backend (Node.js/Express)

### 📡 Endpoints API Disponibles

#### **Authentification** (`/users`)
- `POST /users/signup` - Créer un compte
- `POST /users/login` - Se connecter (retourne JWT token)

#### **Utilisateurs** (`/users` - nécessite Auth)
- `GET /users` - Liste de tous les utilisateurs
- `GET /users/:id` - Détails d'un utilisateur
- `PUT /users/profile_data` - Modifier prénom, nom, profession...
- `PUT /users/profile_about` - Modifier la bio
- `PUT /users/profile_image` - Upload image de profil
- `PUT /users/profile_cover_image` - Upload image de couverture

#### **Conversations** (`/conversations` - nécessite Auth)
- `GET /conversations` - Toutes les conversations
- `GET /conversations/:user2_id` - Conversation avec un user spécifique
- `POST /conversations/message` - Envoyer un message
- `DELETE /conversations/message` - Supprimer un message

#### **Socket.IO (Temps Réel)**
- **Event**: `addUser` - S'ajouter aux utilisateurs connectés
- **Event**: `sendMessage` - Envoyer un message en temps réel
- **Event**: `getMessage` - Recevoir un message
- **Event**: `getUsers` - Liste des utilisateurs en ligne
- **Event**: `disconnect` - Se déconnecter

---

## 🔐 Authentification & Intercepteurs

### 🎫 JWT Token Flow

1. **Login/Register** → Backend retourne `{ token, ...userData }`
2. **Stockage Local** → `AuthStorage.saveToken(token)` (flutter_secure_storage)
3. **Intercepteur Dio** → Ajoute `Authorization: Bearer <token>` automatiquement
4. **Requêtes Protégées** → Toutes les API (sauf login/register) nécessitent le token

### 🔧 Intercepteur dans `dio_client.dart`

```dart
// Avant chaque requête
onRequest: (options, handler) async {
  final token = await AuthStorage.getToken();
  if (token != null) {
    options.headers['Authorization'] = 'Bearer $token';
  }
  return handler.next(options);
}

// En cas d'erreur 401 (token expiré)
onError: (DioException e, handler) {
  if (e.response?.statusCode == 401) {
    // Rediriger vers /login
    Navigator.pushReplacementNamed(context, '/login');
  }
  return handler.next(e);
}
```

---

## 🔄 State Management avec Provider

### 📘 Principe : ChangeNotifier

Le pattern `Provider` est similaire aux Services Angular avec RxJS, mais adapté au modèle déclaratif de Flutter.

#### **Exemple : ChatProvider** (Gestion de Socket.IO)

```dart
class ChatProvider extends ChangeNotifier {
  late IO.Socket _socket;
  bool _isConnected = false;
  List<OnlineUser> _onlineUsers = [];

  // Getters (lecture seule pour l'extérieur)
  bool get isConnected => _isConnected;
  List<OnlineUser> get onlineUsers => _onlineUsers;

  void connectSocket(String userId) {
    _socket.emit('addUser', userId);
    _isConnected = true;
    
    // 🔔 DING DONG ! Notifier tous les widgets qui écoutent
    notifyListeners();
  }
}
```

#### **Dans l'UI : Consumer**

```dart
Consumer<ChatProvider>(
  builder: (context, chatProvider, child) {
    // Ce bloc se re-exécute automatiquement à chaque notifyListeners()
    return Text(chatProvider.isOnline ? 'En ligne' : 'Hors ligne');
  },
)
```

#### **Appeler une méthode sans écouter**

```dart
// Pour juste déclencher une action (ex: bouton refresh)
Provider.of<ChatProvider>(context, listen: false).connectSocket(userId);
```

---

## 🛠️ StatelessWidget vs StatefulWidget

### 🧊 StatelessWidget (Immuable)

Utilisé quand **l'interface ne change jamais** après création.

**Exemples :**
- Page de login (avant interaction)
- Bouton statique
- Texte fixe

```dart
class MyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      child: Text('Cliquez ici'),
    );
  }
}
```

### 🔄 StatefulWidget (Dynamique)

Utilisé quand **l'interface doit changer** (formulaire, compteur, liste dynamique).

**Exemples :**
- Pages avec chargement API (`isLoading`)
- TextField qui change
- Liste de conversations

```dart
class ConversationsPage extends StatefulWidget {
  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  bool _isLoading = true;
  List<Conversation> _conversations = [];

  @override
  void initState() {
    super.initState();
    // 🔥 initState = ngOnInit() en Angular
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final data = await ConversationService.getConversations();
    setState(() {
      _conversations = data; // ✅ Re-render le widget
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? CircularProgressIndicator()
        : ListView.builder(...);
  }
}
```

### ⚡ setState() - La Magie du Re-render

```dart
setState(() {
  counter++; // Modifier une variable
});
// → Flutter efface le widget et le reconstruit avec la nouvelle valeur
```

---

## 🌐 HTTP avec Dio (async/await)

### 🆚 Comparaison : Angular vs Flutter

| **Angular** | **Flutter (Dio)** |
|-------------|------------------|
| `httpClient.get().subscribe()` | `await dio.get()` |
| Observable (flux continu) | Future (promesse unique) |
| Pipe `\| async` | `await` + `setState()` |

### 📦 Exemple : ConversationService

```dart
class ConversationService {
  static final DioClient _dioClient = DioClient();

  // Future = Promesse (comme async en JS)
  static Future<List<Conversation>> getConversations() async {
    try {
      final response = await _dioClient.get('/conversations');
      
      if (response.statusCode == 200) {
        // Transformer JSON → List<Conversation>
        return (response.data as List)
            .map((item) => Conversation.fromJson(item))
            .toList();
      } else {
        throw Exception('Erreur HTTP');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}
```

### 🎯 Utilisation dans un Widget

```dart
@override
void initState() {
  super.initState();
  
  // Charger au démarrage (comme ngOnInit)
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadData();
  });
}

Future<void> _loadData() async {
  setState(() { _isLoading = true; });
  
  try {
    final data = await ConversationService.getConversations();
    setState(() {
      _conversations = data;
      _isLoading = false;
    });
  } catch (e) {
    debugPrint('❌ Erreur: $e');
    setState(() { _isLoading = false; });
  }
}
```

---

## 🐛 Debug & Bonnes Pratiques

### 🖨️ Console (Print)

**Utilisez `debugPrint()` au lieu de `print()`**

```dart
debugPrint('🔍 Chargement des conversations...');
debugPrint('   ✅ ${conversations.length} conversations récupérées');
debugPrint('❌ Erreur: $error');
```

### 🔴 Lire les Erreurs

Quand Flutter affiche un **écran rouge**, regardez le **terminal** :

```
The following RangeError was thrown:
Index out of range: no indices are valid: 0

package:messaging_app_frontend/pages/chat/conversations_page.dart 198:29
```

→ **Ligne 198** du fichier `conversations_page.dart` : accès à un index invalide !

**Solution appliquée :**
```dart
// ❌ AVANT (crash si firstName est vide)
_currentUser!.firstName[0].toUpperCase()

// ✅ APRÈS (sécurisé)
_currentUser!.firstName.isNotEmpty
    ? _currentUser!.firstName[0].toUpperCase()
    : '?'
```

---

## 🚀 Commandes CLI Essentielles

```bash
# Vérifier l'installation
flutter doctor

# Nettoyer le cache (si bugs bizarres)
flutter clean

# Installer les dépendances
flutter pub get

# Lancer l'app
flutter run

# Lancer sur un appareil spécifique
flutter run -d chrome
flutter run -d windows
```

---

## 📝 Résumé des Corrections Apportées

### ✅ Bugs Corrigés

1. **IndexError sur `firstName[0]`** → Ajout de vérifications `isNotEmpty` avant d'accéder à l'index
2. **Absence de debugPrint** → Remplacement de `print()` par `debugPrint()` pour meilleure traçabilité

### 🔧 Améliorations

- Documentation complète de l'architecture
- Commentaires expliquant le flow (initState, setState, Provider)
- Comparaisons avec Angular pour faciliter la compréhension

---

## 📚 Ressources

- [Documentation Flutter officielle](https://flutter.dev)
- [Package Provider](https://pub.dev/packages/provider)
- [Package Dio](https://pub.dev/packages/dio)
- [Socket.IO Client](https://pub.dev/packages/socket_io_client)

---

## 🎓 Pour Aller Plus Loin

1. **Testez avec `flutter run` sur Chrome**
2. **Explorez les DevTools** (http://127.0.0.1:52068/.../devtools)
3. **Ajoutez des `debugPrint()` pour comprendre le flux de données**
4. **Expérimentez avec Provider** : créez vos propres ChangeNotifier

Bon développement ! 🚀

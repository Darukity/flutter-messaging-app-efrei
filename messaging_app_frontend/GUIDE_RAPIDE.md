# 🚀 Guide de Référence Rapide - Flutter Messaging App

## 🐛 Problème Résolu : IndexError

### ❌ Erreur Initiale
```
RangeError (index): Index out of range: no indices are valid: 0
```

### 🔍 Cause
Le code tentait d'accéder au premier caractère d'une chaîne vide :
```dart
_currentUser!.firstName[0]  // ❌ Crash si firstName = ""
```

### ✅ Solution Appliquée
Vérifier si la chaîne n'est pas vide avant d'accéder à l'index :
```dart
_currentUser!.firstName.isNotEmpty
    ? _currentUser!.firstName[0].toUpperCase()
    : '?'  // Afficher '?' si vide
```

**Fichiers modifiés :**
- [conversations_page.dart](messaging_app_frontend/lib/pages/chat/conversations_page.dart) (lignes 198, 274)
- [users_page.dart](messaging_app_frontend/lib/pages/chat/users_page.dart) (ligne 127, 187)
- [profile_page.dart](messaging_app_frontend/lib/pages/profile/profile_page.dart) (ligne 141)
- [chat_detail_page.dart](messaging_app_frontend/lib/pages/chat/chat_detail_page.dart) (ligne 212)

---

## 📋 Commandes Essentielles

### Gestion du Projet
```bash
# Vérifier l'installation Flutter
flutter doctor

# Nettoyer le cache (si bugs)
flutter clean

# Installer les dépendances
flutter pub get

# Lancer l'app sur Chrome
flutter run -d chrome

# Lancer l'app sur Windows
flutter run -d windows
```

### Debug
```bash
# Hot Reload (pendant l'exécution)
r

# Hot Restart (reset complet)
R

# Quitter
q
```

---

## 🔄 Cycle de Vie d'un Widget

```dart
class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  // 1️⃣ INIT - Appelé UNE SEULE FOIS au démarrage
  @override
  void initState() {
    super.initState();
    _loadData();  // Charger les données ici
  }

  // 2️⃣ BUILD - Appelé à CHAQUE setState()
  @override
  Widget build(BuildContext context) {
    return Scaffold(...);
  }

  // 3️⃣ DISPOSE - Appelé quand le widget est détruit
  @override
  void dispose() {
    _controller.dispose();  // Nettoyer les ressources
    super.dispose();
  }
}
```

---

## 🔌 Provider : Utilisation Complète

### 1️⃣ Créer un Provider (ChangeNotifier)

```dart
// providers/task_provider.dart
class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();  // 🔔 Notifier les widgets
  }
}
```

### 2️⃣ Enregistrer le Provider (dans main.dart)

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => TaskProvider()),
  ],
  child: MaterialApp(...),
)
```

### 3️⃣ Écouter avec Consumer (dans un widget)

```dart
Consumer<TaskProvider>(
  builder: (context, taskProvider, child) {
    // Ce bloc se re-exécute automatiquement à chaque notifyListeners()
    return ListView.builder(
      itemCount: taskProvider.tasks.length,
      itemBuilder: (ctx, index) => Text(taskProvider.tasks[index].title),
    );
  },
)
```

### 4️⃣ Appeler une méthode sans écouter

```dart
// Pour juste déclencher une action (ex: bouton)
Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
```

---

## 🌐 HTTP : Charger des Données

### Service (avec Dio)
```dart
// services/task_service.dart
class TaskService {
  static final DioClient _dio = DioClient();

  static Future<List<Task>> getTasks() async {
    try {
      final response = await _dio.get('/tasks');
      return (response.data as List)
          .map((json) => Task.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}
```

### Utilisation dans un Widget
```dart
@override
void initState() {
  super.initState();
  _loadTasks();
}

Future<void> _loadTasks() async {
  setState(() { _isLoading = true; });
  
  try {
    final tasks = await TaskService.getTasks();
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  } catch (e) {
    debugPrint('❌ Erreur: $e');
    setState(() { _isLoading = false; });
  }
}
```

---

## 🗺️ Navigation

### Routes Simples
```dart
// Aller vers une page
Navigator.pushNamed(context, '/users');

// Remplacer la page actuelle (sans retour possible)
Navigator.pushReplacementNamed(context, '/login');

// Retour arrière
Navigator.pop(context);
```

### Routes avec Paramètres
```dart
// Envoyer un paramètre
Navigator.pushNamed(
  context,
  '/chat-detail',
  arguments: userObject,
);

// Récupérer le paramètre (dans onGenerateRoute)
final user = settings.arguments as User;
```

---

## 🎨 Widgets Courants

### Scaffold (Structure de page)
```dart
Scaffold(
  appBar: AppBar(title: Text('Titre')),
  body: Center(child: Text('Contenu')),
  bottomNavigationBar: BottomNavigationBar(...),
)
```

### ListView (Liste défilante)
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(items[index].name),
      onTap: () => _openDetail(items[index]),
    );
  },
)
```

### TextField (Champ de saisie)
```dart
TextField(
  controller: _controller,
  decoration: InputDecoration(
    labelText: 'Nom',
    hintText: 'Entrez votre nom',
  ),
  onChanged: (value) {
    setState(() { _name = value; });
  },
)
```

### ElevatedButton (Bouton)
```dart
ElevatedButton(
  onPressed: () => _submit(),
  child: Text('Envoyer'),
)
```

### CircularProgressIndicator (Spinner)
```dart
_isLoading
  ? CircularProgressIndicator()
  : Text('Données chargées')
```

---

## 🐛 Debug : Astuces

### 1. Afficher dans la Console
```dart
debugPrint('🔍 Valeur : $variable');
debugPrint('   → Liste : ${myList.length} items');
debugPrint('❌ Erreur : $error');
```

### 2. Vérifier l'État
```dart
@override
Widget build(BuildContext context) {
  debugPrint('🔄 Build appelé - isLoading: $_isLoading');
  return ...;
}
```

### 3. Breakpoint (DevTools)
- Cliquer sur le numéro de ligne dans VS Code
- Lancer avec F5 (Debug)
- Inspecter les variables

### 4. Flutter Inspector (DevTools)
```
http://127.0.0.1:52068/.../devtools
```
- Visualiser l'arbre des widgets
- Inspecter les propriétés
- Mesurer les performances

---

## 📦 Packages Utilisés

| Package | Usage |
|---------|-------|
| `provider` | State management (ChangeNotifier) |
| `dio` | HTTP requests (REST API) |
| `socket_io_client` | WebSocket temps réel |
| `flutter_secure_storage` | Stockage sécurisé (token JWT) |

---

## 🆚 Équivalences Angular ↔ Flutter

| **Angular** | **Flutter** |
|-------------|-------------|
| `@Component` | `StatelessWidget` / `StatefulWidget` |
| `@Injectable()` Service | Classe Service normale |
| `HttpClient` | `Dio` |
| Observable | Future (async/await) |
| `\| async` | `Consumer` ou `await` |
| `ngOnInit()` | `initState()` |
| `ngOnDestroy()` | `dispose()` |
| Pipe `\| async` | `Consumer<Provider>` |
| RouterModule | `Navigator` + `routes.dart` |
| DI (constructeur) | `Provider.of()` |

---

## 🎯 Prochaines Étapes Recommandées

1. **Tester l'app** : `flutter run -d chrome`
2. **Explorer les pages** : Login → Users → Conversations → Chat
3. **Ajouter des `debugPrint()`** pour comprendre le flux
4. **Modifier un texte** et voir le Hot Reload (touche `r`)
5. **Expérimenter avec Provider** : modifier une valeur et voir le re-render

---

## 📚 Ressources Utiles

- [Documentation Flutter](https://flutter.dev/docs)
- [Widget Catalog](https://flutter.dev/docs/development/ui/widgets)
- [Provider Package](https://pub.dev/packages/provider)
- [Dio Package](https://pub.dev/packages/dio)

---

✅ **L'application est maintenant prête à être lancée !**

```bash
flutter run -d chrome
```

# Nouvelles Fonctionnalités Administrateur

## Vue d'ensemble

Ce document décrit les nouvelles fonctionnalités ajoutées pour la gestion des utilisateurs et l'upload de fichiers.

## 1. Onglet Admin (Uniquement pour les administrateurs)

### Description
Un nouvel onglet "Admin" a été ajouté au bottom navigation bar qui n'est visible que pour les utilisateurs ayant le rôle "admin".

### Fichiers concernés
- `lib/controller/bottom_bar_controller.dart`
- `lib/views/bottom_bar/bottom_bar_view.dart`
- `lib/configs/user_utils.dart`

### Fonctionnement
- Le contrôleur vérifie le rôle de l'utilisateur connecté via `loadUserData()`
- Si le rôle est "admin", un 6ème onglet est ajouté au bottom navigation
- L'onglet utilise l'icône `Icons.admin_panel_settings`

### Code important
```dart
void checkAdminStatus() {
  final userData = loadUserData();
  if (userData != null) {
    final role = userData['role'] ?? 'user';
    isAdmin.value = role.toLowerCase() == 'admin';
  }
}
```

## 2. Gestion des Utilisateurs Non Vérifiés

### Description
Une interface complète pour afficher et gérer les utilisateurs non vérifiés sur la plateforme.

### Fichiers créés
- `lib/services/user_service.dart` - Service API pour les opérations utilisateur
- `lib/controller/admin_users_controller.dart` - Contrôleur pour la gestion des utilisateurs
- `lib/views/admin/admin_users_view.dart` - Liste des utilisateurs non vérifiés
- `lib/views/admin/user_details_view.dart` - Détails d'un utilisateur avec toggle de vérification

### Fonctionnalités

#### Liste des utilisateurs non vérifiés
- Affichage de tous les utilisateurs avec `isVerified: false`
- Pull-to-refresh pour actualiser la liste
- Bouton de rafraîchissement manuel
- Indication visuelle du statut non vérifié

#### Détails utilisateur
- Affichage complet des informations utilisateur:
  - Nom
  - Email
  - Téléphone
  - Rôle
  - Date d'inscription
  - Statut de vérification

#### Toggle de vérification
- Switch pour activer/désactiver la vérification
- Dialogue de confirmation avant modification
- Mise à jour en temps réel de la liste

### Endpoints API utilisés

```dart
// Récupérer les utilisateurs non vérifiés
GET /users/unverified

// Récupérer les détails d'un utilisateur
GET /users/:userId

// Mettre à jour la vérification
PUT /users/:userId/verification
Body: { "isVerified": true/false }
```

### Utilisation

1. **Accéder à la liste admin:**
   - Se connecter avec un compte admin
   - Cliquer sur l'onglet "Admin" dans le bottom navigation

2. **Voir les détails d'un utilisateur:**
   - Cliquer sur une carte utilisateur dans la liste
   - Les détails complets s'affichent

3. **Vérifier un utilisateur:**
   - Dans la page de détails, activer le switch "Statut de vérification"
   - Confirmer l'action dans le dialogue
   - L'utilisateur est retiré de la liste des non vérifiés

## 3. Upload de Fichiers dans Edit Profile

### Description
Ajout d'une fonctionnalité complète pour uploader des fichiers (documents, images, PDF) depuis le profil utilisateur.

### Fichiers modifiés
- `lib/controller/edit_profile_controller.dart`
- `lib/views/profile/edit_profile_view.dart`
- `lib/services/user_service.dart`

### Fonctionnalités

#### Sélection de fichiers
- Support des formats: PDF, DOC, DOCX, JPG, JPEG, PNG
- Utilise le package `file_picker`
- Affichage du nom du fichier sélectionné

#### Upload vers le serveur
- Upload via multipart/form-data
- Barre de progression pendant l'upload
- Détection automatique du type de fichier
- Notifications de succès/erreur

### Code important

```dart
// Sélectionner un fichier
Future<void> pickFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
  );
  // ...
}

// Uploader le fichier
Future<void> uploadFile() async {
  final response = await _userService.uploadProfileFile(
    userId,
    selectedFilePath.value,
    fileType,
  );
  // ...
}
```

### Endpoint API utilisé

```dart
// Upload de fichier
POST /users/:userId/upload
Content-Type: multipart/form-data
Body:
  - file: [fichier binaire]
  - fileType: "image" | "pdf" | "document"
```

### Utilisation

1. **Aller dans Edit Profile:**
   - Profil → Éditer le profil

2. **Sélectionner un fichier:**
   - Faire défiler jusqu'à la section "Documents"
   - Cliquer sur "Sélectionner un fichier"
   - Choisir un fichier dans le gestionnaire de fichiers

3. **Uploader le fichier:**
   - Le bouton "Télécharger le fichier" apparaît
   - Cliquer dessus pour lancer l'upload
   - Attendre la confirmation de succès

## Configuration Backend Requise

Pour que ces fonctionnalités fonctionnent, votre backend Node.js doit implémenter les endpoints suivants:

### 1. Récupérer les utilisateurs non vérifiés
```javascript
GET /users/unverified
Response: Array of User objects with isVerified: false
```

### 2. Récupérer les détails d'un utilisateur
```javascript
GET /users/:userId
Response: User object
```

### 3. Mettre à jour la vérification
```javascript
PUT /users/:userId/verification
Body: { isVerified: boolean }
Response: Updated User object
```

### 4. Upload de fichier
```javascript
POST /users/:userId/upload
Content-Type: multipart/form-data
Fields:
  - file: File
  - fileType: string
Response: { url: string, fileType: string }
```

## Dépendances Ajoutées

```yaml
dependencies:
  file_picker: ^8.1.4  # Pour la sélection de fichiers
```

N'oubliez pas d'exécuter:
```bash
flutter pub get
```

## Structure des Données

### User Object
```dart
{
  "_id": "string",
  "name": "string",
  "email": "string",
  "phone": "string",
  "role": "user" | "admin",
  "isVerified": boolean,
  "createdAt": "ISO 8601 date string"
}
```

## Permissions et Sécurité

- Seuls les utilisateurs avec `role: "admin"` peuvent voir l'onglet Admin
- Les endpoints de gestion des utilisateurs doivent être protégés côté backend
- Vérifier les permissions avant chaque action de vérification
- Les fichiers uploadés doivent être validés côté serveur

## Tests

Pour tester ces fonctionnalités:

1. **Créer un utilisateur admin:**
   - Modifier manuellement le rôle dans la base de données
   - Ou utiliser votre système d'attribution de rôles

2. **Se connecter avec l'admin:**
   - L'onglet Admin devrait apparaître

3. **Créer des utilisateurs non vérifiés:**
   - Créer des comptes avec `isVerified: false`
   - Ils apparaîtront dans la liste admin

4. **Tester l'upload:**
   - Aller dans Edit Profile
   - Sélectionner différents types de fichiers
   - Vérifier l'upload sur le serveur

## Troubleshooting

### L'onglet Admin n'apparaît pas
- Vérifier que `userData['role']` est bien "admin" (en minuscules)
- Vérifier que `loadUserData()` retourne bien les données
- Redémarrer l'application après connexion

### Les utilisateurs n'apparaissent pas
- Vérifier que l'endpoint `/users/unverified` est accessible
- Vérifier la connexion réseau
- Vérifier les logs dans la console

### L'upload échoue
- Vérifier que le fichier n'est pas trop volumineux
- Vérifier l'endpoint backend
- Vérifier les permissions de fichier
- Vérifier que `file_picker` est bien installé

## Améliorations Futures

Suggestions pour améliorer ces fonctionnalités:

1. **Pagination** pour la liste des utilisateurs
2. **Filtres et recherche** dans la liste admin
3. **Historique des modifications** de vérification
4. **Preview des fichiers** uploadés
5. **Gestion multiple** de fichiers
6. **Notifications push** lors de la vérification
7. **Statistiques** sur les utilisateurs
8. **Export** de la liste des utilisateurs

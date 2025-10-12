# Documentation Complète des Fonctionnalités Admin

## Vue d'ensemble

Cette documentation décrit le système complet d'administration avec onglets permettant de gérer les utilisateurs et les biens immobiliers.

## 🎯 Fonctionnalités Principales

### 1. Système d'Onglets Admin
Interface unifiée avec 4 onglets principaux :
- **Non vérifiés** : Gestion des utilisateurs en attente de vérification
- **Utilisateurs** : Gestion de tous les utilisateurs vérifiés
- **Admins** : Gestion des rôles administrateurs
- **Biens** : Gestion des propriétés immobilières

## 📋 Onglet 1 : Utilisateurs Non Vérifiés

### Description
Permet de visualiser et gérer tous les utilisateurs ayant `isVerified: false`.

### Fonctionnalités
- ✅ Liste de tous les utilisateurs non vérifiés
- ✅ Pull-to-refresh pour actualiser
- ✅ Bouton de rafraîchissement manuel
- ✅ Navigation vers les détails utilisateur
- ✅ Activation du compte (passage à `isVerified: true`)

### Fichiers
- **Vue**: `lib/views/admin/tabs/unverified_users_tab.dart`
- **Controller**: `lib/controller/admin_users_controller.dart`
- **Service**: `lib/services/user_service.dart`

### API Endpoint
```javascript
GET /users/unverified
Response: Array of User objects with isVerified: false
```

### Utilisation
1. Cliquer sur l'onglet "Non vérifiés"
2. Voir la liste des utilisateurs en attente
3. Cliquer sur un utilisateur pour voir ses détails
4. Activer le compte via le toggle de vérification

## 👥 Onglet 2 : Utilisateurs Vérifiés

### Description
Gestion de tous les utilisateurs ayant `isVerified: true`, avec possibilité de désactiver leur accès.

### Fonctionnalités
- ✅ Liste de tous les utilisateurs vérifiés
- ✅ Affichage du rôle de chaque utilisateur
- ✅ Désactivation d'un compte (passage à `isVerified: false`)
- ✅ Consultation des détails utilisateur
- ✅ Badge visuel du statut vérifié

### Fichiers
- **Vue**: `lib/views/admin/tabs/verified_users_tab.dart`
- **Controller**: `lib/controller/verified_users_controller.dart`
- **Service**: `lib/services/user_service.dart`

### API Endpoints
```javascript
GET /users/verified
Response: Array of User objects with isVerified: true

PUT /users/:userId/verification
Body: { isVerified: false }
Response: Updated User object
```

### Actions Disponibles
#### Désactiver un utilisateur
- Bouton "Bloquer" (icône block)
- Dialogue de confirmation
- L'utilisateur perd l'accès à la plateforme
- Retrait automatique de la liste des vérifiés

#### Voir les détails
- Bouton "Voir" (icône visibility)
- Navigation vers la page de détails complète

### Code Important
```dart
// Désactiver un utilisateur
Future<void> deactivateUser(String userId) async {
  await _userService.updateUserVerification(userId, false);
  verifiedUsers.removeWhere((user) => user['_id'] == userId);
}
```

## 👨‍💼 Onglet 3 : Gestion des Rôles Admin

### Description
Permet de promouvoir des utilisateurs en administrateurs ou de rétrograder des admins en utilisateurs normaux.

### Fonctionnalités
- ✅ Liste séparée des admins et utilisateurs
- ✅ Promotion d'utilisateur → admin
- ✅ Rétrogradation d'admin → utilisateur
- ✅ Compteurs en temps réel
- ✅ Interface visuelle différenciée

### Fichiers
- **Vue**: `lib/views/admin/tabs/admin_roles_tab.dart`
- **Controller**: `lib/controller/admin_roles_controller.dart`
- **Service**: `lib/services/user_service.dart`

### API Endpoint
```javascript
PUT /users/:userId/role
Body: { role: "admin" | "user" }
Response: Updated User object
```

### Interface Utilisateur
#### Section Administrateurs
- Icône : `Icons.admin_panel_settings`
- Couleur : Primaire
- Bordure accentuée
- Badge "Admin" avec flèche vers le bas (rétrogradation)

#### Section Utilisateurs
- Icône : `Icons.people`
- Couleur : Neutre
- Badge "Promouvoir" avec flèche vers le haut

### Actions
#### Promouvoir en Admin
```dart
showRoleChangeDialog(user, false);
// Dialogue de confirmation
await controller.updateRole(userId, 'admin');
```

#### Rétrograder en User
```dart
showRoleChangeDialog(user, true);
// Dialogue de confirmation
await controller.updateRole(userId, 'user');
```

### Sécurité
⚠️ **Important** : L'API backend doit vérifier que :
- L'utilisateur qui fait la demande est admin
- On ne peut pas se rétrograder soi-même
- Au moins un admin doit toujours exister

## 🏠 Onglet 4 : Gestion des Biens

### Description
Interface complète pour gérer tous les biens immobiliers : disponibilité, ventes, et suppressions.

### Fonctionnalités
- ✅ Liste de tous les biens
- ✅ Statistiques (Total, Vendus)
- ✅ Marquer un bien comme disponible/indisponible
- ✅ Marquer un bien comme vendu avec nom du vendeur
- ✅ Supprimer un bien
- ✅ Filtres automatiques

### Fichiers
- **Vue**: `lib/views/admin/tabs/properties_management_tab.dart`
- **Controller**: `lib/controller/property_admin_controller.dart`
- **Service**: `lib/services/property_admin_service.dart`

### API Endpoints
```javascript
// Récupérer tous les biens
GET /properties
Response: Array of Property objects

// Mettre à jour la disponibilité
PUT /properties/:propertyId/availability
Body: { isAvailable: boolean }
Response: Updated Property object

// Marquer comme vendu
PUT /properties/:propertyId/sold
Body: {
  isSold: true,
  soldBy: "string",
  soldDate: "ISO 8601 date"
}
Response: Updated Property object

// Supprimer un bien
DELETE /properties/:propertyId
Response: 200 or 204
```

### États d'un Bien
#### Disponible
- Badge bleu "Disponible"
- Bouton "Masquer" (orange)
- Bouton "Marquer vendu" (vert)
- Bouton "Supprimer" (rouge)

#### Indisponible
- Badge rouge "Indisponible"
- Bouton "Afficher" (vert)
- Bouton "Marquer vendu" (vert)
- Bouton "Supprimer" (rouge)

#### Vendu
- Badge vert "VENDU"
- Bordure verte
- Affichage du vendeur
- Message "Bien vendu ✓"
- Bouton "Supprimer" uniquement

### Actions Détaillées

#### 1. Changer la Disponibilité
```dart
await controller.updateAvailability(propertyId, !isAvailable);
```
- Masquer : rend le bien invisible pour les utilisateurs
- Afficher : rend le bien visible à nouveau

#### 2. Marquer comme Vendu
```dart
showSoldDialog(property);
// Demande le nom du vendeur
await controller.markAsSold(propertyId, soldBy);
```
- Dialogue avec champ texte
- Enregistre le nom du vendeur
- Date automatique de la vente
- Le bien devient non modifiable

#### 3. Supprimer un Bien
```dart
showDeleteDialog(property);
// Confirmation
await controller.deleteProperty(propertyId);
```
- Action irréversible
- Dialogue de confirmation obligatoire
- Suppression de la base de données

### Statistiques
Affichage en temps réel :
- **Total** : Nombre total de biens
- **Vendus** : Nombre de biens vendus

### Code Important
```dart
// Structure d'un bien
{
  "_id": "string",
  "title": "string",
  "location": "string",
  "price": "number",
  "isAvailable": boolean,
  "isSold": boolean,
  "soldBy": "string (optional)",
  "soldDate": "ISO 8601 date (optional)"
}
```

## 🔧 Configuration Backend Complète

Votre backend Node.js doit implémenter tous ces endpoints :

### Utilisateurs
```javascript
GET  /users                    // Tous les utilisateurs
GET  /users/verified           // Utilisateurs vérifiés uniquement
GET  /users/unverified         // Utilisateurs non vérifiés uniquement
GET  /users/:userId            // Détails d'un utilisateur
PUT  /users/:userId/verification  // Mettre à jour isVerified
PUT  /users/:userId/role       // Mettre à jour le rôle
POST /users/:userId/upload     // Upload fichier
```

### Propriétés
```javascript
GET    /properties                         // Tous les biens
PUT    /properties/:propertyId/availability // MAJ disponibilité
PUT    /properties/:propertyId/sold        // Marquer comme vendu
DELETE /properties/:propertyId             // Supprimer un bien
```

## 📱 Navigation

### Accès à l'Interface Admin
1. Se connecter avec un compte ayant `role: "admin"`
2. Un 6ème onglet "Admin" apparaît dans le bottom navigation
3. Cliquer sur l'onglet Admin
4. Interface avec 4 sous-onglets s'affiche

### Structure de Navigation
```
Bottom Navigation
└── Admin Tab (visible si role === "admin")
    ├── Non vérifiés
    ├── Utilisateurs
    ├── Admins
    └── Biens
```

## 🎨 Design et UX

### Codes Couleur
- **Vert** : Succès, vérifié, vendu
- **Orange** : En attente, avertissement
- **Rouge** : Danger, suppression, bloqué
- **Bleu** : Information, disponible
- **Primaire** : Actions principales, admin

### Badges et Indicateurs
- Tous les badges utilisent `withValues(alpha: 0.1)` pour le fond
- Bordures plus épaisses pour états importants (admin, vendu)
- Icônes contextuelles selon l'action

### Dialogues de Confirmation
Tous les dialogues suivent le même pattern :
- Titre clair
- Description de l'action
- Bouton "Annuler" (neutre)
- Bouton "Confirmer" (couleur selon l'action)

## 🔒 Sécurité et Permissions

### Vérifications Backend Obligatoires
1. **Authentification** : Token JWT valide
2. **Autorisation** : Role admin vérifié
3. **Validations** :
   - ID utilisateur valide
   - ID propriété valide
   - Données valides dans les updates

### Règles Métier
- Un utilisateur ne peut pas modifier son propre rôle
- Au moins un admin doit toujours exister
- Les propriétés vendues ne peuvent pas redevenir disponibles
- La suppression est irréversible

## 📊 Modèles de Données

### User Model
```dart
{
  "_id": "string",
  "name": "string",
  "email": "string",
  "phone": "string (optional)",
  "role": "user" | "admin",
  "isVerified": boolean,
  "createdAt": "ISO 8601 date"
}
```

### Property Model
```dart
{
  "_id": "string",
  "title": "string",
  "location": "string",
  "price": number,
  "isAvailable": boolean,
  "isSold": boolean,
  "soldBy": "string (optional)",
  "soldDate": "ISO 8601 date (optional)",
  "owner": "User ID",
  "createdAt": "ISO 8601 date"
}
```

## 🧪 Tests et Validation

### Tests Recommandés
1. **Utilisateurs Non Vérifiés**
   - Créer un utilisateur avec `isVerified: false`
   - Vérifier qu'il apparaît dans l'onglet
   - L'activer et vérifier le retrait de la liste

2. **Utilisateurs Vérifiés**
   - Créer un utilisateur avec `isVerified: true`
   - Vérifier qu'il apparaît dans l'onglet
   - Le désactiver et vérifier le retrait

3. **Rôles Admin**
   - Promouvoir un user en admin
   - Vérifier qu'il apparaît dans la section admins
   - Le rétrograder

4. **Biens**
   - Créer un bien disponible
   - Le masquer/afficher
   - Le marquer comme vendu
   - Le supprimer

## 🚀 Améliorations Futures

### Fonctionnalités Suggérées
1. **Recherche et Filtres**
   - Recherche d'utilisateurs par nom/email
   - Filtrage des biens par prix/localisation
   - Tri par date de création

2. **Statistiques Avancées**
   - Graphiques de ventes
   - Taux de conversion
   - Utilisateurs actifs

3. **Historique**
   - Log des actions admin
   - Historique des modifications de rôle
   - Traçabilité des ventes

4. **Notifications**
   - Push notification lors d'activation de compte
   - Email lors de promotion en admin
   - Alerte de vente

5. **Export**
   - Export CSV des utilisateurs
   - Export PDF des biens
   - Rapports mensuels

6. **Permissions Granulaires**
   - Super admin vs admin normal
   - Permissions par fonctionnalité
   - Audit trail

## 📝 Notes Importantes

### Performance
- Utilisez la pagination pour les grandes listes (>100 items)
- Implémentez un cache pour les requêtes fréquentes
- Optimisez les images des biens

### Erreurs Courantes
1. **L'onglet Admin n'apparaît pas**
   - Vérifier que `role === 'admin'` (minuscule)
   - Vérifier `loadUserData()` dans `lib/configs/user_utils.dart`
   - Redémarrer l'app après modification du rôle

2. **Liste vide malgré des données**
   - Vérifier la connexion réseau
   - Vérifier le endpoint backend
   - Consulter les logs dans la console

3. **Erreur lors de la mise à jour**
   - Vérifier les permissions backend
   - Vérifier le format des données
   - Vérifier l'ID de l'utilisateur/bien

## 📚 Structure des Fichiers

```
lib/
├── services/
│   ├── user_service.dart              # API utilisateurs
│   └── property_admin_service.dart    # API biens
├── controller/
│   ├── admin_users_controller.dart    # Non vérifiés
│   ├── verified_users_controller.dart # Vérifiés
│   ├── admin_roles_controller.dart    # Rôles
│   └── property_admin_controller.dart # Biens
└── views/
    └── admin/
        ├── admin_tabs_view.dart       # Vue principale avec onglets
        ├── user_details_view.dart     # Détails utilisateur
        └── tabs/
            ├── unverified_users_tab.dart    # Onglet 1
            ├── verified_users_tab.dart       # Onglet 2
            ├── admin_roles_tab.dart          # Onglet 3
            └── properties_management_tab.dart # Onglet 4
```

## 🎓 Formation Admin

### Guide Rapide
1. **Activer un compte** : Non vérifiés → Cliquer sur utilisateur → Toggle vérification
2. **Désactiver un compte** : Utilisateurs → Bouton bloquer → Confirmer
3. **Promouvoir en admin** : Admins → Section utilisateurs → Promouvoir → Confirmer
4. **Marquer vendu** : Biens → Marquer vendu → Entrer nom → Confirmer
5. **Masquer un bien** : Biens → Bouton Masquer

### Bonnes Pratiques
- Toujours vérifier l'identité avant activation
- Documenter les raisons de désactivation
- N'accorder le rôle admin qu'aux personnes de confiance
- Vérifier les informations avant de marquer un bien comme vendu
- Ne supprimer que les biens invalides ou obsolètes

---

## Support

Pour toute question ou problème :
- Consultez les logs dans la console Flutter
- Vérifiez les réponses API dans le terminal
- Testez les endpoints via Postman/Insomnia
- Consultez cette documentation

**Version**: 1.0
**Date**: 2025-01-15
**Auteur**: Generated with Claude Code

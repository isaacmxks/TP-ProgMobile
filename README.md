# 📱 Application Flutter Web – Authentification & Gestion des Produits

Ce projet est une application web développée avec **Flutter** et **Firebase**, permettant l’authentification des utilisateurs et la gestion de produits de manière sécurisée et dynamique.

---

## 🚀 Fonctionnalités

### 🔐 Authentification des utilisateurs
- Inscription et connexion avec **adresse e-mail et mot de passe**
- Inscription et connexion via :
  - **Google Sign-In**
  - **Twitter**
- Gestion automatique de la session utilisateur
- Déconnexion sécurisée

---

### 👤 Gestion des utilisateurs
- Stockage des informations utilisateur dans **Cloud Firestore**
  - Nom
  - Email
  - Fournisseur d’authentification
- Récupération automatique des informations utilisateur après connexion
- Synchronisation entre Firebase Authentication, Firestore et stockage local

---

### 📦 Gestion des produits
- Ajout de produits avec :
  - Nom
  - Catégorie
  - Prix
  - Quantité
- Association des produits à l’utilisateur connecté
- Affichage en temps réel via **StreamBuilder**
- Modification des informations d’un produit existant
- Suppression des produits

---

### 🔎 Filtrage & Interface
- Filtrage dynamique des produits par **catégorie**
- Les catégories sont récupérées directement depuis **Cloud Firestore**
- Interface intuitive et responsive :
  - Menu latéral avec informations utilisateur
  - Boutons d’action (ajout, modification, suppression)

---

## 🛠️ Technologies utilisées

- **Flutter** (Web)
- **Firebase Authentication**
- **Cloud Firestore**
- **Google Sign-In**
- **Twitter Authentication**
- **Local Storage** (persistance locale)

---

### 👨‍💻 Fait par

- **KALEJA MUTOMBO GUERSHON**
- **KILUNDU MPO ELIE**
- **LIBEKI LOMPOLA CHRISTIAN**
- **MULUMBA MULAMBO NATHAN DERICK**
- **AMUSA KATAMBWA CHRISTOPHER**
- **MAKONTSHI MIKOBI ISAAC**
- **ABEDI MIEZI OSEE**
- **MANDE MUDI NGBUTENE PETER**

---

## ▶️ Lancement de l’application

1. Lancer l’application avec la commande :
```bash
flutter run






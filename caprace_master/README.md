# CAPRACE_MASTER - GPS Tracking & Validation System

## 📋 TABLE DES MATIÈRES

1. [Vue d'ensemble](#-vue-densemble)
2. [Architecture](#️-architecture)
3. [Installation](#-installation)
4. [Configuration](#️-configuration)
5. [Utilisation](#-utilisation)
6. [API et Services](#-api-et-services)
7. [Base de données](#-base-de-données)
8. [Export de données](#-export-de-données)
9. [FlutterFlow](#-flutterflow)
10. [Déploiement](#-déploiement)
11. [Troubleshooting](#-troubleshooting)

---

## 🎯 VUE D'ENSEMBLE

CAPRACE_MASTER est une application mobile hors-ligne (Android & iOS) développée en Flutter pour le suivi GPS sécurisé et la validation de checkpoints virtuels.

### Fonctionnalités principales

- ✅ Acquisition GPS toutes les secondes
- ✅ Enregistrement local dans fichier TRACE
- ✅ Base de données SQLite pour les checkpoints
- ✅ Validation automatique des checkpoints (rayon 20m)
- ✅ Export CSV et GPX
- ✅ Fonctionnement 100% hors-ligne
- ✅ Interface sécurisée avec mot de passe
- ✅ Gestion de 15 jours x 15 checkpoints

### Spécifications techniques

- **Framework**: Flutter 3.x
- **Plateformes**: Android 5.0+ / iOS 12.0+
- **Base de données**: SQLite
- **GPS**: Acquisition haute fréquence (1Hz)
- **Précision**: Rayon de validation 20m
- **Stockage**: 100% local

---

## 🏗️ ARCHITECTURE

### Structure du projet

```
caprace_master/
├── lib/
│   ├── config/           # Configuration et constantes
│   ├── models/           # Modèles de données
│   ├── services/         # Couche métier
│   ├── screens/          # Interfaces utilisateur
│   ├── widgets/          # Composants réutilisables
│   └── utils/            # Utilitaires
├── assets/               # Ressources
├── android/              # Configuration Android
├── ios/                  # Configuration iOS
└── test/                 # Tests
```

[... contenu complet comme dans le fichier précédent ...]

---

**Version:** 1.0.4  
**Date:** 2024-02-07

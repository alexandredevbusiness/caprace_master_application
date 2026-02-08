# CAPRACE_MASTER - Architecture Logicielle Détaillée

## 📋 Vue d'ensemble

**Type**: Application mobile GPS hors ligne (Android/iOS)  
**Framework**: Flutter 3.x (LTS) + Dart  
**Compatibilité**: FlutterFlow  
**Mode**: 100% offline - aucune connexion réseau requise  
**Domaine**: Tracking GPS événementiel avec validation de checkpoints virtuels

---

## 🏗️ Architecture en Couches

```
┌─────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Accueil │  │  Partic. │  │  Organi. │  │  Export  │   │
│  │   Page   │  │   Page   │  │   Page   │  │   Page   │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│  ┌──────────┐                                              │
│  │  Param   │  Widgets: CheckpointGrid, DaySelector, etc. │
│  │   Page   │                                              │
│  └──────────┘                                              │
└───────────────────────┬─────────────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────────────┐
│                     BUSINESS LOGIC LAYER                    │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────┐ │
│  │  GPS Tracking  │  │  Checkpoint    │  │  Session     │ │
│  │    Service     │  │   Validation   │  │  Manager     │ │
│  │                │  │    Service     │  │              │ │
│  │ • Acquisition  │  │ • Distance     │  │ • State      │ │
│  │ • Filtering    │  │ • Detection    │  │ • Jour actif │ │
│  │ • Distance     │  │ • Notification │  │              │ │
│  └────────────────┘  └────────────────┘  └──────────────┘ │
└───────────────────────┬─────────────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────────────┐
│                      DATA LAYER                             │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────┐ │
│  │  TRACE File    │  │  SQLite DB     │  │  Export      │ │
│  │  Service       │  │  Service       │  │  Service     │ │
│  │                │  │                │  │              │ │
│  │ • Write coords │  │ • CP data      │  │ • CSV export │ │
│  │ • Read trace   │  │ • CRUD ops     │  │ • GPX export │ │
│  └────────────────┘  └────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## 📂 Structure du Projet

```
caprace_master/
│
├── lib/
│   ├── main.dart                    # Point d'entrée de l'application
│   │
│   ├── models/                      # Modèles de données
│   │   ├── checkpoint.dart          # Modèle Checkpoint (jour, cp, lat, long, passageok)
│   │   ├── gps_point.dart           # Modèle point GPS (timestamp, lat, long)
│   │   ├── session_state.dart       # État de la session (jour actif, équipage)
│   │   └── checkpoint_status.dart   # Statut des checkpoints (validés/non validés)
│   │
│   ├── services/                    # Services métier
│   │   ├── gps/
│   │   │   ├── gps_service.dart              # Service principal GPS
│   │   │   ├── gps_filter.dart               # Filtrage des données GPS
│   │   │   └── distance_calculator.dart      # Calcul de distance
│   │   │
│   │   ├── database/
│   │   │   └── database_service.dart         # Service SQLite
│   │   │
│   │   ├── file/
│   │   │   └── trace_service.dart            # Gestion du fichier TRACE
│   │   │
│   │   ├── checkpoint/
│   │   │   └── checkpoint_service.dart       # Validation des checkpoints
│   │   │
│   │   ├── export/
│   │   │   ├── csv_export_service.dart       # Export CSV
│   │   │   └── gpx_export_service.dart       # Export GPX
│   │   │
│   │   └── session/
│   │       └── session_service.dart          # Gestion de session
│   │
│   ├── ui/                          # Interface utilisateur
│   │   ├── pages/
│   │   │   ├── home_page.dart               # Page ACCUEIL
│   │   │   ├── participant_page.dart        # Page PARTICIPANT
│   │   │   ├── organisation_page.dart       # Page ORGANISATION
│   │   │   ├── export_page.dart             # Page EXPORT
│   │   │   ├── param_page.dart              # Page PARAM (DATA Editor)
│   │   │   └── password_page.dart           # Page de saisie mot de passe
│   │   │
│   │   ├── widgets/
│   │   │   ├── checkpoint_grid.dart         # Grille 15 checkpoints
│   │   │   ├── day_selector.dart            # Sélecteur 15 jours (3x5)
│   │   │   ├── gps_status_indicator.dart    # Indicateur qualité GPS
│   │   │   └── confirm_dialog.dart          # Dialog de confirmation
│   │   │
│   │   └── theme/
│   │       └── app_theme.dart               # Thème de l'application (dark)
│   │
│   └── utils/                       # Utilitaires
│       ├── constants.dart           # Constantes (rayon 20m, etc.)
│       ├── permissions.dart         # Gestion des permissions
│       └── validators.dart          # Validateurs
│
├── assets/                          # Ressources
│   ├── images/
│   │   └── logo.png                 # Image accueil
│   └── data/
│       └── sample_import.txt        # Exemple fichier import
│
├── test/                            # Tests unitaires et d'intégration
│   ├── services/
│   ├── models/
│   └── widget_test.dart
│
├── android/                         # Configuration Android
│   └── app/
│       └── src/main/AndroidManifest.xml
│
├── ios/                             # Configuration iOS
│   └── Runner/
│       └── Info.plist
│
├── pubspec.yaml                     # Dépendances
├── README.md                        # Documentation projet
└── CHANGELOG.md                     # Historique des versions

```

---

## 🔧 Composants Principaux

### 1. GPS Tracking Service

**Responsabilités:**
- Acquisition position GPS toutes les 1 seconde
- Filtrage des anomalies (micro-mouvements, sauts)
- Calcul de distance cumulée
- Indicateur qualité signal

**Flux de données:**
```
[Geolocator] → [GPSService] → [GPSFilter] → [DistanceCalculator]
                     ↓
              [TraceService] (écriture fichier)
                     ↓
              [CheckpointService] (validation)
```

**Algorithme de filtrage:**
1. Ignorer les points avec accuracy > 20m
2. Détecter les micro-mouvements (< 2m entre 2 points)
3. Détecter les sauts GPS (> 100m en 1 seconde = ~360km/h)
4. Calculer distance uniquement sur points valides

### 2. Database Service (SQLite)

**Table DATA:**
```sql
CREATE TABLE checkpoints (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  jour INTEGER NOT NULL,           -- 1 à 15
  cp INTEGER NOT NULL,              -- 1 à 15
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  passageok INTEGER DEFAULT 0,      -- 0 ou 1
  UNIQUE(jour, cp)
);
```

**Opérations CRUD:**
- `getCheckpointsForDay(int jour)`: Liste des 15 CP d'un jour
- `updateCheckpoint(Checkpoint cp)`: Mise à jour coordonnées
- `validateCheckpoint(int jour, int cp)`: Marquer passageok = 1
- `resetAllCheckpoints()`: Remise à zéro passageok
- `importCheckpoints(String filepath)`: Import depuis fichier

### 3. Checkpoint Validation Service

**Algorithme:**
```dart
// Pour chaque point GPS reçu
1. Récupérer les CP du jour actif non validés (passageok = 0)
2. Pour chaque CP:
   - Calculer distance Haversine(GPS_lat, GPS_long, CP_lat, CP_long)
   - Si distance <= 20m:
     * Marquer passageok = 1 en base
     * Déclencher bip/vibration
     * Afficher popup
     * Mettre à jour UI
```

**Formule Haversine:**
```dart
double distance(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371000; // Rayon terre en mètres
  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
            cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c; // Distance en mètres
}
```

### 4. Trace File Service

**Format fichier TRACE:**
```
# CAPRACE_MASTER TRACE FILE
# Equipage: 8
# Jour: J04
# Date: 2026-02-07T14:30:00Z
#
# timestamp,latitude,longitude,accuracy,speed
2026-02-07T14:30:01Z,48.8566,2.3522,5.2,0.0
2026-02-07T14:30:02Z,48.8567,2.3523,4.8,1.2
...
```

**Opérations:**
- `startNewTrace(int equipage, int jour)`: Créer nouveau fichier
- `appendGPSPoint(GPSPoint point)`: Ajouter ligne
- `closeTrace()`: Fermer fichier
- `readTrace(String filepath)`: Lire pour export

### 5. Export Services

**CSV Export:**
```csv
equipage,jour,timestamp,latitude,longitude,distance_km,cp_valides
8,4,2026-02-07T14:30:01Z,48.8566,2.3522,12.5,8
```

**GPX Export:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="CAPRACE_MASTER">
  <metadata>
    <name>Equipage 8 - Jour J04</name>
    <time>2026-02-07T14:30:00Z</time>
  </metadata>
  <trk>
    <name>Trace J04</name>
    <trkseg>
      <trkpt lat="48.8566" lon="2.3522">
        <time>2026-02-07T14:30:01Z</time>
      </trkpt>
      ...
    </trkseg>
  </trk>
</gpx>
```

---

## 🔐 Sécurité et Permissions

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### iOS (Info.plist)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Cette app nécessite votre position GPS pour le tracking de parcours</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Position GPS requise en arrière-plan pour enregistrer le parcours</string>
```

### Accès Page Organisation
- Clic 5 fois sur l'image d'accueil
- Saisie mot de passe (stocké crypté en SharedPreferences)
- Timeout session après 30 minutes d'inactivité

---

## 📊 Gestion d'État

**Provider pattern:**
```dart
// SessionProvider
- currentDay: int (1-15)
- currentEquipage: int
- isTracking: bool
- validatedCheckpoints: List<int>

// GPSProvider
- currentPosition: Position?
- signalQuality: GPSQuality (NONE, POOR, GOOD, EXCELLENT)
- totalDistance: double

// CheckpointProvider
- checkpoints: Map<int, List<Checkpoint>> // jour → liste CP
```

---

## 🎨 Interface Utilisateur - Spécifications

### Thème Global
```dart
- Background: #000000 (noir)
- Primary Color: #00FF00 (vert)
- Secondary Color: #808080 (gris)
- Accent Color: #0080FF (bleu)
- Text Color: #FFFFFF (blanc)
- Font: Monospace (style technique)
```

### Composants Réutilisables

**CheckpointGrid** (Grille 15 cercles)
- Layout: 7 colonnes (ligne 1-2) + 1 colonne (ligne 3)
- État gris: passageok = 0
- État vert: passageok = 1
- Animation lors de la validation

**DaySelector** (Grille 3x5 jours)
- Gris clair: jours futurs
- Gris foncé: jours passés
- Bleu: jour actif
- Clic pour sélectionner

---

## 🔄 Flux de Données Principaux

### 1. Démarrage d'une Session (Page Organisation)
```
[User] → Bouton START
         ↓
[SessionService] → setCurrentDay(jour)
                 → setCurrentEquipage(numero)
         ↓
[GPSService] → startTracking()
         ↓
[TraceService] → createNewTraceFile()
         ↓
[UI] → Afficher "Recording..."
```

### 2. Validation d'un Checkpoint
```
[GPSService] → Nouvelle position reçue
         ↓
[CheckpointService] → checkProximity(position, checkpoints)
         ↓
Si distance <= 20m:
  [DatabaseService] → updateCheckpoint(passageok = 1)
  [NotificationService] → bip + vibration + popup
  [UI] → Mise à jour CheckpointGrid (gris → vert)
```

### 3. Export des Données
```
[User] → Page Export → Bouton "Exporter en CSV"
         ↓
[TraceService] → readTraceFile()
         ↓
[CSVExportService] → generateCSV(trace, metadata)
         ↓
[ShareService] → share(csvFile, options: [WiFi, BT, WhatsApp])
```

---

## ⚙️ Configuration FlutterFlow

### Compatible
✅ Toutes les pages (UI widgets standards)  
✅ Navigation entre pages  
✅ State management (Provider)  
✅ Formulaires et inputs  
✅ Thème personnalisé  

### Non Compatible (Custom Code requis)
❌ GPSService (utilisation geolocator)  
❌ SQLite operations (sqflite)  
❌ File I/O (dart:io)  
❌ Export CSV/GPX (logique custom)  

### Solution
1. Importer le projet Flutter dans FlutterFlow
2. Utiliser "Custom Code" pour les services
3. Connecter les Custom Actions aux pages FlutterFlow
4. Tester en mode Preview puis build production

---

## 📱 Performances et Optimisations

### GPS Tracking
- Utiliser `LocationSettings` avec distanceFilter = 0
- `accuracy: LocationAccuracy.high`
- Timeout 5 secondes si pas de signal
- Buffer en mémoire avant écriture disque (toutes les 10 secondes)

### Base de données
- Index sur (jour, cp) pour requêtes rapides
- Transactions pour imports batch
- Cache en mémoire des CP du jour actif

### Interface
- Utiliser `const` constructors
- ListView.builder pour listes longues
- Debounce sur les boutons (éviter double-clic)

---

## 🧪 Stratégie de Tests

### Tests Unitaires
- Services GPS (filtrage, calcul distance)
- DatabaseService (CRUD)
- Validation checkpoints
- Export CSV/GPX

### Tests d'Intégration
- Flux complet: START → Tracking → Validation → STOP → Export
- Import fichier DATA
- Reset données

### Tests Manuels
- Test sur téléphone réel en extérieur
- Vérifier précision GPS
- Tester mode avion (offline)
- Partage fichiers via différents canaux

---

## 📦 Déploiement

### Android
1. Build APK: `flutter build apk --release`
2. Signer avec keystore
3. Distribuer via Google Play ou APK direct

### iOS
1. Build IPA: `flutter build ios --release`
2. Archive dans Xcode
3. Distribuer via TestFlight ou App Store

### Checklist Pré-Déploiement
- [ ] Tester GPS en conditions réelles
- [ ] Vérifier stockage local (pas de dépendance réseau)
- [ ] Tester export sur différentes plateformes de partage
- [ ] Valider autonomie batterie
- [ ] Documenter procédure utilisateur

---

## 📝 Notes Techniques

### Gestion de la Batterie
- GPS haute fréquence (1s) = consommation élevée
- Prévoir indicateur batterie sur page Organisation
- Recommander batterie externe pour événements longue durée

### Stockage
- TRACE file: ~1Ko par minute (~60Ko/heure)
- SQLite DB: ~50Ko (données 15 jours × 15 CP)
- Exports: variables selon durée

### Limites
- Précision GPS: 5-15m en conditions optimales
- Rayon validation: 20m (pour compenser imprécision)
- Fonctionne uniquement en extérieur (signal GPS)

---

**Version**: 1.0.0  
**Date**: Février 2026  
**Auteur**: Architecture Senior Flutter

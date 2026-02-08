# CAPRACE_MASTER - Guide Utilisateur

## 🎯 Bienvenue

CAPRACE_MASTER est une application de tracking GPS qui valide automatiquement votre passage aux checkpoints virtuels. Tout fonctionne sans connexion internet.

---

## 📱 Démarrage Rapide

### 1. Premier Lancement

1. **Installer l'application** sur votre téléphone
2. **Autoriser** les permissions GPS quand demandé
3. **Activer le GPS** dans les paramètres du téléphone

### 2. Configuration des Checkpoints (À faire une fois)

#### Accès à la Configuration

1. Sur la page d'accueil, **cliquez 5 fois** rapidement sur l'image centrale
2. Une page de mot de passe apparaît
3. Entrez le **mot de passe** fourni par l'organisateur
4. Cliquez sur "VALIDER L'ACCÈS"

#### Saisir les Checkpoints

1. Dans la page Organisation, cliquez sur **"PARAMÈTRES DATA (SQLITE)"**
2. Sélectionnez le **jour** (J1 à J15)
3. Pour chaque checkpoint :
   - Cliquez sur la ligne correspondante
   - Entrez la **latitude** (ex: 48.8566)
   - Entrez la **longitude** (ex: 2.3522)
   - Cliquez sur "SAVE"

#### Ou Importer un Fichier

Si vous avez un fichier `import.txt` :

1. Cliquez sur **"IMPORT"**
2. Sélectionnez votre fichier
3. Les coordonnées sont chargées automatiquement

---

## 🏃 Utilisation Pendant l'Événement

### Démarrer une Session

#### Pour l'Organisateur (Page Organisation)

1. **Accueil** → Clic 5× sur image → Mot de passe
2. **Sélectionner le jour** actif (J1-J15)
   - Les jours futurs sont gris clair
   - Les jours passés sont gris foncé
   - Le jour actif devient bleu
3. **Saisir le numéro d'équipage** (ex: 8)
4. **Appuyer sur START**
5. ✅ L'enregistrement GPS démarre !

### Suivre le Parcours

#### Pour le Participant

1. **Accueil** → "ESPACE PARTICIPANT"
2. Vous voyez :
   - 📍 **Position GPS actuelle** (latitude, longitude)
   - 📏 **Distance parcourue** (en km)
   - 📡 **État du signal GPS**
     - 🔴 Aucun signal
     - 🟠 Signal faible
     - 🟢 Bon signal
     - 🟢🟢 Excellent signal
   - ⭕ **15 cercles des checkpoints**
     - Gris = pas encore validé
     - Vert = validé !

### Validation Automatique

Quand vous vous approchez d'un checkpoint à moins de **20 mètres** :

1. 📳 **Vibration**
2. 🔔 **Bip sonore**
3. ✅ **Message "Checkpoint validé !"**
4. ⭕→🟢 **Le cercle passe au vert**

> **Astuce** : Gardez l'application ouverte pour voir les validations en temps réel !

---

## 💾 Exporter les Données

### À la Fin de la Journée

1. **Organisation** → "ACCÉDER À L'EXPORTATION"
2. Vous voyez :
   - Nom de l'équipage
   - Jour actif
   - Nombre de checkpoints validés
   - Distance totale

### Choisir le Format

#### Export CSV (pour Excel/Google Sheets)

1. Cliquez sur **"Exporter en CSV"**
2. Le fichier contient :
   - Toutes les coordonnées GPS
   - Timestamps
   - Distance
   - Précision

#### Export GPX (pour applications GPS)

1. Cliquez sur **"Exporter en GPX"**
2. Compatible avec :
   - Google Earth
   - Garmin
   - Applications de randonnée

### Partager les Données

Après l'export, cliquez sur l'icône **Partager** :

- 📶 **Wi-Fi** : Envoi direct vers ordinateur
- 📲 **Bluetooth** : Transfert vers autre téléphone
- 💬 **WhatsApp** : Envoi au groupe

---

## 🔄 Réinitialisation

### Reset TRACE (Supprimer le parcours GPS)

1. Page Export → **"RÉINITIALISER TRACE"**
2. **Appui long 2 secondes**
3. Confirmer
4. ✅ Le fichier GPS est supprimé

> **Attention** : Cette action est irréversible !

### Reset DATA (Remettre les checkpoints à zéro)

1. Page PARAM → **"RESET"**
2. **Appui long 2 secondes**
3. Confirmer
4. ✅ Tous les checkpoints repassent en gris

> **Note** : Les coordonnées GPS des checkpoints ne sont pas supprimées, seul l'état "validé" est remis à zéro.

---

## 🔋 Conseils d'Utilisation

### Optimiser la Batterie

- 🔌 **Batterie externe** recommandée (le GPS consomme beaucoup)
- 🌙 **Mode économie d'énergie** désactivé pour le GPS
- ✈️ **Mode avion** activé (sauf GPS) pour économiser

### Meilleure Précision GPS

- 🌤️ **Ciel dégagé** : Éviter zones boisées/urbaines denses
- 🕐 **Attendre** 30s-1min pour acquisition satellite
- 📱 **Téléphone** à plat dans une poche transparente

### Protection du Téléphone

- 💧 **Pochette étanche** contre la pluie
- 🏃 **Fixation brassard** ou ceinture
- 🔐 **Verrouiller** l'écran pour éviter appuis accidentels

---

## ❓ Questions Fréquentes

### Le GPS ne démarre pas

**Solution** :
1. Vérifier que le GPS est activé dans Paramètres → Localisation
2. Autoriser l'accès GPS à CAPRACE_MASTER
3. Sortir à l'extérieur (le GPS ne fonctionne pas en intérieur)
4. Attendre 1-2 minutes pour l'acquisition satellite

### Un checkpoint ne se valide pas

**Causes possibles** :
1. **Distance > 20m** : Approchez-vous plus près
2. **Mauvais signal GPS** : Attendez meilleur signal (🟢)
3. **Coordonnées incorrectes** : Vérifier en page PARAM
4. **Checkpoint déjà validé** : Le cercle est déjà vert

### La distance affichée est incorrecte

**Explication** :
- Le GPS a une précision de 5-15 mètres
- Des sauts GPS peuvent se produire
- L'application filtre les anomalies
- La distance est arrondie au 0.1 km près

### L'application se ferme toute seule

**Solutions** :
1. Désactiver l'optimisation de batterie pour CAPRACE_MASTER
2. Autoriser l'exécution en arrière-plan
3. Libérer de la mémoire (fermer autres apps)

### Je n'arrive pas à exporter

**Vérifications** :
1. Vous avez bien appuyé sur START avant ?
2. Des données GPS ont été enregistrées ?
3. Il reste de l'espace de stockage ?
4. Les permissions de stockage sont accordées ?

---

## 🆘 Assistance

### En Cas de Problème

1. **Redémarrer l'application**
2. **Vérifier les permissions** (GPS, Stockage)
3. **Vérifier l'espace disque**
4. **Noter le message d'erreur** (screenshot)
5. **Contacter l'organisateur**

### Informations à Fournir

Si vous contactez le support :
- Modèle du téléphone (ex: Samsung Galaxy S21)
- Version Android/iOS (ex: Android 13)
- Message d'erreur exact
- Étapes pour reproduire le problème

---

## 📋 Checklist Avant Départ

- [ ] GPS activé dans les paramètres
- [ ] Batterie chargée (+ batterie externe)
- [ ] Permissions accordées à l'application
- [ ] Checkpoints configurés pour le jour
- [ ] Numéro d'équipage correct
- [ ] Test de validation d'1 checkpoint
- [ ] Téléphone protégé (pochette étanche)

---

## 🎓 Résumé Rapide

| Action | Comment |
|--------|---------|
| **Démarrer** | Organisation → START |
| **Voir position** | Participant → Position GPS |
| **Valider CP** | S'approcher à < 20m |
| **Exporter** | Export → CSV ou GPX |
| **Reset** | Export → RESET (appui long) |

---

## 📞 Contact

**Support Technique**
- Email : support@caprace-master.com
- Téléphone : +33 X XX XX XX XX

**Organisateur**
- [Nom de l'organisateur]
- [Contact]

---

**CAPRACE_MASTER v1.0.0**  
*Profitez de votre événement !* 🏁

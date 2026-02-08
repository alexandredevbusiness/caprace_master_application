import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../config/constants.dart';
import '../services/gps_service.dart';
import 'auth_screen.dart';
import 'participant_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GPSService _gpsService = GPSService.instance;
  int _tapCount = 0;
  String _gpsStatus = 'En attente d\'activation...';
  
  @override
  void initState() {
    super.initState();
    _initGPS();
  }
  
  Future<void> _initGPS() async {
    await _gpsService.checkPermissions();
    
    _gpsService.statusStream.listen((status) {
      if (mounted) {
        setState(() {
          _gpsStatus = status;
        });
      }
    });
  }
  
  void _onImageTap() {
    setState(() {
      _tapCount++;
    });
    
    if (_tapCount >= AppConfig.tapCountToUnlock) {
      _tapCount = 0;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
    
    // Reset du compteur après 2 secondes
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _tapCount = 0;
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Titre
              Text(
                AppConfig.appName,
                style: AppConstants.titleStyle,
              ),
              const SizedBox(height: 8),
              Text(
                AppConfig.appSubtitle,
                style: AppConstants.subtitleStyle,
              ),
              
              const Spacer(),
              
              // Image cliquable (zone secrète)
              GestureDetector(
                onTap: _onImageTap,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppConstants.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppConstants.primaryGreen.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.gps_fixed,
                      size: 80,
                      color: AppConstants.primaryGreen,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Texte système
              Text(
                AppConstants.txtSystemReady,
                style: AppConstants.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppConstants.txtSystemSubtitle,
                style: AppConstants.subtitleStyle,
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
              
              // Statut GPS
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppConstants.cardDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.gps_fixed,
                      size: 20,
                      color: _gpsStatus.contains('actif')
                          ? AppConstants.gpsGood
                          : AppConstants.gpsWaiting,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Statut GPS\n$_gpsStatus',
                        style: AppConstants.labelStyle,
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _gpsStatus.contains('actif')
                            ? AppConstants.gpsGood
                            : AppConstants.dangerRed,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Bouton Participant
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ParticipantScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.person),
                label: Text(AppConstants.btnParticipant),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Version
              Text(
                '${AppConfig.appVersion} - SECURE TRACE SYSTEM',
                style: AppConstants.labelStyle.copyWith(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    super.dispose();
  }
}

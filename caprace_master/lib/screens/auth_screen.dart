import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../services/auth_service.dart';
import 'organisation_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _auth = AuthService.instance;
  final List<String> _password = [];
  String _errorMessage = '';
  
  void _onNumberPressed(String number) {
    if (_password.length < 4) {
      setState(() {
        _password.add(number);
        _errorMessage = '';
      });
      
      if (_password.length == 4) {
        _verifyPassword();
      }
    }
  }
  
  void _onDeletePressed() {
    if (_password.isNotEmpty) {
      setState(() {
        _password.removeLast();
        _errorMessage = '';
      });
    }
  }
  
  Future<void> _verifyPassword() async {
    final inputPass = _password.join();
    final isValid = await _auth.verifyPassword(inputPass);
    
    if (isValid) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OrganisationScreen()),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'Code incorrect';
        _password.clear();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.lock, size: 48, color: Colors.white),
              const SizedBox(height: 16),
              Text('ZONE SÉCURISÉE', style: AppConstants.titleStyle),
              const SizedBox(height: 8),
              Text(
                'Saisissez le code d\'accès Organisation',
                style: AppConstants.bodyStyle,
              ),
              const SizedBox(height: 32),
              
              // Dots de mot de passe
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < _password.length
                          ? AppConstants.primaryGreen
                          : AppConstants.cardDark,
                      border: Border.all(
                        color: AppConstants.primaryGreen,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
              
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: const TextStyle(color: AppConstants.dangerRed),
                ),
              ],
              
              const Spacer(),
              
              // Clavier numérique
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  ...'123456789'.split('').map((n) => _buildKey(n)),
                  _buildKey('⌫', onPressed: _onDeletePressed, isDelete: true),
                  _buildKey('0'),
                  _buildKey('✓', onPressed: _verifyPassword, isValidate: true),
                ],
              ),
              
              const SizedBox(height: 32),
              
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: Text(AppConstants.btnReturn.toUpperCase()),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
              ),
              
              const SizedBox(height: 16),
              Text(
                'TRACE MASTER SYSTEM V1.0.4\nSTATUS: ENCRYPTED SESSION',
                style: AppConstants.labelStyle.copyWith(fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildKey(String label, {
    VoidCallback? onPressed,
    bool isDelete = false,
    bool isValidate = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed ?? () => _onNumberPressed(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDelete
            ? AppConstants.dangerRed
            : isValidate
                ? AppConstants.primaryGreen
                : AppConstants.cardDark,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

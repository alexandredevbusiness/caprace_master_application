/// Modèle représentant la configuration de l'équipage
class CrewConfig {
  final int crewNumber;
  final int currentDay;
  final bool isTracking;
  final String? password; // Pour l'accès Organisation
  
  CrewConfig({
    required this.crewNumber,
    required this.currentDay,
    this.isTracking = false,
    this.password,
  });
  
  factory CrewConfig.fromMap(Map<String, dynamic> map) {
    return CrewConfig(
      crewNumber: map['crewNumber'] as int? ?? 1,
      currentDay: map['currentDay'] as int? ?? 1,
      isTracking: map['isTracking'] as bool? ?? false,
      password: map['password'] as String?,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'crewNumber': crewNumber,
      'currentDay': currentDay,
      'isTracking': isTracking,
      'password': password,
    };
  }
  
  CrewConfig copyWith({
    int? crewNumber,
    int? currentDay,
    bool? isTracking,
    String? password,
  }) {
    return CrewConfig(
      crewNumber: crewNumber ?? this.crewNumber,
      currentDay: currentDay ?? this.currentDay,
      isTracking: isTracking ?? this.isTracking,
      password: password ?? this.password,
    );
  }
  
  /// Obtenir le nom de l'équipage formaté
  String get formattedCrewNumber => 'EQ-${crewNumber.toString()}';
  
  /// Obtenir le jour formaté
  String get formattedDay => 'J${currentDay.toString().padLeft(2, '0')}';
  
  @override
  String toString() {
    return 'CrewConfig($formattedCrewNumber, $formattedDay, tracking:$isTracking)';
  }
}

/// Modèle représentant un checkpoint virtuel dans la base de données
class Checkpoint {
  final int jour;           // Jour (1-15)
  final int cp;             // Numéro du checkpoint (1-15)
  final double latitude;    // Latitude du checkpoint
  final double longitude;   // Longitude du checkpoint
  final int passageok;      // 0 = non validé, 1 = validé
  
  Checkpoint({
    required this.jour,
    required this.cp,
    required this.latitude,
    required this.longitude,
    required this.passageok,
  });
  
  factory Checkpoint.fromMap(Map<String, dynamic> map) {
    return Checkpoint(
      jour: map['jour'] as int,
      cp: map['cp'] as int,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      passageok: map['passageok'] as int,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'jour': jour,
      'cp': cp,
      'latitude': latitude,
      'longitude': longitude,
      'passageok': passageok,
    };
  }
  
  Checkpoint copyWith({
    int? jour,
    int? cp,
    double? latitude,
    double? longitude,
    int? passageok,
  }) {
    return Checkpoint(
      jour: jour ?? this.jour,
      cp: cp ?? this.cp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      passageok: passageok ?? this.passageok,
    );
  }
  
  bool get isValidated => passageok == 1;
  bool get hasCoordinates => latitude != 0.0 && longitude != 0.0;
  
  @override
  String toString() {
    return 'Checkpoint(J$jour-CP$cp: $latitude,$longitude, validé:$passageok)';
  }
}

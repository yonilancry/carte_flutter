import 'package:pocketbase/pocketbase.dart';

/// Modèle représentant un point sur la carte.
class MapPoint {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  const MapPoint({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  /// Crée un MapPoint depuis un record PocketBase.
  factory MapPoint.fromRecord(RecordModel record) {
    return MapPoint(
      id: record.id,
      name: record.get<String>('name'),
      latitude: record.get<double>('latitude'),
      longitude: record.get<double>('longitude'),
    );
  }

  /// Convertit en Map pour l'envoi vers PocketBase.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

import 'package:pocketbase/pocketbase.dart';
import '../models/map_point.dart';

/// Service gérant la communication avec PocketBase.
///
/// La collection "points" doit exister dans PocketBase avec les champs :
///   - name (Text)
///   - latitude (Number)
///   - longitude (Number)
class PocketBaseService {
  // Adresse par défaut de PocketBase en local.
  // Sur un émulateur Android, utiliser http://10.0.2.2:8090
  static const String _baseUrl = 'http://127.0.0.1:8090';
  static const String _collection = 'points';

  final PocketBase _pb;

  PocketBaseService() : _pb = PocketBase(_baseUrl);

  /// Récupère tous les points depuis la base de données.
  Future<List<MapPoint>> getAllPoints() async {
    final records = await _pb.collection(_collection).getFullList();
    return records.map((r) => MapPoint.fromRecord(r)).toList();
  }

  /// Ajoute un nouveau point et retourne le point créé avec son ID.
  Future<MapPoint> addPoint(MapPoint point) async {
    final record = await _pb.collection(_collection).create(body: point.toJson());
    return MapPoint.fromRecord(record);
  }

  /// Met à jour le nom d'un point existant.
  Future<MapPoint> updatePoint(String id, String newName) async {
    final record = await _pb.collection(_collection).update(id, body: {
      'name': newName,
    });
    return MapPoint.fromRecord(record);
  }

  /// Supprime un point par son ID.
  Future<void> deletePoint(String id) async {
    await _pb.collection(_collection).delete(id);
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Résultat d'une recherche de géocodage.
class GeocodingResult {
  final String displayName;
  final double latitude;
  final double longitude;

  const GeocodingResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });
}

/// Service de géocodage utilisant l'API Nominatim (OpenStreetMap).
/// Gratuit, sans clé API.
class GeocodingService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org/search';

  /// Recherche une adresse et retourne une liste de résultats.
  Future<List<GeocodingResult>> search(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'q': query,
      'format': 'json',
      'limit': '5',
    });

    final response = await http.get(uri, headers: {
      'User-Agent': 'carte_flutter/1.0',
    });

    if (response.statusCode != 200) return [];

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) {
      return GeocodingResult(
        displayName: item['display_name'] as String,
        latitude: double.parse(item['lat'] as String),
        longitude: double.parse(item['lon'] as String),
      );
    }).toList();
  }
}

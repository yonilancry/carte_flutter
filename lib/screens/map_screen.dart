import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/map_point.dart';
import '../services/pocketbase_service.dart';
import '../services/geocoding_service.dart';
import '../widgets/point_dialog.dart';

/// Écran principal affichant la carte interactive.
class MapScreen extends StatefulWidget {
  final List<MapPoint> points;
  final VoidCallback onPointsChanged;

  const MapScreen({
    super.key,
    required this.points,
    required this.onPointsChanged,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final PocketBaseService _service = PocketBaseService();
  final GeocodingService _geocoding = GeocodingService();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  bool _searching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Recherche une adresse et propose les résultats.
  Future<void> _searchAddress() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _searching = true);

    try {
      final results = await _geocoding.search(query);
      if (!mounted) return;

      setState(() => _searching = false);

      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucun résultat trouvé')),
        );
        return;
      }

      // Si un seul résultat, l'utiliser directement. Sinon, laisser choisir.
      final GeocodingResult selected;
      if (results.length == 1) {
        selected = results.first;
      } else {
        final picked = await showModalBottomSheet<GeocodingResult>(
          context: context,
          builder: (context) => ListView.builder(
            shrinkWrap: true,
            itemCount: results.length,
            itemBuilder: (context, index) {
              final r = results[index];
              return ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(
                  r.displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => Navigator.pop(context, r),
              );
            },
          ),
        );
        if (picked == null) return;
        selected = picked;
      }

      // Centrer la carte sur le résultat
      _mapController.move(
        LatLng(selected.latitude, selected.longitude),
        16.0,
      );

      // Demander un nom pour le point
      if (!mounted) return;
      final name = await showPointNameDialog(
        context,
        title: 'Nommer ce lieu',
        initialValue: selected.displayName.split(',').first,
      );
      if (name == null) return;

      // Sauvegarder le point
      final point = MapPoint(
        id: '',
        name: name,
        latitude: selected.latitude,
        longitude: selected.longitude,
      );
      await _service.addPoint(point);
      widget.onPointsChanged();
    } catch (e) {
      setState(() => _searching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de recherche : $e')),
        );
      }
    }
  }

  /// Ajoute un point à la position tapée sur la carte.
  Future<void> _addPoint(LatLng position) async {
    final name = await showPointNameDialog(context);
    if (name == null) return;

    try {
      final point = MapPoint(
        id: '',
        name: name,
        latitude: position.latitude,
        longitude: position.longitude,
      );
      await _service.addPoint(point);
      widget.onPointsChanged();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout : $e')),
        );
      }
    }
  }

  /// Affiche les options pour un marqueur (renommer / supprimer).
  void _showMarkerOptions(MapPoint point) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(point.name),
              subtitle: Text(
                '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}',
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Renommer'),
              onTap: () {
                Navigator.pop(context);
                _renamePoint(point);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deletePoint(point);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _renamePoint(MapPoint point) async {
    final newName = await showPointNameDialog(
      context,
      title: 'Renommer le point',
      initialValue: point.name,
    );
    if (newName == null) return;

    try {
      await _service.updatePoint(point.id, newName);
      widget.onPointsChanged();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

  Future<void> _deletePoint(MapPoint point) async {
    try {
      await _service.deletePoint(point.id);
      widget.onPointsChanged();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(48.8566, 2.3522),
            initialZoom: 6.0,
            onTap: (tapPosition, latLng) => _addPoint(latLng),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.carte_flutter',
            ),
            MarkerLayer(
              markers: widget.points.map((point) {
                return Marker(
                  point: LatLng(point.latitude, point.longitude),
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => _showMarkerOptions(point),
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        // Barre de recherche d'adresse
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Rechercher une adresse...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onSubmitted: (_) => _searchAddress(),
                  ),
                ),
                if (_searching)
                  const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchAddress,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

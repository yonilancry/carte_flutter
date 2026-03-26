import 'package:flutter/material.dart';
import '../models/map_point.dart';
import '../services/pocketbase_service.dart';
import '../widgets/point_dialog.dart';

/// Écran affichant la liste scrollable de tous les points.
class ListScreen extends StatelessWidget {
  final List<MapPoint> points;
  final VoidCallback onPointsChanged;

  const ListScreen({
    super.key,
    required this.points,
    required this.onPointsChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucun point enregistré',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tapez sur la carte pour ajouter un point',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: points.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final point = points[index];
        return _PointTile(
          point: point,
          onPointsChanged: onPointsChanged,
        );
      },
    );
  }
}

class _PointTile extends StatelessWidget {
  final MapPoint point;
  final VoidCallback onPointsChanged;

  const _PointTile({
    required this.point,
    required this.onPointsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final service = PocketBaseService();

    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.location_pin),
      ),
      title: Text(point.name),
      subtitle: Text(
        'Lat: ${point.latitude.toStringAsFixed(5)}  '
        'Lng: ${point.longitude.toStringAsFixed(5)}',
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == 'rename') {
            final newName = await showPointNameDialog(
              context,
              title: 'Renommer le point',
              initialValue: point.name,
            );
            if (newName != null) {
              try {
                await service.updatePoint(point.id, newName);
                onPointsChanged();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur : $e')),
                  );
                }
              }
            }
          } else if (value == 'delete') {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Supprimer ce point ?'),
                content: Text('Voulez-vous supprimer "${point.name}" ?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Annuler'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Supprimer'),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              try {
                await service.deletePoint(point.id);
                onPointsChanged();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur : $e')),
                  );
                }
              }
            }
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'rename', child: Text('Renommer')),
          PopupMenuItem(value: 'delete', child: Text('Supprimer')),
        ],
      ),
    );
  }
}

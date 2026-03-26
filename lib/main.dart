import 'package:flutter/material.dart';
import 'models/map_point.dart';
import 'services/pocketbase_service.dart';
import 'screens/map_screen.dart';
import 'screens/list_screen.dart';

void main() {
  runApp(const CarteApp());
}

class CarteApp extends StatelessWidget {
  const CarteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carte Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

/// Page principale avec navigation par onglets (Carte / Liste).
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final PocketBaseService _service = PocketBaseService();

  List<MapPoint> _points = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  /// Charge tous les points depuis PocketBase.
  Future<void> _loadPoints() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final points = await _service.getAllPoints();
      setState(() {
        _points = points;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Erreur PocketBase: $e');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Carte' : 'Liste des points'),
        actions: [
          // Bouton de rafraîchissement
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPoints,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Carte',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_outlined),
            selectedIcon: Icon(Icons.list),
            label: 'Liste',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    // Affichage d'un message d'erreur avec possibilité de réessayer
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Impossible de se connecter à PocketBase',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Vérifiez que PocketBase est lancé sur\nhttp://127.0.0.1:8090',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadPoints,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    // Indicateur de chargement
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Contenu selon l'onglet sélectionné
    if (_currentIndex == 0) {
      return MapScreen(
        points: _points,
        onPointsChanged: _loadPoints,
      );
    } else {
      return ListScreen(
        points: _points,
        onPointsChanged: _loadPoints,
      );
    }
  }
}

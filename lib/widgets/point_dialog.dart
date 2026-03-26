import 'package:flutter/material.dart';

/// Dialog pour saisir ou modifier le nom d'un point.
///
/// Retourne le nom saisi, ou null si l'utilisateur annule.
Future<String?> showPointNameDialog(
  BuildContext context, {
  String title = 'Nouveau point',
  String initialValue = '',
}) {
  final controller = TextEditingController(text: initialValue);

  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Nom du point',
          hintText: 'Ex: Maison, Bureau...',
        ),
        // Valider en appuyant sur Entrée
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            Navigator.of(context).pop(value.trim());
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isNotEmpty) {
              Navigator.of(context).pop(name);
            }
          },
          child: const Text('Valider'),
        ),
      ],
    ),
  );
}

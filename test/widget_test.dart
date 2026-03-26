import 'package:flutter_test/flutter_test.dart';
import 'package:carte_flutter/main.dart';

void main() {
  testWidgets('App builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(const CarteApp());
    expect(find.text('Carte'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_app/main.dart';

void main() {
  testWidgets('Rick & Morty App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RickAndMortyApp());

    expect(find.byType(RickAndMortyApp), findsOneWidget);
  });
}

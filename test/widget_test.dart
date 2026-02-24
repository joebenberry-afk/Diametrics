// Basic widget test for DiaMetrics app.

import 'package:flutter_test/flutter_test.dart';
import 'package:diametrics/main.dart';

void main() {
  testWidgets('App starts and shows splash screen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DiametricsApp());

    // Verify that the splash screen is displayed with app title
    expect(find.text('DiaMetrics'), findsOneWidget);
    expect(find.text('Loading...'), findsOneWidget);
  });
}

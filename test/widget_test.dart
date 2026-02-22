// Basic widget test for DiaMetrics app.

import 'package:flutter_test/flutter_test.dart';
import 'package:diametrics/main.dart';

void main() {
  testWidgets('App starts and shows login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DiametricsApp(onboardingComplete: false));

    // Verify that the login screen is displayed with app title
    expect(find.text('DiaMetrics'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);
  });
}

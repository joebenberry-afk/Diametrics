// Basic widget test for DiaMetrics app.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diametrics/main.dart';

void main() {
  testWidgets('App starts and shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: DiametricsApp()));
    expect(find.text('DiaMetrics'), findsOneWidget);
  });
}

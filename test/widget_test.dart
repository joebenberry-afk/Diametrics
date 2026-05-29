// Basic widget test for DiaMetrics app.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diametrics/main.dart';
import 'package:diametrics/models/user_profile.dart';
import 'package:diametrics/viewmodels/profile_viewmodel.dart';

void main() {
  testWidgets('App starts and shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Keep the router on the splash screen by reporting the profile
          // provider as still loading — avoids hitting the real DB in tests.
          userProfileProvider.overrideWith(() => _LoadingProfileViewModel()),
        ],
        child: const DiametricsApp(),
      ),
    );
    expect(find.text('DiaMetrics'), findsOneWidget);

    // Drain any pending asset-load failures — Image.asset on the splash
    // screen has no real asset bundle in widget tests.
    tester.takeException();
  });
}

class _LoadingProfileViewModel extends ProfileViewModel {
  @override
  Future<UserProfile?> build() {
    // Never completes — router treats this as isLoading and stays on splash.
    return Completer<UserProfile?>().future;
  }
}

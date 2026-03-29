
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

final stepCountProvider = StreamProvider<int>((ref) async* {
  // Request permissions first
  if (await Permission.activityRecognition.request().isGranted) {
    // We try to yield the step count.
    try {
      final stream = Pedometer.stepCountStream;
      await for (final StepCount stepCount in stream) {
        yield stepCount.steps;
      }
    } catch (e) {
      // In case pedometer is not supported (e.g. emulators), we return 0.
      yield 0;
    }
  } else {
    // Permission denied
    yield 0;
  }
});

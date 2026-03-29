
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

final stepCountProvider = StreamProvider<int>((ref) async* {
  // Request permissions first
  if (await Permission.activityRecognition.request().isGranted) {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stream = Pedometer.stepCountStream;
      
      await for (final StepCount stepCount in stream) {
        final today = DateTime.now().toIso8601String().substring(0, 10);
        final savedDate = prefs.getString('diametrics_step_date');
        
        int baseline = prefs.getInt('diametrics_step_baseline') ?? stepCount.steps;
        
        // If it's a new day, or no baseline exists, set the current total as the new zero
        if (savedDate != today) {
          baseline = stepCount.steps;
          await prefs.setInt('diametrics_step_baseline', baseline);
          await prefs.setString('diametrics_step_date', today);
        }
        
        // Android pedometer resets on reboot, so if steps < baseline, resetting helps
        if (stepCount.steps < baseline) {
          baseline = 0;
          await prefs.setInt('diametrics_step_baseline', baseline);
        }
        
        final sessionSteps = stepCount.steps - baseline;
        yield sessionSteps < 0 ? 0 : sessionSteps;
      }
    } catch (e) {
      // Pedometer not supported on emulator, yield 0
      yield 0;
    }
  } else {
    yield 0;
  }
});

import '../models/projection_result.dart';

/// Typed extra argument for the /log/meal/projection route.
class ProjectionRouteArgs {
  final ProjectionResult result;
  final String unit;
  final int mealCount;

  const ProjectionRouteArgs({
    required this.result,
    required this.unit,
    required this.mealCount,
  });
}

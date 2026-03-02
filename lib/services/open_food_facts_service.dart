import '../src/domain/entities/food_item.dart';
import 'backend_food_service.dart';

/// Looks up packaged food nutrition by barcode.
///
/// Proxies requests through [BackendFoodService] to the Open Food Facts API.
/// The Open Food Facts API is free and requires no key, but routing through
/// the backend centralises all external calls and ensures the Flutter APK
/// makes no direct third-party network calls.
class OpenFoodFactsService {
  /// Returns a [FoodItem] for the given [barcode] (EAN-13, UPC-A, etc.).
  ///
  /// Returns `null` if the product is not found.
  /// Throws a [BackendUnavailableException] on network errors.
  static Future<FoodItem?> lookup(String barcode) async {
    return BackendFoodService.barcodeLookup(barcode);
  }
}

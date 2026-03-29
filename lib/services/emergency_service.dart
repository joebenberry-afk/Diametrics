import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContact {
  final String name;
  final String relation;
  final String phoneNumber;

  const EmergencyContact({
    required this.name,
    required this.relation,
    required this.phoneNumber,
  });
}

class EmergencyService {
  static const _storage = FlutterSecureStorage();
  static const _keyName = 'emergency_contact_name';
  static const _keyRelation = 'emergency_contact_relation';
  static const _keyPhone = 'emergency_contact_phone';

  /// Saves the emergency contact securely.
  static Future<void> saveContact(EmergencyContact contact) async {
    await _storage.write(key: _keyName, value: contact.name);
    await _storage.write(key: _keyRelation, value: contact.relation);
    await _storage.write(key: _keyPhone, value: contact.phoneNumber);
    log('Emergency contact saved: ${contact.name}');
  }

  /// Retrieves the saved emergency contact.
  static Future<EmergencyContact?> getContact() async {
    final name = await _storage.read(key: _keyName);
    final relation = await _storage.read(key: _keyRelation);
    final phone = await _storage.read(key: _keyPhone);

    if (name != null && relation != null && phone != null) {
      return EmergencyContact(
        name: name,
        relation: relation,
        phoneNumber: phone,
      );
    }
    return null;
  }

  /// Triggers a native phone call to the emergency contact.
  static Future<bool> callEmergencyContact() async {
    final contact = await getContact();
    if (contact == null) return false;

    // Clean phone number: remove typical characters
    final cleanPhone = contact.phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');

    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    } else {
      log('Could not launch dialer for $cleanPhone');
      return false;
    }
  }

  /// Delete emergency contact
  static Future<void> deleteContact() async {
    await _storage.delete(key: _keyName);
    await _storage.delete(key: _keyRelation);
    await _storage.delete(key: _keyPhone);
  }
}

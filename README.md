# DiaMetrics
DiaMetrics is a local-first medical application designed for elderly diabetic patients in Trinidad and Tobago. It features offline AI food recognition and secure HIPAA-avoidant local data storage.

## Security & Privacy
DiaMetrics uses hardware-backed AES-256 database encryption and biometric authentication to protect patient data on-device. Please see `SECURITY.md` for information on our API Key restrictions.

## Building the App (Production)
To protect DiaMetrics' proprietary offline logic and custom AI parsers from reverse-engineering, **all production APKs must be built with Dart code obfuscation**.

Run the following command in the root directory:
```bash
flutter build apk --obfuscate --split-debug-info=build/app/outputs/symbols
```

This command:
1. Replaces function and class names with meaningless symbols.
2. Removes debug information (saving it to the symbols directory for crash analysis).
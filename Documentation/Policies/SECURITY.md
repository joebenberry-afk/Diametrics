# DiaMetrics Security Hardening

This document outlines the security measures required to maintain the privacy and integrity of DiaMetrics patient data and proprietary code.

## 1. Hardware-Backed Database Encryption
DiaMetrics utilizes `flutter_secure_storage` and AES-256 SQLCipher to encrypt the local SQLite database (`app.db`).
* When the app runs, a cryptographically secure 256-bit key is generated (`dart:math.Random.secure()`).
* This key is stored in the **Android Keystore** (hardware-backed).
* The database is inaccessible without this key, protecting critical HIPAA-compliant medical logs even on a rooted device.

## 2. Gemini API Key Fingerprint Restriction
While the Gemini API key is securely injected at build time via `--dart-define`, it can theoretically be extracted by reverse-engineering the APK.

To fully protect our API quota, **you must restrict the API Key in Google Cloud Console** so that it only accepts requests from our strictly signed Android app.

### Instructions:
1. Log into the Google Cloud Console and navigate to your **APIs & Services > Credentials**.
2. Click on the API Key used for DiaMetrics.
3. Under **Application restrictions**, select **Android apps**.
4. Click **Add an item**.
5. Enter the **Package name**: `com.example.diametrics` (or your final production package name).
6. Enter the **SHA-1 certificate fingerprint**.
   * *To get your SHA-1 for the release keystore, run:*
     `keytool -list -v -keystore your_keystore.jks -alias your_alias_name`
7. Click **Save**.

*Once applied, even if a bad actor extracts the `--dart-define` API key from the APK, any requests they make from outside our official Android app will be rejected by Google Cloud.*

## 3. Code Obfuscation
DiaMetrics relies on proprietary offline logic for RAG filtering and custom UI parsers. To prevent reverse-engineering of the Dart code, **all production APKs must be built with code obfuscation**.

*See the `README.md` for the correct build commands.*

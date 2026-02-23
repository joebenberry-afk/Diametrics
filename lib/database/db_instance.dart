import 'database.dart';

/// Global singleton database instance.
///
/// Uses [openEncryptedDatabase] to create an AES-256 encrypted
/// SQLite database via SQLCipher. Must be initialized with [initDatabase]
/// before use.
late final AppDatabase db;

/// Initializes the encrypted database. Call once at app startup.
Future<void> initDatabase() async {
  final executor = await openEncryptedDatabase();
  db = AppDatabase(executor);
}

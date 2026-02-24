import 'database.dart';

/// Global singleton database instance.
///
/// Uses [openEncryptedDatabase] to create an AES-256 encrypted
/// SQLite database via SQLCipher. Must be initialized with [initDatabase]
/// before use.
AppDatabase? _db;

/// Returns the initialized [AppDatabase]. Throws if [initDatabase] has not
/// been called yet.
AppDatabase get db {
  final instance = _db;
  if (instance == null) {
    throw StateError('Database not initialized. Call initDatabase() first.');
  }
  return instance;
}

/// Initializes the encrypted database. Safe to call multiple times; subsequent
/// calls are no-ops if the database is already open.
Future<void> initDatabase() async {
  if (_db != null) return;
  final executor = await openEncryptedDatabase();
  _db = AppDatabase(executor);
}

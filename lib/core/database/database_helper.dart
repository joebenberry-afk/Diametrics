import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "diametrics_v1.db";
  static const _databaseVersion = 3; // v3: added name column to user_profiles

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Drop old tables and recreate for PoC simplicity
      await db.execute('DROP TABLE IF EXISTS glucose_logs');
      await db.execute('DROP TABLE IF EXISTS meal_logs');
      await db.execute('DROP TABLE IF EXISTS medication_logs');
      await _createTables(db);
    }
    if (oldVersion < 3) {
      // Add patient name column (safe for existing installs)
      await db.execute(
        "ALTER TABLE user_profiles ADD COLUMN name TEXT NOT NULL DEFAULT ''",
      );
    }
  }

  Future _createTables(Database db) async {
    _createGlucoseTable(db);
    _createMealTable(db);
    _createMedicationTable(db);
    _createUserProfileTable(db);
  }

  void _createGlucoseTable(Database db) async {
    await db.execute('''
      CREATE TABLE glucose_logs (
        id TEXT PRIMARY KEY,
        value REAL NOT NULL,
        unit TEXT NOT NULL,
        context TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        notes TEXT,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  void _createMealTable(Database db) async {
    await db.execute('''
      CREATE TABLE meal_logs (
        id TEXT PRIMARY KEY,
        name TEXT,
        carbohydrates REAL NOT NULL,
        dietaryFiber REAL NOT NULL,
        proteins REAL NOT NULL,
        fats REAL NOT NULL,
        calories REAL NOT NULL,
        containsAlcohol INTEGER NOT NULL DEFAULT 0,
        containsCaffeine INTEGER NOT NULL DEFAULT 0,
        mealType TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        notes TEXT,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  void _createMedicationTable(Database db) async {
    await db.execute('''
      CREATE TABLE medication_logs (
        id TEXT PRIMARY KEY,
        medicationType TEXT NOT NULL,
        name TEXT,
        units REAL NOT NULL,
        timestamp TEXT NOT NULL,
        notes TEXT,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  void _createUserProfileTable(Database db) async {
    await db.execute('''
      CREATE TABLE user_profiles (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL DEFAULT '',
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        heightCm REAL NOT NULL,
        weightKg REAL NOT NULL,
        targetWeightKg REAL,
        diabetesType TEXT NOT NULL,
        diagnosisYear INTEGER NOT NULL,
        preferredGlucoseUnit TEXT NOT NULL,
        usesInsulin INTEGER NOT NULL DEFAULT 0,
        usesPills INTEGER NOT NULL DEFAULT 0,
        usesCgm INTEGER NOT NULL DEFAULT 0,
        targetGlucoseMin REAL NOT NULL,
        targetGlucoseMax REAL NOT NULL,
        hasAgreedToDisclaimer INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  // Generic Operations can be added here, but typically Repositories will interact with the database directly.
}

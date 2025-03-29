import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:firebase_database/firebase_database.dart';

class SQLiteHelper {
  static final SQLiteHelper _instance = SQLiteHelper.internal();
  factory SQLiteHelper() => _instance;

  Database? _db;
  final DatabaseReference _firebaseRef = FirebaseDatabase.instance.ref('disease_remedies');

  SQLiteHelper.internal();

  Future<void> initDb() async{
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'eferme.db');

    _db = await openDatabase(
      path, 
      version: 1, 
      onCreate: (Database db, version) async {
      await db.execute('''
        CREATE TABLE users (
          id TEXT PRIMARY KEY, 
          name TEXT, 
          email TEXT, 
          password TEXT,
          profilePicture TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE weather_data(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          city_name TEXT,
          temperature REAL,
          description TEXT,
          humidity INTEGER,
          wind_speed REAL,
          forecast TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE disease_remedies(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          disease TEXT,
          remedy TEXT
        )
      ''');
    });
  }

  Future<void> _ensureDbInitialized() async {
    if (_db == null) {
      await initDb();
    }
  }

  Future<void> insertUser(Map<String, dynamic> user) async {
    await _ensureDbInitialized();
    await _db!.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>> getUser(String userId) async {
    await _ensureDbInitialized();
    final result = await _db!.query('users', where: 'id = ?', whereArgs: [userId]);
    return result.isNotEmpty ? result.first : {};
  }

  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<dynamic>? whereArgs}) async {
    return await _db!.query(table, where: where, whereArgs: whereArgs);
  }

  Future<Map<String, dynamic>?> getUserByCredentials(String email, String passwordHash) async {
    final result = await _db!.query(
      'users', 
      where: 'email = ? AND password = ?', 
      whereArgs: [email, passwordHash],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateUserPassword(String userId, String hashedPassword) async {
    await _ensureDbInitialized();
    await _db!.update(
      'users',
      {'password': hashedPassword},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
  Future<void> updateUserProfile(String userId, String name, String email, String? profilePicture) async {
    await _ensureDbInitialized();
    await _db!.update(
      'users',
      {
        'name': name,
        'email': email,
        'profilePicture': profilePicture,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> insertWeatherData(Map<String, dynamic> weatherData) async {
    await _ensureDbInitialized();
    await _db!.insert('weather_data', weatherData, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>> getLastSyncedWeatherData() async {
    await _ensureDbInitialized();
    final result = await _db!.query(
      'weather_data', 
      orderBy: 'id DESC', 
      limit: 1
    );
    return result.isNotEmpty ? result.first : {};
  }

  Future<void> insertDiseaseRemedy(Map<String, dynamic> diseaseRemedy) async {
    await _ensureDbInitialized();
    await _db!.insert('disease_remedies', diseaseRemedy, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getDiseaseRemedies() async {
    await _ensureDbInitialized();
    return await _db!.query('disease_remedies');
  }

  Future<void> syncDiseaseRemedies() async {
    final localRemedies = await getDiseaseRemedies();
    final remoteRemedies = await _firebaseRef.get();

    // Sync local remedies with remote remedies
    for (var remedy in localRemedies) {
      await _firebaseRef.child(remedy['id'].toString()).set({
        'disease': remedy['disease'],
        'remedy': remedy['remedy'],
      });
    }

    // Sync remote remedies with local remedies
    for (var snapshot in remoteRemedies.children) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      await insertDiseaseRemedy({
        'id': int.parse(snapshot.key!),
        'disease': data['disease'],
        'remedy': data['remedy'],
      });
    }
  }
   
}



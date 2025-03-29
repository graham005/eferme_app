import 'package:flutter_test/flutter_test.dart';
import 'package:eferme_app/services/sqlite_helper.dart';

void main() {
  group('SQLiteHelper', () {
    final sqliteHelper = SQLiteHelper();

    setUp(() async {
      await sqliteHelper.initDb();
    });

    test('insert and retrieve user', () async {
      final user = {
        'id': '1',
        'name': 'Test User',
        'email': 'test@example.com',
        'password': 'hashed_password',
        'profilePicture': null,
      };

      await sqliteHelper.insertUser(user);
      final retrievedUser = await sqliteHelper.getUser('1');

      expect(retrievedUser, isNotEmpty);
      expect(retrievedUser['name'], 'Test User');
      expect(retrievedUser['email'], 'test@example.com');
    });

    test('update user profile', () async {
      final user = {
        'id': '1',
        'name': 'Test User',
        'email': 'test@example.com',
        'password': 'hashed_password',
        'profilePicture': null,
      };

      await sqliteHelper.insertUser(user);
      await sqliteHelper.updateUserProfile('1', 'Updated User', 'updated@example.com', 'new_profile_picture');

      final updatedUser = await sqliteHelper.getUser('1');

      expect(updatedUser['name'], 'Updated User');
      expect(updatedUser['email'], 'updated@example.com');
      expect(updatedUser['profilePicture'], 'new_profile_picture');
    });
  });
}
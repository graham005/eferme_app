import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eferme_app/services/sqlite_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final SQLiteHelper _sqliteHelper = SQLiteHelper();
  final FirebaseStorage _storageInstance = FirebaseStorage.instance;

  Future<void> init() async {
    await _sqliteHelper.initDb();
  }

  // Sign up (online)
  Future<UserCredential> signUp(String email, String password, String name, String? profilePicture) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _auth.currentUser?.updateDisplayName(name);

    // Save user data locally
    final hashedPassword = hashPassword(password);
    await _sqliteHelper.insertUser({
      'id': userCredential.user!.uid,
      'name': name,
      'email': email,
      'password': hashedPassword,
      'profilePicture': profilePicture,
    });

    return userCredential;
  }

  // Sign in (online or offline)
  Future<bool> signIn(String email, String password) async {
    try{
    // Online sign in
      if(await hasInternetConnection()){
        print('Attempting online sign in......');
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        // Save user ID to secure storage
        final currentUser = _auth.currentUser;
        if(currentUser != null){
          final hashedPassword = hashPassword(password);
        await _sqliteHelper.insertUser({
          'id': currentUser.uid,
          'name': currentUser.displayName ?? '',
          'email': email,
          'password': hashedPassword,
          'profilePicture': currentUser.photoURL,
        });
        await _storage.write(key: 'userId', value: currentUser.uid);
        return true;
        }
        else {
          // print('Error: User is null after online sign in.');
          return false;
        }
      }
      else{
      // Offline sign in
      print('Attempting offline sign in......');
        final user = await _sqliteHelper.getUserByCredentials(email, hashPassword(password));
        // print('Offline user: $user');
        if (user != null){
          await _storage.write(key: 'userId', value: user['id']);
          // print('User found in SQLite.');
          return true;
        } else {
          // print('Error: User not found in SQLite.');
          return false;
        }
      }}
    catch(e){
      print('Error signing in: $e');
        return false;
      }
  }

  // Forgot password (online only)
  Future<void> sendPasswordResetEmail(String email) async {
    if (!await hasInternetConnection()) {
      throw Exception('No internet connection');
    }
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _storage.delete(key: 'userId');
  }

  // Check if there is an internet connection
  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        print('No network connection');
        return false;
      }

      // Perform a simple HTTP request to check internet connectivity
      final response = await http.get(Uri.parse('https://www.google.com')).timeout(Duration(seconds: 5));
      if (response.statusCode == 200) {
        print('Internet connection available');
        return true;
      } else {
        print('No internet connection (HTTP status: ${response.statusCode})');
        return false;
      }
    } catch (e) {
      print('Error checking internet connection: $e');
      return false;
    }
  }

  // Check if user exists by credentials in SQLite
  // Future<Map<String, dynamic>?> getUserByCredentials(String email, String password) async {
  //   final result = await _sqliteHelper.query('users', where: 'email = ? and password_hash = ?', whereArgs: [email, password]);
  //   return result.isNotEmpty ? result.first : null;
  // }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user exists locally
  Future<bool> isUserLoggedInLocally() async {
    final userId = await _storage.read(key: 'userId');
    return userId != null && (await _sqliteHelper.getUser(userId)).isNotEmpty;
  }

  // Hash password for secure storage
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Get stored user ID from secure storage
  Future<String?> getStoredUserId() async {
    return await _storage.read(key: 'userId');
  }

  // Get user data from SQLite by user ID
  Future<Map<String, dynamic>> getUserFromSQLite(String? userId) async {
    if(userId == null) return {};
    return await _sqliteHelper.getUser(userId);
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    if (!await hasInternetConnection()) {
      throw Exception('No internet connection');
    }

    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    // Re-authenticate the user
    AuthCredential credential = EmailAuthProvider.credential(email: user.email!, password: oldPassword);
    await user.reauthenticateWithCredential(credential);

    // Update password in Firebase Authentication
    await user.updatePassword(newPassword);

    // Update password in SQLite
    final hashedPassword = hashPassword(newPassword);
    final userId = await getStoredUserId();
    if (userId != null) {
      await _sqliteHelper.updateUserPassword(userId, hashedPassword);
    }
  }
  Future<void> updateProfile(String name, String email, File? profileImage) async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    // Update profile image in Firebase Storage
    String? profileImageUrl;
    if (profileImage != null) {
      final storageRef = _storageInstance.ref().child('profile_images/${user.uid}');
      await storageRef.putFile(profileImage);
      profileImageUrl = await storageRef.getDownloadURL();
    }

    // Update user profile in Firebase Authentication
    await user.updateDisplayName(name);
    await user.verifyBeforeUpdateEmail(email);
    if (profileImageUrl != null) {
      await user.updatePhotoURL(profileImageUrl);
    }

    // Update user profile in SQLite
    final userId = await getStoredUserId();
    if (userId != null) {
      await _sqliteHelper.updateUserProfile(userId, name, email, profileImageUrl);
    }
  }
}
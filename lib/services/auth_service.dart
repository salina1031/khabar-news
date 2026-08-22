import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

// AuthService wraps FirebaseAuth + the matching Firestore user profile.
// Keeping all Firebase calls here means the rest of the app never touches
// the Firebase SDK directly, which makes it easy to read and demo.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of the currently signed-in Firebase user (or null when signed out).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentFirebaseUser => _auth.currentUser;

  // Registers a new resident account and creates their Firestore profile.
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
    String ward = '',
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = credential.user!.uid;

    final newUser = UserModel(
      id: uid,
      name: name,
      email: email.trim(),
      phone: phone,
      ward: ward,
      role: 'user',
    );

    await _db.collection('users').doc(uid).set(newUser.toMap());
    return newUser;
  }

  // Signs in an existing user (works for both residents and admins -
  // the role is read from Firestore after login).
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = credential.user!.uid;
    return fetchUserProfile(uid);
  }

  Future<UserModel> fetchUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw Exception('User profile not found. Please contact an admin.');
    }
    return UserModel.fromMap(doc.data()!, uid);
  }

  Future<void> signOut() => _auth.signOut();

  // Sends a password reset email via Firebase Auth. Firebase itself checks
  // whether the email exists, so we don't need to query Firestore first.
  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }
}

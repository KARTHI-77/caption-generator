import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => currentUser != null;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // User selects Google account
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase Sign In
      final userCredential =
          await _auth.signInWithCredential(credential);

      // Create Firestore user document
      await _createUserDocument(userCredential.user);

      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception("Google Sign-In Failed: $e");
    }
  }

  Future<void> _createUserDocument(User? user) async {
    if (user == null) return;

    final doc = _firestore.collection("users").doc(user.uid);

    final snapshot = await doc.get();

    if (!snapshot.exists) {
      await doc.set({
        "uid": user.uid,
        "name": user.displayName,
        "email": user.email,
        "photoUrl": user.photoURL,
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
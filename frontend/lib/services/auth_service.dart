import 'package:flutter/foundation.dart';
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

  // ============================================================
  // GOOGLE SIGN-IN
  // ============================================================

  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        print("WEB: Starting Google sign-in...");

        final GoogleAuthProvider googleProvider = GoogleAuthProvider();

        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        print("WEB: Google provider created.");
        print("WEB: Calling signInWithPopup...");

        final UserCredential userCredential = await _auth.signInWithPopup(
          googleProvider,
        );

        print("WEB: Google sign-in successful.");
        print("WEB: User: ${userCredential.user?.email}");

        await _createUserDocument(userCredential.user);

        return userCredential;
      }

      print("NATIVE: Starting Google sign-in...");

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print("NATIVE: User cancelled sign-in.");
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      await _createUserDocument(userCredential.user);

      return userCredential;
    } on FirebaseAuthException catch (e, stackTrace) {
      print("========== FIREBASE AUTH ERROR ==========");
      print("CODE: ${e.code}");
      print("MESSAGE: ${e.message}");
      print("EMAIL: ${e.email}");
      print("CREDENTIAL: ${e.credential}");
      print("STACK TRACE:");
      print(stackTrace);
      print("=========================================");

      rethrow;
    } catch (e, stackTrace) {
      print("========== GOOGLE SIGN-IN ERROR ==========");
      print("ERROR TYPE: ${e.runtimeType}");
      print("ERROR: $e");
      print("STACK TRACE:");
      print(stackTrace);
      print("==========================================");

      rethrow;
    }
  }

  // ============================================================
  // CREATE FIRESTORE USER DOCUMENT
  // ============================================================

  Future<void> _createUserDocument(User? user) async {
    if (user == null) return;

    final DocumentReference<Map<String, dynamic>> doc = _firestore
        .collection("users")
        .doc(user.uid);

    final DocumentSnapshot<Map<String, dynamic>> snapshot = await doc.get();

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

  // ============================================================
  // SIGN OUT
  // ============================================================

  Future<void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }

    await _auth.signOut();
  }
}

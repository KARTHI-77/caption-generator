import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/caption_model.dart';

class CaptionFirestoreService {
  CaptionFirestoreService._();

  static final CaptionFirestoreService instance =
      CaptionFirestoreService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  Future<void> saveCaption(CaptionModel caption) async {
    final uid = _auth.currentUser!.uid;

    await _firestore
        .collection("users")
        .doc(uid)
        .collection("captions")
        .add(caption.toMap());
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCaptionHistory() {
    final uid = _auth.currentUser!.uid;

     return _firestore
      .collection("users")
      .doc(uid)
      .collection("captions")
      .orderBy("createdAt", descending: true)
      .snapshots();
  }
}


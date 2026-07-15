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

  Future<void> deleteCaption(String documentId) async {
    final uid = _auth.currentUser!.uid;

    await _firestore
      .collection("users")
      .doc(uid)
      .collection("captions")
      .doc(documentId)
      .delete();
  }
  Future<void> toggleFavorite(
    String documentId,
    bool currentValue,
  ) async {

     final uid = _auth.currentUser!.uid;

     await _firestore
      .collection("users")
      .doc(uid)
      .collection("captions")
      .doc(documentId)
      .update({
    "favorite": !currentValue,
   });
  }

  Future<Map<String, dynamic>> getProfileStats() async {
   final uid = _auth.currentUser!.uid;

   final snapshot = await _firestore
      .collection("users")
      .doc(uid)
      .collection("captions")
      .get();

   final docs = snapshot.docs;

   final totalCaptions = docs.length;

   final favoriteCount =
       docs.where((doc) => doc["favorite"] == true).length;

   final languages = <String>{};
   final styleCount = <String, int>{};

   for (final doc in docs) {
     final language = doc["language"] as String? ?? "";
     final style = doc["style"] as String? ?? "";

      if (language.isNotEmpty) {
       languages.add(language);
      }

      if (style.isNotEmpty) {
       styleCount[style] = (styleCount[style] ?? 0) + 1;
      }
    }

   String mostUsedStyle = "-";
   if (styleCount.isNotEmpty) {
     mostUsedStyle = styleCount.entries
         .reduce((a, b) => a.value >= b.value ? a : b)
         .key;
   }

    return {
     "totalCaptions": totalCaptions,
     "favoriteCount": favoriteCount,
     "languageCount": languages.length,
     "mostUsedStyle": mostUsedStyle,
    };
  }
}


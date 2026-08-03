import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UserRepository {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static const String templeId = "temple001";


  Future<UserModel?> getUser(String uid) async {

    final snapshot = await _firestore
        .collection("temples")
        .doc(templeId)
        .collection("users")
        .doc(uid)
        .get();


    if (!snapshot.exists) {
      return null;
    }


    return UserModel.fromJson({
      "id": snapshot.id,
      ...snapshot.data()!,
    });
  }
}
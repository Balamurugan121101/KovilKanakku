import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/donation_model.dart';

class DonationRepository {
  DonationRepository();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String templeId = "temple001";

  CollectionReference<Map<String, dynamic>> get _donationCollection =>
      _firestore
          .collection("temples")
          .doc(templeId)
          .collection("donations");

  DocumentReference<Map<String, dynamic>> get _settingsDoc =>
      _firestore
          .collection("temples")
          .doc(templeId)
          .collection("settings")
          .doc("config");

  Future<String> _generateReceiptNumber(
      Transaction transaction,
      DocumentSnapshot<Map<String, dynamic>> settings,
      ) async {
    final data = settings.data()!;

    final prefix = data["receiptPrefix"] as String;
    final nextNumber = data["nextReceiptNumber"] as int;

    transaction.update(_settingsDoc, {
      "nextReceiptNumber": nextNumber + 1,
    });

    return "$prefix-${nextNumber.toString().padLeft(6, '0')}";
  }

  Future<void> addDonation({
    required String donorName,
    required double amount,
    String? phone,
    String? purpose,
    String? eventId,
  }) async {
    await _firestore.runTransaction((transaction) async {
      final settingsSnapshot = await transaction.get(_settingsDoc);

      final receiptNumber =
      await _generateReceiptNumber(transaction, settingsSnapshot);

      final donationDoc = _donationCollection.doc();

      transaction.set(donationDoc, {
        "id": donationDoc.id,
        "donorName": donorName,
        "amount": amount,
        "phone": phone,
        "purpose": purpose,
        "eventId": eventId,
        "receiptNumber": receiptNumber,
        "createdBy": FirebaseAuth.instance.currentUser!.uid,
        "donatedAt": Timestamp.now(),
      });
    });
  }

  Future<List<DonationModel>> getDonations() async {
    final snapshot = await _donationCollection
        .orderBy("donatedAt", descending: true)
        .get();

    return snapshot.docs
        .map(
          (doc) => DonationModel.fromJson({
        ...doc.data(),
        "donatedAt":
        (doc["donatedAt"] as Timestamp).toDate().toIso8601String(),
      }),
    )
        .toList();
  }

  Future<DonationModel?> getDonation(String id) async {
    final doc = await _donationCollection.doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return DonationModel.fromJson({
      ...doc.data()!,
      "donatedAt":
      (doc["donatedAt"] as Timestamp).toDate().toIso8601String(),
    });
  }

  Future<void> updateDonation(DonationModel donation) async {
    await _donationCollection.doc(donation.id).update({
      "donorName": donation.donorName,
      "amount": donation.amount,
      "phone": donation.phone,
      "purpose": donation.purpose,
      "eventId": donation.eventId,
    });
  }

  Future<void> deleteDonation(String id) async {
    await _donationCollection.doc(id).delete();
  }
}
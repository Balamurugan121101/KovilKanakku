import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/settings_model.dart';

class SettingsRepository {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // Change this later when multi-temple login is implemented.
  static const String templeId = 'temple001';

  DocumentReference<Map<String, dynamic>>
  get _settingsRef {
    return _firestore
        .collection('temples')
        .doc(templeId)
        .collection('settings')
        .doc('config');
  }

  Future<SettingsModel?> getSettings() async {
    final snapshot = await _settingsRef.get();

    if (!snapshot.exists) {
      return null;
    }

    return SettingsModel.fromJson(
      snapshot.data()!,
    );
  }

  Future<void> saveSettings(
      SettingsModel settings,
      ) async {
    await _settingsRef.set(
      settings.toJson(),
      SetOptions(
        merge: true,
      ),
    );
  }
}
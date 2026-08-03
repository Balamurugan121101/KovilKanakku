import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:temple/firebase/firestore_paths.dart';
import 'package:temple/models/settings_model.dart';

class SettingsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<SettingsModel> getSettings() async {
    final doc = await _firestore
        .doc('${FirestorePaths.settings()}/config')
        .get();

    return SettingsModel.fromJson(doc.data()!);
  }

  Future<void> updateSettings(SettingsModel settings) async {
    await _firestore
        .doc('${FirestorePaths.settings()}/config')
        .set(settings.toJson());
  }
}
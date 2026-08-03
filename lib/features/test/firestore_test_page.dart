import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:temple/repositories/settings_repository.dart';
import 'package:temple/repositories/auth_repository.dart';

class FirestoreTestPage extends StatefulWidget {
  const FirestoreTestPage({super.key});

  @override
  State<FirestoreTestPage> createState() => _FirestoreTestPageState();
}

class _FirestoreTestPageState extends State<FirestoreTestPage> {
  final _repository = SettingsRepository();

  String message = "Loading...";

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final settings = await _repository.getSettings();

      setState(() {
        message = '''
Temple: ${settings.templeName}

Address: ${settings.address}

Phone: ${settings.phone}

Receipt Prefix: ${settings.receiptPrefix}

Next Receipt No: ${settings.nextReceiptNumber}
''';
      });
      final authRepository = AuthRepository();

      await authRepository.login(
        email: "admin@anandharama.com",
        password: "Anandharama@123",
      );

      print(FirebaseAuth.instance.currentUser?.uid);
      print(FirebaseAuth.instance.currentUser?.email);

    } catch (e) {
      setState(() {
        message = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firestore Test"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(message),
        ),
      ),
    );
  }
}
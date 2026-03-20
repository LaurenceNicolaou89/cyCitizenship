import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();

  // Open all required Hive boxes (H-1, H-7)
  await Future.wait([
    Hive.openBox('questions'),
    Hive.openBox('pending_sync'),
    Hive.openBox('flashcards'),
  ]);

  // Global error handling (L-6)
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  runApp(const CyCitizenshipApp());
}

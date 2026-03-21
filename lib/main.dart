import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/utils/seed_data.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();

  await Future.wait([
    Hive.openBox('questions'),
    Hive.openBox('pending_sync'),
    Hive.openBox('flashcards'),
  ]);

  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  // Seed Firestore in background — don't block app startup
  final seeded = prefs.getBool('firestore_seeded') ?? false;
  if (!seeded) {
    SeedData.seedFirestore(FirebaseFirestore.instance).then((_) {
      prefs.setBool('firestore_seeded', true);
      if (kDebugMode) {
        debugPrint('Firestore seeded successfully');
      }
    }).catchError((e) {
      if (kDebugMode) {
        debugPrint('Seed data failed (will retry next launch): $e');
      }
    });
  }

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  runApp(CyCitizenshipApp(
    onboardingComplete: onboardingComplete,
    prefs: prefs,
  ));
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
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

  // Open all required Hive boxes (H-1, H-7)
  await Future.wait([
    Hive.openBox('questions'),
    Hive.openBox('pending_sync'),
    Hive.openBox('flashcards'),
  ]);

  // Pre-load SharedPreferences for synchronous route redirect
  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  // Seed Firestore on first launch
  final seeded = prefs.getBool('firestore_seeded') ?? false;
  if (!seeded) {
    try {
      await SeedData.seedFirestore(FirebaseFirestore.instance);
      await prefs.setBool('firestore_seeded', true);
    } catch (e) {
      debugPrint('Seed data failed (will retry next launch): $e');
    }
  }

  // Global error handling (L-6)
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  runApp(CyCitizenshipApp(onboardingComplete: onboardingComplete));
}

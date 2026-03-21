import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/question_model.dart';

class QuestionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _boxName = 'questions';

  /// In-memory cache to avoid repeated Hive deserialization (CYC-085).
  List<QuestionModel>? _cachedQuestions;

  /// No-op -- the 'questions' box is already opened in main.dart.
  /// Kept for interface compatibility; callers may still call initialize().
  Future<void> initialize() async {
    // Box is opened in main.dart via Hive.openBox('questions').
    // Using Hive.box() directly everywhere to avoid redundant opens.
  }

  Future<List<QuestionModel>> getQuestions({String? category}) async {
    // Try local first
    final localQuestions = _getLocalQuestions(category: category);
    if (localQuestions.isNotEmpty) {
      // Sync in background if online
      _syncFromFirestore();
      return localQuestions;
    }

    // If no local data, try remote
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return localQuestions; // Return empty if offline and no cache
    }

    await _syncFromFirestore();
    return _getLocalQuestions(category: category);
  }

  List<QuestionModel> _getLocalQuestions({String? category}) {
    // Populate in-memory cache on first call (CYC-085).
    if (_cachedQuestions == null) {
      final box = Hive.box(_boxName);
      final deserialized = <QuestionModel>[];

      for (final key in box.keys) {
        final data = box.get(key);
        if (data != null && data is Map) {
          try {
            final map = Map<String, dynamic>.from(data);
            deserialized.add(QuestionModel(
              id: key.toString(),
              textEn: map['textEn'] ?? '',
              textRu: map['textRu'] ?? '',
              textEl: map['textEl'] ?? '',
              options: (map['options'] as List?)
                      ?.map((o) => QuestionOption.fromMap(
                          Map<String, dynamic>.from(o as Map)))
                      .toList() ??
                  [],
              correctIndex: map['correctIndex'] ?? 0,
              category: map['category'] ?? '',
              difficulty: map['difficulty'] ?? 'medium',
              explanation:
                  Map<String, String>.from(map['explanation'] ?? {}),
              source: map['source'] ?? '',
            ));
          } catch (_) {
            continue;
          }
        }
      }
      _cachedQuestions = deserialized;
    }

    if (category == null) return List.unmodifiable(_cachedQuestions!);
    return _cachedQuestions!
        .where((q) => q.category == category)
        .toList();
  }

  Future<void> _syncFromFirestore() async {
    try {
      final snapshot = await _db.collection('questions').get();
      final box = Hive.box(_boxName);

      // Batch all writes into a single Hive operation (CYC-086).
      final entries = <String, Map<String, dynamic>>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        entries[doc.id] = {
          'textEn': data['textEn'],
          'textRu': data['textRu'],
          'textEl': data['textEl'],
          'options': (data['options'] as List?)
              ?.map((o) => Map<String, dynamic>.from(o as Map))
              .toList(),
          'correctIndex': data['correctIndex'],
          'category': data['category'],
          'difficulty': data['difficulty'],
          'explanation': data['explanation'] != null
              ? Map<String, String>.from(data['explanation'] as Map)
              : <String, String>{},
          'source': data['source'],
        };
      }
      await box.putAll(entries);

      // Invalidate in-memory cache so next read picks up new data (CYC-085).
      _cachedQuestions = null;
    } catch (_) {
      // Silently fail -- will use cached data
    }
  }

  Future<void> forceSync() async {
    await _syncFromFirestore();
  }

  int get cachedQuestionCount {
    if (!Hive.isBoxOpen(_boxName)) return 0;
    return Hive.box(_boxName).length;
  }
}

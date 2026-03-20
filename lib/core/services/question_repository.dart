import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/question_model.dart';

class QuestionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _boxName = 'questions';

  Future<void> initialize() async {
    await Hive.openBox(_boxName);
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
    final box = Hive.box(_boxName);
    final allQuestions = <QuestionModel>[];

    for (final key in box.keys) {
      final data = box.get(key);
      if (data != null && data is Map) {
        try {
          final map = Map<String, dynamic>.from(data);
          final question = QuestionModel(
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
            explanation: Map<String, String>.from(map['explanation'] ?? {}),
            source: map['source'] ?? '',
          );

          if (category == null || question.category == category) {
            allQuestions.add(question);
          }
        } catch (_) {
          continue;
        }
      }
    }
    return allQuestions;
  }

  Future<void> _syncFromFirestore() async {
    try {
      final snapshot = await _db.collection('questions').get();
      final box = Hive.box(_boxName);

      for (final doc in snapshot.docs) {
        final data = doc.data();
        // Store as plain map for Hive compatibility
        await box.put(doc.id, {
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
        });
      }
    } catch (_) {
      // Silently fail — will use cached data
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

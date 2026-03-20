import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressSyncService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  static const String _pendingBoxName = 'pending_sync';

  Future<void> initialize() async {
    _connectivitySub = _connectivity.onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) {
        syncPendingData();
      }
    });
  }

  Future<void> queueAnswer(
      String userId, Map<String, dynamic> answer) async {
    final box = Hive.box(_pendingBoxName);
    final pending = List<Map<String, dynamic>>.from(
        (box.get('pending_answers') as List?)
                ?.cast<Map<String, dynamic>>() ??
            []);
    pending.add({...answer, 'userId': userId});
    await box.put('pending_answers', pending);
  }

  Future<void> queueMockExam(
      String userId, Map<String, dynamic> exam) async {
    final box = Hive.box(_pendingBoxName);
    final pending = List<Map<String, dynamic>>.from(
        (box.get('pending_exams') as List?)
                ?.cast<Map<String, dynamic>>() ??
            []);
    pending.add({...exam, 'userId': userId});
    await box.put('pending_exams', pending);
  }

  Future<void> syncPendingData() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) return;

    final box = Hive.box(_pendingBoxName);

    // Sync pending answers
    final pendingAnswers = List<Map<String, dynamic>>.from(
        (box.get('pending_answers') as List?)
                ?.cast<Map<String, dynamic>>() ??
            []);

    if (pendingAnswers.isNotEmpty) {
      final batch = _db.batch();
      for (final answer in pendingAnswers) {
        final userId = answer['userId'] as String;
        final data = Map<String, dynamic>.from(answer)..remove('userId');
        final ref = _db
            .collection('user_progress')
            .doc(userId)
            .collection('answers')
            .doc();
        batch.set(ref, data);
      }
      try {
        await batch.commit();
        await box.put('pending_answers', <Map<String, dynamic>>[]);
      } catch (_) {
        // Will retry on next connectivity change
      }
    }

    // Sync pending exams
    final pendingExams = List<Map<String, dynamic>>.from(
        (box.get('pending_exams') as List?)
                ?.cast<Map<String, dynamic>>() ??
            []);

    if (pendingExams.isNotEmpty) {
      final batch = _db.batch();
      for (final exam in pendingExams) {
        final userId = exam['userId'] as String;
        final data = Map<String, dynamic>.from(exam)..remove('userId');
        final ref = _db
            .collection('user_progress')
            .doc(userId)
            .collection('mock_exams')
            .doc();
        batch.set(ref, data);
      }
      try {
        await batch.commit();
        await box.put('pending_exams', <Map<String, dynamic>>[]);
      } catch (_) {
        // Will retry on next connectivity change
      }
    }
  }

  int get pendingCount {
    if (!Hive.isBoxOpen(_pendingBoxName)) return 0;
    final box = Hive.box(_pendingBoxName);
    final answers = (box.get('pending_answers') as List?)?.length ?? 0;
    final exams = (box.get('pending_exams') as List?)?.length ?? 0;
    return answers + exams;
  }

  void dispose() {
    _connectivitySub?.cancel();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Schema definitions for write validation ──────────────────────────

  /// Allowed fields and their expected types for each writable collection.
  /// Types: String, num, bool, Timestamp, List, Map
  static final Map<String, Map<String, Type>> _schemas = {
    'users': {
      'email': String,
      'displayName': String,
      'language': String,
      'isPremium': bool,
      'purchaseDate': Timestamp,
      'createdAt': Timestamp,
      'streak': num,
      'lastStudyDate': Timestamp,
      'badges': List,
      'examTarget': String,
      'checklist': Map,
    },
    'answers': {
      'questionId': String,
      'correct': bool,
      'answeredAt': Timestamp,
      'category': String,
    },
    'mock_exams': {
      'score': num,
      'totalQuestions': num,
      'duration': num,
      'completedAt': Timestamp,
      'answers': List,
    },
    'category_stats': {
      'totalAnswered': num,
      'totalCorrect': num,
      'lastUpdated': Timestamp,
    },
    'ai_messages': {
      'role': String,
      'content': String,
      'timestamp': Timestamp,
    },
  };

  // ── Validation helpers ───────────────────────────────────────────────

  /// Strips unknown fields and validates types against the schema.
  /// Returns a sanitized copy of [data]. Unknown fields are silently removed.
  /// Fields with wrong types are also removed to prevent corrupt writes.
  Map<String, dynamic> _validate(
    String schemaKey,
    Map<String, dynamic> data,
  ) {
    final schema = _schemas[schemaKey];
    if (schema == null) return data; // no schema = pass-through (read-only collections)

    final sanitized = <String, dynamic>{};
    for (final entry in data.entries) {
      final expectedType = schema[entry.key];
      if (expectedType == null) continue; // unknown field – strip it

      if (_matchesType(entry.value, expectedType)) {
        sanitized[entry.key] = entry.value;
      }
      // wrong type – silently strip
    }
    return sanitized;
  }

  /// Validates each message map in an AI conversation message list.
  List<Map<String, dynamic>> _validateMessages(
    List<Map<String, dynamic>> messages,
  ) {
    return messages.map((m) => _validate('ai_messages', m)).toList();
  }

  /// Returns true when [value] is an instance of the [expected] type.
  bool _matchesType(dynamic value, Type expected) {
    if (value == null) return false;
    if (expected == String) return value is String;
    if (expected == num) return value is num;
    if (expected == bool) return value is bool;
    if (expected == Timestamp) return value is Timestamp;
    if (expected == List) return value is List;
    if (expected == Map) return value is Map;
    return false;
  }

  // ── Users ────────────────────────────────────────────────────────────

  Future<void> createUser(String userId, Map<String, dynamic> data) async {
    final sanitized = _validate('users', data);
    await _db.collection('users').doc(userId).set(sanitized, SetOptions(merge: true));
  }

  Future<DocumentSnapshot> getUser(String userId) async {
    return await _db.collection('users').doc(userId).get();
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    final sanitized = _validate('users', data);
    await _db.collection('users').doc(userId).update(sanitized);
  }

  Stream<DocumentSnapshot> userStream(String userId) {
    return _db.collection('users').doc(userId).snapshots();
  }

  // ── Questions ────────────────────────────────────────────────────────

  Future<QuerySnapshot> getQuestions({
    String? category,
    int? limit,
  }) async {
    Query query = _db.collection('questions');
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    if (limit != null) {
      query = query.limit(limit);
    }
    return await query.get();
  }

  Stream<QuerySnapshot> questionsStream() {
    return _db.collection('questions').snapshots();
  }

  // ── User Progress ───────────────────────────────────────────────────

  Future<void> saveAnswer(String userId, Map<String, dynamic> answer) async {
    final sanitized = _validate('answers', answer);
    await _db
        .collection('user_progress')
        .doc(userId)
        .collection('answers')
        .add(sanitized);
  }

  Future<void> saveMockExam(String userId, Map<String, dynamic> exam) async {
    final sanitized = _validate('mock_exams', exam);
    await _db
        .collection('user_progress')
        .doc(userId)
        .collection('mock_exams')
        .add(sanitized);
  }

  Future<QuerySnapshot> getMockExams(String userId) async {
    return await _db
        .collection('user_progress')
        .doc(userId)
        .collection('mock_exams')
        .orderBy('completedAt', descending: true)
        .get();
  }

  Future<void> updateCategoryStats(
    String userId,
    String category,
    Map<String, dynamic> stats,
  ) async {
    final sanitized = _validate('category_stats', stats);
    await _db
        .collection('user_progress')
        .doc(userId)
        .collection('category_stats')
        .doc(category)
        .set(sanitized, SetOptions(merge: true));
  }

  Future<QuerySnapshot> getCategoryStats(String userId) async {
    return await _db
        .collection('user_progress')
        .doc(userId)
        .collection('category_stats')
        .get();
  }

  /// Returns aggregate stats: {totalAnswered: int, averageScore: int}
  /// Computed from category_stats subcollection.
  Future<Map<String, int>> getUserAggregateStats(String userId) async {
    final snapshot = await getCategoryStats(userId);
    if (snapshot.docs.isEmpty) {
      return {'totalAnswered': 0, 'averageScore': 0};
    }

    int totalAnswered = 0;
    int totalCorrect = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final answered = (data['totalAnswered'] ?? 0) as int;
      final correct = (data['correctAnswers'] ?? 0) as int;
      totalAnswered += answered;
      totalCorrect += correct;
    }

    final averageScore =
        totalAnswered > 0 ? ((totalCorrect / totalAnswered) * 100).round() : 0;

    return {
      'totalAnswered': totalAnswered,
      'averageScore': averageScore,
    };
  }

  // ── Exam Dates ──────────────────────────────────────────────────────

  Future<QuerySnapshot> getExamDates() async {
    return await _db
        .collection('exam_dates')
        .orderBy('date', descending: false)
        .get();
  }

  // ── Keep Learning Courses ───────────────────────────────────────────

  Future<QuerySnapshot> getCourses() async {
    return await _db.collection('keep_learning').doc('courses').collection('items').get();
  }

  // ── AI Conversations ───────────────────────────────────────────────

  Future<void> saveConversation(
    String userId,
    String type,
    String conversationId,
    List<Map<String, dynamic>> messages,
  ) async {
    final sanitized = _validateMessages(messages);
    await _db
        .collection('ai_conversations')
        .doc(userId)
        .collection(type)
        .doc(conversationId)
        .set({'messages': sanitized});
  }
}

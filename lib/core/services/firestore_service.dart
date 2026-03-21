import 'package:cloud_firestore/cloud_firestore.dart';

import 'i_firestore_service.dart';

class FirestoreService implements IFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Users
  @override
  Future<void> createUser(String userId, Map<String, dynamic> data) async {
    await _db.collection('users').doc(userId).set(data, SetOptions(merge: true));
  }

  @override
  Future<DocumentSnapshot> getUser(String userId) async {
    return await _db.collection('users').doc(userId).get();
  }

  @override
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _db.collection('users').doc(userId).update(data);
  }

  @override
  Stream<DocumentSnapshot> userStream(String userId) {
    return _db.collection('users').doc(userId).snapshots();
  }

  // Questions
  @override
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

  @override
  Stream<QuerySnapshot> questionsStream() {
    return _db.collection('questions').snapshots();
  }

  // User Progress
  @override
  Future<void> saveAnswer(String userId, Map<String, dynamic> answer) async {
    await _db
        .collection('user_progress')
        .doc(userId)
        .collection('answers')
        .add(answer);
  }

  @override
  Future<void> saveMockExam(String userId, Map<String, dynamic> exam) async {
    await _db
        .collection('user_progress')
        .doc(userId)
        .collection('mock_exams')
        .add(exam);
  }

  @override
  Future<QuerySnapshot> getMockExams(String userId) async {
    return await _db
        .collection('user_progress')
        .doc(userId)
        .collection('mock_exams')
        .orderBy('completedAt', descending: true)
        .get();
  }

  @override
  Future<void> updateCategoryStats(
    String userId,
    String category,
    Map<String, dynamic> stats,
  ) async {
    await _db
        .collection('user_progress')
        .doc(userId)
        .collection('category_stats')
        .doc(category)
        .set(stats, SetOptions(merge: true));
  }

  @override
  Future<QuerySnapshot> getCategoryStats(String userId) async {
    return await _db
        .collection('user_progress')
        .doc(userId)
        .collection('category_stats')
        .get();
  }

  // Exam Dates
  @override
  Future<QuerySnapshot> getExamDates() async {
    return await _db
        .collection('exam_dates')
        .orderBy('date', descending: false)
        .get();
  }

  // Keep Learning Courses
  @override
  Future<QuerySnapshot> getCourses() async {
    return await _db.collection('keep_learning').doc('courses').collection('items').get();
  }

  // AI Conversations
  @override
  Future<void> saveConversation(
    String userId,
    String type,
    String conversationId,
    List<Map<String, dynamic>> messages,
  ) async {
    await _db
        .collection('ai_conversations')
        .doc(userId)
        .collection(type)
        .doc(conversationId)
        .set({'messages': messages});
  }
}

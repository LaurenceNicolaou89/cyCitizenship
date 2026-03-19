import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Users
  Future<void> createUser(String userId, Map<String, dynamic> data) async {
    await _db.collection('users').doc(userId).set(data, SetOptions(merge: true));
  }

  Future<DocumentSnapshot> getUser(String userId) async {
    return await _db.collection('users').doc(userId).get();
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _db.collection('users').doc(userId).update(data);
  }

  Stream<DocumentSnapshot> userStream(String userId) {
    return _db.collection('users').doc(userId).snapshots();
  }

  // Questions
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

  // User Progress
  Future<void> saveAnswer(String userId, Map<String, dynamic> answer) async {
    await _db
        .collection('user_progress')
        .doc(userId)
        .collection('answers')
        .add(answer);
  }

  Future<void> saveMockExam(String userId, Map<String, dynamic> exam) async {
    await _db
        .collection('user_progress')
        .doc(userId)
        .collection('mock_exams')
        .add(exam);
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
    await _db
        .collection('user_progress')
        .doc(userId)
        .collection('category_stats')
        .doc(category)
        .set(stats, SetOptions(merge: true));
  }

  Future<QuerySnapshot> getCategoryStats(String userId) async {
    return await _db
        .collection('user_progress')
        .doc(userId)
        .collection('category_stats')
        .get();
  }

  // Exam Dates
  Future<QuerySnapshot> getExamDates() async {
    return await _db
        .collection('exam_dates')
        .orderBy('date', descending: false)
        .get();
  }

  // Keep Learning Courses
  Future<QuerySnapshot> getCourses() async {
    return await _db.collection('keep_learning').doc('courses').collection('items').get();
  }

  // AI Conversations
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

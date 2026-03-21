import 'package:cloud_firestore/cloud_firestore.dart';

abstract class IFirestoreService {
  // Users
  Future<void> createUser(String userId, Map<String, dynamic> data);
  Future<DocumentSnapshot> getUser(String userId);
  Future<void> updateUser(String userId, Map<String, dynamic> data);
  Stream<DocumentSnapshot> userStream(String userId);

  // Questions
  Future<QuerySnapshot> getQuestions({String? category, int? limit});
  Stream<QuerySnapshot> questionsStream();

  // User Progress
  Future<void> saveAnswer(String userId, Map<String, dynamic> answer);
  Future<void> saveMockExam(String userId, Map<String, dynamic> exam);
  Future<QuerySnapshot> getMockExams(String userId);
  Future<void> updateCategoryStats(
    String userId,
    String category,
    Map<String, dynamic> stats,
  );
  Future<QuerySnapshot> getCategoryStats(String userId);

  // Exam Dates
  Future<QuerySnapshot> getExamDates();

  // Keep Learning Courses
  Future<QuerySnapshot> getCourses();

  // AI Conversations
  Future<void> saveConversation(
    String userId,
    String type,
    String conversationId,
    List<Map<String, dynamic>> messages,
  );
}
